# chat.nix — messaging apps.
{ pkgs, ... }: {
  home.packages = with pkgs; [
    telegram-desktop
    discord
  ];
}
