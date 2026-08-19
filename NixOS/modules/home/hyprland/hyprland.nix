# hyprland.nix — the Hyprland window manager itself.
#
# WM behaviour only: binds, layout, decoration, env, portals, polkit agent.
# Machine specifics (monitor, touchpad) live in the host's home.nix.
# Terminal, lockscreen, idle, wallpaper and GTK/Qt theming are separate
# modules under modules/home/.
{ pkgs, theme, ... }:

let
  lib = pkgs.lib;

  # Автогенерация биндов переключения на рабочие столы 1-9
  workspaceBinds = builtins.concatLists (
    map (i: [
      "$mod, ${toString i}, workspace, ${toString i}"
      "$mod SHIFT, ${toString i}, movetoworkspace, ${toString i}"
      "$mod, KP_${toString i}, workspace, ${toString i}"
      "$mod SHIFT, KP_${toString i}, movetoworkspace, ${toString i}"
    ]) (lib.range 1 6)
  );
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    configType = "hyprlang";
    systemd.variables = [ "--all" ];

    settings = {
      exec-once = [
        "waybar"
        "hyprpaper"
        "nm-applet --indicator"
        "wl-paste --watch cliphist store"
      ];

      env = [
        "XCURSOR_SIZE,${toString theme.cursor.size}"
        "XCURSOR_THEME,rose-pine-hyprcursor"
        "HYPRCURSOR_THEME,rose-pine-hyprcursor"
        "HYPRCURSOR_SIZE,${toString theme.cursor.size}"
        "NIXOS_OZONE_WL,1"
        "GTK_THEME,Adwaita:dark" # GTK_THEME variant syntax; theme.gtk.theme is used by home-manager gtk module
        "QT_QPA_PLATFORMTHEME,kde"
        "QT_STYLE_OVERRIDE,${theme.qt.style}"
        "KDE_SESSION_VERSION,6"
      ];

      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
      };

      dwindle = {
        preserve_split = true;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        # Градиент оранжевый -> золото под цвет заката с обоев
        "col.active_border" = "rgba(${theme.colors.accent}ee) rgba(${theme.colors.accent-bright}ee) 45deg";
        "col.inactive_border" = "rgba(${theme.colors.border}aa)";
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
        "$mod, E, exec, thunar"
        "$mod, V, togglefloating"
        "$mod, R, exec, wofi -L 8 --show drun"
        "$mod, P, pseudo"
        "$mod, J, layoutmsg, togglesplit"
        "$mod, L, exec, hyprlock"
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, F, exec, firefox"
        "$mod, T, exec, Throne"
        "$mod, N, exec, pkill hyprsunset || hyprsunset -t 3500"
        "$$mod, B, exec, zen-beta"
      ]
      ++ workspaceBinds;

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
        ", XF86AudioMicMute, exec, pamixer --default-source -t"
      ];

      xwayland = {
        force_zero_scaling = true;
      };
    };
  };

  # ─── hyprland-qt-support: стиль QML для hypr*-приложений (hyprpolkitagent и др.) ───
  # Отвечает только за "форму" (скругление углов, толщина рамки) — те же
  # значения, что и у окон в decoration/general выше (rounding = 8,
  # border_size = 2). Цвета в саму QML-тему не входят — их даёт активная
  # цветовая схема Qt/KDE, см. theming.nix.
  xdg.configFile."hypr/application-style.conf".text = ''
    roundness = 2
    border_width = 2
    reduce_motion = false
  '';

  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];

    config = {
      hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };
  };

  services.hyprpolkitagent.enable = true;

  home.packages = with pkgs; [
    # Скриншоты
    grim
    slurp

    # Буфер обмена под Wayland
    wl-clipboard
    cliphist

    # Polkit-агент hyprland
    hyprpolkitagent

    # Яркость, звук, медиаклавиши
    brightnessctl # backlight — no-op on machines without backlight
    pamixer
    pavucontrol
    playerctl

    # Ночной свет
    hyprsunset

    # GUI-dialogs (используются скриптами waybar)
    yad

    # Сетевой апплет
    networkmanagerapplet
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    QT_STYLE_OVERRIDE = theme.qt.style;
    TERMINAL = "kitty";
  };
}
