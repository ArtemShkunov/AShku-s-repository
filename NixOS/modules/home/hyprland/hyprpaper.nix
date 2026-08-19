# hyprpaper.nix — wallpaper daemon.
#
# Wallpaper path comes from the theme (repo-relative, so Nix copies it into
# the store — no absolute-home-path hackery).
{ theme, ... }: {
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = false;
      ipc = "on";
      wallpaper = [
        {
          monitor = "";
          path = "${theme.wallpapers.desktop}";
        }
      ];
    };
  };
}
