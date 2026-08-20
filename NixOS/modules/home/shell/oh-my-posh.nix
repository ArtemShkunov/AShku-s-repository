# oh-my-posh.nix — the shell prompt only.
#
# Separate from shell/zsh.nix so the same prompt can be used with any shell
# (zsh and bash integrations are enabled below). Segment colors come from
# theme.prompt; the terminal palette is separate (theme.terminal).
{ theme, ... }:

let
  # ---- Палитра Sunset Pines (из themes/) ----
  colorUser = theme.prompt.user;
  colorPath = theme.prompt.path;
  colorGit = theme.prompt.git;
  colorLang = theme.prompt.lang;
  colorSuccess = theme.prompt.success;
  colorError = theme.prompt.error;
  colorDuration = theme.prompt.duration;
  colorShell = theme.prompt.shell;
  fgCream = theme.prompt.fg;

  # ---- Иконки и разделители (Nerd Font) ----
  iconUser = " "; # nf-fa-user
  iconFolder = " "; # nf-fa-folder-open
  arrow = ""; # powerline-стрелка
  leftRounded = ""; # левое закругление (nf-ple-left_half_circle_thick)
  rightRounded = ""; # правое закругление (nf-ple-right_half_circle_thick)

  # Иконки языков
  iconC = " ";
  iconCpp = " ";
  iconCMake = " ";
  iconPython = " ";
  iconNode = " ";
  iconGo = " ";
  iconRust = " ";

  # Классические иконки Git статусов
  gitUntracked = "  "; # Untracked
  gitModified = "  "; # Modified
  gitAdded = "  "; # Added
  gitDeleted = "  "; # Deleted
  gitStaged = "  "; # Staged
  gitConflict = "  "; # Conflict
  gitAhead = "  "; # Ahead
  gitBehind = "  "; # Behind
  gitBranch = "  "; # Branch
  gitRepo = " 󰊢 ";

  ompSettings = {
    "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
    version = 3;
    final_space = true;

    # Заменяет старый precmd_title — заголовок окна терминала
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
            template = "{{ if gt .Code 0 }}<#${colorError}>┌─</>{{ else }}<#${colorSuccess}>┌─</>{{ end }}";
          }

          # Пользователь + иконка
          {
            type = "session";
            style = "diamond";
            leading_diamond = leftRounded;
            powerline_symbol = arrow;
            background = "#${colorUser}";
            foreground = "#${fgCream}";
            template = "${iconUser} {{ .UserName }} ";
          }

          # Путь + иконка (аналог %~ — полный путь с заменой $HOME на ~)
          {
            type = "path";
            style = "powerline";
            powerline_symbol = arrow;
            background = "#${colorPath}";
            foreground = "#${fgCream}";
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
            background = "#${colorGit}";
            foreground = "#${fgCream}";
            display-mode = "always";
            home-enabled = true;

            template = "{{ if .RepoName }}${gitRepo}{{ .HEAD }}{{ if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Staging.Changed }} ${gitStaged}{{ if gt .Staging.Added 0 }}${gitAdded}{{ .Staging.Added }} {{ end }}{{ if gt .Staging.Modified 0 }}${gitModified}{{ .Staging.Modified }} {{ end }}{{ if gt .Staging.Deleted 0 }}${gitDeleted}{{ .Staging.Deleted }} {{ end }}{{ if gt .Staging.Unmerged 0 }}${gitConflict}{{ .Staging.Unmerged }} {{ end }}{{ end }}{{ if .Working.Changed }}{{ if gt .Working.Untracked 0 }}${gitUntracked}{{ .Working.Untracked }} {{ end }}{{ if gt .Working.Added 0 }}${gitAdded}{{ .Working.Added }} {{ end }}{{ if gt .Working.Modified 0 }}${gitModified}{{ .Working.Modified }} {{ end }}{{ if gt .Working.Deleted 0 }}${gitDeleted}{{ .Working.Deleted }} {{ end }}{{ if gt .Working.Unmerged 0 }}${gitConflict}{{ .Working.Unmerged }} {{ end }}{{ end }}{{ end }} ";

            options = {
              fetch_status = true;
              untracked_modes = {
                "*" = "all";
              };
              branch_icon = gitBranch;
              branch_ahead_icon = gitAhead;
              branch_behind_icon = gitBehind;
            };
          }

          # ---- Секция языков/версий ----
          # Каждый языковой сегмент активен только при наличии
          # соответствующих файлов (display_mode = "files").
          # C
          {
            type = "language";
            style = "diamond";
            trailing_diamond = rightRounded;
            background = "#${colorLang}";
            foreground = "#${fgCream}";
            template = " ${iconC}{{ .Full }} ";

            options = {
              name = "c";
              display-mode = "always";
              home-enabled = true;

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
            style = "diamond";
            trailing_diamond = rightRounded;
            background = "#${colorLang}";
            foreground = "#${fgCream}";
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
            style = "diamond";
            trailing_diamond = rightRounded;
            background = "#${colorLang}";
            foreground = "#${fgCream}";
            template = " ${iconCMake}{{ .Full }} ";
            options = {
              display_mode = "files";
            };
          }

          # Python
          {
            type = "python";
            style = "diamond";
            trailing_diamond = rightRounded;
            background = "#${colorLang}";
            foreground = "#${fgCream}";
            template = " ${iconPython}{{ .Full }} ";
            options = {
              display_mode = "files";
            };
          }

          # Node.js
          {
            type = "node";
            style = "diamond";
            trailing_diamond = rightRounded;
            background = "#${colorLang}";
            foreground = "#${fgCream}";
            template = " ${iconNode}{{ .Full }} ";
            options = {
              display_mode = "files";
            };
          }

          # Go
          {
            type = "go";
            style = "diamond";
            trailing_diamond = rightRounded;
            foreground = "#${fgCream}";
            template = " ${iconGo}{{ .Full }} ";
            options = {
              display_mode = "files";
            };
          }

          # Rust (последний в цепочке — закругляет правый край всей плашки)
          {
            type = "rust";
            style = "diamond";
            trailing_diamond = rightRounded;
            background = "#${colorLang}";
            foreground = "#${fgCream}";
            template = " ${iconRust}{{ .Full }} ";
            options = {
              display-mode = "always";
              home-enabled = true;
            };
          }

          # DevShell-бейдж — из $IN_NIX_SHELL
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
            foreground = "#${colorError}";
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
            template = "{{ if gt .Code 0 }}<#${colorError}>└─❯</>{{ else }}<#${colorSuccess}>└─❯</>{{ end }}";
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
            foreground = "#${colorDuration}";
            template = "  {{ .FormattedMs }} ";
            options = {
              threshold = 5000;
            };
          }
          # Текущий shell
          {
            type = "shell";
            style = "plain";
            foreground = "#${colorShell}";
            template = "  {{ .Name }} ";
          }
        ];
      }
    ];

    # ---- Transient prompt: после Enter строка сворачивается в "❯ " ----
    transient_prompt = {
      background = "transparent";
      template = "{{ if gt .Code 0 }}<#${colorError}>❯</>{{ else }}<#${colorSuccess}>❯</>{{ end }} ";
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
}
