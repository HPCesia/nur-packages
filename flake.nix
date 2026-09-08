{
  description = "My personal NUR repository";
  nixConfig = {
    extra-substituters = ["https://hpcesia-nur.cachix.org"];
    extra-trusted-public-keys = [
      "hpcesia-nur.cachix.org-1:/Fz990j/JffxBxEQ3QopyGGhH9uO8goHdSKZnzaQSWg="
    ];
  };
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs = {
    self,
    nixpkgs,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in {
    legacyPackages = forAllSystems (system:
      import ./default.nix {
        pkgs = import nixpkgs {inherit system;};
      });
    packages = forAllSystems (system: let
      attrs = self.legacyPackages.${system};
    in
      builtins.listToAttrs (
        builtins.concatMap (name: let
          result = builtins.tryEval attrs.${name};
        in
          if result.success && nixpkgs.lib.isDerivation result.value
          then [
            {
              inherit name;
              value = result.value;
            }
          ]
          else []) (builtins.attrNames attrs)
      ));
    devShells = forAllSystems (system: {
      default = import ./shell.nix {
        pkgs = import nixpkgs {inherit system;};
      };
    });
    nixosModules = import ./nixos-modules;
    # homeModules = import ./home-modules;
    # darwinModules = import ./darwin-modules;
    # flakeModules = import ./flake-modules;
  };
}
