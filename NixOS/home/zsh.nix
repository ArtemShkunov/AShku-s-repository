# home.nix (или фрагмент, который нужно импортировать в твой существующий home.nix)
{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    # ===================== История =====================
    history = {
      size = 1000;
      save = 2000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      ignoreSpace = true;
      append = true;
      share = false; # аналог обычного APPEND_HISTORY, без "живого" шаринга между сессиями
    };

    # ===================== oh-my-zsh =====================
    oh-my-zsh = {
      enable = true;
      # Тему не подключаем - используем свой кастомный promt ниже.
      theme = "";
      plugins = [
        "git"
        "sudo"
      ];
    };

    # ===================== плагины подсветки/автодополнения =====================
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
    ];

    # ===================== опции shell (аналог shopt/setopt из bashrc) =====================
    setOptions = [
      "EXTENDED_GLOB"       # аналог shopt -s globstar
      "HIST_IGNORE_DUPS"
      "HIST_IGNORE_SPACE"
      "APPEND_HISTORY"
      "INC_APPEND_HISTORY"
      "PROMPT_SUBST"        # нужно для кастомного promt
    ];

    # ===================== алиасы =====================
    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l  = "ls -CF";
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
      alert = ''notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e 's/^\\s*[0-9]\\+\\s*//;s/[;&|]\\s*alert$//')"'';
      ramus = "/home/artemmkk-sh/.local/opt/ramus/start.sh";
    };

    # ===================== весь кастомный promt и git-функция =====================
    initExtra = ''
      # ---- Логика Git: получение ветки со значком, статуса или хеша ----
      __git_prompt_info() {
          if git rev-parse --git-dir > /dev/null 2>&1; then
              local branch
              branch=$(git branch --show-current 2>/dev/null)
              [ -z "$branch" ] && branch=$(git rev-parse --short HEAD 2>/dev/null)

              local status_info=""
              local git_status
              git_status=$(git status --porcelain 2>/dev/null)

              [[ "$git_status" =~ ^([MADRC].|.[MADRC]) ]] && status_info+=" "
              [[ "$git_status" =~ ^( .[MTADRC]) ]] && status_info+=" "
              [[ "$git_status" =~ ^( .[D]) ]] && status_info+=" "
              [[ "$git_status" =~ (UU|AA|DD|AU|UA|UD|DU) ]] && status_info+=" "
              [[ "$git_status" =~ '\?\?' ]] && status_info+=" "

              local upstream
              upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
              if [ -n "$upstream" ]; then
                  local counts ahead behind
                  counts=$(git rev-list --left-right --count HEAD...$upstream 2>/dev/null)
                  ahead=$(echo $counts | awk '{print $1}')
                  behind=$(echo $counts | awk '{print $2}')

                  if [[ -n "$ahead" && "$ahead" -gt 0 ]]; then status_info+=" "; fi
                  if [[ -n "$behind" && "$behind" -gt 0 ]]; then status_info+=" "; fi
              fi

              echo "󰊢  ''${branch}''${status_info}"
          fi
      }

      # ---- Основная функция формирования приглашения ----
      set_custom_prompt() {
          local EXIT=$?

          local COLOR_USER="133;46;25"
          local COLOR_PATH="170;30;20"
          local COLOR_GIT="210;50;15"
          local COLOR_TIME="219;80;11"

          local FRAME ERR
          if [ "$EXIT" -eq 0 ]; then
              FRAME=$'%{\e[1;32m%}'
              ERR=""
          else
              FRAME=$'%{\e[1;31m%}'
              ERR=" %{\e[38;5;52m%}✗ $EXIT%{\e[0m%}"
          fi

          local GIT_CONTENT
          GIT_CONTENT=$(__git_prompt_info)

          local IND_S="''${FRAME}┌─"
          local IND_E="''${FRAME}└─╼"

          local P="''${IND_S}"
          P+="%{\e[38;2;''${COLOR_USER}m%}"
          P+="%{\e[1;97;48;2;''${COLOR_USER}m%} %n "
          P+="%{\e[38;2;''${COLOR_USER};48;2;''${COLOR_PATH}m%}"
          P+="%{\e[1;97;48;2;''${COLOR_PATH}m%} %~ "
          P+="%{\e[38;2;''${COLOR_PATH};48;2;''${COLOR_GIT}m%}"
          if [ -n "$GIT_CONTENT" ]; then
              P+="%{\e[1;97;48;2;''${COLOR_GIT}m%} ''${GIT_CONTENT} "
          else
              P+="%{\e[1;97;48;2;''${COLOR_GIT}m%}"
          fi
          P+="%{\e[38;2;''${COLOR_GIT};48;2;''${COLOR_TIME}m%}"
          P+="%{\e[1;97;48;2;''${COLOR_TIME}m%} %* "
          P+="%{\e[0;38;2;''${COLOR_TIME}m%}%{\e[0m%}"

          P+="''${ERR}
"
          P+="''${IND_E}''${FRAME} %{\e[0m%}"

          PROMPT="$P"
      }

      autoload -Uz add-zsh-hook
      add-zsh-hook precmd set_custom_prompt

      case "$TERM" in
          xterm*|rxvt*)
              precmd_title() {
                  print -Pn "\e]0;%n@%m: %~\a"
              }
              add-zsh-hook precmd precmd_title
              ;;
      esac
    '';
  };

  # Nerd Font с иконками  и 󰊢 - без него promt покажет квадратики
  home.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
}
