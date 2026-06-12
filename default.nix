# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: {
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  dwproton-bin = pkgs.callPackage ./pkgs/dwproton-bin {};

  elio = pkgs.callPackage ./pkgs/elio {};

  harmonoid = pkgs.callPackage ./pkgs/harmonoid {};

  helixPlugins = pkgs.callPackage ./pkgs/helix-plugins {};

  kelivo = pkgs.callPackage ./pkgs/kelivo {};

  localbooru-bin = pkgs.callPackage ./pkgs/localbooru-bin {};

  mo2-lint = pkgs.callPackage ./pkgs/mo2-lint {};

  musly-player = pkgs.callPackage ./pkgs/musly-player {};

  nocturne = pkgs.callPackage ./pkgs/nocturne {};

  particle-music = pkgs.callPackage ./pkgs/particle-music {};

  shimmie2 = pkgs.callPackage ./pkgs/shimmie2 {};

  spritz-wine-bin = pkgs.callPackage ./pkgs/spritz-wine-bin {};
}
