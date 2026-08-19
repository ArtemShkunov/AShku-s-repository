# networking.nix — shared network configuration.
{ ... }: {
  # Enable networking
  networking.networkmanager.enable = true;

  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # Network printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
