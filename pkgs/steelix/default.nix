# Modify from https://github.com/NixOS/nixpkgs/blob/c4e0120b295daaac44f245f1c50ec06e844fe53b/pkgs/by-name/st/steelix/package.nix
{
  lib,
  callPackage,
  helix,
  tree-sitter-grammars,
  lockedGrammars ? lib.filterAttrs (name: _: tree-sitter-grammars ? "tree-sitter-${name}") (lib.importJSON ./grammars.json),
  steelix-unwrapped ? callPackage ./unwrapped.nix {},
}:
(helix.override {
  helix-unwrapped = steelix-unwrapped;
  lockedGrammars = lockedGrammars;
  # helix replaces its `defaultGrammarsOverlay` rather than composing it when
  # `grammarsOverlay` is set, so compose it back and layer our fixes on top.
  grammarsOverlay = lib.composeExtensions helix.passthru.defaultGrammarsOverlay (final: prev: {
    tree-sitter-tlaplus = prev.tree-sitter-tlaplus.overrideAttrs {
      dontPatch = true;
    };
  });
}).overrideAttrs
(
  _: previousAttrs: {
    pname = "steelix";
    strictDeps = true;

    passthru =
      (previousAttrs.passthru or {})
      // {
        updateScript = [(toString ./update.sh)];
      };

    meta =
      previousAttrs.meta
      // {
        description = "Helix editor with Steel (Scheme) scripting support";
        longDescription = ''
          Steelix is a fork of the Helix editor with Steel (Scheme) scripting support.
        '';
        homepage = "https://github.com/mattwparas/helix";
        changelog = "https://github.com/mattwparas/helix/blob/${steelix-unwrapped.src.rev}/CHANGELOG.md";
        license = lib.licenses.mpl20;
        mainProgram = "hx";
      };
  }
)
