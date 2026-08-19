# office.nix — document/office apps and language tools.
{ pkgs, ... }: {
  home.packages = with pkgs; [
    libreoffice
    obsidian
    kdePackages.okular

    # Spelling/hyphenation for LibreOffice (RU + EN)
    hunspell
    hyphen
    hyphenDicts.ru-ru
    hyphenDicts.ru_RU
    hunspellDicts.ru_RU
    hunspellDicts.ru-ru
  ];
}
