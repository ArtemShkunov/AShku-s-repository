# printing.nix — shared CUPS/printing configuration.
{ pkgs, ... }: {
  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.printing.drivers = [
    pkgs.gutenprint
    pkgs.brlaser # Brother printers
    pkgs.hplipWithPlugin # HP printers (requires unfree enabled)
  ];

  # Printer settings GUI
  environment.systemPackages = [ pkgs.system-config-printer ];
}
