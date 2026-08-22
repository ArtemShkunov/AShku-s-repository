{
  config,
  pkgs,
  ...
}:
{
  networking.hostName = "Desktop";
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "ntfs" "exfat" ];

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
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" "intel" ];

  boot.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" "i915" ];
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" "i915" ];
}
