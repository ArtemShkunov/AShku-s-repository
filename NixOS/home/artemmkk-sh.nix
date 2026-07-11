{ config, pkgs, ... }:
{
  imports = [
    ./zsh.nix
    ./neovim.nix
    ./hyprland.nix
  ];

  home.username = "artemmkk-sh";
  home.homeDirectory = "/home/artemmkk-sh";
  home.packages = with pkgs; [
    telegram-desktop
    obsidian
  ];


  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal = {
          family = "Fira Code";
          style = "Nerd";
        };
        size = 12;
      };
      window = {
        opacity = 0.90;
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "shayu25u578";
    userEmail = "shkunovayu@student.bmstu.ru";
  };

  home.stateVersion = "26.05";
}
