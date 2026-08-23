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

  boot.kernelParams = [ "i915.enable_dc=0" ];

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
  ];
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
    "i915"
  ];
}
