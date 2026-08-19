# media.nix — media playback and audio utilities.
{ pkgs, ... }: {
  home.packages = with pkgs; [
    vlc
    wiremix # audio device mixer
  ];
}
