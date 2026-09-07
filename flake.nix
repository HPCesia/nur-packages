{
  description = "My personal NUR repository";
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
