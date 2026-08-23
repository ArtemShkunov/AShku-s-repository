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
    "it87" # ITE Super-I/O on the B660 DS3H — exposes fan PWM for fancontrol
    "uvcvideo" # Logitech UVC webcam (046d:081b)
  ];

  # Motherboard drivers: Gigabyte B660 DS3H DDR4.
  environment.systemPackages = with pkgs; [
    lm_sensors # `sensors` CLI for board/fan/voltage readout
    v4l-utils # webcam / V4L2 utilities
  ];

  # RGB lighting control (OpenRGB). Auto-loads i2c-dev + i2c-i801 for the
  # Gigabyte RGB Fusion controller.
  services.hardware.openrgb = {
    enable = true;
    motherboard = "intel";
  };

  # Software fan control (lm_sensors fancontrol). Requires a config generated
  # on-machine once the it87 driver exposes PWM: run `sudo pwmconfig` and paste
  # its output into `hardware.fancontrol.config` below, then flip enable.
  hardware.fancontrol = {
    enable = false;
    config = ''
      # TODO: fill from `sudo pwmconfig` output once /sys/class/hwmon/*/pwm* exists.
    '';
  };
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
    "i915"
  ];
}
