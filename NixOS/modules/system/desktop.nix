# desktop.nix — shared desktop/WM environment.
#
# The Hyprland desktop environment itself: X11 base (for XWayland/keymap),
# portals, file manager, polkit, and the desktop GUI programs. Machine
# specifics (monitor, touchpad, drivers) belong in the host's device layer.
{ pkgs, ... }: {
  # Enable the X11 windowing system (needed for XWayland + keymap).
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable Hyprland
  programs.hyprland.enable = true;

  # Enable dconf
  programs.dconf.enable = true;
  security.pam.services.hyprlock = { };

  # Polkit daemon (needed by hyprpolkitagent).
  security.polkit.enable = true;

  # File manager + supporting services.
  services.gvfs.enable = true; # remote files / trash
  services.tumbler.enable = true; # thumbnails for Thunar
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs; [
    thunar-archive-plugin
    thunar-volman
  ];

  # Desktop programs.
  programs.throne.enable = true;
  programs.throne.tunMode.enable = true;
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    unzip
    unrar
    kdePackages.ark # archives
    mousepad # XFCE text editor
    ristretto # XFCE image viewer
  ];
}
