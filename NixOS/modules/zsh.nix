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
    # ---- Иконки и разделители (Nerd Font) ----
    iconUser     = " "; # nf-fa-user
    iconFolder   = " "; # nf-fa-folder-open
    arrow        = ""; # powerline-стрелка
    leftRounded  = ""; # левое закругление (nf-ple-left_half_circle_thick)
    rightRounded = ""; # правое закругление (nf-ple-right_half_circle_thick)

    # Иконки языков
    iconC        = " ";
    iconCpp      = " ";
    iconCMake    = " ";
    iconPython   = " ";
    iconNode     = " ";
    iconGo       = " ";
    iconRust     = " ";

    # Классические иконки Git статусов
    gitUntracked = "  "; # Untracked
    gitModified  = "  "; # Modified
    gitAdded     = "  "; # Added
    gitDeleted   = "  "; # Deleted
    gitStaged    = "  "; # Staged
    gitConflict  = "  "; # Conflict
    gitAhead     = "  "; # Ahead
    gitBehind    = "  "; # Behind
    gitBranch    = "  "; # Branch󰊢
    gitRepo      = " 󰊢 ";


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
                        style = "diamond";
                        leading_diamond = leftRounded;
                        powerline_symbol = arrow;
                        background = colorUser;
                        foreground = fgCream;
                        template = "${iconUser} {{ .UserName }} ";
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

                    # Git — сегмент остаётся на месте даже вне репозитория.
                    # В активном состоянии показывает ветку и явные счётчики статусов,
                    # включая untracked-файлы.
                    {
                        type = "git";
                        style = "powerline";
                        powerline_symbol = arrow;
                        background = colorGit;
                        foreground = fgCream;
                        fallback_template = " ";

                        template = "{{ if .RepoName }}${gitRepo}{{ .HEAD }}{{ if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Staging.Changed }} ${gitStaged}{{ if gt .Staging.Added 0 }}${gitAdded}{{ .Staging.Added }} {{ end }}{{ if gt .Staging.Modified 0 }}${gitModified}{{ .Staging.Modified }} {{ end }}{{ if gt .Staging.Deleted 0 }}${gitDeleted}{{ .Staging.Deleted }} {{ end }}{{ if gt .Staging.Unmerged 0 }}${gitConflict}{{ .Staging.Unmerged }} {{ end }}{{ end }}{{ if .Working.Changed }}{{ if gt .Working.Untracked 0 }}${gitUntracked}{{ .Working.Untracked }} {{ end }}{{ if gt .Working.Added 0 }}${gitAdded}{{ .Working.Added }} {{ end }}{{ if gt .Working.Modified 0 }}${gitModified}{{ .Working.Modified }} {{ end }}{{ if gt .Working.Deleted 0 }}${gitDeleted}{{ .Working.Deleted }} {{ end }}{{ if gt .Working.Unmerged 0 }}${gitConflict}{{ .Working.Unmerged }} {{ end }}{{ end }}{{ end }}";

                        options = {
                            fetch_status = true;
                            untracked_modes = { "*" = "all"; };
                            branch_icon = gitBranch;
                            branch_ahead_icon = gitAhead;
                            branch_behind_icon = gitBehind;
                        };
                    }
                    # ---- Секция языков/версий вместо времени ----
                    # Каждый языковой сегмент активен только при наличии
                    # соответствующих файлов (display_mode = "files").
                    # Когда язык не активен, fallback_template оставляет
                    # пустую цветную плашку вместо исчезновения сегмента.
                    # C
                    {
                        type = "language";
                        style = "powerline";
                        powerline_symbol = arrow;
                        background = colorLang;
                        foreground = fgCream;
                        template = " ${iconC}{{ .Full }} ";

                        options = {
                            name = "c";
                            display_mode = "files";

                            extensions = [
                                "*.c"
                                "*.h"
                            ];

                            tools = [
                                {
                                    name = "gcc";
                                    executable = "gcc";
                                    args = [ "--version" ];
                                    regex = "gcc(?: \\([^)]*\\))? (?P<version>\\d+\\.\\d+(?:\\.\\d+)?)";
                                }

                                {
                                    name = "clang";
                                    executable = "clang";
                                    args = [ "--version" ];
                                    regex = "clang version (?P<version>\\d+\\.\\d+(?:\\.\\d+)?)";
                                }
                            ];
                        };
                    }

                    # C++
                    {
                        type = "language";
                        style = "powerline";
                        background = colorLang;
                        foreground = fgCream;
                        template = " ${iconCpp}{{ .Full }} ";

                        options = {
                            name = "cpp";
                            display_mode = "files";

                            extensions = [
                                "*.cpp"
                                "*.cc"
                                "*.cxx"
                                "*.hpp"
                                "*.hh"
                                "*.hxx"
                            ];

                            tools = [
                                {
                                    name = "g++";
                                    executable = "g++";
                                    args = [ "--version" ];
                                    regex = "g\\+\\+ \\([^)]*\\) (?P<version>\\d+\\.\\d+(?:\\.\\d+)?)";
                                }

                                {
                                    name = "clang++";
                                    executable = "clang++";
                                    args = [ "--version" ];
                                    regex = "clang version (?P<version>\\d+\\.\\d+(?:\\.\\d+)?)";
                                }
                            ];
                        };
                    }
                    # CMake
                    {
                        type = "cmake";
                        style = "powerline";
                        background = colorLang;
                        foreground = fgCream;
                        template = " ${iconCMake}{{ .Full }} ";
                        options = { display_mode = "files"; };
                    }
                    # Python
                    {
                        type = "python";
                        style = "powerline";
                        background = colorLang;
                        foreground = fgCream;
                        template = " ${iconPython}{{ .Full }} ";
                        options = { display_mode = "files"; };
                    }
                    # Node.js
                    {
                        type = "node";
                        style = "powerline";
                        background = colorLang;
                        foreground = fgCream;
                        template = " ${iconNode}{{ .Full }} ";
                        options = { display_mode = "files"; };
                    }
                    # Go
                    {
                        type = "go";
                        style = "powerline";
                        background = colorLang;
                        foreground = fgCream;
                        template = " ${iconGo}{{ .Full }} ";
                        options = { display_mode = "files"; };
                    }
                    # Rust (последний в цепочке — закругляет правый край всей плашки)
                    {
                        type = "rust";
                        style = "diamond";
                        trailing_diamond = rightRounded;
                        background = colorLang;
                        foreground = fgCream;
                        template = " ${iconRust}{{ .Full }} ";
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
                        template = "{{ if gt .Code 0 }}<${colorError}>└─❯</>{{ else }}<${colorSuccess}>└─❯</>{{ end }}";
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
        enableBashIntegration = true;
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
