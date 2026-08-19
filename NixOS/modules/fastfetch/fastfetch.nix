# fastfetch.nix — модуль home-manager
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    fastfetch
    curl
  ];

  xdg.configFile."fastfetch/config.jsonc".source = ./nixos-01.jsonc;
  xdg.configFile."fastfetch/nixos-02.jsonc".source = ./nixos-02.jsonc;

  xdg.configFile."fastfetch/logo/nixos_logo_1.webp".source = ./logo/nixos_logo_1.webp;
  xdg.configFile."fastfetch/logo/nixos_logo_2.webp".source = ./logo/nixos_logo_2.webp;

  xdg.configFile."fastfetch/scripts/nixos-01_fastfetch.sh" = {
    source = ./scripts/nixos-01_fastfetch.sh;
    executable = true;
  };
  xdg.configFile."fastfetch/scripts/nixos-02_fastfetch.sh" = {
    source = ./scripts/nixos-02_fastfetch.sh;
    executable = true;
  };
  xdg.configFile."fastfetch/scripts/nixos_bashrc.sh" = {
    source = ./scripts/nixos_bashrc.sh;
    executable = true;
  };

  # Запуск fastfetch при старте шелла
  programs.zsh.initExtra = ''
    fastfetch
  '';
}
