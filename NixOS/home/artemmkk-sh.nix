{ config, pkgs, ... }:
{
  imports = [
    ./zsh.nix
    ./neovim.nix
  ];

  home.username = "artemmkk-sh";
  home.homeDirectory = "/home/artemmkk-sh";
  home.packages = with pkgs; [
    telegram-desktop
    obsidian
  ];

  programs.git = {
    enable = true;
    userName = "shayu25u578";
    userEmail = "shkunovayu@student.bmstu.ru";
  };

  home.stateVersion = "26.05";
}
