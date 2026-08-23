# Общие для всех машин куски Waybar: скрипты, определения общих модулей и
# базовый CSS. Это НЕ home-manager модуль, а обычная функция — она не
# подключается напрямую через imports, а импортируется как данные из
# waybar-desktop.nix / waybar-laptop.nix, которые уже собирают из неё
# конкретный programs.waybar.
{ pkgs, theme }:

let
  # Скрипт для кастомного меню питания через wofi с позиционированием в верхнем правом углу
  powerMenu = pkgs.writeShellScriptBin "powermenu" ''
    entries=" Power off\n Reboot\n⏾ Suspend\n Lock\n󰗽 Exit"
    selected=$(echo -e "$entries" | wofi -L 6 --dmenu --prompt "Power" --location top_right --xoffset -16 --yoffset 45 --width 250 --height 250)
    case $selected in
        " Power off")
            exec systemctl poweroff -i;;
        " Reboot")
            exec systemctl reboot;;
        "⏾ Suspend")
            exec systemctl suspend;;
        " Lock")
            hyprlock;;
        "󰗽 Exit")
            hyprctl dispatch 'hl.dsp.exit()';;
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

    # Раскладки собираются в массив (а не конкатенацией строк с переносами),
    # иначе отступы из этого .nix-файла попадают внутрь значений и вторая
    # (и последующие) раскладки перестают совпадать при сравнении с выбором.
    IFS=',' read -ra codes <<< "$layouts_raw"

    labels=()
    for code in "''${codes[@]}"; do
        labels+=("$(pretty_name "$code")")
    done

    selected=$(printf '%s\n' "''${labels[@]}" | wofi -L 3 --dmenu --prompt "Layout" --location top_right --xoffset -16 --yoffset 45 --width 250 --height 250)

    [ -z "$selected" ] && exit 0

    chosen_index=-1
    for i in "''${!labels[@]}"; do
        if [ "''${labels[$i]}" = "$selected" ]; then
            chosen_index=$i
            break
        fi
    done

    [ "$chosen_index" -lt 0 ] && exit 0

    hyprctl switchxkblayout current "$chosen_index"
  '';
in
{
  # jq, gawk и iproute2 нужны для sysinfo.sh (jq — сборка JSON, awk — парсинг
  # /proc/meminfo и вывода `ip route`, ip — определение сетевого интерфейса).
  packages = [
    pkgs.jq
    pkgs.gawk
    pkgs.iproute2
    sysInfo
    pkgs.btop
  ];

  # Backport of waybar PR #5013: route workspace clicks/scroll through the
  # Hyprland Lua IPC protocol (required since Hyprland 0.54 + Lua configs).
  package = pkgs.waybar.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./waybar-lua-ipc.patch ];
  });

  # Группы имён модулей для modules-left/center/right. Разбиты на части,
  # чтобы специфичные для ноутбука backlight/battery можно было вставить
  # в waybar-laptop.nix ровно на своё место, не трогая остальной порядок.
  moduleGroups = {
    left = [
      "custom/wofi"
      "hyprland/workspaces"
      "custom/sysinfo"
    ];
    center = [ "clock" ];
    rightPre = [
      "tray"
      "bluetooth"
      "network"
    ]; # далее — backlight (только ноутбук)
    rightMid = [
      "pulseaudio"
      "pulseaudio#microphone"
    ]; # далее — battery (только ноутбук)
    rightPost = [
      "hyprland/language"
      "custom/power"
    ];
  };

  # Общие настройки бара и модулей, одинаковые на всех машинах.
  # backlight/battery сюда не входят — они только в waybar-laptop.nix.
  mainBarBase = {
    layer = "top";
    position = "top";
    height = 34;
    spacing = 14; # Увеличенное базовое расстояние между модулями

    # Кнопка Wofi с позиционированием под левым краем панели
    "custom/wofi" = {
      format = " ";
      on-click = "wofi -L 8 --show drun --location top_left --xoffset 16 --yoffset 45";
      tooltip = false;
    };

    # 6 рабочих столов
    "hyprland/workspaces" = {
      format = "{name}";
      all-outputs = true;
      active-only = false;
      persistent-workspaces = {
        "1" = [ ];
        "2" = [ ];
        "3" = [ ];
        "4" = [ ];
        "5" = [ ];
        "6" = [ ];
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
      format = "󰂯 ";
      format-disabled = "󰂲 ";
      format-off = "󰂲 ";
      format-connected = "󰂱 {device_alias}";
      format-connected-battery = "󰂱 {device_alias} ({device_battery_percentage}%)";
      tooltip-format = "{controller_alias}\t{controller_address}";
      tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
      tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
      on-click = "kitty --title bluetui -e bluetui";
    };

    # Сеть. По клику открывается менеджер подключений NM
    network = {
      format-wifi = "  {essid} ({signalStrength}%)";
      format-ethernet = "󰈀  {ipaddr}/{cidr}";
      format-disconnected = "󰤭  Disconnected";
      tooltip-format = "{ifname} via {gwaddr}";
      on-click = "nm-connection-editor";
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

    # Раскладка клавиатуры. Отображение обновляется автоматически через
    # IPC Hyprland, по клику открывается кастомное wofi-меню выбора раскладки.
    # keyboard-name зависит от конкретной машины — задаётся в host home.nix.
    "hyprland/language" = {
      format = "{}";
      format-en = "EN";
      format-ru = "RU";
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

  # Общий CSS. Без стилей backlight/battery — их добавляет waybar-laptop.nix.
  style = ''
    * {
      font-family: "${theme.fonts.mono}", "${theme.fonts.monoFallback}", sans-serif;
      font-size: 14px;
    }

    window#waybar {
      background-color: ${theme.css.surface-85};
      color: #${theme.colors.fg};

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
    #pulseaudio,
    #pulseaudio\.microphone,
    #language,
    #custom-sysinfo,
    #custom-power {
      padding: 0 8px;
    }

    /* Стилизация кнопок рабочих столов */
    #workspaces button {
      padding: 0 10px;
      color: #${theme.colors.fg};
      background: transparent;
      border-radius: 6px;
      margin: 2px 4px; /* Зазор между кнопками номеров столов */
    }

    #workspaces button.active {
      background-color: #${theme.colors.accent};
      color: #${theme.colors.bg};
    }

    #workspaces button:hover {
      background: #${theme.colors.border};
    }

    /* Дополнительный отступ слева для самой первой иконки */
    #custom-wofi {
      color: #${theme.colors.accent-bright};
      font-size: 18px;
      padding-left: 14px;
    }

    /* Дополнительный отступ справа для самой последней иконки */
    #custom-power {
      color: #${theme.colors.error};
      font-size: 16px;
      padding-right: 14px;
    }

    /* Предупреждающие цвета для системного индикатора, как у батареи */
    #custom-sysinfo.warning {
      color: #${theme.colors.accent-bright};
    }

    #custom-sysinfo.critical {
      color: #${theme.colors.error};
    }

    #tray {
      margin-right: 4px;
    }
  '';
}
