# power.nix — suspend tweaks: wake from suspend on any keyboard/mouse/touchpad.
{ ... }: {
  # Allow the machine to be resumed from suspend with ANY keyboard, mouse or
  # touchpad, not just the power button. By default the xHCI USB controllers
  # and hubs have `power/wakeup = disabled`, which blocks every downstream USB
  # device from waking the system; internal laptop keyboards/touchpads live on
  # parent devices (i2c/serio) whose wakeup is also off. Walk the sysfs tree and
  # turn wakeup on for all input devices, the whole USB chain, and the ACPI
  # PS/2 entries. No RemainAfterExit: the unit must re-run before every suspend
  # (suspend.target), since some drivers clear their wakeup flag on unbind.
  systemd.services.enable-wakeup = {
    description = "Enable wakeup on input and USB devices";
    script = ''
      for dev in /sys/class/input/input*/device; do
        p="$dev"
        while [ "$p" != "/" ]; do
          if [ -f "$p/power/wakeup" ]; then
            echo enabled > "$p/power/wakeup" 2>/dev/null || true
            break
          fi
          p="$(dirname "$p")"
        done
      done
      for dev in /sys/bus/usb/devices/*; do
        if [ -f "$dev/power/wakeup" ]; then
          echo enabled > "$dev/power/wakeup" 2>/dev/null || true
        fi
      done
      # PS/2 ports are wired through ACPI; writing to /proc/acpi/wakeup
      # toggles, so flip only entries that are currently disabled.
      for name in PS2K PS2M KBD; do
        if grep -q "^$name[[:space:]].*disabled" /proc/acpi/wakeup 2>/dev/null; then
          echo "$name" > /proc/acpi/wakeup 2>/dev/null || true
        fi
      done
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    wantedBy = [
      "multi-user.target"
      "suspend.target"
    ];
  };

  # Catch devices plugged in after boot.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/wakeup", ATTR{power/wakeup}="enabled"
  '';
}
