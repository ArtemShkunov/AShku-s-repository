{ config, pkgs, lib, ... }:

let
  # Скрипт для кастомного меню питания через wofi с позиционированием в верхнем правом углу
  powerMenu = pkgs.writeShellScriptBin "powermenu" ''
    entries="⏻ Power off\n⟳ Reboot\n⏾ Suspend\n󰗽 Exit"
    selected=$(echo -e "$entries" | wofi --dmenu --prompt "Power" --location top_right --xoffset -16 --yoffset 45 --width 250 --height 150)
    case $selected in
      "⏻ Power off")
        exec systemctl poweroff -i;;
      "⟳ Reboot")
        exec systemctl reboot;;
      "⏾ Suspend")
        exec systemctl suspend;;
      "󰗽 Exit")
        hyprctl dispatch exit;;
    esac
  '';
in
{
  # Добавляем gnome-calendar прямо в этот модуль для вызова по клику на часы
  home.packages = [ pkgs.gnome-calendar ];

  programs.waybar = {
    enable = true;
    
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 34;
        spacing = 14; # Увеличенное базовое расстояние между модулями
        
        modules-left = [ "custom/wofi" "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "tray" "network" "backlight" "pulseaudio" "pulseaudio#microphone" "battery" "custom/power" ];

        # Кнопка Wofi с позиционированием под левым краем панели
        "custom/wofi" = {
          format = ""; 
          on-click = "wofi --show drun --location top_left --xoffset 16 --yoffset 45 --width 350";
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

        # Дата и время. По клику запускается календарь
        clock = {
          format = "{:%H:%M  |  %A, %d %b}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          on-click = "gnome-calendar";
        };

        # Фоновые приложения в трее
        tray = {
          spacing = 12; # Расстояние между иконками приложений в трее
        };

        # Сеть. По клику открывается менеджер подключений NM
        network = {
          format-wifi = "  {essid}";
          format-ethernet = "󰈀  {ipaddr}/{cidr}";
          format-disconnected = "󰤭  Отключено";
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
        background-color: rgba(30, 30, 30, 0.9);
        color: #ffffff;
        
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
      #custom-power {
        padding: 0 10px;
      }

      /* Стилизация кнопок рабочих столов */
      #workspaces button {
        padding: 0 10px;
        color: #ffffff;
        background: transparent;
        border-radius: 6px;
        margin: 2px 4px; /* Зазор между кнопками номеров столов */
      }

      #workspaces button.active {
        background-color: #e01b24; 
        color: #ffffff;
      }

      #workspaces button:hover {
        background: #5e5c64;
      }

      /* Дополнительный отступ слева для самой первой иконки */
      #custom-wofi {
        color: #e01b24;
        font-size: 18px;
        padding-left: 14px;
      }

      /* Дополнительный отступ справа для самой последней иконки */
      #custom-power {
        color: #e01b24;
        font-size: 16px;
        padding-right: 14px;
      }

      #tray {
        margin-right: 4px;
      }
    '';
  };
}
