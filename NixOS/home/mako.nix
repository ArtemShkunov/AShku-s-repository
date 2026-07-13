{ config, pkgs, ... }:
{
  services.mako = {
    enable = true;

    settings = {
      background-color = "#241f30ee";
      text-color = "#f5e9dc";
      border-color = "#f2994a";
      border-size = 2;
      border-radius = 8;

      default-timeout = 6000;
      ignore-timeout = false;

      font = "JetBrainsMono Nerd Font 11";
      width = 320;
      height = 110;
      margin = "8";
      padding = "10,14";
      anchor = "top-right";

      icons = true;
      max-icon-size = 32;

      #低приоритетные — приглушённая рамка
      "urgency=low" = {
        border-color = "#4a3b4f";
        default-timeout = 4000;
      };

      # Важные — тревожный красно-оранжевый, не исчезают сами
      "urgency=high" = {
        border-color = "#e8613c";
        default-timeout = 0;
      };
    };
  };
}
