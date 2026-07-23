{ config, pkgs, inputs, ... }:
{
  imports = [
    ../modules/zsh.nix
    ../modules/nvim/neovim.nix
    ../modules/hyprland/hyprland.nix
    ../modules/hyprland/waybar.nix
    ../modules/hyprland/mako.nix
    ../modules/hyprland/wofi.nix
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
    kdePackages.breeze-gtk
    vlc
    xdg-terminal-exec
    libreoffice
    hunspell
    hyphen
    hyphenDicts.ru-ru
    hyphenDicts.ru_RU
    hunspellDicts.ru_RU
    hunspellDicts.ru-ru
    inputs.zen-browser.packages."${system}".default
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

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [ "kitty.desktop" ];
    };
  };

  home.stateVersion = "26.05";
}
