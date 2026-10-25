# shortcuts.nix — the `?` / Super+H cheat-sheet.
#
# Descriptions are attached to every Hyprland bind in hyprland.nix, so the
# menu is generated from the live config instead of a hand-maintained list.
{ pkgs, theme, ... }:
let
  shortcuts = pkgs.writeShellScriptBin "shortcuts" ''
    set -euo pipefail

    {
      printf '%s\t%s\n' '3-finger swipe' 'Switch workspaces'
      hyprctl -j binds | ${pkgs.jq}/bin/jq -r '
        def mods($mask):
          [
            { bit: 1,  name: "SHIFT" },
            { bit: 4,  name: "CTRL"  },
            { bit: 8,  name: "ALT"   },
            { bit: 64, name: "SUPER" }
          ]
          | map(select(((($mask / .bit) | floor) % 2) == 1) | .name)
          | join("+");

        def combo:
          mods(.modmask) as $mods
          | if $mods == "" then .key else "\($mods)+\(.key)" end;

        .[]
        | select(.has_description and (.mouse | not))
        | "\(combo)\t\(.description)"
      '
    } |
      ${pkgs.util-linux}/bin/column -t -s $'\t' |
      ${pkgs.fuzzel}/bin/fuzzel \
        --dmenu \
        --prompt "Keybindings  " \
        --lines 24 \
        --width 78
  '';
in
{
  home.packages = [ shortcuts ];
}
