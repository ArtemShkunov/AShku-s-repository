# kitty.nix — the kitty terminal emulator.
#
# Terminal colours come from theme.terminal (the 16-color palette) and
# theme.colors; font from theme.fonts. Machine-independent.
{ pkgs, theme, ... }: {
  programs.kitty = {
    enable = true;
    settings = {
      background_opacity = "0.75";
      confirm_os_window_close = 0;

      # Цвета терминала в тон теме
      background = "#${theme.colors.bg}";
      foreground = "#${theme.colors.fg}";
      cursor = "#${theme.colors.accent-bright}";
      selection_background = "#${theme.colors.border}";
      selection_foreground = "#${theme.colors.fg}";

      color0 = "#${theme.terminal.color0}";
      color1 = "#${theme.terminal.color1}";
      color2 = "#${theme.terminal.color2}";
      color3 = "#${theme.terminal.color3}";
      color4 = "#${theme.terminal.color4}";
      color5 = "#${theme.terminal.color5}";
      color6 = "#${theme.terminal.color6}";
      color7 = "#${theme.terminal.color7}";
      color8 = "#${theme.terminal.color8}";
      color9 = "#${theme.terminal.color9}";
      color10 = "#${theme.terminal.color10}";
      color11 = "#${theme.terminal.color11}";
      color12 = "#${theme.terminal.color12}";
      color13 = "#${theme.terminal.color13}";
      color14 = "#${theme.terminal.color14}";
      color15 = "#${theme.terminal.color15}";
    };

    keybindings = {
      "ctrl+1" = "send_text all \\x1b[49;5u";
      "ctrl+2" = "send_text all \\x1b[50;5u";
      "ctrl+3" = "send_text all \\x1b[51;5u";
      "ctrl+4" = "send_text all \\x1b[52;5u";
      "ctrl+5" = "send_text all \\x1b[53;5u";
      "ctrl+6" = "send_text all \\x1b[54;5u";
      "ctrl+7" = "send_text all \\x1b[55;5u";
      "ctrl+8" = "send_text all \\x1b[56;5u";
      "ctrl+9" = "send_text all \\x1b[57;5u";
    };

    font = {
      name = theme.fonts.mono;
    };
  };

  # xdg-terminal-exec — default terminal launcher resolution.
  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = [ "kitty.desktop" ];
    };
  };

  home.packages = with pkgs; [ xdg-terminal-exec ];
}
