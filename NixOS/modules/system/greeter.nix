{
  config,
  lib,
  pkgs,
  theme,
  ...
}:

# ─── Экран входа: greetd + ReGreet, тема "sunset pines" ───
#
# LightDM отсюда убран — он был нужен только для XFCE-гритера, а XFCE
# теперь удалён. ReGreet — GTK4-гритер для минималистичного демона greetd,
# из всех вариантов под Wayland/Hyprland он ближе всего по духу к
# hyprlock/hyprpolkitagent: тёмный, кастомизируется через тему + CSS,
# без лишнего "десктопного" функционала LightDM.
#
# Важная оговорка о том, что реально означает "похож на hyprlock во всём":
# цвета, скругления, шрифт и тёмный фон — воспроизводятся полностью.
# А вот РАСКЛАДКА экрана (у hyprlock она обьявляется вручную, элемент за
# элементом, через labels/image в hyprlock.conf) у ReGreet фиксирована
# самим приложением: поле пароля, список пользователей/сессий и кнопки
# питания стоят там, где их разместили авторы ReGreet, подвинуть их нельзя.
# Это компромисс, на который идут все, кто использует greetd — более точное
# повторение потребовало бы поднимать на экране входа полноценный Hyprland
# с самописной imitation-of-hyprlock сценой, что уже не "гритер", а отдельный
# хрупкий костыль поверх PAM. ReGreet — разумный максимум за вменяемые деньги.
#
# Это системный модуль (не home-manager!) — гритер рисуется демоном greetd
# ещё ДО входа в чей-либо сеанс, от имени системного пользователя "greeter",
# у которого нет доступа к home-manager конфигу artemmkk-sh.
{
  services.greetd = {
    enable = true;
    settings = {
      # user для default_session по умолчанию уже "greeter" (задаётся самим
      # модулем services.greetd), явно не указываем.
    };
  };

  # greetd — не x11-программа и не читает /usr/share/{x,wayland}-sessions
  # (эти пути на NixOS попросту не существуют). ReGreet ищет .desktop файлы
  # сессий только через $XDG_DATA_DIRS, поэтому явно подсовываем ему тот же
  # каталог с сессиями, который NixOS собирает для дисплей-менеджеров
  # (туда автоматически попадает hyprland.desktop благодаря
  # programs.hyprland.enable = true в configuration.nix).
  systemd.services.greetd.environment.XDG_DATA_DIRS =
    "${config.services.displayManager.sessionData.desktops}/share:/run/current-system/sw/share:/usr/share";

  services.displayManager.regreet = {
    enable = true;

    # Та же связка темы, что и на десктопе (modules/home/theming.nix) —
    # имена берутся из theme.gtk.
    theme = {
      name = theme.gtk.theme;
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = theme.gtk.iconTheme;
      package = pkgs.yaru-theme;
    };

    cursorTheme = {
      name = theme.gtk.cursorTheme;
      package = pkgs.adwaita-icon-theme;
    };

    font = {
      name = theme.fonts.mono;
      size = 14;
    };

    # Тёмный режим и мигающий курсор — не покрываются typed-опциями выше,
    # поэтому идут через settings.GTK. ВАЖНО: theme_name/icon_theme_name/
    # cursor_theme_name/font_name сюда НЕ дублируем — модуль сам генерирует
    # их из theme/iconTheme/cursorTheme/font выше, а повторное определение
    # тех же ключей в settings ловит баг с "double settings definition"
    # (nixpkgs issue #335082).
    settings = {
      GTK = {
        application_prefer_dark_theme = true;
        cursor_blink = true;
      };
    };

    # Фон — плоский цвет, как и у hyprlock (у него тоже нет обоев, только
    # rgba(1a1a1aff)), поэтому никакой [background]-секции с картинкой не
    # заводим — заодно нет и риска нарваться на проблему прав доступа
    # к ~/Data/Wallpaper.png (гритер работает от пользователя "greeter",
    # который не может залезть в домашний каталог artemmkk-sh).
    #
    # Если позже захочется настоящие обои вместо плоского цвета — тот же
    # трюк, что был в старой версии этого файла для LightDM: скопировать
    # картинку в репозиторий конфига и подключить относительным путём,
    # тогда Nix сам положит её в /nix/store, и прав уже хватит:
    #
    #   cp ~/Data/Wallpaper.png ~/.nixos-config/hosts/thinkpad-t480/greeter-wallpaper.png
    #
    # settings.background = { path = ./greeter-wallpaper.png; fit = "Cover"; };

    # extraCss — единственное место, где реально настраивается "форма":
    # скругления/рамки/цвета конкретных виджетов. Здесь используются только
    # универсальные GTK4-селекторы (window/entry/button/label), которые
    # гарантированно существуют в любом GTK4-приложении. Точную подгонку
    # под внутреннюю структуру ReGreet (например, отдельный класс у контейнера
    # с часами) авторы ReGreet сами рекомендуют делать через GTK Inspector
    # в demo-режиме (regreet --demo), а не угадывать селекторы вслепую —
    # см. https://github.com/rharish101/ReGreet#css.
    extraCss = ''
      window {
        background-color: #${theme.colors.bg};
      }

      entry {
        background-color: #${theme.colors.bg}d9;
        border: 2px solid #${theme.colors.accent}d9;
        border-radius: 14px;
        color: #${theme.colors.fg};
        padding: 8px 12px;
      }

      entry:focus-within {
        border-color: #${theme.colors.accent-bright};
        box-shadow: 0 0 0 1px #${theme.colors.accent-bright}59;
      }

      button {
        background-color: transparent;
        border: 1px solid #${theme.colors.accent}66;
        border-radius: 10px;
        color: #${theme.colors.fg};
      }

      button:hover {
        background-color: #${theme.colors.accent}26;
        border-color: #${theme.colors.accent-bright};
      }

      label {
        color: #${theme.colors.fg};
      }
    '';
  };
}
