{
  lib,
  fetchzip,
  buildHelper,
}: let
  versionData = lib.importJSON ./version.json;
  versions = versionData.dwproton;

  allVersions =
    lib.mapAttrs (
      version: src:
        buildHelper {
          name = "spritz-wine-dwproton";
          inherit version;
          src = fetchzip src;
        }
    )
    versions;

  latestKey = builtins.head (lib.sort (a: b: builtins.compareVersions a b > 0) (builtins.attrNames versions));
  latest = allVersions.${latestKey};

  versionedAttrs =
    lib.mapAttrs' (
      version: drv:
        lib.nameValuePair (lib.replaceStrings ["."] ["_"] version) drv
    )
    allVersions;
in
  latest // versionedAttrs
