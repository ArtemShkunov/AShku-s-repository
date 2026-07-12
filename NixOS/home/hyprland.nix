
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
      monitor = ",1920x1200@120,auto,1";

      exec-once = [
        "waybar"
        "hypridle"
        "sh -c 'pkill hyprpaper; sleep 1; hyprpaper'"
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
        touchpad = {
          natural_scroll = true;
          clickfinger_behavior = true;
        };
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
      background_opacity = "0.85";
      confirm_os_window_close = 0;
    };
  };

# Обои: модуль services.hyprpaper сейчас нестабилен (его контент утекает
  # прямо в hyprland.conf вместо отдельного hyprpaper.conf — похоже на баг
  # на фоне миграции экосистемы Hyprland на Lua). Пишем hyprpaper.conf
  # напрямую как обычный текстовый файл — так надёжнее.
  # Замени путь на свою картинку.
  xdg.configFile."hypr/hyprpaper.conf".text = ''
    preload=${config.home.homeDirectory}/Data/Wallpaper.jpg
    wallpaper=,${config.home.homeDirectory}/Data/Wallpaper.jpg
    splash = false
  '';

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

    # Файловый менеджер
    nautilus

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
