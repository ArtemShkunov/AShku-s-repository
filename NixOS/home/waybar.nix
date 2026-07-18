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
  # Добавляем gnome-calendar прямо в этот модуль для вызова по клику на часы.
  # jq, gawk и iproute2 нужны для sysinfo.sh (jq — сборка JSON, awk — парсинг
  # /proc/meminfo и вывода `ip route`, ip — определение сетевого интерфейса).
  home.packages = [ pkgs.gnome-calendar pkgs.jq pkgs.gawk pkgs.iproute2 sysInfo pkgs.btop ];

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
        modules-right = [ "tray" "network" "backlight" "pulseaudio" "pulseaudio#microphone" "battery" "hyprland/language" "custom/power" ];

        # Кнопка Wofi с позиционированием под левым краем панели
        "custom/wofi" = {
          format = ""; 
          on-click = "wofi --show drun --location top_left --xoffset 16 --yoffset 45";
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
          on-click = "gnome-calendar";
        };

        # Фоновые приложения в трее
        tray = {
          spacing = 8; # Расстояние между иконками приложений в трее
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
          on-click = "pavucontrol";
        };

        # Микрофон
        "pulseaudio#microphone" = {
          format = "{format_source}";
          format-source = " {volume}%";
          format-source-muted = " Muted";
          on-click = "pamixer --default-source -t";
          on-click-right = "pavucontrol";
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
