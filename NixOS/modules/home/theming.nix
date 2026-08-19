# theming.nix — user-level application of the active theme.
#
# GTK, Qt/KDE, cursor, dconf/xsettingsd and the theme packages. All names
# come from the `theme` value; swap the theme and this whole layer follows.
# (System-level theme packages are in modules/system/theming.nix.)
{ pkgs, theme, ... }: {
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.rose-pine-cursor;
    name = theme.cursor.name;
    size = theme.cursor.size;
  };

  gtk = {
    enable = true;

    theme = {
      name = theme.gtk.theme;
    };

    iconTheme = {
      name = theme.gtk.iconTheme;
      package = pkgs.yaru-theme;
    };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      icon-theme = theme.gtk.iconTheme;
      gtk-theme = theme.gtk.theme;
      cursor-size = theme.cursor.size;
      color-scheme = "prefer-dark";
      accent-color = "orange";
    };
  };

  services.xsettingsd = {
    enable = true;
    settings = {
      "Net/ThemeName" = theme.gtk.theme;
      "Net/IconThemeName" = theme.gtk.iconTheme;
      "Gtk/CursorThemeSize" = theme.cursor.size;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kde";
    style = {
      name = theme.qt.style;
      package = pkgs.kdePackages.breeze;
    };
  };

  # kdeglobals: icons + base color scheme. The BreezeDark.colors body comes
  # from the breeze package so the Qt widget style matches KDE defaults.
  xdg.configFile."kdeglobals".text = ''
    [Icons]
    Theme=${theme.gtk.iconTheme}

    [General]

    ${builtins.readFile "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors"}
  '';

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Qt/KDE theme integration (qt.style = breeze)
    kdePackages.breeze
    kdePackages.breeze-icons
    kdePackages.plasma-integration
    kdePackages.qqc2-desktop-style
    kdePackages.kconfig
    kdePackages.breeze-gtk

    # Cursors
    rose-pine-hyprcursor

    # Nerd Font — та же семья, что в zsh-промпте
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code

    # Иконки / темы
    yaru-theme
    adwaita-icon-theme
    gnome-themes-extra # полноценная тема Adwaita-dark для GTK3
    gnome-desktop # Adwaita для GTK4/Libadwaita

    # Qt platform theme switchers
    libsForQt5.qt5ct
    qt6Packages.qt6ct
  ];
}
