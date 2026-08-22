{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      zen-browser,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      # Active theme — swap themes/default.nix (or edit it) to re-theme.
      theme = import ./themes/default.nix;
    in
    {
      nixosConfigurations."honor-magicbook-x16-plus" = nixpkgs.lib.nixosSystem {
        inherit system;
        # `theme` (and `inputs`) are passed to every system module.
        specialArgs = { inherit inputs theme; };
        modules = [
          ./hosts/honor-magicbook-x16-plus/default.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = "backup";
            home-manager.useUserPackages = true;
            # `theme` (and `inputs`) reach every home-manager module.
            home-manager.extraSpecialArgs = { inherit inputs theme; };
            # Shared user config + this host's machine-specific home bits.
            home-manager.users."artemmkk-sh" = {
              imports = [
                (import ./home/artemmkk-sh.nix)
                (import ./hosts/honor-magicbook-x16-plus/home.nix)
              ];
            };
          }
        ];
      };
    };

      nixosConfigurations."Desktop" = nixpkgs.lib.nixosSystem {
        inherit system;
        # `theme` (and `inputs`) are passed to every system module.
        specialArgs = { inherit inputs theme; };
        modules = [
          ./hosts/Desktop/default.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.backupFileExtension = "backup";
            home-manager.useUserPackages = true;
            # `theme` (and `inputs`) reach every home-manager module.
            home-manager.extraSpecialArgs = { inherit inputs theme; };
            # Shared user config + this host's machine-specific home bits.
            home-manager.users."artemmkk-sh" = {
              imports = [
                (import ./home/artemmkk-sh.nix)
                (import ./hosts/Desktop/home.nix)
              ];
            };
          }
        ];
      };
}
