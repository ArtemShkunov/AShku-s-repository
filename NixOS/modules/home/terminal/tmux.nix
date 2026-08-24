# tmux.nix — tmux multiplexer: keybinds, plugins, session restore.
#
# Status-bar colors come from theme.colors; all the keybinding/plugin logic
# is theming-free.
{
  pkgs,
  config,
  theme,
  ...
}:

let
  # Диагностика восстановления процессов tmux-resurrect: хуки логируют
  # состояние на каждой фазе restore (какой last-файл читается, что лежит
  # в @resurrect-processes, какие команды вообще считаются восстанавли-
  # ваемыми) — чтобы поймать момент, где процессы перестают восстанавли-
  # ваться.
  resurrect-debug = pkgs.writeShellScriptBin "resurrect-debug" ''
    phase="''${1:-unknown}"
    log_dir="$HOME/.cache/resurrect"
    log="$log_dir/debug.log"
    last="$HOME/.tmux/resurrect/last"
    mkdir -p "$log_dir"
    {
      printf '[%s] phase=%s\n' "$(${pkgs.coreutils}/bin/date '+%F %T.%N')" "$phase"
      printf '  last=%s\n' "$(${pkgs.coreutils}/bin/readlink "$last" 2>/dev/null || echo missing)"
      printf '  processes_opt=[%s]\n' "$(${pkgs.tmux}/bin/tmux show-options -gv @resurrect-processes 2>/dev/null)"
      printf '  panes_now=%s\n' "$(${pkgs.tmux}/bin/tmux list-panes -a 2>/dev/null | ${pkgs.coreutils}/bin/wc -l)"
      if [ -f "$last" ]; then
        ${pkgs.gawk}/bin/awk -F '\t' \
          '$1 == "pane" && $11 !~ /^:$/ { printf "  restorable %s:%s.%s cmd=%s\n", $2, $3, $6, $11 }' "$last"
      fi
    } >> "$log"
  '';

  # Путь к скрипту плагина. ВАЖНО: nixpkgs кладёт плагин в
  # share/tmux-plugins/<pluginName>, где pluginName = "sessionx"
  # (без префикса "tmux-"), поэтому сегмент берём из .pluginName.
  sessionxScript = "${pkgs.tmuxPlugins.tmux-sessionx}/share/tmux-plugins/${pkgs.tmuxPlugins.tmux-sessionx.pluginName}/scripts/sessionx.sh";

  # Вотер для запуска ВНЕ tmux: он выполняется как команда панели сессии-
  # лаунчера, поэтому у процесса есть и $TMUX, и pty — без них fzf-tmux не
  # может привязать popup к клиенту (проверено: фоновый подшелл из обёртки
  # рисует popup «в никуда»). Ждём attach до 10с, открываем popup, убираем
  # лаунчер.
  tmux-sessionx-wait = pkgs.writeShellScript "tmux-sessionx-wait" ''
    launch="_sessionx-launch"
    n=0
    until [[ -n $(${pkgs.tmux}/bin/tmux list-clients -t "$launch" 2> /dev/null) ]]; do
      n=$((n + 1))
      if [ "$n" -gt 200 ]; then
        ${pkgs.tmux}/bin/tmux kill-session -t "$launch" 2> /dev/null
        exit 0
      fi
      ${pkgs.coreutils}/bin/sleep 0.05
    done
    "${sessionxScript}"
    ${pkgs.tmux}/bin/tmux kill-session -t "$launch" 2> /dev/null
  '';

  # Обёртка для вызова popup-менеджера сессий tmux-sessionx.
  #
  # Внутри tmux просто запускаем скрипт плагина. Вне tmux sessionx не может
  # нарисовать popup (display-popup требует клиента), поэтому обёртка создаёт
  # одноразовую сессию-лаунчер (её панель запускает tmux-sessionx-wait),
  # аттачится к ней и получает popup поверх себя: выбор проекта делает
  # switch-client, и клиент остаётся в tmux уже в выбранной сессии; Esc убивает
  # лаунчер и возвращает в голый шелл.
  tmux-sessionx = pkgs.writeShellScriptBin "tmux-sessionx" ''
    if [[ -n "''${TMUX:-}" ]]; then
      exec "${sessionxScript}"
    fi

    launch="_sessionx-launch"
    ${pkgs.tmux}/bin/tmux kill-session -t "$launch" 2> /dev/null
    ${pkgs.tmux}/bin/tmux new-session -d -s "$launch" -c "''${PWD:-$HOME}" "${tmux-sessionx-wait}"

    exec ${pkgs.tmux}/bin/tmux attach -t "$launch"
  '';
in
{
  home.packages = [ tmux-sessionx ];

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
        # Опции resurrect задаются ДО загрузки кода самих плагинов: continuum
        # запускает авто-восстановление через 1 секунду после парсинга своей
        # строки конфига, поэтому всё, что читается во время restore
        # (@resurrect-processes и хуки ниже), должно быть выставлено раньше.
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-strategy-nvim 'session'
          # nvim в ps виден как полный /nix/store/... путь (wrapper делает exec), поэтому
          # обычный матч по слову "nvim" не срабатывает — ~-регэксп ловит путь, а "->"
          # переписывает команду обратно в голый `nvim`, чтобы сработала 'session'-стратегия.
          set -g @resurrect-processes 'btop opencode "~nvim->nvim"'
          # ВРЕМЕННО: диагностика фаз восстановления (см. ~/.cache/resurrect/debug.log)
          set -g @resurrect-hook-pre-restore-all '${resurrect-debug}/bin/resurrect-debug pre-restore-all'
          set -g @resurrect-hook-pre-restore-pane-processes '${resurrect-debug}/bin/resurrect-debug pre-pane-processes'
          set -g @resurrect-hook-post-restore-all '${resurrect-debug}/bin/resurrect-debug post-restore-all'
        '';
      }
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
          # Список каталогов для создания новых сессий (замена поведения
          # старого tmux-sessionizer): подкаталоги ~/Projects попадают в popup.
          set -g @sessionx-custom-paths '${config.home.homeDirectory}/Projects'
          set -g @sessionx-custom-paths-subdirectories 'true'
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

      bind-key -r f run-shell "${sessionxScript}"

      # ---- Статус-бар: стиль catppuccin-tmux (omerxx), цвета из theme ----
      # Скруглённые сегменты: слева сессия, окна с номером-плашкой справа,
      # справа модули (директория / дата-время / хост).
      set -g status-position top
      set -g status-justify left
      set -g status-style "bg=#${theme.colors.bg},fg=#${theme.colors.fg}"
      set -g status-left-length 150
      set -g status-right-length 150

      # Сессия: пилюля [ ][иконка][ #S ], зелёная/красная при зажатом префиксе
      set -g status-left "#[fg=#{?client_prefix,#${theme.colors.error},#${theme.colors.success}},bg=#${theme.colors.bg},nobold,nounderscore,noitalics] #[fg=#${theme.colors.bg},bg=#{?client_prefix,#${theme.colors.error},#${theme.colors.success}},nobold,nounderscore,noitalics] #[fg=#${theme.colors.fg},bg=#${theme.colors.surface}] #S#[fg=#${theme.colors.surface},bg=#${theme.colors.bg},nobold,nounderscore,noitalics] "

      setw -g window-status-separator ""
      setw -g window-status-style "fg=#${theme.colors.fg},bg=#${theme.colors.bg},none"
      setw -g window-status-activity-style "fg=#${theme.colors.fg},bg=#${theme.colors.bg},none"

      # Неактивное окно: одна пилюля [ имя █ номер ], закрыта с обеих сторон
      setw -g window-status-format "#[fg=#${theme.colors.surface},bg=#${theme.colors.bg},nobold,nounderscore,noitalics]#[fg=#${theme.colors.fg},bg=#${theme.colors.surface}]#W#[fg=#${theme.colors.blue},bg=#${theme.colors.surface},nobold,nounderscore,noitalics] █#[fg=#${theme.colors.surface},bg=#${theme.colors.blue}]#I#[fg=#${theme.colors.blue},bg=#${theme.colors.bg}] "
      # Активное окно: левый край слит с фоном бара (fg=bg=bg — капсула "открыта"), номер — акцентный
      setw -g window-status-current-format "#[fg=#${theme.colors.bg},bg=#${theme.colors.bg},nobold,nounderscore,noitalics]#[fg=#${theme.colors.fg},bg=#${theme.colors.bg}]#W#{?window_zoomed_flag,(),}#[fg=#${theme.colors.accent},bg=#${theme.colors.bg},nobold,nounderscore,noitalics] █#[fg=#${theme.colors.bg},bg=#${theme.colors.accent}]#I#[fg=#${theme.colors.accent},bg=#${theme.colors.bg}] "

      # Модули справа: те же пилюли [ иконка текст ]
      set -g status-right "#[fg=#${theme.colors.magenta},bg=#${theme.colors.bg},nobold,nounderscore,noitalics] #[fg=#${theme.colors.bg},bg=#${theme.colors.magenta},nobold,nounderscore,noitalics] #[fg=#${theme.colors.fg},bg=#${theme.colors.surface}] #{b:pane_current_path}#[fg=#${theme.colors.surface},bg=#${theme.colors.bg},nobold,nounderscore,noitalics] #[fg=#${theme.colors.accent-bright},bg=#${theme.colors.bg},nobold,nounderscore,noitalics] #[fg=#${theme.colors.bg},bg=#${theme.colors.accent-bright},nobold,nounderscore,noitalics] #[fg=#${theme.colors.fg},bg=#${theme.colors.surface}] %d.%m %H:%M#[fg=#${theme.colors.surface},bg=#${theme.colors.bg},nobold,nounderscore,noitalics] #[fg=#${theme.colors.blue},bg=#${theme.colors.bg},nobold,nounderscore,noitalics] #[fg=#${theme.colors.bg},bg=#${theme.colors.blue},nobold,nounderscore,noitalics]󰇅 #[fg=#${theme.colors.fg},bg=#${theme.colors.surface}] #h#[fg=#${theme.colors.surface},bg=#${theme.colors.bg},nobold,nounderscore,noitalics] "

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
