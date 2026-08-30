# networking.nix — shared network configuration.
{ ... }: {
  # Enable networking
  networking.networkmanager.enable = true;

  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  # LocalSend — discovery (UDP) and file transfer (TCP) both use 53317.
  networking.firewall.allowedTCPPorts = [ 53317 ];
  networking.firewall.allowedUDPPorts = [ 53317 ];

  # Network printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
