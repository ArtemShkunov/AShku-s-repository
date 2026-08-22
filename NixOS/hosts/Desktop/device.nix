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
}
