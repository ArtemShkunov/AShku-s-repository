{ pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    enableZshIntegration = true; # или enableZshIntegration / enableFishIntegration
  };

  # 1. Основной конфиг Zellij (~/.config/zellij/config.kdl)
  xdg.configFile."zellij/config.kdl".text = ''
    theme "custom-tmux"

    themes {
      custom-tmux {
        bg "#16141f"
        fg "#f5e9dc"
        black "#16141f"
        red "#e06c75"
        green "#98c379"
        yellow "#f7ce68"
        blue "#61afef"
        magenta "#c678dd"
        cyan "#56b6c2"
        white "#f5e9dc"
        orange "#f2994a"
      }
    }

    default_mode "normal"
    mouse_mode true
    copy_clipboard "system"
    pane_frames false

    ui {
      pane_frames {
        rounded_corners true
        hide_session_name true
      }
    }

    keybinds clear-defaults=true {
      // Основной режим с прямыми хоткеями
      normal {
        // Вызов zellij-sessionizer во всплывающем окне по Ctrl+f
        bind "Ctrl f" {
          Run "zellij-sessionizer" {
            floating true
            close_on_exit true
            height "60%"
            width "60%"
            x "20%"
            y "20%"
          }
        }

        // Навигация по панелям (Vim-style)
        bind "Alt h" "Left" { MoveFocus "Left"; }
        bind "Alt j" "Down" { MoveFocus "Down"; }
        bind "Alt k" "Up" { MoveFocus "Up"; }
        bind "Alt l" "Right" { MoveFocus "Right"; }

        // Изменение размеров панелей
        bind "Alt H" { Resize "Increase Left"; }
        bind "Alt J" { Resize "Increase Down"; }
        bind "Alt K" { Resize "Increase Up"; }
        bind "Alt L" { Resize "Increase Right"; }

        // Разделение панелей (| и -)
        bind "Alt |" { NewPane "Right"; }
        bind "Alt -" { NewPane "Down"; }

        // Создание новой вкладки
        bind "Alt c" { NewTab; }

        // Отключение от сессии (detach)
        bind "Alt d" { Detach; }

        // Вход в служебные режимы Zellij
        bind "Ctrl p" { SwitchToMode "Pane"; }
        bind "Ctrl t" { SwitchToMode "Tab"; }
        bind "Ctrl o" { SwitchToMode "Session"; }
        bind "Ctrl s" { SwitchToMode "Scroll"; }
      }

      // Эмуляция Tmux Prefix режима (Ctrl+b)
      tmux {
        bind "f" {
          Run "zellij-sessionizer" {
            floating true
            close_on_exit true
            height "60%"
            width "60%"
            x "20%"
            y "20%"
          }
          SwitchToMode "Normal";
        }
        bind "|" { NewPane "Right"; SwitchToMode "Normal"; }
        bind "-" { NewPane "Down"; SwitchToMode "Normal"; }
        bind "c" { NewTab; SwitchToMode "Normal"; }
        bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
        bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
        bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }
        bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
        bind "d" { Detach; }
        bind "Esc" { SwitchToMode "Normal"; }
      }

      shared_except "tmux" "locked" {
        bind "Ctrl b" { SwitchToMode "Tmux"; }
      }
    }
  '';

  # 2. Лейаут статус-бара (~/.config/zellij/layouts/default.kdl)
  xdg.configFile."zellij/layouts/default.kdl".text = ''
    layout {
      default_tab_template {
        children
        pane size=1 borderless=true {
          plugin location="https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm" {
            format_left  "#[bg=#f2994a,fg=#16141f,bold]  {session} #[bg=#16141f,fg=#f2994a] {tabs}"
            format_right "#[fg=#f5e9dc,bg=#16141f]   {command_path} #[fg=#6b6b80,bg=#16141f]| #[fg=#f5e9dc,bg=#16141f] {datetime} #[fg=#6b6b80,bg=#16141f]| #[fg=#f5e9dc,bg=#16141f] {command_host} #[fg=#6b6b80,bg=#16141f]| #[fg=#f5e9dc,bg=#16141f] {command_user} "
            format_space "#[bg=#16141f]"

            border_enabled "false"

            tab_normal   " #[fg=#f5e9dc,bg=#16141f] {index}->{name} "
            tab_active   "#[bg=#f7ce68,fg=#16141f,bold] {index}->{name} "

            command_path_command "basename $PWD"
            command_path_format "{output}"
            command_path_interval "1"

            command_host_command "hostname"
            command_host_format "{output}"
            command_host_interval "3600"

            command_user_command "whoami"
            command_user_format "{output}"
            command_user_interval "3600"

            datetime        "%d.%m %H:%M"
            datetime_format "{timestamp}"
          }
        }
      }
    }
  '';
}
