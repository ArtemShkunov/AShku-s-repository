# theming.nix — system-level theme packages.
#
# Only the packages that must exist system-wide for themes to render
# (GTK/Qt themes, icons, Wayland Qt bridge). User-level theme application
# lives in modules/home/theming.nix.
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gnome-themes-extra # Adwaita-dark theme for GTK3
    rose-pine-icon-theme
    adwaita-icon-theme
    adwaita-qt
    kdePackages.qtwayland
  ];
}
