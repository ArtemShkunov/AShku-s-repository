# device.nix — MACHINE-SPECIFIC system settings.
#
# Everything in this file is specific to this physical machine (hostname,
# bootloader, battery/power management, bluetooth hardware). A new machine
# (e.g. a desktop) gets its own host dir with its own device.nix and
# hardware-configuration.nix; every other module in this repo is shared.
{
  config,
  pkgs,
  ...
}:
{
  # Hostname — machine identity.
  networking.hostName = "honor-magicbook-x16-plus";

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [
    "ntfs"
    "exfat"
  ];

  # Laptop-only: battery charge thresholds + CPU power governor.
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Machine bluetooth hardware.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };
}
