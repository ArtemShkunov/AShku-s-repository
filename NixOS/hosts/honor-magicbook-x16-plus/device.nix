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

  # Machine hardware/drivers.
  #
  # Audited on this board (BRI-XX, Ryzen 7 8845HS "Phoenix"):
  # - GPU Radeon 780M / CPU microcode: amdgpu + amd microcode updates are
  #   in-tree already (see hardware-configuration.nix); nothing to add.
  # - WiFi Qualcomm WCN6855 (ath11k_pci): firmware comes via
  #   hardware.enableRedistributableFirmware and the kernel wireless-regdb is
  #   loaded through hardware.wirelessRegulatoryDatabase (both default true).
  #   The `ath11k ... failed to process regulatory info -22` journal lines are
  #   a known cosmetic quirk of this card, not a failure.
  # - Camera: UVC (uvcvideo), works out of the box.
  # - Fingerprint Goodix 27c6:5f10: unsupported by mainline libfprint;
  #   intentionally skipped (the experimental community driver requires a
  #   Windows dual-boot partition to extract a per-device TLS key).
  #
  # Enabled below: Thunderbolt/USB4 authorization daemon, firmware update
  # service, and iio-sensor-proxy for the amd_sfh accelerometer/light sensor.

  # Thunderbolt / USB4 device authorization (this board has two USB4 NHI
  # controllers; bolt manages docking stations and authorized devices).
  services.hardware.bolt.enable = true;

  # Firmware update service (UEFI capsules, SSD firmware, etc.).
  services.fwupd.enable = true;

  # Expose the amd_sfh accelerometer / ambient-light sensor to userspace
  # (iio-sensor-proxy picks them up over the HID sensor framework).
  hardware.sensor.iio.enable = true;

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
