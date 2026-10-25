# fuzzel.nix — Fuzzel launcher and dmenu menus.
#
# Fuzzel is the interactive launcher and handles mouse selection in every menu.
{ pkgs, theme, ... }:

let
  fuzzelMenu = pkgs.writeShellScriptBin "fuzzel-menu" ''
    exec ${pkgs.fuzzel}/bin/fuzzel --dmenu --enable-mouse=yes "$@"
  '';

  clipboardHistory = pkgs.writeShellScriptBin "clipboard-history" ''
    set -euo pipefail

    selected=$(
      ${pkgs.cliphist}/bin/cliphist list |
        ${pkgs.fuzzel}/bin/fuzzel \
          --dmenu \
          --enable-mouse=yes \
          --prompt "Clipboard  " \
          --lines 15 \
          --width 72
    )

    [ -z "$selected" ] && exit 0

    printf '%s\n' "$selected" |
      ${pkgs.cliphist}/bin/cliphist decode |
      ${pkgs.wl-clipboard}/bin/wl-copy
  '';
in
{
  # Fuzzel is a Wayland-native launcher with mouse selection.
  programs.fuzzel = {
    enable = true;
    package = pkgs.fuzzel;
    settings = {
      main = {
        font = "${theme.fonts.mono}:size=13";
        terminal = "${pkgs.kitty}/bin/kitty";
        prompt = "Apps  ";
        placeholder = "Type to search applications…";
        lines = 15;
        width = 58;
        horizontal-pad = 24;
        vertical-pad = 18;
        inner-pad = 14;
        icon-theme = "Yaru";
        icons-enabled = "yes";
        enable-mouse = "yes";
      };
      colors = {
        background = "${theme.colors.surface}ff";
        text = "${theme.colors.fg}ff";
        prompt = "${theme.colors.accent-bright}ff";
        placeholder = "${theme.colors.fg-dim}ff";
        input = "${theme.colors.fg}ff";
        match = "${theme.colors.accent-bright}ff";
        selection = "${theme.colors.accent}ff";
        selection-text = "${theme.colors.bg}ff";
        selection-match = "${theme.colors.bg}ff";
        border = "${theme.colors.border}ff";
      };
      border = {
        width = 2;
        radius = 8;
        selection-radius = 5;
      };
    };
  };

  home.packages = [
    clipboardHistory
    fuzzelMenu
  ];
}
