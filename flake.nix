{
  inputs = {
    utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/master";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    mpdrp.url = "github:itslychee/mpdrp";
    mpdrp.inputs.unstable-nixpkgs.follows = "nixpkgs-unstable";
  };
  outputs = {
    self,
    utils,
    nixpkgs,
    home-manager,
    mpdrp,
    ...
  }@inputs: let
    mkSystem = {
      hostname,
      system ? "x86_64-linux",
      users,
      flags ? {},
      overrides ? {},
    }@args: overrides: let
      mkConfig = {
        hostname,
        system ? "x86_64-linux",
        users,
        flags ? {}
      }: rec {
        inherit system;
        specialArgs = {
         inherit hostname inputs flags; 
        };
        modules = [
          {   nixpkgs.config.allowUnfreePredicate = _: true; }
          ./hosts/${hostname}/configuration.nix
          ./hosts/${hostname}/hardware-configuration.nix
          ./hosts/shared.nix
          {
            nixpkgs.overlays = [
              (old: final: {
                unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
              })
              mpdrp.overlays.${system}.default
            ];
            system.stateVersion = "22.11";
            services.dbus.enable = true;
          }
          home-manager.nixosModules.home-manager { 
            home-manager.verbose = true;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.sharedModules = [
              { home.stateVersion = "23.05"; }
              { imports = [ mpdrp.nixosModules.default ];}
            ];
            home-manager.users = users;
          }
        ];
      }; in nixpkgs.lib.nixosSystem ((mkConfig args) // overrides (mkConfig args));
  in {
    formatter = utils.lib.eachDefaultSystem (system: inputs.nixpkgs-unstable.legacyPackages.${system}.alejandra); 
    nixosConfigurations.embassy = mkSystem {
      hostname = "embassy";
      users = {
        lychee = ./home;
      };
    } (_: {});
    nixosConfigurations.cutesy = (mkSystem {
      hostname = "cutesy";
      users = {
        lychee = ./home;
        prod = ./home;
      };
      flags = {
        harden = true;
        headless = true;
      };
    }) (_: {});
    nixosConfigurations.fruitpie = (mkSystem {
      hostname = "fruitpie";
      users.pi = ./home;
      flags = {
        harden = true;
        headless = true;
      };
    }) (_: {});
  };
}

