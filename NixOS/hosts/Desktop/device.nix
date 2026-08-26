{
  config,
  pkgs,
  ...
}:
{

  services.xserver.enable = true;

  networking.hostName = "Desktop";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [
    "ntfs"
    "exfat"
  ];

  # NOTE: do not force `mem_sleep_default=s2idle` here — this board (Gigabyte
  # B660) never completes a usable resume under s2idle; the firmware default
  # `deep` (S3) suspends/resumes cleanly and honours USB keyboard/mouse wake.

  boot.kernelParams = [
    "i915.enable_dc=0"
    # Let the it87 driver claim the ITE Super-I/O region on the Gigabyte
    # B660 DS3H so it can expose fan PWM (gigabyte_wmi still reads sensors).
    "acpi_enforce_resources=lax"
  ];

  # Dual GPU: Intel iGPU + NVIDIA RTX 3050
  # NOTE: For PRIME offload, run `lspci -nn | grep -E 'VGA|3D'` on the machine
  # and set hardware.nvidia.prime.offload.intelBusId / amdgpuBusId accordingly
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
  };

  # Intel iGPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [
    "nvidia"
    "intel"
  ];

  boot.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
    "i915"
    "gigabyte_wmi" # board hwmon (temps / voltages / fans via WMI)
    "uvcvideo" # Logitech UVC webcam (046d:081b)
    "snd_hda_intel" # NVIDIA HDMI/DP audio codec (monitor built-in speakers)
  ];

  # Motherboard drivers: Gigabyte B660 DS3H DDR4.
  environment.systemPackages = with pkgs; [
    lm_sensors # `sensors` CLI for board/fan/voltage readout
    v4l-utils # webcam / V4L2 utilities
  ];

  # ─── Webcam (Logitech UVC 046d:081b) ───
  # The UVC device is reached by Wayland apps (Firefox/Chrome/etc.) through the
  # camera portal provided by xdg-desktop-portal-hyprland (enabled in the
  # shared hyprland module) on top of the PipeWire service (shared audio.nix).
  # No separate option exists in this nixpkgs; the explicit piece of hardware
  # support here is the device permission rule below.
  #
  # Explicit device permissions for the Logitech webcam: video group, rw
  # access, and a stable /dev/video-logitech symlink.
  services.udev.extraRules = ''
    SUBSYSTEM=="video4linux", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="081b", GROUP="video", MODE="0664", SYMLINK+="video-logitech"
  '';



  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
    "i915"
  ];
}
