{ config, pkgs, lib, ... }:

let
    # Скрипт для кастомного меню питания через wofi с позиционированием в верхнем правом углу 
    powerMenu = pkgs.writeShellScriptBin "powermenu" ''
    entries="⏻ Power off\n⟳ Reboot\n⏾ Suspend\n Lock\n󰗽 Exit"
    selected=$(echo -e "$entries" | wofi -L 6 --dmenu --prompt "Power" --location top_right --xoffset -16 --yoffset 45 --width 250 --height 250)
    case $selected in
        "⏻ Power off")
            exec systemctl poweroff -i;;
        "⟳ Reboot")
            exec systemctl reboot;;
        "⏾ Suspend")
            exec systemctl suspend;;
        " Lock")
            hyprlock;;
        "󰗽 Exit")
            hyprctl dispatch exit;;
    esac
    '';


    # Скрипт для яркости/ночного света
    # Меню по клику на яркость: тумблер ночного режима или GUI-регулятор
    brightnessMenu = pkgs.writeShellScriptBin "brightnessmenu" ''
    set -euo pipefail

    entries="🌙 Night mode\n☀ Brightness"
    selected=$(echo -e "$entries" | wofi -L 3 --dmenu --prompt "Backlight" --location top_right --xoffset -16 --yoffset 45 --width 250 --height 150)

    case "$selected" in
        "🌙 Night mode")
            # Значение температуры держим синхронно с bind $mod,N в hyprland.nix
            pkill hyprsunset || hyprsunset -t 3500 &
            ;;
        "☀ Brightness")
            current=$(brightnessctl get)
            max=$(brightnessctl max)
            percent=$(( current * 100 / max ))

            yad --title="Brightness" --width=320 --center \
            --scale --print-partial --text="Regulate brightness..." \
            --min=1 --max=100 --value="$percent" --step=1 \
            --button="Ready:0" |
            while IFS= read -r val; do
                brightnessctl set "''${val}%" >/dev/null 2>&1
            done
            ;;    esac
    '';


    # Скрипт для комбинированного информационного поля (CPU, RAM, сеть, температура)
    # лежит рядом с этим файлом как sysinfo.sh и подключается как есть.
    sysInfo = pkgs.writeShellScriptBin "sysinfo" (builtins.readFile ./sysinfo.sh);

    # Кастомное меню выбора раскладки клавиатуры через wofi.
    # Список раскладок берётся динамически из input:kb_layout в Hyprland,
    # так что работает с любым набором раскладок без правки индексов.
    layoutMenu = pkgs.writeShellScriptBin "layoutmenu" ''
    set -euo pipefail

    layouts_raw=$(hyprctl getoption input:kb_layout -j | jq -r '.str')

    # Человекочитаемое имя раскладки по её короткому коду.
    # Дополните под свой набор раскладок.
    pretty_name() {
        case "$1" in
            us) echo "EN(US)";;
            ru) echo "RU";;
            *) echo "$1" ;;
        esac
    }

    menu=""
    map=""
    idx=0
    old_ifs=$IFS
    IFS=','
    for code in $layouts_raw; do
        label=$(pretty_name "$code")
        menu="$menu$label
        "
        map="$map$idx	$label
        "
        idx=$((idx + 1))
    done
    IFS=$old_ifs

    selected=$(printf "%s" "$menu" | wofi -L 3 --dmenu --prompt "Layout" --location top_right --xoffset -16 --yoffset 45 --width 250 --height 250)

    [ -z "$selected" ] && exit 0

    chosen_index=$(printf "%s" "$map" | awk -F'\t' -v sel="$selected" '$2 == sel {print $1; exit}')

    [ -z "$chosen_index" ] && exit 0

    hyprctl switchxkblayout current "$chosen_index"
    '';
in
    {
    # jq, gawk и iproute2 нужны для sysinfo.sh (jq — сборка JSON, awk — парсинг
    # /proc/meminfo и вывода `ip route`, ip — определение сетевого интерфейса).
    home.packages = [  pkgs.jq pkgs.gawk pkgs.iproute2 sysInfo pkgs.btop ];

    programs.waybar = {
        enable = true;

        settings = {
            mainBar = {
                layer = "top";
                position = "top";
                height = 34;
                spacing = 14; # Увеличенное базовое расстояние между модулями

                modules-left = [ "custom/wofi" "hyprland/workspaces" "custom/sysinfo" ];
                modules-center = [ "clock" ];
                modules-right = [ "tray" "bluetooth" "network" "backlight" "pulseaudio" "pulseaudio#microphone" "battery" "hyprland/language" "custom/power" ];

                # Кнопка Wofi с позиционированием под левым краем панели
                "custom/wofi" = {
                    format = ""; 
                    on-click = "wofi -L 8 --show drun --location top_left --xoffset 16 --yoffset 45";
                    tooltip = false;
                };

                # 6 рабочих столов
                "hyprland/workspaces" = {
                    format = "{name}";
                    on-click = "activate";
                    all-outputs = true;
                    active-only = false;
                    persistent-workspaces = {
                        "1" = []; "2" = []; "3" = []; "4" = []; "5" = []; 
                        "6" = [];           
                    };
                };

                # Комбинированное поле: CPU, RAM, скорость сети, температура, IP и страна.
                # По клику открывается системный монитор.
                "custom/sysinfo" = {
                    exec = "${sysInfo}/bin/sysinfo";
                    interval = 3;
                    return-type = "json";
                    on-click = "kitty -e btop";
                    tooltip = true;
                };

                # Дата и время. По клику запускается календарь
                clock = {
                    format = "{:%H:%M  |  %A, %d %b}";
                    tooltip-format = "<tt><small>{calendar}</small></tt>";
                };

                # Фоновые приложения в трее
                tray = {
                    spacing = 8; # Расстояние между иконками приложений в трее
                };

                # Bluetooth. Значок меняется в зависимости от состояния адаптера
                # и наличия подключённого устройства. По клику открывается bluetui. 󰂲 
                bluetooth = {
                    format = "󰂯";
                    format-disabled = "󰂲";
                    format-off = "󰂲";
                    format-connected = "󰂱 {device_alias}";
                    format-connected-battery = "󰂱 {device_alias} ({device_battery_percentage}%)";
                    tooltip-format = "{controller_alias}\t{controller_address}";
                    tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
                    tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
                    on-click = "kitty --title bluetui -e bluetui";
                };

                # Сеть. По клику открывается менеджер подключений NM
                network = {
                    format-wifi = "  {essid} ({signalStrength}%)";
                    format-ethernet = "󰈀  {ipaddr}/{cidr}";
                    format-disconnected = "󰤭  Disconnected";
                    tooltip-format = "{ifname} via {gwaddr}";
                    on-click = "nm-connection-editor";
                };

                # Яркость
                backlight = {
                    format = "{icon} {percent}%";
                    format-icons = ["" "" "" "" "" "" "" "" ""];
                    on-click = "${brightnessMenu}/bin/brightnessmenu";
                    tooltip=false;
                };

                # Звук
                pulseaudio = {
                    format = "{icon} {volume}%";
                    format-muted = "󰖁 Muted";
                    format-icons = {
                        default = [ 
                            " " # Тихо 
                            " " # Средне 
                            " " # Громко  
                        ];
                    };
                    on-click = "kitty -e wiremix";
                };

                # Микрофон
                "pulseaudio#microphone" = {
                    format = "{format_source}";
                    format-source = " {volume}%";
                    format-source-muted = "  Muted";
                    on-click = "pamixer --default-source -t";
                    on-click-right = "kitty -e wiremix";
                };

                # Батарея
                battery = {
                    states = {
                        warning = 30;
                        critical = 15;
                    };
                    format = "{icon} {capacity}%";
                    format-charging = "󰂄 {capacity}%";
                    format-plugged = " {capacity}%";
                    format-icons = [" " " " " " " " " "];
                };

                # Раскладка клавиатуры. Отображение обновляется автоматически через
                # IPC Hyprland, по клику открывается кастомное wofi-меню выбора раскладки.
                "hyprland/language" = {
                    format = "{}";
                    format-en = "EN";
                    format-ru = "RU";
                    keyboard-name = "at-translated-set-2-keyboard"; # проверьте через `hyprctl devices`
                    on-click = "${layoutMenu}/bin/layoutmenu";
                    tooltip = false;
                };

                # Кнопка питания (скрипт позиционирует окно wofi вверху справа)
                "custom/power" = {
                    format = "⏻";
                    on-click = "${powerMenu}/bin/powermenu";
                    tooltip = false;
                };
            };
        };

        style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Fira Code Nerd Font", sans-serif;
        font-size: 14px;
      }

      window#waybar {
        background-color: rgba(36, 31, 48, 0.85);
        color: #f5e9dc;

        /* Отступы панели от краев экрана: 8px сверху, 16px по бокам */
        margin: 8px 16px 0 16px;

        /* Скругление краев всей панели под стиль окон Hyprland */
        border-radius: 8px;
      }

      /* Увеличенные внутренние отступы для каждого элемента управления */
      #custom-wofi,
      #clock,
      #bluetooth,
      #network,
      #backlight,
      #pulseaudio,
      #pulseaudio\.microphone,
      #battery,
      #language,
      #custom-sysinfo,
      #custom-power {
        padding: 0 8px;
      }

      /* Стилизация кнопок рабочих столов */
      #workspaces button {
        padding: 0 10px;
        color: #f5e9dc;
        background: transparent;
        border-radius: 6px;
        margin: 2px 4px; /* Зазор между кнопками номеров столов */
      }

      #workspaces button.active {
        background-color: #f2994a;
        color: #16141f;
      }

      #workspaces button:hover {
        background: #4a3b4f;
      }

      /* Дополнительный отступ слева для самой первой иконки */
      #custom-wofi {
        color: #f7ce68;
        font-size: 18px;
        padding-left: 14px;
      }

      /* Дополнительный отступ справа для самой последней иконки */
      #custom-power {
        color: #e8613c;
        font-size: 16px;
        padding-right: 14px;
      }

      #battery.warning {
        color: #f7ce68;
      }

      #battery.critical {
        color: #e8613c;
      }

      /* Предупреждающие цвета для системного индикатора, как у батареи */
      #custom-sysinfo.warning {
        color: #f7ce68;
      }

      #custom-sysinfo.critical {
        color: #e8613c;
      }

      #tray {
        margin-right: 4px;
      }
        '';
    };
}
