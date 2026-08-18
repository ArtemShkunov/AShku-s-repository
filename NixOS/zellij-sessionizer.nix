{ pkgs, ... }:

let
  zellij-sessionizer = pkgs.writeShellScriptBin "zellij-sessionizer" ''
    #!/usr/bin/env bash

    if [[ -n $ZELLIJ ]]; then
      echo "Уже внутри zellij-сессии — переключайся через Session Manager (Ctrl+o) или Ctrl+f (detach) и запусти zellij-sessionizer заново." >&2
      exit 1
    fi

    if [[ $# -eq 1 ]]; then
      selected=$1
    else
      selected=$(find ~/Projects ~/.nixos-config ~/ -mindepth 1 -maxdepth 1 -type d 2>/dev/null | ${pkgs.fzf}/bin/fzf)
    fi

    if [[ -z $selected ]]; then
      exit 0
    fi

    selected_name=$(basename "$selected" | tr . _)

    cd "$selected" || exit 1

    # attach --create: подключается к сессии, если она уже есть,
    # иначе создаёт новую с этим именем и рабочей директорией $selected.
    exec ${pkgs.zellij}/bin/zellij attach --create "$selected_name"
  '';
in
{
  home.packages = [
    zellij-sessionizer
    pkgs.fzf
  ];
}
