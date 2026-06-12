{
  lib,
  newScope,
}:
lib.makeScope newScope (
  self:
    with self; {
      buildHelper = callPackage ./build-helper.nix {};
      cachyos = callPackage ./cachyos.nix {};
      dwproton = callPackage ./dwproton.nix {};
      tkg = callPackage ./tkg.nix {};
    }
)
