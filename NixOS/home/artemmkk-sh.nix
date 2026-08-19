# Home Manager entry for user "artemmkk-sh".
#
# Machine-independent user configuration: imports every shared home module.
# Machine-specific overrides (monitor, touchpad, keyboard name, peripherals)
# are injected by the flake from hosts/<host>/home.nix.
{ ... }: {
  imports = [
    # Shell
    ../modules/home/shell/zsh.nix
    ../modules/home/shell/oh-my-posh.nix

    # Terminal
    ../modules/home/terminal/kitty.nix
    ../modules/home/terminal/tmux.nix
    ../modules/home/terminal/sessionizer.nix

    # Editors / dev
    ../modules/home/editors/git.nix
    ../modules/home/editors/neovim/neovim.nix
    ../modules/home/apps/dev.nix

    # Desktop (Hyprland)
    ../modules/home/hyprland/hyprland.nix
    ../modules/home/hyprland/waybar.nix
    ../modules/home/hyprland/wofi.nix
    ../modules/home/hyprland/mako.nix
    ../modules/home/hyprland/hyprlock.nix
    ../modules/home/hyprland/hypridle.nix
    ../modules/home/hyprland/hyprpaper.nix

    # Theming (GTK/Qt/cursor)
    ../modules/home/theming.nix

    # Apps
    ../modules/home/apps/chat.nix
    ../modules/home/apps/browsers.nix
    ../modules/home/apps/office.nix
    ../modules/home/apps/media.nix
    ../modules/home/apps/network.nix

    # Misc
    ../modules/home/fastfetch/fastfetch.nix
  ];

  home.username = "artemmkk-sh";
  home.homeDirectory = "/home/artemmkk-sh";
  home.stateVersion = "26.05";

  home.sessionVariables = {
    LC_TIME = "en_US.UTF-8";
  };
}
