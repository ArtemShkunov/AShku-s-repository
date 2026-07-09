{ config, pkgs, ... }:
{
  home.username = "artemmkk-sh";
  home.homeDirectory = "/home/artemmkk-sh";
  home.packages = iwth pkgs; [
    telegram-desktop
    obsidian
  ];
  programs.git = {
    enable = true;
    userName = "shayu25u578";
    userEmail = "shkunovayu@student.bmstu.ru";
  };



  programs.zsh.enable = true;

  programs.neovim = {
    enable = true;
    # placeholder for later plugins
  };

  home.stateVersion = "26.05";
}
