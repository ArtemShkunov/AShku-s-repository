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

      # ---- Статус-бар в цветах темы ----
      set -g status-style "bg=#${theme.colors.bg},fg=#${theme.colors.fg}"
      set -g status-left-length 40
      set -g status-left "#[fg=#${theme.colors.bg},bg=#${theme.colors.accent},bold]  #S #[fg=#${theme.colors.accent},bg=#${theme.colors.bg}]"
      setw -g window-status-current-format "#[fg=#${theme.colors.bg},bg=#${theme.colors.accent-bright},bold] #I->#W #[fg=#${theme.colors.accent-bright},bg=#${theme.colors.bg}]"
      setw -g window-status-format " #I->#W "

      set -g status-right-length 100
      set -g status-right "#[fg=#${theme.colors.fg},bg=#${theme.colors.bg}]   #{b:pane_current_path} #[fg=#${theme.colors.grey},bg=#${theme.colors.bg}]| #[fg=#${theme.colors.fg},bg=#${theme.colors.bg}] %d.%m %H:%M #[fg=#${theme.colors.grey},bg=#${theme.colors.bg}]| #[fg=#${theme.colors.fg},bg=#${theme.colors.bg}] #h #[fg=#${theme.colors.grey},bg=#${theme.colors.bg}]| #[fg=#${theme.colors.fg},bg=#${theme.colors.bg}] #(whoami) "

      set -g pane-border-style "fg=#${theme.colors.bg}"
      set -g pane-active-border-style "fg=#${theme.colors.accent}"

      set -g message-style "bg=#${theme.colors.accent},fg=#${theme.colors.bg}"

      # ---- Автосохранение сессии при отключении (prefix+d и любой detach) ----
      set-hook -g client-detached 'run-shell -b "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh"'
    '';
  };
}
