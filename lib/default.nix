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
}
