# tmux.nix — tmux multiplexer: keybinds, plugins, session restore.
#
# Status-bar colors come from theme.colors; all the keybinding/plugin logic
# is theming-free.
{ pkgs, theme, ... }: {
  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    terminal = "tmux-256color";
    historyLimit = 10000;
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";

    plugins = with pkgs; [
      tmuxPlugins.resurrect
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5'
        '';
      }
      {
        # Fuzzy session manager popup: switch/create/rename/kill sessions.
        plugin = tmuxPlugins.tmux-sessionx;
        extraConfig = ''
          set -g @sessionx-bind 'o'
        '';
      }
    ];

    extraConfig = ''
      # ---- Resurrect: что именно сохранять ----
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-strategy-nvim 'session'

      set -g renumber-windows on
      set -g focus-events on
      setw -g pane-base-index 1

      set -ga terminal-overrides ",xterm-256color:Tc"

      set -s extended-keys on
      set -as terminal-features 'xterm-kitty*:extkeys'

      # ---- Разбиение окон ----
      unbind '"'
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      bind c new-window -c "#{pane_current_path}"

      # ---- Навигация по панелям (vim-style) ----
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

      bind-key -r f run-shell "tmux neww tmux-sessionizer"

      # ---- Статус-бар: стиль catppuccin-tmux (omerxx), цвета из theme ----
      # Скруглённые сегменты: слева сессия, окна с номером-плашкой справа,
      # справа модули (директория / дата-время / хост).
      set -g status-position top
      set -g status-justify left
      set -g status-style "bg=#${theme.colors.bg},fg=#${theme.colors.fg}"
      set -g status-left-length 100
      set -g status-right-length 100

      # Сессия: чип зелёный, при зажатом префиксе краснеет
      set -g status-left "#[fg=#{?client_prefix,#${theme.colors.error},#${theme.colors.success}},bg=#${theme.colors.bg}]#[fg=#${theme.colors.bg},bg=#{?client_prefix,#${theme.colors.error},#${theme.colors.success}}] #[fg=#${theme.colors.fg},bg=#${theme.colors.surface}] #S#[fg=#${theme.colors.surface},bg=#${theme.colors.bg}]"

      setw -g window-status-separator ""
      setw -g window-status-style "fg=#${theme.colors.fg},bg=#${theme.colors.bg},none"
      setw -g window-status-activity-style "fg=#${theme.colors.fg},bg=#${theme.colors.bg},none"

      # Неактивное окно: капсула surface + синяя плашка номера справа
      setw -g window-status-format "#[fg=#${theme.colors.surface},bg=#${theme.colors.bg},nobold,nounderscore,noitalics]#[fg=#${theme.colors.fg},bg=#${theme.colors.surface}]#W#[fg=#${theme.colors.blue},bg=#${theme.colors.surface}] █#[fg=#${theme.colors.surface},bg=#${theme.colors.blue}]#I#[fg=#${theme.colors.blue},bg=#${theme.colors.bg}] "
      # Активное окно: имя на фоне бара + оранжевая плашка номера, индикатор зума
      setw -g window-status-current-format "#[fg=#${theme.colors.fg},bg=#${theme.colors.bg}]#W#{?window_zoomed_flag,(,)}#[fg=#${theme.colors.accent},bg=#${theme.colors.bg}] █#[fg=#${theme.colors.bg},bg=#${theme.colors.accent}]#I#[fg=#${theme.colors.accent},bg=#${theme.colors.bg}] "

      # Модули справа: иконка-чип + серый сегмент текста
      set -g status-right "#[fg=#${theme.colors.magenta},bg=#${theme.colors.bg}]#[fg=#${theme.colors.bg},bg=#${theme.colors.magenta}] #[fg=#${theme.colors.fg},bg=#${theme.colors.surface}] #{b:pane_current_path}#[fg=#${theme.colors.surface},bg=#${theme.colors.bg}]#[fg=#${theme.colors.accent-bright},bg=#${theme.colors.bg}]#[fg=#${theme.colors.bg},bg=#${theme.colors.accent-bright}] #[fg=#${theme.colors.fg},bg=#${theme.colors.surface}] %d.%m %H:%M#[fg=#${theme.colors.surface},bg=#${theme.colors.bg}]#[fg=#${theme.colors.blue},bg=#${theme.colors.bg}]#[fg=#${theme.colors.bg},bg=#${theme.colors.blue}] #[fg=#${theme.colors.fg},bg=#${theme.colors.surface}] #h#[fg=#${theme.colors.surface},bg=#${theme.colors.bg}]"

      set -g pane-border-style "fg=#${theme.colors.surface}"
      set -g pane-active-border-style "fg=#${theme.colors.blue}"

      set -g message-style "fg=#${theme.colors.cyan},bg=#${theme.colors.surface},align=centre"
      set -g message-command-style "fg=#${theme.colors.cyan},bg=#${theme.colors.surface},align=centre"
      setw -g mode-style "fg=#${theme.colors.magenta},bg=#${theme.colors.grey},bold"

      # ---- Автосохранение сессии при отключении (prefix+d и любой detach) ----
      set-hook -g client-detached 'run-shell -b "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh"'
    '';
  };
}
