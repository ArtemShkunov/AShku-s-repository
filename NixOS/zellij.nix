{ pkgs, ... }:
{
  programs.zellij = {
    enable = true;
    # Точка входа — zellij-sessionizer, а не автозапуск home-manager.
    enableZshIntegration = false;
  };

  home.packages = [ pkgs.zellij ];

  # config.kdl пишем руками, а не через programs.zellij.settings:
  # nix->kdl генератор home-manager на сегодня ломается на вложенных
  # keybinds (https://github.com/NixOS/nixpkgs/issues/444111) — тот же
  # принцип, что и в старом tmux.nix: extraConfig/xdg.configFile
  # надёжнее декларативного генератора, когда у него известные баги.
  xdg.configFile."zellij/config.kdl".text = ''
    // ---- Общие настройки (аналоги опций из старого tmux.nix) ----
    default_shell "zsh"
    theme "sunset-pines"
    mouse_mode true
    copy_on_select true
    scroll_buffer_size 10000

    ui {
        pane_frames {
            rounded_corners true
        }
    }

    // ---- Встроенная сериализация сессий ----
    // Аналог tmux-resurrect + continuum, но без внешних плагинов —
    // Zellij сам сохраняет и восстанавливает раскладку панелей/вкладок.
    session_serialization true
    pane_viewport_serialization true
    scrollback_lines_to_serialize 10000

    // ---- Sunset Pines ----
    // fg/bg/black/white и orange/yellow/red — прямо из твоей палитры.
    // green/blue/magenta/cyan там не были заданы (в статус-баре tmux
    // их не было), тут это приглушённые оттенки под тёплую
    // navy-purple/orange гамму — поправь на свой вкус.
    themes {
        sunset-pines {
            fg      "#f5e9dc"
            bg      "#16141f"
            black   "#241f30"
            red     "#e8613c"
            green   "#7c9473"
            yellow  "#f7ce68"
            blue    "#6d7fb3"
            magenta "#c96f8c"
            cyan    "#6fa8a0"
            white   "#fff8f0"
            orange  "#f2994a"
        }
    }

    // ---- Keybinds ----
    // Не чистим default-бинды (никаких clear-defaults) — Ctrl+p/t/n/s/o
    // и остальные встроенные режимы (resize/scroll/rename/search)
    // остаются доступны, добавляем только то, что упрощает частые
    // операции без входа в под-режим.
    keybinds {
        normal {
            // Разбиение окон (аналог bind | / bind -)
            bind "Alt |" { NewPane "Right"; }
            bind "Alt -" { NewPane "Down"; }
            bind "Alt c" { NewTab; }

            // Навигация по панелям, vim-style (аналог h/j/k/l)
            // Alt+h/Alt+Left и т.п. уже смэплены по умолчанию на
            // MoveFocusOrTab — тут просто явно фиксируем поведение.
            bind "Alt h" { MoveFocus "Left"; }
            bind "Alt j" { MoveFocus "Down"; }
            bind "Alt k" { MoveFocus "Up"; }
            bind "Alt l" { MoveFocus "Right"; }

            // Resize (аналог bind -r H/J/K/L)
            bind "Alt Shift h" { Resize "Increase Left"; }
            bind "Alt Shift j" { Resize "Increase Down"; }
            bind "Alt Shift k" { Resize "Increase Up"; }
            bind "Alt Shift l" { Resize "Increase Right"; }
        }

        shared_except "locked" {
            // У Zellij нет живого switch-client — Ctrl+f делает Detach
            // и возвращает в fzf-пикер zellij-sessionizer, если именно
            // он был точкой входа в терминал (см. sessionizer.nix).
            bind "Ctrl f" { Detach; }

            // Встроенный Session Manager — ближайший к tmux
            // switch-client способ прыгать МЕЖДУ уже запущенными
            // сессиями изнутри Zellij, без detach.
            bind "Ctrl o" { LaunchOrFocusPlugin "session-manager" {
                floating true
                move_to_focused_tab true
            }; }
        }
    }
  '';

  # default.kdl в ~/.config/zellij/layouts переопределяет встроенный
  # default-layout Zellij. Тут одна панель zjstatus сверху, заменяющая
  # tab-bar И status-bar разом — тот самый "один статус-лайн только
  # сверху", как в tmux status-style.
  xdg.configFile."zellij/layouts/default.kdl".text = ''
    layout {
        default_tab_template {
            pane size=2 borderless=true {
                // Если pkgs.zellijPlugins.zjstatus не резолвится в
                // твоём пине nixpkgs — см. вариант через flake-input
                // в комментарии внизу этого файла.
                plugin location="file:${pkgs.zellijPlugins.zjstatus}/bin/zjstatus.wasm" {
                    format_left   "#[fg=#16141f,bg=#f2994a,bold]  {session} #[fg=#f2994a,bg=#16141f]"
                    format_center "{tabs}"
                    format_right  "#[fg=#f5e9dc,bg=#16141f]  {command_cwd} #[fg=#4a3b4f,bg=#16141f]│ #[fg=#f5e9dc,bg=#16141f] {datetime}#[fg=#4a3b4f,bg=#16141f]│ #[fg=#f5e9dc,bg=#16141f] {command_host} #[fg=#4a3b4f,bg=#16141f]│ #[fg=#f5e9dc,bg=#16141f] {command_user} "
                    format_space  " "

                    border_enabled "false"
                    hide_frame_for_single_pane "true"

                    // window-status-current-format / window-status-format
                    tab_normal    "#[fg=#f5e9dc,bg=#16141f] {index}->{name} "
                    tab_active    "#[fg=#16141f,bg=#f7ce68,bold] {index}->{name} #[fg=#f7ce68,bg=#16141f]"
                    tab_separator ""

                    // status-right: путь | дата время | хост | юзер
                    datetime          "{format}"
                    datetime_format   "%d.%m %H:%M"
                    datetime_timezone "Europe/Moscow"

                    command_cwd_command  "bash -c 'basename \"$PWD\"'"
                    command_cwd_cwd      "{focused_pane_cwd}"
                    command_cwd_format   "{stdout}"
                    command_cwd_interval "1"

                    command_host_command  "hostname"
                    command_host_format   "{stdout}"
                    command_host_interval "0"

                    command_user_command  "whoami"
                    command_user_format   "{stdout}"
                    command_user_interval "0"
                }
            }
            children
        }
    }
  '';

  # ---- Если pkgs.zellijPlugins.zjstatus не резолвится ----
  # Значит его нет в твоём пине nixpkgs. Тогда в flake.nix:
  #
  #   inputs.zjstatus = {
  #     url = "github:dj95/zjstatus";
  #     inputs.nixpkgs.follows = "nixpkgs";
  #   };
  #
  # и добавить оверлей рядом с остальными твоими overlay:
  #
  #   (final: prev: { zjstatus = inputs.zjstatus.packages.${prev.system}.default; })
  #
  # — и в layout-файле заменить `pkgs.zellijPlugins.zjstatus`
  #   на `pkgs.zjstatus`.
}
