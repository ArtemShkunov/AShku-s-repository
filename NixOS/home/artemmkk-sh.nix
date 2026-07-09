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

    # -------- Language packages for neovim

    # C/C++

    clang-tools
    cppcheck

    # Python
    
    pyright
    ruff
    black

    # Lua

    lua-language-server
    stylua
    selene
    
    # Nix

    nixd
    statix
    nixfmt-rfc-style
    deadnix
  ];

  programs.git = {
    enable = true;
    userName = "shayu25u578";
    userEmail = "shkunovayu@student.bmstu.ru";
  };

  home.stateVersion = "26.05";
}
