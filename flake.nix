{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    mvn2nix.url = "github:sysedwinistrator/mvn2nix";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    mvn2nix,
    utils,
    ...
  }: let
    pkgsForSystem = system:
      import nixpkgs {
        # ./overlay.nix contains the logic to package local repository
        overlays = [mvn2nix.overlay (import ./overlay.nix)];
        inherit system;
      };
  in
    utils.lib.eachSystem utils.lib.defaultSystems (system: rec {
      legacyPackages = pkgsForSystem system;
      packages = utils.lib.flattenTree {
        inherit (legacyPackages) sonar-scanner-cli;
      };
      defaultPackage = legacyPackages.sonar-scanner-cli;
    });
}
