{pkgs}:
with pkgs.lib; {
  sqlite3SourceBuilder = pkgs.callPackage ./sqlite3-source-builder.nix {};

  renamePackage = oldName: newName: drv:
    derivations.warnOnInstantiate
    "${oldName} has been renamed to ${newName}"
    (drv.overrideAttrs (old: {
      meta =
        (old.meta or {})
        // {
          nurRenamed = true;
        };
    }));

  deprecatePackage = name: reason: drv:
    derivations.warnOnInstantiate
    "${name} has been deprecated: ${reason}"
    (drv.overrideAttrs (old: {
      meta =
        (old.meta or {})
        // {
          nurDeprecated = true;
          nurDeprecatedReason = reason;
        };
    }));

  removePackage = name: reason:
    throw "${name} has been removed: ${reason}";
}
