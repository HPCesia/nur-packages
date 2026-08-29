{
  lib,
  selfLib,
  newScope,
  callPackage,
  fetchFromCodeberg,
}:
lib.makeScope newScope (
  self:
  let
    helixPluginsNix = fetchFromCodeberg {
      owner = "maxschipper";
      repo = "helix-plugins-nix";
      rev = "629a6b9489dbab75b8bff3daaf4843f66f97e35c";
      hash = "sha256-Wq62h4qPsABKb0pJJDoXJvxVWSuBsShy3r4FioKqi2Y=";
    };

    upstream = callPackage "${helixPluginsNix}/pkgs/default.nix" { };

    deprecate =
      name: drv:
      selfLib.deprecatePackage name
        "use the package of the same name from helix-plugins-nix (https://codeberg.org/maxschipper/helix-plugins-nix) instead"
        drv;
  in
  {
    fcitx-focus = callPackage ./fcitx-focus.nix {
      buildHelixPluginWithNative = upstream.buildHelixPluginWithNative;
    };

    file-tree = deprecate "helixPlugins.file-tree" upstream.file-tree-hx;
    file-tree-hx = deprecate "helixPlugins.file-tree-hx" upstream.file-tree-hx;

    forest = deprecate "helixPlugins.forest" upstream.forest;

    glyph = deprecate "helixPlugins.glyph" upstream.glyph;

    helix-file-watcher = deprecate "helixPlugins.helix-file-watcher" upstream.helix-file-watcher;

    notify = deprecate "helixPlugins.notify" upstream.notify;

    oil = deprecate "helixPlugins.oil" upstream.oil;

    scooter = deprecate "helixPlugins.scooter" upstream.scooter;
    scooter-hx = deprecate "helixPlugins.scooter-hx" upstream.scooter;

    smith = callPackage ./smith.nix { buildHelixPlugin = upstream.buildHelixPlugin; };

    trail = deprecate "helixPlugins.trail" upstream.trail;

    wakatime = deprecate "helixPlugins.wakatime" upstream.wakatime;
    wakatime-hx = deprecate "helixPlugins.wakatime-hx" upstream.wakatime;
  }
)
