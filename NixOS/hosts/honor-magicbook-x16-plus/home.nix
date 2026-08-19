# home.nix — MACHINE-SPECIFIC home-manager settings.
#
# Counterpart of device.nix for the home-manager side: anything that depends
# on this machine's display, input devices or peripherals lives here, NOT in
# the shared modules. New machine → new home.nix.
{ pkgs, ... }: {
  # This machine's display: resolution / refresh / scale.
  wayland.windowManager.hyprland.settings.monitor = ",2560x1600@120,auto,1.25";

  # This machine's touchpad.
  wayland.windowManager.hyprland.settings.input.touchpad = {
    natural_scroll = true;
    clickfinger_behavior = true;
    tap-to-click = true;
  };

  # Waybar keyboard-layout module needs the exact input device name from
  # `hyprctl devices`. Machine-specific — override here per machine.
  programs.waybar.settings.mainBar."hyprland/language".keyboard-name = "at-translated-set-2-keyboard";

  # Machine peripherals: Logitech mouse daemon + udev rules.
  home.packages = with pkgs; [
    logiops
    logitech-udev-rules
  ];
}
