{
  lib,
  selfLib,
  newScope,
}:
lib.makeScope newScope (
  self:
    with self; {
      buildHelixPlugin = callPackage ./build-helix-plugin.nix {};

      fcitx-focus = callPackage ./fcitx-focus.nix {};

      file-tree = callPackage ./file-tree.nix {};
      file-tree-hx = selfLib.renamePackage "helixPlugins.file-tree-hx" "helixPlugins.file-tree" self.file-tree;

      forest = callPackage ./forest.nix {};

      glyph = callPackage ./glyph.nix {};

      helix-file-watcher = callPackage ./helix-file-watcher.nix {};

      notify = callPackage ./notify.nix {};

      oil = callPackage ./oil.nix {};

      scooter = callPackage ./scooter.nix {};
      scooter-hx = selfLib.renamePackage "helixPlugins.scooter-hx" "helixPlugins.scooter" self.scooter;

      trail = callPackage ./trail.nix {};

      wakatime = callPackage ./wakatime.nix {};
      wakatime-hx = selfLib.renamePackage "helixPlugins.wakatime-hx" "helixPlugins.wakatime" self.wakatime;
    }
)
