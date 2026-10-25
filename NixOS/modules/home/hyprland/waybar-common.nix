# Общие для всех машин куски Waybar: скрипты, определения общих модулей и
# базовый CSS. Это НЕ home-manager модуль, а обычная функция — она не
# подключается напрямую через imports, а импортируется как данные из
# waybar-desktop.nix / waybar-laptop.nix, которые уже собирают из неё
# конкретный programs.waybar.
{ pkgs, theme }:

let
  # Меню питания через Fuzzel dmenu, рядом с верхним правым краем бара.
  powerMenu = pkgs.writeShellScriptBin "powermenu" ''
    entries=" Power off\n Reboot\n⏾ Suspend\n Lock\n󰗽 Exit"
    selected=$(
      printf '%b\n' "$entries" |
        fuzzel-menu \
          --prompt "Power  " \
          --lines 5 \
          --width 28
    )
    case "$selected" in
        *"Power off")
            exec systemctl poweroff -i;;
        *"Reboot")
            exec systemctl reboot;;
        *"Suspend")
            exec systemctl suspend;;
        *"Lock")
            hyprlock;;
        *"Exit")
            hyprctl dispatch 'hl.dsp.exit()';;
    esac
  '';

  # Левая кнопка на модуле сети: включить/выключить Wi-Fi.
  wifiToggle = pkgs.writeShellScriptBin "wifi-toggle" ''
    set -euo pipefail
    state=$(${pkgs.networkmanager}/bin/nmcli -t -f WIFI radio)
    if [ "$state" = "enabled" ]; then
      ${pkgs.networkmanager}/bin/nmcli radio wifi off
    else
      ${pkgs.networkmanager}/bin/nmcli radio wifi on
    fi
  '';

  # Invoke the configured default browser once directly. The default web
  # handler in this setup is Zen, and xdg-open can dispatch duplicate handlers
  # when the same desktop entry appears in system and user application paths.
  defaultBrowser = pkgs.writeShellScriptBin "default-browser" ''
    exec zen-beta "https://"
  '';

  # Левая кнопка на модуле Bluetooth: включить/выключить адаптер.
  bluetoothToggle = pkgs.writeShellScriptBin "bluetooth-toggle" ''
    set -euo pipefail
    if ${pkgs.bluez}/bin/bluetoothctl show | grep -q 'Powered: yes'; then
      ${pkgs.bluez}/bin/bluetoothctl power off
    else
      ${pkgs.bluez}/bin/bluetoothctl power on
    fi
  '';

  # Скрипт для комбинированного информационного поля (CPU, RAM, сеть, температура)
  # лежит рядом с этим файлом как sysinfo.sh и подключается как есть.
  sysInfo = pkgs.writeShellScriptBin "sysinfo" (builtins.readFile ./sysinfo.sh);

  # Кастомное меню выбора раскладки клавиатуры через Fuzzel.
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

    selected=$(
      printf '%s\n' "''${labels[@]}" |
        fuzzel-menu \
          --prompt "Layout  " \
          --lines 3 \
          --width 28
    )

    [ -z "$selected" ] && exit 0

    chosen_index=-1
    for i in "''${!labels[@]}"; do
        if [ "''${labels[$i]}" = "$selected" ]; then
            chosen_index=$i
            break
        fi
    done

    [ "$chosen_index" -lt 0 ] && exit 0

    # Переключаем раскладку на ВСЕХ клавиатурах, а не только на "current":
    # у одной физической клавиатуры может быть несколько input-устройств,
    # и waybar слушает события конкретного имени. Синхронизация всех
    # гарантирует обновление индикатора независимо от того, какое устройство
    # Hyprland считает активным. Ошибки по псевдоклавиатурам игнорируем.
    while IFS= read -r kb; do
        [ -z "$kb" ] && continue
        hyprctl switchxkblayout "$kb" "$chosen_index" >/dev/null 2>&1 || true
    done < <(hyprctl devices -j | jq -r '.keyboards[].name')
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
    defaultBrowser
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
      "custom/launcher"
      "hyprland/workspaces"
      "custom/sysinfo"
      "custom/shortcuts"
    ];
    center = [ "clock" ];
    rightPre = [ "tray" ];
    # System indicators adjacent in one visually unified group.
    systemIndicators = [
      "custom/status-start"
      "network"
      "bluetooth"
      "pulseaudio"
      "pulseaudio#microphone"
      "custom/status-end"
    ];
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
    spacing = 0; # Соседние элементы образуют непрерывные TUI-группы

    # Кнопка запуска приложений (Fuzzel).
    "custom/launcher" = {
      format = "";
      on-click = "fuzzel";
      tooltip = false;
    };

    # Waybar's Hyprland module reports the currently used workspaces; with
    # active-only=false it keeps every workspace that has clients, plus current.
    "hyprland/workspaces" = {
      format = "{name}";
      all-outputs = true;
      active-only = false;
      sort-by = "number";
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

    # Подсказки по шорткатам; тот же скрипт висит на Super+H.
    "custom/shortcuts" = {
      format = "?";
      on-click = "shortcuts";
      tooltip = false;
    };

    "custom/status-start" = {
      format = "";
      tooltip = false;
    };
    "custom/status-end" = {
      format = "";
      tooltip = false;
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
      format-connected = "󰂱";
      format-connected-battery = "󰂱";
      tooltip-format = "{controller_alias}\t{controller_address}";
      tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
      tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
      on-click = "${bluetoothToggle}/bin/bluetooth-toggle";
      on-click-right = "kitty --title bluetui -e bluetui";
      on-scroll-up = "${bluetoothToggle}/bin/bluetooth-toggle";
      on-scroll-down = "${bluetoothToggle}/bin/bluetooth-toggle";
    };

    # Сеть: ЛКМ — тумблер Wi-Fi, ПКМ — менеджер подключений NM.
    network = {
      format-wifi = "";
      format-ethernet = "󰈀";
      format-disconnected = "󰤭";
      tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ipaddr}/{cidr}";
      tooltip-format-ethernet = "{ifname}\n{ipaddr}/{cidr}";
      tooltip-format-disconnected = "Disconnected";
      on-click = "${wifiToggle}/bin/wifi-toggle";
      on-click-right = "nm-connection-editor";
      on-scroll-up = "${wifiToggle}/bin/wifi-toggle";
      on-scroll-down = "${wifiToggle}/bin/wifi-toggle";
    };

    # Звук: ЛКМ — mute, ПКМ — pavucontrol.
    pulseaudio = {
      format = "{icon}";
      format-muted = "󰖁";
      format-icons = [
        ""
        ""
        ""
      ];
      scroll-step = 5;
      on-click = "pamixer -t";
      on-click-right = "pavucontrol";
    };

    # Микрофон: ЛКМ — mute, ПКМ — pavucontrol.
    "pulseaudio#microphone" = {
      format = "{format_source}";
      format-source = "";
      format-source-muted = "";
      on-click = "pamixer --default-source -t";
      on-click-right = "pavucontrol";
    };

    # Раскладка клавиатуры. Отображение обновляется автоматически через
    # IPC Hyprland, по клику открывается кастомное меню выбора раскладки.
    # keyboard-name зависит от конкретной машины — задаётся в host home.nix.
    "hyprland/language" = {
      format = "{}";
      format-en = "EN";
      format-ru = "RU";
      on-click = "${layoutMenu}/bin/layoutmenu";
      tooltip = false;
    };

    # Кнопка питания открывает компактное меню Fuzzel.
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

    /* Непрозрачная, сдержанная TUI-панель. */
    window#waybar {
      background-color: #${theme.colors.bg};
      color: #${theme.colors.fg};
      border: 1px solid #${theme.colors.grey};

      /* Отступы панели от краев экрана: 8px сверху, 16px по бокам */
      margin: 8px 16px 0 16px;

      /* Скругление краев всей панели под стиль окон Hyprland */
      border-radius: 0;
    }

    /* Modules use flat terminal-like cells; no hover glow. */
    #custom-launcher,
    #custom-shortcuts,
    #workspaces,
    #clock,
    #tray,
    #language,
    #custom-sysinfo,
    #custom-power,
    #battery,
    #custom-powerprofile {
      background-color: transparent;
      border: none;
      border-radius: 0;
      padding: 0 8px;
      margin: 0;
    }

    #custom-status-start,
    #custom-status-end {
      background-color: #${theme.colors.surface};
      border: none;
      padding: 0;
      margin: 0;
      min-width: 1px;
    }

    /* Adjacent status indicators read as a single TUI group. */
    #network,
    #bluetooth,
    #pulseaudio,
    #pulseaudio\.microphone,
    #backlight {
      background-color: #${theme.colors.surface};
      border: none;
      border-radius: 0;
      padding: 0 7px;
      margin: 0;
    }

    #network {
      padding-left: 10px;
    }

    #pulseaudio\.microphone {
      padding-right: 10px;
    }

    #network,
    #bluetooth,
    #pulseaudio,
    #pulseaudio\.microphone,
    #backlight,
    #custom-launcher,
    #custom-shortcuts,
    #clock,
    #language,
    #custom-sysinfo,
    #custom-power,
    #battery,
    #custom-powerprofile {
      transition: none;
    }

    #network:hover,
    #bluetooth:hover,
    #pulseaudio:hover,
    #pulseaudio\.microphone:hover,
    #backlight:hover,
    #custom-launcher:hover,
    #custom-shortcuts:hover,
    #clock:hover,
    #language:hover,
    #custom-sysinfo:hover,
    #custom-power:hover,
    #battery:hover,
    #custom-powerprofile:hover {
      background-color: inherit;
      border: none;
      box-shadow: none;
      color: inherit;
    }

    /* Стилизация кнопок рабочих столов */
    #workspaces button {
      padding: 0 9px;
      color: #${theme.colors.fg};
      background: transparent;
      border: none;
      border-radius: 0;
      margin: 0;
    }

    #workspaces button.active {
      background-color: #${theme.colors.surface};
      color: #${theme.colors.accent-bright};
    }

    #workspaces button:hover,
    #workspaces button:active {
      background-color: inherit;
      box-shadow: none;
    }

    #workspaces button.occupied {
      color: #${theme.colors.fg};
    }

    /* Иконка запуска приложений. */
    #custom-launcher {
      color: #${theme.colors.accent-bright};
      font-size: 18px;
      padding: 0 10px;
    }

    /* Вопросительный знак — подсказки по шорткатам. */
    #custom-shortcuts {
      color: #${theme.colors.accent};
      font-size: 16px;
      font-weight: bold;
      padding: 0 10px;
    }

    /* Кнопка питания. */
    #custom-power {
      color: #${theme.colors.error};
      font-size: 16px;
      padding: 0 10px;
    }

    /* Предупреждающие цвета для системного индикатора, как у батареи */
    #custom-sysinfo.warning {
      color: #${theme.colors.accent-bright};
    }

    #custom-sysinfo.critical {
      color: #${theme.colors.error};
    }

    #tray {
      padding: 0 6px;
    }
  '';
}
