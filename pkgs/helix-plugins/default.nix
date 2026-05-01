{
  lib,
  newScope,
}:
lib.makeScope newScope (
  self:
    with self; {
      buildHelixPlugin = callPackage ./build-helix-plugin.nix {};

      helix-file-watcher = callPackage ./helix-file-watcher {};

      scooter-hx = callPackage ./scooter-hx.nix {};

      wakatime-hx = callPackage ./wakatime-hx.nix {};
    }
)
