# hosts/thinkpad-t480/hyprland.nix
#
# Системная часть Hyprland. Сосуществует с XFCE: lightdm остаётся
# единственным display manager'ом и просто предлагает Hyprland
# как дополнительную сессию в списке при входе.
{ config, pkgs, lib, ... }:

{
  # Сам Hyprland через встроенный NixOS-модуль.
  # Он сам регистрирует .desktop-файл сессии для lightdm —
  # никакого greetd не нужно, XFCE и Hyprland будут просто
  # соседствовать в выпадающем списке сессий на экране входа.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # XDG Desktop Portal — нужен для screen-share, file pickers, notifications
  # из GUI-приложений под Wayland.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = [ "hyprland" ];
  };

  # ВАЖНО: lightdm + xfce НЕ трогаем здесь — они остаются как есть
  # в основном configuration.nix:
  #   services.xserver.displayManager.lightdm.enable = true;
  #   services.xserver.desktopManager.xfce.enable = true;
  # Этот модуль только добавляет Hyprland рядом, не заменяя ничего.

  # Аудио: pipewire (стандарт для Wayland-композиторов, но и XFCE
  # прекрасно с ним работает через pulse-совместимый слой)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Отключаем pulseaudio явно, чтобы не было конфликта с pipewire-pulse
  services.pulseaudio.enable = lib.mkForce false;

  # Полезные системные утилиты для Wayland-окружения
  environment.systemPackages = with pkgs; [
    wl-clipboard          # буфер обмена под Wayland (в XFCE/X11 у тебя остаётся xclip)
    grim                  # скриншоты
    slurp                 # выбор области для скриншота
    swappy                # аннотирование скриншотов
    wf-recorder            # запись экрана
    brightnessctl           # яркость экрана — актуально для T480
    playerctl                # управление медиа
    polkit_gnome              # polkit-агент для запроса прав
    pavucontrol                 # GUI для звука поверх pipewire-pulse
  ];

  # Разрешаем яркость без sudo для обычных пользователей

  # Wayland-совместимость для Electron/Chromium-приложений.
  # Эти переменные session-wide, но XFCE-сессия под X11 их просто
  # игнорирует, так что конфликтов нет.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
