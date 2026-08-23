# Waybar для ПК (Desktop): общая часть из waybar-common.nix без
# специфичных для ноутбука battery/backlight.
{ pkgs, theme, ... }:

let
  common = import ./waybar-common.nix { inherit pkgs theme; };
in
{
  home.packages = common.packages;

  programs.waybar = {
    enable = true;
    package = common.package;
    # Start the bar as a systemd user service (PartOf graphical-session.target),
    # like hyprpaper/hypridle/mako. This avoids the parse-time spawn problem:
    # top-level `hl.exec_cmd` runs before the Wayland socket exists and the
    # process dies without anything respawning it.
    systemd.enable = true;

    settings.mainBar = common.mainBarBase // {
      modules-left = common.moduleGroups.left;
      modules-center = common.moduleGroups.center;
      modules-right =
        common.moduleGroups.rightPre ++ common.moduleGroups.rightMid ++ common.moduleGroups.rightPost;
    };

    style = common.style;
  };
}
