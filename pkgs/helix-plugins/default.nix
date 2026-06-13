{
  lib,
  newScope,
}:
lib.makeScope newScope (
  self:
    with self; {
      buildHelixPlugin = callPackage ./build-helix-plugin.nix {};

      fcitx-focus = callPackage ./fcitx-focus.nix {};

      file-tree = callPackage ./file-tree-hx.nix {};

      helix-file-watcher = callPackage ./helix-file-watcher.nix {};

      scooter-hx = callPackage ./scooter-hx.nix {};

      wakatime-hx = callPackage ./wakatime-hx.nix {};
    }
)
