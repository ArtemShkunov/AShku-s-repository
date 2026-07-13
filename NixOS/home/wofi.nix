{ config, pkgs, ... }:
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
        font-family: "JetBrainsMono Nerd Font", "Fira Code Nerd Font", sans-serif;
        font-size: 14px;
      }

      window {
        background-color: #241f30;
        border: 2px solid #f2994a;
        border-radius: 10px;
      }

      #input {
        margin: 8px;
        padding: 8px 12px;
        background-color: #16141f;
        color: #f5e9dc;
        border: 1px solid #4a3b4f;
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
        background-color: #f2994a;
      }

      #entry:selected #text {
        color: #16141f;
      }

      #text {
        color: #f5e9dc;
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
