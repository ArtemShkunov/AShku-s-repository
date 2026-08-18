{ pkgs, ... }:

let
  zellij-sessionizer = pkgs.writeShellScriptBin "zellij-sessionizer" ''
    #!/usr/bin/env bash

    if [[ $# -eq 1 ]]; then
      selected=$1
    else
      selected=$(find ~/Projects ~/.nixos-config ~/ -mindepth 1 -maxdepth 1 -type d 2>/dev/null | ${pkgs.fzf}/bin/fzf)
    fi

    if [[ -z $selected ]]; then
      exit 0
    fi

    selected_name=$(basename "$selected" | tr . _)

    if [[ -z $ZELLIJ ]]; then
      # Запуск вне Zellij: создаем или подключаемся к сессии с нужным CWD
      ${pkgs.zellij}/bin/zellij attach -c "$selected_name" options --default-cwd "$selected"
    else
      # Запуск внутри Zellij
      if ! ${pkgs.zellij}/bin/zellij list-sessions 2>/dev/null | grep -q "^$selected_name"; then
        # Создаем сессию в фоне, если её ещё нет
        ${pkgs.zellij}/bin/zellij attach --create-background "$selected_name" options --default-cwd "$selected"
      fi
      # Переключаемся на выбранную сессию
      ${pkgs.zellij}/bin/zellij action switch-session "$selected_name"
    fi
  '';
in
{
  home.packages = [
    zellij-sessionizer
    pkgs.fzf
    pkgs.zellij
  ];
}
