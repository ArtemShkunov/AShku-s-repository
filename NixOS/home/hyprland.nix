{ config, pkgs, lib, ... }:

let
  # Автогенерация биндов переключения на рабочие столы 1-9
  workspaceBinds = builtins.concatLists (map
    (i: [
      "$mod, ${toString i}, workspace, ${toString i}"
      "$mod SHIFT, ${toString i}, movetoworkspace, ${toString i}"
    ])
    (lib.range 1 9));
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    configType = "hyprlang";

    settings = {
      monitor = ",2560x1600@120,auto,1.25";

      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE GTK_THEME"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP GTK_THEME"
        "waybar"
        "hypridle"
        "hyprpaper"
        "nm-applet --indicator"
        "wl-paste --watch cliphist store"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,Adwaita"
        "HYPRCURSOR_THEME,Adwaita"
        "HYPRCURSOR_SIZE,24"
        "NIXOS_OZONE_WL,1"
      ];

      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          clickfinger_behavior = true;
        };
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        # Градиент оранжевый -> золото под цвет заката с обоев
        "col.active_border" = "rgba(f2994aee) rgba(f7ce68ee) 45deg";
        "col.inactive_border" = "rgba(4a3b4faa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
        blur.enabled = true;
        blur.size = 3;
        blur.passes = 1;
      };

      animations.enabled = true;

      "$mod" = "SUPER";

      bind = [
        "$mod, Q, exec, kitty"
        "$mod, C, killactive"
        "$mod, M, exit"
        "$mod, E, exec, nautilus"
        "$mod, V, togglefloating"
        "$mod, R, exec, wofi --show drun"
        "$mod, P, pseudo"
        "$mod, J, layoutmsg, togglesplit"
        "$mod, L, exec, hyprlock"
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
      ] ++ workspaceBinds;

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindel = [
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
      ];
      bindl = [
        ", XF86AudioMute, exec, pamixer -t"
      ];
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.75";
      confirm_os_window_close = 0;

      # Цвета терминала в тон закатным обоям
      background = "#16141f";
      foreground = "#f5e9dc";
      cursor     = "#f7ce68";
      selection_background = "#4a3b4f";
      selection_foreground = "#f5e9dc";

      color0  = "#16141f"; color8  = "#8a7a8a"; # black
      color1  = "#e8613c"; color9  = "#f2994a"; # red/orange
      color2  = "#a3b18a"; color10 = "#c9d6b1"; # green
      color3  = "#f7ce68"; color11 = "#ffe29a"; # yellow/gold
      color4  = "#7a8bbd"; color12 = "#a3b1d6"; # blue
      color5  = "#b47aa0"; color13 = "#d1a3c4"; # magenta
      color6  = "#6ea8a0"; color14 = "#9fcac2"; # cyan
      color7  = "#f5e9dc"; color15 = "#ffffff"; # white
      font = {
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
      };
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      ipc = "on";
      wallpaper = [
        {
          monitor = "";
          path = "${config.home.homeDirectory}/Data/Wallpaper.png";
        }
      ];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [ "hyprland" "gtk" ];
    };
  };

  gtk = {
    enable = true;

    theme = {
      name = "Yaru-dark-orange";
      package = pkgs.yaru-theme;
    };

    iconTheme = {
      name = "Yaru-orange";
      package = pkgs.yaru-theme;
    };

    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "Yaru-dark-orange";
      icon-theme = "Yaru-orange";
      cursor-theme = "Adwaita";
      cursor-size = 24;
      color-scheme = "prefer-dark";
      accent-color = "orange";
    };
  };

  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = "Yaru-dark-orange";
      "Net/IconThemeName" = "Yaru-orange";
      "Gtk/CursorThemeName" = "Adwaita";
      "Gtk/CursorThemeSize" = 24;
    };
  };

  home.packages = with pkgs; [
    # Статус-бар
    waybar

    # Обои
    hyprpaper

    # Блокировка экрана и idle-менеджер
    hyprlock
    hypridle

    # Скриншоты
    grim
    slurp

    # Буфер обмена под Wayland (замена xclip из X11-конфига)
    wl-clipboard
    cliphist

    # Polkit-агент для запроса прав (нужен для GUI-программ с sudo)
    polkit_gnome

    # Яркость, звук, медиаклавиши
    brightnessctl
    pamixer
    pavucontrol
    playerctl

    # Сетевой апплет
    networkmanagerapplet

    # Пакеты из Gnome Shell
    nautilus
    gnome-system-monitor
    yaru-theme

    # Nerd Font — та же семья, что используется в zsh-промпте
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code

    # Тема иконок
    adwaita-icon-theme
  ];

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };
}
