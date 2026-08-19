# hyprlock.nix — lockscreen in the active theme's colors.
{ theme, ... }: {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0; # без "льготного" периода без пароля — это экран блокировки
        hide_cursor = true;
        no_fade_in = false;
        no_fade_out = true;
      };

      background = [
        {
          monitor = "";
          path = "";
          color = "rgba(${theme.colors.bg-lock}ff)";
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "260, 60";
          position = "0, -100";
          halign = "center";
          valign = "center";

          outline_thickness = 3;
          dots_size = 0.25;
          dots_spacing = 0.25;
          dots_center = true;
          fade_on_empty = false;

          # Те же цвета, что в hyprland.nix / kitty.
          outer_color = "rgba(${theme.colors.accent}ee)";
          inner_color = "rgba(${theme.colors.bg}d8)";
          font_color = "rgb(${theme.colors.fg})";
          check_color = "rgb(${theme.colors.success})";
          fail_color = "rgb(${theme.colors.error})";

          placeholder_text = ''<span foreground="##${theme.colors.fg-dim}">Password...</span>'';
          fail_text = ''<span foreground="##${theme.colors.error}">Wrong password</span>'';

          shadow_passes = 2;
          shadow_size = 3;
        }
      ];

      label = [
        {
          # Часы
          monitor = "";
          text = "$TIME";
          font_size = 90;
          font_family = theme.fonts.mono;
          color = "rgb(${theme.colors.accent-bright})";
          position = "0, 160";
          halign = "center";
          valign = "center";
        }
        {
          # Дата
          monitor = "";
          text = ''cmd[update:60000] echo "$(LC_TIME=en_US.UTF-8 date +'%A, %d %B')"'';
          font_size = 22;
          font_family = theme.fonts.mono;
          color = "rgb(${theme.colors.fg})";
          position = "0, 80";
          halign = "center";
          valign = "center";
        }
        {
          # Имя пользователя
          monitor = "";
          text = "  $USER";
          font_size = 18;
          font_family = theme.fonts.mono;
          color = "rgb(${theme.colors.accent})";
          position = "0, -30";
          halign = "center";
          valign = "center";
        }
        {
          # Текущая раскладка клавиатуры, справа от поля ввода
          monitor = "";
          text = "$LAYOUT[EN,RU]";
          font_size = 14;
          font_family = theme.fonts.mono;
          color = "rgb(${theme.colors.accent})";
          position = "175, -100";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
