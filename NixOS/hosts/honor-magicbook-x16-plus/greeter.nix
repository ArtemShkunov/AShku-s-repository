{ config, lib, pkgs, ... }:

# ─── LightDM greeter: экран входа в теме "sunset pines" ───
#
# Это системный модуль (не home-manager!), потому что greeter рисуется
# демоном lightdm ещё ДО входа в чей-либо сеанс — у него нет доступа
# к home-manager конфигу пользователя.
#
# Выбор сессии (Hyprland / XFCE) остаётся полностью рабочим: он идёт
# через индикатор "~session" ниже и никак не завязан на тему.
{
  services.xserver.displayManager.lightdm = {
    enable = true; # уже включено в configuration.nix, дублируется для ясности модуля

    # Цвет фона греетера — самый тёмный тон из палитры (тот же, что
    # background в kitty.nix и hyprlock). Работает сразу, без каких-либо
    # дополнительных файлов и без проблем с правами доступа.
    background = "#16141f";

    # ── Вариант с реальными обоями вместо плоского цвета ──
    # lightdm рисует greeter от имени системного пользователя lightdm,
    # а не artemmkk-sh, поэтому путь вида /home/artemmkk-sh/Data/Wallpaper.png
    # может оказаться недоступен из-за прав на домашнюю директорию (обычно 700).
    # Надёжный способ — скопировать обои в репозиторий конфига и подключить
    # как относительный путь: Nix сам скопирует файл в /nix/store, и
    # никаких проблем с правами уже не будет.
    #
    #   cp ~/Data/Wallpaper.png ~/.nixos-config/hosts/thinkpad-t480/greeter-wallpaper.png
    #
    # background = ./greeter-wallpaper.png;

    greeters.gtk = {
      enable = true;

      # Та же связка, что и на десктопе в hyprland.nix: Adwaita-dark + Yaru.
      theme = {
        name = "Adwaita-dark";
        package = pkgs.gnome-themes-extra;
      };

      iconTheme = {
        name = "Yaru";
        package = pkgs.yaru-theme;
      };

      cursorTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
        size = 24; # совпадает с HYPRCURSOR_SIZE / XCURSOR_SIZE
      };

      clock-format = "%H:%M";

      # ~session оставляет переключатель сеанса на экране входа —
      # именно он даёт возможность выбрать XFCE вместо Hyprland.
      indicators = [
        "~host"
        "~spacer"
        "~clock"
        "~spacer"
        "~session"
        "~language"
        "~a11y"
        "~power"
      ];

      extraConfig = ''
        font-name = JetBrainsMono Nerd Font 11
        # Не даём AccountsService подставлять случайный per-user фон
        # поверх нашего — иначе тема может "слететь" после первого входа.
        user-background = false
      '';
    };
  };
}
