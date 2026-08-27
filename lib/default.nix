{pkgs}:
with pkgs.lib; {
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
}
