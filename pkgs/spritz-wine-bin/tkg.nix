{
  lib,
  newScope,
  buildHelper,
}: let
  versions = lib.importJSON ./version.json;
in
  lib.makeScope newScope (
    self:
      lib.mapAttrs' (
        version: src:
          lib.nameValuePair (lib.replaceString "." "_" version) (
            self.callPackage ({fetchzip}:
              buildHelper {
                name = "spritz-wine-tkg";
                inherit version;
                src = fetchzip src;
              }) {}
          )
      )
      versions.tkg
  )
