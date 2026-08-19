# browsers.nix — web browsers (from flake inputs).
{ pkgs, inputs, ... }: {
  home.packages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
