# network.nix — networking / file-transfer / network tools.
{ pkgs, ... }: {
  home.packages = with pkgs; [
    blueman # bluetooth GUI
    bluetui # bluetooth TUI
    impala # network monitoring
    localsend # LAN file transfer
  ];
}
