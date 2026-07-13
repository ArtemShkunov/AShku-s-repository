{ config, pkgs, lib, ... }:

let
  # Скрипт для кастомного меню питания через wofi
  powerMenu = pkgs.writeShellScriptBin "powermenu" ''
    entries="⏻ Выключение\n⟳ Перезагрузка\n⏾ Спящий режим\n󰗽 Выйти"
    selected=$(echo -e $entries | wofi --dmenu --prompt "Питание" --width 250 --height 210)
    case $selected in
      "⏻ Выключение")
        exec systemctl poweroff -i;;
      "⟳ Перезагрузка")
        exec systemctl reboot;;
      "⏾ Спящий режим")
        exec systemctl suspend;;
      "󰗽 Выйти")
        hyprctl dispatch exit;;
    esac
  '';
in
{
  programs.waybar = {
    enable = true;
    
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 5;
        
        # Размещение модулей на панели
        modules-left = [ "custom/wofi" "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "network" "backlight" "pulseaudio" "pulseaudio#microphone" "battery" "custom/power" ];

        # Кнопка запуска Wofi
        "custom/wofi" = {
          format = ""; # Иконка NixOS или любая другая
          on-click = "wofi --show drun";
          tooltip = false;
        };

        # 9 рабочих столов
        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
          all-outputs = true;
          active-only = false;
          persistent-workspaces = {
             "1" = []; "2" = []; "3" = []; "4" = []; "5" = []; 
             "6" = []; "7" = []; "8" = []; "9" = [];
          };
        };

        # Дата, время и день недели
        clock = {
          format = "{:%H:%M  |  %A, %d %b}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        # Фоновые приложения
        tray = {
          spacing = 10;
        };

        # Сеть
        network = {
          format-wifi = "  {essid}";
          format-ethernet = "󰈀  {ipaddr}/{cidr}";
          format-disconnected = "󰤭  Отключено";
          tooltip-format = "{ifname} via {gwaddr}";
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
            default = ["" "" ""];
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
          format-icons = ["" "" "" "" ""];
        };

        # Кнопка меню питания
        "custom/power" = {
          format = "⏻";
          on-click = "${powerMenu}/bin/powermenu";
          tooltip = false;
        };
      };
    };

    # Кастомизация внешнего вида панели
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Fira Code Nerd Font", sans-serif;
        font-size: 14px;
      }
      
      window#waybar {
        background-color: rgba(30, 30, 30, 0.9);
        color: #ffffff;
      }

      /* Стилизация кнопок рабочих столов */
      #workspaces button {
        padding: 0 8px;
        color: #ffffff;
        background: transparent;
        border-radius: 5px;
        margin: 2px;
      }

      /* Цвет активного рабочего стола (под красную тему Yaru) */
      #workspaces button.active {
        background-color: #e01b24; 
        color: #ffffff;
      }

      #workspaces button:hover {
        background: #5e5c64;
      }

      /* Общие стили для блоков */
      .modules-left > widget > span,
      .modules-center > widget > span,
      .modules-right > widget > span {
        margin: 0 5px;
        padding: 0 10px;
      }

      #custom-wofi {
        color: #e01b24;
        font-size: 18px;
        padding-right: 15px;
      }

      #custom-power {
        color: #e01b24;
        font-size: 16px;
        padding-left: 10px;
        padding-right: 15px;
      }

      #tray {
        margin-right: 10px;
      }
    '';
  };
}
