{
  config,
  pkgs,
  theme,
  ...
}:
{
  services.mako = {
    enable = true;

    settings = {
      background-color = "#${theme.colors.surface}ee";
      text-color = "#${theme.colors.fg}";
      border-color = "#${theme.colors.accent}";
      border-size = 2;
      border-radius = 8;

      default-timeout = 6000;
      ignore-timeout = false;

      font = "${theme.fonts.mono} 11";
      width = 320;
      height = 110;
      margin = "8";
      padding = "10,14";
      anchor = "top-right";

      icons = true;
      max-icon-size = 32;

      # Низкоприоритетные — приглушённая рамка
      "urgency=low" = {
        border-color = "#${theme.colors.border}";
        default-timeout = 4000;
      };

      # Важные — тревожный красно-оранжевый, не исчезают сами
      "urgency=high" = {
        border-color = "#${theme.colors.error}";
        default-timeout = 0;
      };
    };
  };
}
