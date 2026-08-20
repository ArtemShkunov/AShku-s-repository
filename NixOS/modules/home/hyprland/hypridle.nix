# hypridle.nix — idle management (lock/dpms/suspend on inactivity).
{ ... }: {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # Запускать hyprlock именно по dbus/logind-событию блокировки,
        # но не плодить несколько инстансов, если он уже открыт.
        lock_cmd = "pidof hyprlock || hyprlock";
        # Срабатывает на ЛЮБОЙ уход в сон: по таймауту, вручную (systemctl
        # suspend / loginctl suspend) или при закрытии крышки — поэтому
        # экран будет блокироваться независимо от того, как вызван сон.
        before_sleep_cmd = "loginctl lock-session";
        # Чтобы монитор не приходилось "будить" двойным нажатием клавиши.
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms(\"on\")'";
        ignore_dbus_inhibit = false;
      };

      listener = [
        {
          timeout = 300; # 5 минут бездействия — блокировка экрана
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330; # 5.5 минут — гасим подсветку экрана
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms(\"off\")'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms(\"on\")'";
        }
        {
          timeout = 360; # 6 минут — уход в спящий режим
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
