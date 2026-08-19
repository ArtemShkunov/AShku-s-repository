# dev.nix — development tools and direnv.
{ pkgs, ... }: {
  home.packages = with pkgs; [
    zed-editor-fhs
    ripgrep
    lazygit
    opencode
        opencode-desktop
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };
}
