# printing.nix — shared CUPS/printing configuration.
{ pkgs, ... }: {
  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.printing.drivers = [
    pkgs.gutenprint
    pkgs.brlaser # Brother printers
    pkgs.hplip # HP printers (requires unfree enabled; no proprietary plugin, avoids developers.hp.com fetch)
  ];

  # Printer settings GUI
  environment.systemPackages = [ pkgs.system-config-printer ];
}
