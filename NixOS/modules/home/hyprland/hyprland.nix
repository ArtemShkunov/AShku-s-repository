# hyprland.nix — the Hyprland window manager itself.
#
# WM behaviour only: binds, layout, decoration, env, portals, polkit agent.
# Machine specifics (monitor, touchpad) live in the host's home.nix.
# Terminal, lockscreen, idle, wallpaper and GTK/Qt theming are separate
# modules under modules/home/.
{ pkgs, theme, ... }:

let
  lib = pkgs.lib;
  mkLuaInline = lib.generators.mkLuaInline;

  # Бинды переключения на рабочие столы 1-6 в Lua-идиоме.
  workspaceBinds = builtins.concatLists (
    map (i: [
      {
        _args = [
          (mkLuaInline "mod .. \" + ${toString i}\"")
          (mkLuaInline "hl.dsp.focus({ workspace = ${toString i} })")
        ];
      }
      {
        _args = [
          (mkLuaInline "mod .. \" + SHIFT + ${toString i}\"")
          (mkLuaInline "hl.dsp.window.move({ workspace = ${toString i} })")
        ];
      }
      {
        _args = [
          (mkLuaInline "mod .. \" + KP_${toString i}\"")
          (mkLuaInline "hl.dsp.focus({ workspace = ${toString i} })")
        ];
      }
      {
        _args = [
          (mkLuaInline "mod .. \" + SHIFT + KP_${toString i}\"")
          (mkLuaInline "hl.dsp.window.move({ workspace = ${toString i} })")
        ];
      }
    ]) (lib.range 1 6)
  );
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    configType = "lua";
    systemd.variables = [ "--all" ];

    settings = {
      mod = {
        _var = "SUPER";
      };

      env = [
        {
          _args = [
            "XCURSOR_SIZE"
            (toString theme.cursor.size)
          ];
        }
        {
          _args = [
            "XCURSOR_THEME"
            "rose-pine-hyprcursor"
          ];
        }
        {
          _args = [
            "HYPRCURSOR_THEME"
            "rose-pine-hyprcursor"
          ];
        }
        {
          _args = [
            "HYPRCURSOR_SIZE"
            (toString theme.cursor.size)
          ];
        }
        {
          _args = [
            "NIXOS_OZONE_WL"
            "1"
          ];
        }
        {
          _args = [
            "GTK_THEME"
            "Adwaita:dark"
          ];
        }
        {
          _args = [
            "QT_QPA_PLATFORMTHEME"
            "kde"
          ];
        }
        {
          _args = [
            "QT_STYLE_OVERRIDE"
            theme.qt.style
          ];
        }
        {
          _args = [
            "KDE_SESSION_VERSION"
            "6"
          ];
        }
      ];

      config = {
        input = {
          kb_layout = "us,ru";
          kb_options = "grp:alt_shift_toggle";
          follow_mouse = 1;
          numlock_by_default = true;
        };

        dwindle = {
          preserve_split = true;
        };

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          # Градиент оранжевый -> золото под цвет заката с обоев
          col = {
            active_border = {
              colors = [
                "rgba(${theme.colors.accent}ee)"
                "rgba(${theme.colors.accent-bright}ee)"
              ];
              angle = 45;
            };
            inactive_border = "rgba(${theme.colors.border}aa)";
          };
          layout = "dwindle";
        };

        decoration = {
          rounding = 8;
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };
        };

        animations.enabled = true;

        xwayland = {
          force_zero_scaling = true;
        };
      };

      bind = [
        {
          _args = [
            (mkLuaInline "mod .. \" + Q\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"kitty\")")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + C\"")
            (mkLuaInline "hl.dsp.window.close()")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + M\"")
            (mkLuaInline "hl.dsp.exit()")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + E\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"thunar\")")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + V\"")
            (mkLuaInline "hl.dsp.window.float({ action = \"toggle\" })")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + R\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"wofi -L 8 --show drun\")")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + P\"")
            (mkLuaInline "hl.dsp.window.pseudo()")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + J\"")
            (mkLuaInline "hl.dsp.layout(\"togglesplit\")")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + L\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"hyprlock\")")
          ];
        }
        {
          _args = [
            "Print"
            (mkLuaInline "hl.dsp.exec_cmd(\"grim -g \\\"$(slurp)\\\" - | wl-copy\")")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + left\"")
            (mkLuaInline "hl.dsp.focus({ direction = \"left\" })")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + right\"")
            (mkLuaInline "hl.dsp.focus({ direction = \"right\" })")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + up\"")
            (mkLuaInline "hl.dsp.focus({ direction = \"up\" })")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + down\"")
            (mkLuaInline "hl.dsp.focus({ direction = \"down\" })")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + F\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"firefox\")")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + T\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"Throne\")")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + N\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"pkill hyprsunset || hyprsunset -t 3500\")")
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + B\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"zen-beta\")")
          ];
        }

        # bindm — перемещение/ресайз окна мышью
        {
          _args = [
            (mkLuaInline "mod .. \" + mouse:272\"")
            (mkLuaInline "hl.dsp.window.drag()")
            { mouse = true; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + mouse:273\"")
            (mkLuaInline "hl.dsp.window.resize()")
            { mouse = true; }
          ];
        }

        # bindel — удерживаемые (repeating)
        {
          _args = [
            "XF86MonBrightnessDown"
            (mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl set 5%-\")")
            {
              locked = true;
              repeating = true;
            }
          ];
        }
        {
          _args = [
            "XF86MonBrightnessUp"
            (mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl set 5%+\")")
            {
              locked = true;
              repeating = true;
            }
          ];
        }
        {
          _args = [
            "XF86AudioLowerVolume"
            (mkLuaInline "hl.dsp.exec_cmd(\"pamixer -d 5\")")
            {
              locked = true;
              repeating = true;
            }
          ];
        }
        {
          _args = [
            "XF86AudioRaiseVolume"
            (mkLuaInline "hl.dsp.exec_cmd(\"pamixer -i 5\")")
            {
              locked = true;
              repeating = true;
            }
          ];
        }

        # bindl — залоченные (locked)
        {
          _args = [
            "XF86AudioMute"
            (mkLuaInline "hl.dsp.exec_cmd(\"pamixer -t\")")
            { locked = true; }
          ];
        }
        {
          _args = [
            "XF86AudioMicMute"
            (mkLuaInline "hl.dsp.exec_cmd(\"pamixer --default-source -t\")")
            { locked = true; }
          ];
        }
      ]
      ++ workspaceBinds;
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

  # Session daemons that used to live in `settings.exec_cmd`. Top-level
  # `hl.exec_cmd` spawns at config-parse time — before the Wayland socket
  # exists — so the processes died at login. Run them as systemd user
  # services instead (same pattern as hyprpaper/hypridle/mako).
  systemd.user.services = {
    "nm-applet" = {
      Unit = {
        Description = "NetworkManager applet";
        PartOf = [ "hyprland-session.target" ];
        After = [ "hyprland-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.networkmanagerapplet}/bin/nm-applet --indicator";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install.WantedBy = [ "hyprland-session.target" ];
    };

    "wl-paste-cliphist" = {
      Unit = {
        Description = "Clipboard history store (wl-paste --watch cliphist)";
        PartOf = [ "hyprland-session.target" ];
        After = [ "hyprland-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install.WantedBy = [ "hyprland-session.target" ];
    };
  };

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
