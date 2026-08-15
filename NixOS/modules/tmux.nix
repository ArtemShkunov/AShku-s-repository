{ pkgs, ... }:
{
    programs.tmux = {
        enable = true;
        package = pkgs.tmux;
        terminal = "tmux-256color";
        historyLimit = 10000;
        mouse = true;
        baseIndex = 1;
        escapeTime = 0;
        keyMode = "vi";

        extraConfig = ''
      # ---- Основные ----

      set -g renumber-windows on
      set -g focus-events on
      setw -g pane-base-index 1

      set -ga terminal-overrides ",xterm-256color:Tc"

      # ---- Разбиение окон ----
      unbind '"'
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # новое окно с текущей директорией
      bind c new-window -c "#{pane_current_path}"

      # ---- Навигация по панелям (vim-style) ----
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # ---- Изменение размера панелей ----
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # ---- Copy-mode в vi-стиле ----
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # ---- Перезагрузка конфига ----
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

      # ---- Sessionizer ----
      bind-key -r f run-shell "tmux neww tmux-sessionizer"

      # ---- Sunset Pines статус-бар ----
      set -g status-style "bg=#16141f,fg=#f5e9dc"
      set -g status-left-length 40
      set -g status-left "#[fg=#16141f,bg=#f2994a,bold] #S #[fg=#f2994a,bg=#16141f]"
      set -g status-right "#[fg=#f7ce68] %H:%M #[fg=#f5e9dc]│ %d-%b-%Y "
      setw -g window-status-current-format "#[fg=#16141f,bg=#f7ce68,bold] #I:#W #[fg=#f7ce68,bg=#16141f]"
      setw -g window-status-format " #I:#W "

      set -g pane-border-style "fg=#16141f"
      set -g pane-active-border-style "fg=#f2994a"

      set -g message-style "bg=#f2994a,fg=#16141f"
        '';
    };
}
