
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
      monitor = ",preferred,auto,1";

      exec-once = [
        "waybar"
        "hyprpaper"
        "hypridle"
        "nm-applet --indicator"
        "wl-paste --watch cliphist store"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "NIXOS_OZONE_WL,1"
      ];

      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(89b4faee)";
        "col.inactive_border" = "rgba(595959aa)";
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
        "$mod, Return, exec, kitty"
        "$mod, Q, killactive"
        "$mod, M, exit"
        "$mod, E, exec, thunar"
        "$mod, V, togglefloating"
        "$mod, R, exec, wofi --show drun"
        "$mod, P, pseudo"
        "$mod, J, togglesplit"
        "$mod, L, exec, hyprlock"
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
      ] ++ workspaceBinds;

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  home.packages = with pkgs; [
    # Статус-бар
    waybar

    # Лаунчер приложений
    wofi

    # Демон уведомлений
    mako

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

    # Терминал
    kitty

    # Файловый менеджер
    xfce.thunar

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
