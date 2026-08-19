# base.nix — shared system baseline.
#
# Machine-independent foundation: nix/flake settings, locale, timezone,
# the user account, and essential CLI tools. Imported by every host.
{ pkgs, ... }: {
  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Allow zsh and define the user account.
  programs.zsh.enable = true;
  users.users."artemmkk-sh" = {
    isNormalUser = true;
    description = "Artemmkk-sh";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  environment.variables = {
    TERMINAL = "kitty";
  };

  # Essential system packages (non-GUI).
  environment.systemPackages = with pkgs; [
    vim # fallback editor
    wget
    git # flakes and much more
    gparted
    ntfs3g
  ];

  system.stateVersion = "26.05";
}
