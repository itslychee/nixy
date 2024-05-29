{
  lib,
  inputs,
  ...
}: let
  inherit (lib) mapAttrs';
in {
  nixpkgs.config.allowUnfree = true;
  nix = {
    nixPath = ["nixpkgs=flake:nixpkgs"];
    registry =
      mapAttrs' (name: val: {
        inherit name;
        value.flake = val;
      })
      inputs;
    settings = {
      flake-registry = "";
      substituters = ["https://cache.garnix.io"];
      trusted-public-keys = ["cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="];
      trusted-users = ["@wheel" "root"];
      builders-use-substitutes = true;
      use-xdg-base-directories = true;
      auto-optimise-store = true;
      max-jobs = "auto";
      experimental-features = [
        "flakes"
        "nix-command"
        "no-url-literals"
        "repl-flake"
        "cgroups"
      ];
    };
  };
}
