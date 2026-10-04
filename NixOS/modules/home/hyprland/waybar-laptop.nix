# Waybar для ноутбука: общая часть из waybar-common.nix плюс battery и
# backlight, которых нет и не должно быть на ПК.
{ pkgs, theme, ... }:

let
  common = import ./waybar-common.nix { inherit pkgs theme; };

  # Скрипт для яркости/ночного света. Меню по клику на backlight-модуль:
  # тумблер ночного режима или GUI-регулятор. brightnessctl работает с
  # внутренней панелью ноутбука, поэтому скрипт живёт только здесь.
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
            --scale --value="$percent" --min-value=1 --max-value=100 --step=1 \
            --print-partial --text="Regulate brightness..." \
            --button="Ready:0" |
            while IFS= read -r val; do
                if [[ "$val" =~ ^[0-9]+$ ]]; then
                    brightnessctl set "''${val}%" >/dev/null 2>&1
                fi
            done
            ;;
    esac
  '';

  # Меню выбора TLP-профиля через wofi (вверху справа).
  profileMenu = pkgs.writeShellScriptBin "profilemenu" ''
    set -euo pipefail

    cur=$(tlp-stat -m 2>/dev/null | head -1 | cut -d/ -f1)
    mark() {
      if [ "$1" = "$cur" ]; then
        printf ' *'
      fi
    }

    entries=" 󰓅 Performance$(mark performance)\n 󰐦 Balanced$(mark balanced)\n 󰌪 Power saver$(mark power-saver)"
    selected=$(echo -e "$entries" | wofi -L 3 --dmenu --prompt "Power profile" --location top_right --xoffset -16 --yoffset 45 --width 250 --height 150)
    [ -z "$selected" ] && exit 0

    case "$selected" in
      *Performance*) profile=performance;;
      *Balanced*) profile=balanced;;
      *Power*) profile=power-saver;;
      *) exit 0;;
    esac

    # tlpctl сам применяет профиль; уведомляем только при успехе.
    tlpctl set "$profile" >/dev/null && notify-send -u low -t 2000 "Power profile" "$profile"
  '';

  # Состояние для custom-модуля waybar: JSON {text, tooltip, class}.
  profileStatus = pkgs.writeShellScriptBin "profilestatus" ''
    set -euo pipefail

    state=$(tlp-stat -m 2>/dev/null | head -1)
    profile=''${state%%/*}
    [ -z "$profile" ] && profile=balanced

    src=bat
    for f in /sys/class/power_supply/*/online; do
      if [ "$(cat "$f" 2>/dev/null)" = "1" ]; then
        src=ac
        break
      fi
    done

    case "$profile" in
      performance) text="󰓅 Perf"; tip="Performance";;
      power-saver) text="󰌪 Save"; tip="Power saver";;
      *) text="󰐦 Bal"; tip="Balanced"; profile=balanced;;
    esac

    if [ "$src" = ac ]; then
      srcname="AC"
    else
      srcname="battery"
    fi

    # -c обязателен: waybar 0.15 читает только первую строку вывода
    # и парсит её как JSON (src/modules/custom.cpp, parseOutputJson).
    ${pkgs.jq}/bin/jq -c -n --arg text "$text" \
      --arg tip "$tip ($srcname)" \
      --arg cls "$profile" \
      '{text:$text, tooltip:$tip, class:$cls}'
  '';
in
{
  # libnotify — notify-send для меню профиля (его же ждёт alert в zsh).
  home.packages = common.packages ++ [ pkgs.libnotify ];

  programs.waybar = {
    enable = true;
    package = common.package;
    systemd.enable = true;

    settings.mainBar = common.mainBarBase // {
      modules-left = common.moduleGroups.left;
      modules-center = common.moduleGroups.center;
      modules-right =
        common.moduleGroups.rightPre
        ++ [ "backlight" ]
        ++ common.moduleGroups.rightMid
        ++ [ "custom/powerprofile" "battery" ]
        ++ common.moduleGroups.rightPost;

      # Яркость
      backlight = {
        format = "{icon} {percent}%";
        format-icons = ["" "" "" "" "" "" "" "" ""];
        on-click = "${brightnessMenu}/bin/brightnessmenu";
        tooltip = false;
      };

      # TLP-профиль: индикатор + wofi-меню выбора (tlpctl, без root).
      "custom/powerprofile" = {
        exec = "${profileStatus}/bin/profilestatus";
        return-type = "json";
        interval = 2;
        on-click = "${profileMenu}/bin/profilemenu";
        tooltip = true;
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
        format-icons = ["" "" "" "" ""];
      };
    };

    style = common.style + ''
      #backlight,
      #battery,
      #custom-powerprofile {
        padding: 0 8px;
      }

      #custom-powerprofile.performance {
        color: #${theme.colors.accent-bright};
      }

      #custom-powerprofile.power-saver {
        color: #${theme.colors.accent};
      }

      #battery.warning {
        color: #${theme.colors.accent-bright};
      }

      #battery.critical {
        color: #${theme.colors.error};
      }
    '';
  };
}
