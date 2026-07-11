# home/hyprland.nix
{ config, pkgs, lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    configType = "hyprlang";

    settings = {
      monitor = [ ",preferred,auto,1" ];

      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "wofi --show drun";

      exec-once = [
        "waybar"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "hyprpaper"
        "nm-applet"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORMTHEME,qt5ct"
      ];

      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
        };
        sensitivity = 0;
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        "col.active_border" = "rgba(89b4faee)";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 4;
          passes = 2;
        };
        drop_shadow = true;
      };

      animations = {
        enabled = true;
        bezier = [ "myBezier, 0.05, 0.9, 0.1, 1.05" ];
        animation = [
          "windows, 1, 5, myBezier"
          "windowsOut, 1, 5, default, popin 80%"
          "border, 1, 8, default"
          "fade, 1, 5, default"
          "workspaces, 1, 4, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      gestures = {
        workspace_swipe = true;
      };

      bind =
        [
          "$mod, Return, exec, $terminal"
          "$mod, Q, killactive"
          "$mod, M, exit"
          "$mod, E, exec, thunar"
          "$mod, V, togglefloating"
          "$mod, R, exec, $menu"
          "$mod, P, pseudo"
          "$mod, J, togglesplit"
          "$mod, F, fullscreen"

          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
        ]
        ++ (
          # workspaces 1-10 через $mod + число, перенос окна через $mod+shift+число
          builtins.concatLists (builtins.genList
            (i:
              let ws = toString (i + 1); in [
                "$mod, ${ws}, workspace, ${ws}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${ws}"
              ])
            9)
        );

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      binde = [
        ",XF86MonBrightnessUp, exec, brightnessctl set +5%"
        ",XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
    };
  };

  # Статус-бар
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 28;
      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [ "pulseaudio" "network" "battery" "tray" ];
    };
  };

  # Wallpaper daemon (легковесный, из экосистемы Hyprland)
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "~/Pictures/wallpaper.jpg" ];
      wallpaper = [ ",~/Pictures/wallpaper.jpg" ];
    };
  };

  # Application launcher
  programs.wofi.enable = true;

  # Notifications
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 8;
    };
  };

  home.packages = with pkgs; [
    kitty
    thunar
    wl-clipboard
  ];
}
