{ pkgs, ... }: {
  wayland.windowsManager.hyprland.settings.monitor = {
    output = "DP-1";
    mode = "1920x1080@120";
    position = "auto";
    scale = "1"; 
  };

  programs.waybar.settings.mainBar."hyprland/language".keyboard-name = "company--usb-device--keyboard";

  home.packages = with pkgs; [
    logiops
    logitech-udev-rules
  ];



}
