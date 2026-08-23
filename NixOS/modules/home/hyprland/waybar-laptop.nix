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
in
{
  home.packages = common.packages;

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
        ++ [ "battery" ]
        ++ common.moduleGroups.rightPost;

      # Яркость
      backlight = {
        format = "{icon} {percent}%";
        format-icons = [
          ""
          ""
          ""
          ""
          ""
          ""
          ""
          ""
          ""
        ];
        on-click = "${brightnessMenu}/bin/brightnessmenu";
        tooltip = false;
      };

      # Батарея
      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = " {capacity}%";
        format-icons = [
          " "
          " "
          " "
          " "
          " "
        ];
      };
    };

    style = common.style + ''
      #backlight,
      #battery {
        padding: 0 8px;
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
