{
  lib,
  newScope,
}:
lib.makeScope newScope (
  self:
    with self; {
      buildHelper = callPackage ./build-helper.nix {};
      cachyos = callPackage ./cachyos.nix {};
      tkg = callPackage ./tkg.nix {};
    }
)
