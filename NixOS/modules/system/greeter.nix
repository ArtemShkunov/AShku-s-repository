# ─── Экран входа: ly ───
#
# Ly — лёгкий TUI-дисплей-менеджер. В отличие от greetd + ReGreet ему не нужен
# отдельный Wayland-композитор (cage) и GTK-сессия: он рисуется прямо в TTY,
# читает сессии из того же каталога, который NixOS готовит для дисплей-
# менеджеров (туда попадает hyprland.desktop), и сразу запускает выбранную
# сессию. Это системный модуль: конфиг применяется до входа пользователя.
{
  theme,
  ...
}:
{
  services.displayManager.ly = {
    enable = true;

    # Только цвета, заголовок и поведение. Остальные значения (tty, session
    # wrappers, shutdown/restart commands) модуль NixOS подставляет сам.
    settings = {
      animation = "none";
      bg = "0x00${theme.colors.bg}";
      fg = "0x00${theme.colors.fg}";
      border_fg = "0x00${theme.colors.accent}";
      error_fg = "0x01${theme.colors.error}";
      box_title = theme.name;
      clock = "%H:%M";
      default_input = "login";
      hide_borders = false;
      numlock = true;
    };
  };
}
