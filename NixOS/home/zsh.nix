# zsh.nix — модуль home-manager
{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    history = {
      size = 1000;
      save = 2000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      ignoreSpace = true;
      append = true;
      share = false;
    };

    oh-my-zsh = {
      enable = true;
      theme = "";
      plugins = [
        "git"
        "sudo"
      ];
    };

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

    setOptions = [
      "EXTENDED_GLOB"
      "HIST_IGNORE_DUPS"
      "HIST_IGNORE_SPACE"
      "APPEND_HISTORY"
      "INC_APPEND_HISTORY"
      "PROMPT_SUBST"
    ];

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

              # Используем классический символ ветки git
              echo " 󰊢 ''${branch}''${status_info} "
          fi
      }

      # ---- Основная функция формирования приглашения ----
      set_custom_prompt() {
          local EXIT=$?

          # Цвета секций (RGB)
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
              ERR=$' %{\e[38;5;52m%}✗ '"$EXIT"$'%{\e[0m%}'
          fi

          local GIT_CONTENT
          GIT_CONTENT=$(__git_prompt_info)

          local IND_S="''${FRAME}"$'┌─'
          local IND_E="''${FRAME}"$'└─'
          
          if [ -z "$GIT_CONTENT" ]; then
	   GIT_CONTENT=""
	  fi

          # --- СТРОКА 1 ---
          local P="''${IND_S}"

          # Секция 1: Пользователь (Начало с полукруга)
          P+=$'%{\e[38;2;'"''${COLOR_USER}"$'m%}'
          P+=$'%{\e[1;97;48;2;'"''${COLOR_USER}"$'m%}'"''${USER}"$' '

          # Переход: Секция 1 -> Секция 2 (Путь)
          P+=$'%{\e[38;2;'"''${COLOR_USER}"$';48;2;'"''${COLOR_PATH}"$'m%}'
          P+=$'%{\e[1;97;48;2;'"''${COLOR_PATH}"$'m%} %~ '


          P+=$'%{\e[38;2;'"''${COLOR_PATH}"$';48;2;'"''${COLOR_GIT}"$'m%}'
          P+=$'%{\e[1;97;48;2;'"''${COLOR_GIT}"$'m%}'"''${GIT_CONTENT}"$' '

          # Переход: Секция 3 -> Секция 4 (Время)
          P+=$'%{\e[38;2;'"''${COLOR_GIT}"$';48;2;'"''${COLOR_TIME}"$'m%}'

          # Секция 4: Время
          P+=$'%{\e[1;97;48;2;'"''${COLOR_TIME}"$'m%} %* '

          # Финальный треугольник: уходит в цвет фона (сброс цвета)
          P+=$'%{\e[0;38;2;'"''${COLOR_TIME}"$'m%}'$'%{\e[0m%}'

          # Ошибки и перенос
          P+="''${ERR}"$'\n'

          # --- СТРОКА 2 ---
          # Тонкая стрелка на конце рамки под цвет статуса выполнения
          P+="''${IND_E} ❯ "

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

  xfconf.settings.xfce4-terminal = {
    "font-name" = "FiraCode Nerd Font 14";
    "font-use-system" = false;
  };
}
