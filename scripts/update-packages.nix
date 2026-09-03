/*
Selection of packages with `passthru.updateScript`, shared by the
runner (scripts/update.nix) and scripts/update-package --list.

Usage:

    nix-instantiate --eval --json --strict \
      -E 'map (p: p.attrPath) (import ./scripts/update-packages.nix {})'
*/
{
  pkgs ? import <nixpkgs> {},
  # Space-separated list of package attribute paths to update.
  # Empty string means "update everything".
  packages ? "",
}: let
  inherit (pkgs) lib;
  nurPkgs = import ../default.nix {inherit pkgs;};

  updateScriptOf = pkg: let
    script =
      (
        if pkg.passthru or null != null
        then pkg.passthru
        else {}
      ).updateScript or null;
  in
    if script == null
    then null
    else if lib.isDerivation script
    then [(toString script)]
    else if lib.isAttrs script
    then
      if script ? command
      then map toString (lib.toList script.command)
      else null
    else map toString (lib.toList script);

  reservedNames = [
    "lib"
    "overlays"
    "nixosModules"
    "homeModules"
    "darwinModules"
    "flakeModules"
  ];

  collect = prefix: attrs: let
    names = builtins.tryEval (builtins.attrNames attrs);
  in
    if !names.success
    then []
    else
      builtins.concatLists (
        map (
          name: let
            result = builtins.tryEval attrs.${name};
          in
            if !result.success
            then []
            else if lib.isDerivation result.value
            then let
              script = updateScriptOf result.value;
              meta = result.value.meta or null;
              position =
                if meta != null
                then meta.position or null
                else null;
            in
              lib.optional (script != null && !(meta.nurRenamed or false) && !(meta.nurDeprecated or false)) {
                inherit name;
                attrPath = lib.concatStringsSep "." (prefix ++ [name]);
                inherit script;
                pname = result.value.pname or (lib.getName result.value);
                pkgName = result.value.name;
                oldVersion = result.value.version or "";
                inherit position;
              }
            else if lib.isAttrs result.value
            then collect (prefix ++ [name]) result.value
            else []
        )
        names.value
      );

  allPackages = collect [] (lib.filterAttrs (name: _: !builtins.elem name reservedNames) nurPkgs);

  deduplicated = let
    isClean = p: !(p.meta.nurRenamed or false) && !(p.meta.nurDeprecated or false);
    grouped =
      lib.foldl (
        acc: cur: let
          key = builtins.hashString "sha256" (
            lib.concatStringsSep "\n" (cur.script ++ [(toString cur.position)])
          );
          prev = acc.${key} or null;
          keep =
            prev
            == null
            || (isClean cur && !isClean prev)
            || (isClean cur == isClean prev && lib.hasInfix "." cur.attrPath && !lib.hasInfix "." prev.attrPath);
        in
          acc
          // {
            ${key} =
              if keep
              then cur
              else prev;
          }
      ) {}
      allPackages;
  in
    map (k: grouped.${k}) (builtins.attrNames grouped);

  matchesSelection = p: sel: p.attrPath == sel || lib.hasSuffix ".${sel}" p.attrPath;

  selected =
    if packages != ""
    then lib.filter (p: lib.any (sel: matchesSelection p sel) (lib.splitString " " packages)) deduplicated
    else deduplicated;
in
  selected
