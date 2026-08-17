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

        plugins = with pkgs; [
            {
                plugin = tmuxPlugins.rose-pine;
                extraConfig = ''
set -g @rose_pine_variant 'moon' # Options are 'main', 'moon' or 'dawn'
set -g @rose_pine_host 'on' # Enables hostname in the status bar
set -g @rose_pine_date_time '%H:%M | %A, %d %b'
set -g @rose_pine_user 'on' # Turn on the username component in the statusbar
set -g @rose_pine_directory 'on' # Turn on the current folder component in the status bar

# set -g @rose_pine_bar_bg_disable 'on' 
# set -g @rose_pine_bar_bg_disabled_color_option 'xterm-256color'

set -g @rose_pine_window_tabs_enabled 'on'
set -g @rose_pine_window_status_separator " > " # Changes the default icon that appears between window names


set -g @rose_pine_left_separator ' ' # The strings to use as separators are 1-space padded
set -g @rose_pine_right_separator ' <- ' # Accepts both normal chars & nerdfont icons
set -g @rose_pine_field_separator ' > ' # Default is two-space-padded, but can be set to anything
set -g @rose_pine_window_separator ' -> ' # Replaces the default `:` between the window number and name

# These are not padded
set -g @rose_pine_session_icon '' # Changes the default icon to the left of the session name
set -g @rose_pine_current_window_icon '' # Changes the default icon to the left of the active window name
set -g @rose_pine_folder_icon ' ' # Changes the default icon to the left of the current directory folder
set -g @rose_pine_username_icon '' # Changes the default icon to the right of the hostname
set -g @rose_pine_hostname_icon '󰒋' # Changes the default icon to the right of the hostname
set -g @rose_pine_date_time_icon '󰃰' # Changes the default icon to the right of the date module

                '';
            }

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
      #
      # set -g status-style "bg=#16141f,fg=#f5e9dc"
      # set -g status-left-length 40
      # set -g status-left "#[fg=#16141f,bg=#f2994a,bold] #S #[fg=#f2994a,bg=#16141f]"
      # setw -g window-status-current-format "#[fg=#16141f,bg=#f7ce68,bold] #I:#W #[fg=#f7ce68,bg=#16141f]"
      # setw -g window-status-format " #I:#W "
      #
      set -g pane-border-style "fg=#16141f"
      set -g pane-active-border-style "fg=#f2994a"

      set -g message-style "bg=#f2994a,fg=#16141f"

      # ---- Автосохранение сессии при отключении (prefix+d и любой detach) ----
      set-hook -g client-detached 'run-shell -b "${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh"'
        '';
    };
}

