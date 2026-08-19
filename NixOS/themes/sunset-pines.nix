# Sunset Pines — single source of truth for theming.
#
# Every module (system and home-manager) reads its colors, fonts and theme
# names from this file via the `theme` argument passed from the flake.
# To re-theme the whole machine, edit only this file (or swap the import in
# themes/default.nix).
#
# Conventions:
#   * Color values are bare hex WITHOUT the leading '#', e.g. "16141f".
#     Consumers add '#' where the format requires it (CSS, kitty, oh-my-posh)
#     and use raw hex inside rgba()/rgb() for Hyprland/hyprlock:
#       "#${theme.colors.bg}"              # CSS/kitty
#       "rgba(${theme.colors.accent}ee)"   # Hyprland/hyprlock
#     For alpha in CSS append hex alpha: "#${theme.colors.surface}d9" (85%).
#   * Packages are NOT referenced here — only names/sizes. Modules map
#     names to pkgs (e.g. gtk.iconTheme -> pkgs.yaru-theme).
{
  name = "Sunset Pines";

  # Semantic colors shared by waybar/wofi/mako/tmux/hyprlock/greeter/etc.
  colors = {
    bg = "16141f"; # base background
    bg-lock = "1a1a1a"; # hyprlock flat background
    surface = "241f30"; # raised surfaces (waybar/wofi/mako windows)
    border = "4a3b4f"; # muted borders, hover states
    fg = "f5e9dc"; # primary text
    fg-dim = "8a7a8a"; # muted/secondary text
    fg-cream = "fff6ee"; # bright warm text (used by oh-my-posh)
    accent = "f2994a"; # sunset orange
    accent-bright = "f7ce68"; # gold
    success = "a3b18a"; # green
    error = "e8613c"; # red/orange
    blue = "7a8bbd";
    magenta = "b47aa0";
    cyan = "6ea8a0";
    white = "ffffff";
    grey = "6b6b80"; # tmux/status separators
  };

  # Full 16-color terminal palette (kitty, etc.)
  terminal = {
    color0 = "16141f";
    color1 = "e8613c";
    color2 = "a3b18a";
    color3 = "f7ce68";
    color4 = "7a8bbd";
    color5 = "b47aa0";
    color6 = "6ea8a0";
    color7 = "f5e9dc";
    color8 = "8a7a8a";
    color9 = "f2994a";
    color10 = "c9d6b1";
    color11 = "ffe29a";
    color12 = "a3b1d6";
    color13 = "d1a3c4";
    color14 = "9fcac2";
    color15 = "ffffff";
  };

  # oh-my-posh segment colors (kept distinct from the terminal palette:
  # the prompt historically uses a warmer set of reds/oranges).
  prompt = {
    user = "852E19";
    path = "AA1E14";
    git = "D2320F";
    lang = "DB500B";
    success = "6FAE7B";
    error = "C0392B";
    duration = "B2472E";
    shell = "6FAE7B";
    fg = "FFF6EE";
  };

  fonts = {
    mono = "JetBrainsMono Nerd Font";
    monoFallback = "Fira Code Nerd Font";
  };

  cursor = {
    name = "BreezeX-RosePine-Linux"; # rose-pine-cursor
    size = 24;
  };

  gtk = {
    theme = "Adwaita-dark"; # pkgs.gnome-themes-extra
    iconTheme = "Yaru"; # pkgs.yaru-theme
    cursorTheme = "Adwaita"; # pkgs.adwaita-icon-theme
  };

  qt = {
    style = "breeze"; # pkgs.kdePackages.breeze
  };

  wallpapers = {
    desktop = ./sunset-pines/wallpaper.png;
  };
}
