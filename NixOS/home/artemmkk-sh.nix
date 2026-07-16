{ config, pkgs, ... }:
{
  imports = [
    ./zsh.nix
    ./neovim.nix
    ./hyprland.nix
    ./waybar.nix
    ./mako.nix
    ./wofi.nix
  ];

  home.username = "artemmkk-sh";
  home.homeDirectory = "/home/artemmkk-sh";
  home.packages = with pkgs; [
    telegram-desktop
    obsidian
    kdePackages.breeze
    kdePackages.breeze-icons
    kdePackages.plasma-integration
    kdePackages.qqc2-desktop-style
    kdePackages.okular
    kdePackages.kconfig
    vlc
  ];


  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "shayu25u578";
        email = "shkunovayu@student.bmstu.ru";
      };
    };
  };

  home.stateVersion = "26.05";
}
