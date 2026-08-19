{
  config,
  pkgs,
  theme,
  ...
}:
{
  programs.wofi = {
    enable = true;

    settings = {
      width = 600;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Apps";
      allow_markup = true;
      insensitive = true;
      allow_images = true;
      image_size = 32;
      term = "kitty";
    };

    style = ''
      * {
        font-family: "${theme.fonts.mono}", "${theme.fonts.monoFallback}", sans-serif;
        font-size: 14px;
      }

      window {
        background-color: #${theme.colors.surface};
        border: 2px solid #${theme.colors.accent};
        border-radius: 10px;
      }

      #input {
        margin: 8px;
        padding: 8px 12px;
        background-color: #${theme.colors.bg};
        color: #${theme.colors.fg};
        border: 1px solid #${theme.colors.border};
        border-radius: 6px;
      }

      #inner-box,
      #outer-box {
        background-color: transparent;
      }

      #entry {
        padding: 6px 8px;
        border-radius: 6px;
      }

      #entry:selected {
        background-color: #${theme.colors.accent};
      }

      #entry:selected #text {
        color: #${theme.colors.bg};
      }

      #text {
        color: #${theme.colors.fg};
      }

      #img {
        margin-right: 8px;
      }

      #scroll {
        margin: 0 4px 8px 4px;
      }
    '';
  };
}
