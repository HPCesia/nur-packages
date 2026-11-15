# Huawei's macOS "home" directories and the XDG locations the Linux build
# rewrites them to. The jar/ELF patchers and the IDE wrapper all derive their
# rules from this one table.
rec {
  dirs = {
    "Library/Caches/Huawei" = ".cache/Huawei";
    "Library/Huawei" = ".Huawei";
    "Library/Application Support/Huawei" = ".config/Huawei";
    "Library/Logs/Huawei" = ".local/state/Huawei";
  };

  # Same table as a store file, for the patchers' --library-map option.
  json = builtins.toFile "harmonyos-library-paths.json" (builtins.toJSON dirs);

  # Tab separated "macOS root<TAB>XDG root" lines, read by the IDE wrapper.
  tsv = builtins.toFile "harmonyos-library-paths.tsv" (
    builtins.concatStringsSep "" (
      map (mac: "${mac}\t${dirs.${mac}}\n") (builtins.attrNames dirs)
    )
  );
}
