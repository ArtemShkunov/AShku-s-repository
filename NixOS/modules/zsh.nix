# zsh.nix — модуль home-manager
{ config, pkgs, ... }:

let
  # ---- Палитра Sunset Pines ----
  # "Sunset"-часть (как и раньше) — user / path / git / языки
  colorUser = "#852E19";
  colorPath = "#AA1E14";
  colorGit  = "#D2320F";
  colorLang = "#DB500B"; # бывшая секция времени, теперь — языки/версии

  # "Pines"-часть — новые правые секции: успех/shell зелёный (pine),
  # предупреждение о долгой команде — тёплый тёмно-красный
  colorSuccess  = "#6FAE7B";
  colorError    = "#C0392B";
  colorDuration = "#B2472E";
  colorShell    = "#6FAE7B";

  fgCream = "#FFF6EE"; # единый тёплый светлый текст на всех цветных секциях

  # ---- Иконки (Nerd Font) ----
  iconUser   = ""; # nf-fa-user
  iconFolder = ""; # nf-fa-folder-open
  arrow      = ""; # powerline-стрелка (nf-pl-right_hard_divider)

  ompSettings = {
    "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
    version = 3;
    final_space = true;

    # Заменяет старый precmd_title/case "$TERM" — заголовок окна терминала
    console_title_template = "{{ .UserName }}@{{ .HostName }}: {{ .Folder }}";

    blocks = [
      # ================= СТРОКА 1 =================
      {
        type = "prompt";
        alignment = "left";
        segments = [
          # Открывающий угол, окрашен по коду возврата прошлой команды
          {
            type = "text";
            style = "plain";
            template = "{{ if gt .Code 0 }}<${colorError}>┌─</>{{ else }}<${colorSuccess}>┌─</>{{ end }}";
          }

          # Пользователь + иконка
          {
            type = "session";
            style = "powerline";
            powerline_symbol = arrow;
            background = colorUser;
            foreground = fgCream;
            template = " ${iconUser} {{ .UserName }} ";
          }

          # Путь + иконка (аналог %~ — полный путь с заменой $HOME на ~)
          {
            type = "path";
            style = "powerline";
            powerline_symbol = arrow;
            background = colorPath;
            foreground = fgCream;
            template = " ${iconFolder} {{ .Path }} ";
            options = {
              style = "full";
              home_icon = "~";
            };
          }

          # Git — то же самое, что и раньше делала __git_prompt_info,
          # но статусами занимается сам oh-my-posh (fetch_status)
          {
            type = "git";
            style = "powerline";
            powerline_symbol = arrow;
            background = colorGit;
            foreground = fgCream;
            template = " {{ .HEAD }}{{ if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }} {{ .Working.String }}{{ end }}{{ if .Staging.Changed }} {{ .Staging.String }}{{ end }} ";
            options = {
              fetch_status = true;
              branch_icon = "󰊢 ";
              branch_ahead_icon = " ";
              branch_behind_icon = " ";
            };
          }

          # ---- Секция языков/версий вместо времени ----
          # Каждый сегмент показывается сам по себе, только если в
          # текущей директории есть соответствующие файлы
          # (display_mode = "files" — штатное поведение oh-my-posh).
          # Иконка и версия берутся из встроенного шаблона сегмента —
          # template нарочно не переопределён.
          {
            type = "cmake";
            style = "powerline";
            powerline_symbol = arrow;
            background = colorLang;
            foreground = fgCream;
            options = { display_mode = "files"; };
          }
          {
            type = "python";
            style = "powerline";
            powerline_symbol = arrow;
            background = colorLang;
            foreground = fgCream;
            options = { display_mode = "files"; };
          }
          {
            type = "node";
            style = "powerline";
            powerline_symbol = arrow;
            background = colorLang;
            foreground = fgCream;
            options = { display_mode = "files"; };
          }
          {
            type = "go";
            style = "powerline";
            powerline_symbol = arrow;
            background = colorLang;
            foreground = fgCream;
            options = { display_mode = "files"; };
          }
          {
            type = "rust";
            style = "powerline";
            powerline_symbol = arrow;
            background = colorLang;
            foreground = fgCream;
            options = { display_mode = "files"; };
          }

          # DevShell-бейдж — как и раньше, из $IN_NIX_SHELL
          {
            type = "text";
            style = "plain";
            foreground = "magenta";
            template = "{{ if .Env.IN_NIX_SHELL }} #devshell{{ end }}";
          }

          # Код ошибки — показывается сам по себе только при exit != 0
          {
            type = "status";
            style = "plain";
            foreground = colorError;
            template = " ✗ {{ .Code }}";
          }
        ];
      }

      # ================= СТРОКА 2 =================
      {
        type = "prompt";
        alignment = "left";
        newline = true;
        segments = [
          {
            type = "text";
            style = "plain";
            template = "{{ if gt .Code 0 }}<${colorError}>└─</>{{ else }}<${colorSuccess}>└─</>{{ end }}❯ ";
          }
        ];
      }

      # ============ ПРАВАЯ ЧАСТЬ (та же строка, что и приглашение) ============
      {
        type = "rprompt";
        segments = [
          # Время выполнения прошлой команды — виден только если > 5с
          {
            type = "executiontime";
            style = "plain";
            foreground = colorDuration;
            template = "  {{ .FormattedMs }} ";
            options = { threshold = 5000; };
          }
          # Текущий shell
          {
            type = "shell";
            style = "plain";
            foreground = colorShell;
            template = "  {{ .Name }} ";
          }
        ];
      }
    ];

    # ---- Transient prompt: после Enter строка сворачивается в "❯ " ----
    transient_prompt = {
      background = "transparent";
      template = "{{ if gt .Code 0 }}<${colorError}>❯</>{{ else }}<${colorSuccess}>❯</>{{ end }} ";
    };
  };
in
{
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = ompSettings;
  };

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
      theme = ""; # промпт рисует oh-my-posh, не oh-my-zsh
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
    };


    initContent = ''

# ---- Обёртка над `nix develop`, чтобы поднимался zsh, а не bash ----
nix() {
    if [[ "$1" == "develop" ]]; then
        command nix "$@" --command zsh
    else
        command nix "$@"
    fi
}

# ---- Быстрый вызов tmux-sessionizer по Ctrl+f ----
      tmux-sessionizer-widget() {
          zle push-input
          BUFFER="tmux-sessionizer"
          zle accept-line
      }
      zle -N tmux-sessionizer-widget
      bindkey '^f' tmux-sessionizer-widget


      fastfetch
        '';
    };

}
