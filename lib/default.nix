{
  self,
  nixpkgs,
  ...
} @ inputs: let
  inherit
    (nixpkgs.lib)
    genAttrs
    listToAttrs
    nixosSystem
    flatten
    mkForce
    ;
in rec {
  # Supported systems that I use throughout my daily life
  systems = ["x86_64-linux" "aarch64-linux"];
  per = genAttrs systems;
  keys = import ./keys.nix; 

  mkSystems = arch: hosts: (listToAttrs (
    map (name: {
      inherit name;
      value = mkSystem arch name;
    })
    hosts
  ));
  mkSystem = arch: hostname:
    nixosSystem {
      specialArgs = {
        mylib = self.lib;
        inherit inputs;
      };
      modules = flatten [
        { 
          hey.nix.enable = true;
          networking = {
              useDHCP = mkForce false;
              hostName = hostname;
          };
          nixpkgs = {
              config.allowUnfree = true;
              hostPlatform = arch;
          };
        }
        # Host
        (import "${self}/hosts/${hostname}")
        # Module system
        (import "${self}/modules")
      ];
    };
}
