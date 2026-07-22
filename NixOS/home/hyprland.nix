{ config, pkgs, lib, ... }:

let
  # Автогенерация биндов переключения на рабочие столы 1-9
  workspaceBinds = builtins.concatLists (map
    (i: [
      "$mod, ${toString i}, workspace, ${toString i}"
      "$mod SHIFT, ${toString i}, movetoworkspace, ${toString i}"
      "$mod, KP_${toString i}, workspace, ${toString i}"
      "$mod SHIFT, KP_${toString i}, movetoworkspace, ${toString i}"
    ])
    (lib.range 1 6));
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    configType = "hyprlang";
    systemd.variables = [ "--all" ];

    settings = {
      monitor = ",2560x1600@120,auto,1.25";

      exec-once = [
        "waybar"
        "hyprpaper"
        "nm-applet --indicator"
        "wl-paste --watch cliphist store"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,Adwaita"
        "HYPRCURSOR_THEME,Adwaita"
        "HYPRCURSOR_SIZE,24"
        "NIXOS_OZONE_WL,1"
        "GTK_THEME,Adwaita:dark"
        "QT_QPA_PLATFORMTHEME,kde"
        "QT_STYLE_OVERRIDE,breeze"
        "KDE_SESSION_VERSION,6"
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
        ", XF86AudioMicMute, exec, pamixer --default-source -t"
      ];

      xwayland = {
        force_zero_scaling = true;
      };
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
    };
    font = {
      name = "JetBrainsMono Nerd Font";
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

  services.hyprpolkitagent.enable = true;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # Запускать hyprlock именно по dbus/logind-событию блокировки,
        # но не плодить несколько инстансов, если он уже открыт.
        lock_cmd = "pidof hyprlock || hyprlock";
        # Срабатывает на ЛЮБОЙ уход в сон: по таймауту, вручную (systemctl
        # suspend / loginctl suspend) или при закрытии крышки — поэтому
        # экран будет блокироваться независимо от того, как вызван сон.
        before_sleep_cmd = "loginctl lock-session";
        # Чтобы монитор не приходилось "будить" двойным нажатием клавиши.
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };

      listener = [
        {
          timeout = 300; # 5 минут бездействия — блокировка экрана
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330; # 5.5 минут — гасим подсветку экрана
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 360; # 6 минут — уход в спящий режим
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  # ─── hyprlock: экран блокировки в теме "sunset pines" ───
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0; # без "льготного" периода без пароля — это экран блокировки
        hide_cursor = true;
        no_fade_in = false;
        no_fade_out = true;
      };

      background = [
        {
          monitor = "";
          path = "";
          color = "rgba(1a1a1aff)";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "260, 60";
          position = "0, -100";
          halign = "center";
          valign = "center";

          outline_thickness = 3;
          dots_size = 0.25;
          dots_spacing = 0.25;
          dots_center = true;
          fade_on_empty = false;

          # Оранжево-золотой контур на тёмно-фиолетовом поле ввода —
          # та же палитра, что и в hyprland.nix / kitty.
          outer_color = "rgba(f2994aee)";
          inner_color = "rgba(16141fd8)";
          font_color = "rgb(f5e9dc)";
          check_color = "rgb(a3b18a)";
          fail_color = "rgb(e8613c)";

          placeholder_text = ''<span foreground="##8a7a8a">Password...</span>'';
          fail_text = ''<span foreground="##e8613c">Wrong password</span>'';

          shadow_passes = 2;
          shadow_size = 3;
        }
      ];

      label = [
        {
          # Часы
          monitor = "";
          text = "$TIME";
          font_size = 90;
          font_family = "JetBrainsMono Nerd Font";
          color = "rgb(f7ce68)";
          position = "0, 160";
          halign = "center";
          valign = "center";
        }
        {
          # Дата
          monitor = "";
          text = ''cmd[update:60000] echo "$(LC_TIME=en_US.UTF-8 date +'%A, %d %B')"'';          
          font_size = 22;
          font_family = "JetBrainsMono Nerd Font";
          color = "rgb(f5e9dc)";
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
        {
          # Имя пользователя
          monitor = "";
          text = "  $USER";
          font_size = 18;
          font_family = "JetBrainsMono Nerd Font";
          color = "rgb(f2994a)";
          position = "0, -30";
          halign = "center";
          valign = "center";
        }
        {
          # Текущая раскладка клавиатуры, справа от поля ввода
          monitor = "";
          text = "$LAYOUT[EN,RU]";
          font_size = 14;
          font_family = "JetBrainsMono Nerd Font";
          color = "rgb(f2994a)";
          position = "175, -100";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

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

  # ─── hyprland-qt-support: стиль QML для hypr*-приложений (hyprpolkitagent и др.) ───
  # Отвечает только за "форму" (скругление углов, толщина рамки) — те же
  # значения, что и у окон в decoration/general выше (rounding = 8,
  # border_size = 2). Цвета в саму QML-тему не входят — их даёт активная
  # цветовая схема Qt/KDE, см. kdeglobals ниже.
  xdg.configFile."hypr/application-style.conf".text = ''
    roundness = 2
    border_width = 2
    reduce_motion = false
  '';

  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
    };

    iconTheme = {
      name = "Yaru";
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
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      icon-theme = "Yaru";
      gtk-theme = "Adwaita-dark";
      cursor-theme = "Adwaita";
      cursor-size = 24;
      color-scheme = "prefer-dark";
      accent-color = "orange";
    };
  };

  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = "Adwaita-dark";
      "Net/IconThemeName" = "Yaru";
      "Gtk/CursorThemeName" = "Adwaita";
      "Gtk/CursorThemeSize" = 24;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kde";
    style = {
      name = "breeze";
      package = pkgs.kdePackages.breeze;    
    };
  };
  # ------------------------------------- Прошлая кастомная тема ---
  xdg.configFile."kdeglobals".text = ''
  [Icons]
  Theme=Yaru

  [General]
        
  ${builtins.readFile "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors"}
  '';

 # ── Кастомная KColorScheme "Sunset Pines" для Qt/KDE-приложений ───
  # Та же палитра, что и в kitty/hyprlock/hyprland (см. выше: #16141f фон,
  # #f2994a/#f7ce68 акцент, #f5e9dc текст). Схема кладётся в
  # ~/.local/share/color-schemes как отдельный .colors-файл правильного
  # формата (секции Colors:Window/Button/View/Selection/... — так же, как
  # устроен BreezeDark.colors), а kdeglobals лишь ссылается на неё по имени.
  # Стиль виджетов остаётся Breeze (см. qt.style ниже) — меняется только
  # цветовая схема поверх него, это и есть штатный способ кастомизации в KDE.
  # Подхватывается всеми Qt-приложениями через qt.platformTheme.name = "kde"
  # (Ark, Telegram, hyprpolkitagent) — без необходимости лезть в qt5ct/qt6ct.
  # xdg.dataFile."color-schemes/SunsetPines.colors".text = ''
  #   [ColorEffects:Disabled]
  #   Color=112,111,110
  #   ColorAmount=0
  #   ColorEffect=0
  #   ContrastAmount=0.65
  #   ContrastEffect=1
  #   IntensityAmount=0.1
  #   IntensityEffect=2
  #
  #   [ColorEffects:Inactive]
  #   ChangeSelectionColor=true
  #   Color=112,111,110
  #   ColorAmount=0.025
  #   ColorEffect=2
  #   ContrastAmount=0.1
  #   ContrastEffect=2
  #   Enable=false
  #   IntensityAmount=0
  #   IntensityEffect=0
  #
  #   [Colors:Button]
  #   BackgroundAlternate=30,27,38
  #   BackgroundNormal=26,23,34
  #   DecorationFocus=242,153,74
  #   DecorationHover=247,206,104
  #   ForegroundActive=247,206,104
  #   ForegroundInactive=138,122,138
  #   ForegroundLink=122,139,189
  #   ForegroundNegative=232,97,60
  #   ForegroundNeutral=247,206,104
  #   ForegroundNormal=245,233,220
  #   ForegroundPositive=163,177,138
  #   ForegroundVisited=180,122,164
  #
  #   [Colors:Selection]
  #   BackgroundAlternate=242,153,74
  #   BackgroundNormal=74,59,79
  #   DecorationFocus=242,153,74
  #   DecorationHover=247,206,104
  #   ForegroundActive=245,233,220
  #   ForegroundInactive=245,233,220
  #   ForegroundLink=163,177,213
  #   ForegroundLinkVisited=209,163,196
  #   ForegroundNegative=232,97,60
  #   ForegroundNeutral=247,206,104
  #   ForegroundNormal=245,233,220
  #   ForegroundPositive=163,177,138
  #   ForegroundVisited=209,163,196
  #
  #   [Colors:Tooltip]
  #   BackgroundAlternate=30,27,38
  #   BackgroundNormal=22,20,31
  #   ForegroundActive=247,206,104
  #   ForegroundInactive=138,122,138
  #   ForegroundLink=122,139,189
  #   ForegroundNegative=232,97,60
  #   ForegroundNeutral=247,206,104
  #   ForegroundNormal=245,233,220
  #   ForegroundPositive=163,177,138
  #   ForegroundVisited=180,122,164
  #
  #   [Colors:View]
  #   BackgroundAlternate=30,27,38
  #   BackgroundNormal=22,20,31
  #   DecorationFocus=242,153,74
  #   DecorationHover=247,206,104
  #   ForegroundActive=247,206,104
  #   ForegroundInactive=138,122,138
  #   ForegroundLink=122,139,189
  #   ForegroundNegative=232,97,60
  #   ForegroundNeutral=247,206,104
  #   ForegroundNormal=245,233,220
  #   ForegroundPositive=163,177,138
  #   ForegroundVisited=180,122,164
  #
  #   [Colors:Window]
  #   BackgroundAlternate=30,27,38
  #   BackgroundNormal=22,20,31
  #   ForegroundActive=247,206,104
  #   ForegroundInactive=138,122,138
  #   ForegroundLink=122,139,189
  #   ForegroundNegative=232,97,60
  #   ForegroundNeutral=247,206,104
  #   ForegroundNormal=245,233,220
  #   ForegroundPositive=163,177,138
  #   ForegroundVisited=180,122,164
  #
  #   [General]
  #   ColorScheme=SunsetPines
  #   Name=Sunset Pines
  #   shadeSortColumn=true
  #
  #   [KDE]
  #   contrast=4
  #
  #   [WM]
  #   activeBackground=22,20,31
  #   activeBlend=245,233,220
  #   activeForeground=245,233,220
  #   inactiveBackground=26,23,34
  #   inactiveBlend=138,122,138
  #   inactiveForeground=138,122,138
  # '';
  #
  # xdg.configFile."kdeglobals".text = ''
  #   [General]
  #   ColorScheme=SunsetPines
  #   Name=Sunset Pines
  #
  #   [Icons]
  #   Theme=Yaru
  # '';

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

    # Polkit-agent hyprland
    hyprpolkitagent

    # Polkit-агент для запроса прав (нужен для GUI-программ с sudo)
    # polkit_gnome

    # Яркость, звук, медиаклавиши
    brightnessctl
    pamixer
    pavucontrol
    playerctl

    # Ночной свет
    hyprsunset


    # GUI-dialogs
    yad

    # Сетевой апплет
    networkmanagerapplet

    # Пакеты из Gnome Shell
    yaru-theme

    # Nerd Font — та же семья, что используется в zsh-промпте
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code

    # Тема иконок
    adwaita-icon-theme
    gnome-themes-extra      # полноценная тема Adwaita-dark для GTK3
  
    # Для GTK4/Libadwaita (современные приложения GNOME)
    gnome-desktop           # содержит Adwaita для GTK4

    # Дополнительно для старых приложений
    gtk-engine-murrine            # движок тем для GTK2

    libsForQt5.qt5ct
    qt6Packages.qt6ct
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
    QT_STYLE_OVERRIDE = "breeze";
    TERMINAL = "kitty";
  };


 }
