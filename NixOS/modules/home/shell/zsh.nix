# zsh.nix — zsh shell: history, plugins, aliases, keybinds.
#
# The prompt is NOT here — oh-my-posh lives in shell/oh-my-posh.nix so it
# can be used with any shell.
{ config, pkgs, ... }: {
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
      l = "ls -CF";
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
    '';
  };

  # zoxide — smarter `cd`; provides the z/zi commands via --cmd z.
  programs.zoxide = {
    enable = true;
    options = [ "--cmd z" ];
  };
}
