# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  selfLib = import ./lib {inherit pkgs;};
  callPackage = pkgs.lib.callPackageWith (pkgs // {inherit selfLib;});
in {
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = selfLib;
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  dwproton-bin = callPackage ./pkgs/dwproton-bin {};

  elio = callPackage ./pkgs/elio {};

  gitmal = callPackage ./pkgs/gitmal {};

  harmonoid = callPackage ./pkgs/harmonoid {};

  helixPlugins = callPackage ./pkgs/helix-plugins {};

  kelivo = callPackage ./pkgs/kelivo {};

  miaomiaowu = callPackage ./pkgs/miaomiaowu {};

  localbooru-bin = callPackage ./pkgs/localbooru-bin {};

  mo2-lint = callPackage ./pkgs/mo2-lint {};

  musly-player = callPackage ./pkgs/musly-player {};

  nocturne = callPackage ./pkgs/nocturne {};

  particle-music = callPackage ./pkgs/particle-music {};

  shimmie2 = callPackage ./pkgs/shimmie2 {};

  spritz-wine-bin = callPackage ./pkgs/spritz-wine-bin {};
}
