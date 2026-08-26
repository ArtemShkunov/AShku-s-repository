{ pkgs, ... }: {
  imports = [
    ../../modules/home/hyprland/waybar-desktop.nix
  ];

  wayland.windowManager.hyprland.settings.monitor = {
    output = "DP-1";
    mode = "1920x1080@164";
    position = "auto";
    scale = "1";
  };

  # Должно совпадать с клавиатурой, которую Hyprland помечает как main
  # (см. `hyprctl devices`), иначе индикатор раскладки в waybar не обновляется.
  programs.waybar.settings.mainBar."hyprland/language".keyboard-name = "logitech-logig-mkeyboard";

  # Dual GPU: NVIDIA RTX 3050 + Intel iGPU
  wayland.windowManager.hyprland.settings.env = [
    {
      _args = [
        "WLR_NO_HARDWARE_CURSORS"
        "1"
      ];
    }
    {
      _args = [
        "WLR_RENDERER_ALLOW_SOFTWARE"
        "1"
      ];
    }
    {
      _args = [
        "NVD_BACKEND"
        "direct"
      ];
    }
    {
      _args = [
        "__GL_GSYNC_ALLOWED"
        "0"
      ];
    }
    {
      _args = [
        "__GL_VRR_ALLOWED"
        "0"
      ];
    }
    {
      _args = [
        "__NV_PRIME_RENDER_OFFLOAD"
        "1"
      ];
    }
    {
      _args = [
        "__GLX_VENDOR_LIBRARY_NAME"
        "nvidia"
      ];
    }
    {
      _args = [
        "__VK_LAYER_NV_optimus"
        "NVIDIA_only"
      ];
    }
  ];

  home.packages = with pkgs; [
    logiops
    logitech-udev-rules
  ];
}
