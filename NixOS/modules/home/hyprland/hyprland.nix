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

  # Бинды переключения на рабочие столы 1-9 в Lua-идиоме.
  workspaceBinds = builtins.concatLists (
    map (i: [
      {
        _args = [
          (mkLuaInline "mod .. \" + ${toString i}\"")
          (mkLuaInline "hl.dsp.focus({ workspace = ${toString i} })")
          { description = "Workspace ${toString i}"; }
        ];
      }
      {
        _args = [
          (mkLuaInline "mod .. \" + SHIFT + ${toString i}\"")
          (mkLuaInline "hl.dsp.window.move({ workspace = ${toString i} })")
          { description = "Move window to workspace ${toString i}"; }
        ];
      }
      {
        _args = [
          (mkLuaInline "mod .. \" + KP_${toString i}\"")
          (mkLuaInline "hl.dsp.focus({ workspace = ${toString i} })")
          { description = "Workspace ${toString i} (numpad)"; }
        ];
      }
      {
        _args = [
          (mkLuaInline "mod .. \" + SHIFT + KP_${toString i}\"")
          (mkLuaInline "hl.dsp.window.move({ workspace = ${toString i} })")
          { description = "Move window to workspace ${toString i} (numpad)"; }
        ];
      }
    ]) (lib.range 1 9)
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

      # Трёхпальцевый горизонтальный свайп по тачпаду переключает рабочие столы.
      gesture = {
        fingers = 3;
        direction = "horizontal";
        action = "workspace";
      };

      bind = [
        {
          _args = [
            (mkLuaInline "mod .. \" + Q\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"kitty\")")
            { description = "Terminal"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + C\"")
            (mkLuaInline "hl.dsp.window.close()")
            { description = "Close window"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + M\"")
            (mkLuaInline "hl.dsp.exit()")
            { description = "Exit Hyprland"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + E\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"thunar\")")
            { description = "File manager"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + V\"")
            (mkLuaInline "hl.dsp.window.float({ action = \"toggle\" })")
            { description = "Toggle floating"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + F\"")
            (mkLuaInline "hl.dsp.window.fullscreen({ action = \"toggle\" })")
            { description = "Toggle fullscreen"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + R\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"fuzzel\")")
            { description = "Application launcher"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + P\"")
            (mkLuaInline "hl.dsp.window.pseudo()")
            { description = "Toggle pseudotile"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + J\"")
            (mkLuaInline "hl.dsp.layout(\"togglesplit\")")
            { description = "Toggle split direction"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + L\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"hyprlock\")")
            { description = "Lock screen"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + SHIFT + V\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"clipboard-history\")")
            { description = "Clipboard history"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + H\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"shortcuts\")")
            { description = "Keyboard shortcuts"; }
          ];
        }
        {
          _args = [
            "Print"
            (mkLuaInline "hl.dsp.exec_cmd(\"grim -g \\\"$(slurp)\\\" - | wl-copy\")")
            { description = "Screenshot region"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + left\"")
            (mkLuaInline "hl.dsp.focus({ direction = \"left\" })")
            { description = "Focus left"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + right\"")
            (mkLuaInline "hl.dsp.focus({ direction = \"right\" })")
            { description = "Focus right"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + up\"")
            (mkLuaInline "hl.dsp.focus({ direction = \"up\" })")
            { description = "Focus up"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + down\"")
            (mkLuaInline "hl.dsp.focus({ direction = \"down\" })")
            { description = "Focus down"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + CTRL + left\"")
            (mkLuaInline "hl.dsp.focus({ workspace = \"e-1\" })")
            { description = "Previous workspace"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + CTRL + right\"")
            (mkLuaInline "hl.dsp.focus({ workspace = \"e+1\" })")
            { description = "Next workspace"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + ALT + left\"")
            (mkLuaInline "hl.dsp.window.swap({ direction = \"left\" })")
            { description = "Swap window left"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + ALT + right\"")
            (mkLuaInline "hl.dsp.window.swap({ direction = \"right\" })")
            { description = "Swap window right"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + ALT + up\"")
            (mkLuaInline "hl.dsp.window.swap({ direction = \"up\" })")
            { description = "Swap window up"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + ALT + down\"")
            (mkLuaInline "hl.dsp.window.swap({ direction = \"down\" })")
            { description = "Swap window down"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "\"ALT + Tab\"")
            (mkLuaInline "hl.dsp.window.cycle_next()")
            { description = "Next window"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "\"ALT + SHIFT + Tab\"")
            (mkLuaInline "hl.dsp.window.cycle_next({ next = false })")
            { description = "Previous window"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + SHIFT + F\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"firefox\")")
            { description = "Firefox"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + T\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"Throne\")")
            { description = "Throne"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + N\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"pkill hyprsunset || hyprsunset -t 3500\")")
            { description = "Toggle night light"; }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + B\"")
            (mkLuaInline "hl.dsp.exec_cmd(\"default-browser\")")
            { description = "Default browser"; }
          ];
        }

        # bindm — перемещение/ресайз окна мышью
        {
          _args = [
            (mkLuaInline "mod .. \" + mouse:272\"")
            (mkLuaInline "hl.dsp.window.drag()")
            {
              mouse = true;
              description = "Move window with mouse";
            }
          ];
        }
        {
          _args = [
            (mkLuaInline "mod .. \" + mouse:273\"")
            (mkLuaInline "hl.dsp.window.resize()")
            {
              mouse = true;
              description = "Resize window with mouse";
            }
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
              description = "Brightness down";
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
              description = "Brightness up";
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
              description = "Volume down";
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
              description = "Volume up";
            }
          ];
        }

        # bindl — залоченные (locked)
        {
          _args = [
            "XF86AudioMute"
            (mkLuaInline "hl.dsp.exec_cmd(\"pamixer -t\")")
            {
              locked = true;
              description = "Mute output";
            }
          ];
        }
        {
          _args = [
            "XF86AudioMicMute"
            (mkLuaInline "hl.dsp.exec_cmd(\"pamixer --default-source -t\")")
            {
              locked = true;
              description = "Mute microphone";
            }
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
