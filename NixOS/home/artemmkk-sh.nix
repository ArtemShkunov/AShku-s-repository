{ config, pkgs, ... }:
{
  imports = [
    ./zsh.nix
    ./neovim.nix
    ./hyprland.nix
    ./waybar.nix
  ];

  home.username = "artemmkk-sh";
  home.homeDirectory = "/home/artemmkk-sh";
  home.packages = with pkgs; [
    telegram-desktop
    obsidian
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
