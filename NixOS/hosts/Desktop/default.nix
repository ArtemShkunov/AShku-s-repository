# Host entry point for honor-magicbook-x16-plus.
#
# A host = hardware-configuration.nix (generated) + device.nix (machine
# specifics) + the shared system modules. Everything else in the repo is
# shared and identical across machines.
{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./device.nix

    ../../modules/system/base.nix
    ../../modules/system/networking.nix
    ../../modules/system/audio.nix
    ../../modules/system/printing.nix
    ../../modules/system/fonts.nix
    ../../modules/system/theming.nix
    ../../modules/system/desktop.nix
    ../../modules/system/greeter.nix
  ];
}

