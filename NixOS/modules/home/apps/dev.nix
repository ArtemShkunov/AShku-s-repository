# dev.nix — development tools and direnv.
{ pkgs, ... }: {
  home.packages = with pkgs; [
    zed-editor-fhs
    ripgrep
    lazygit
    opencode
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };
}
