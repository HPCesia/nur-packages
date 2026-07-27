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
  grammarsOverlay = final: prev: {
    tree-sitter-agda = prev.tree-sitter-agda.override {
      excludeBrokenTreeSitterJson = false;
    };
    tree-sitter-beancount = prev.tree-sitter-beancount.override {
      excludeBrokenTreeSitterJson = false;
    };
    tree-sitter-git-rebase = prev.tree-sitter-git-rebase.overrideAttrs {
      dontPatch = true;
    };
    tree-sitter-glimmer = prev.tree-sitter-glimmer.override {
      excludeBrokenTreeSitterJson = false;
    };
    tree-sitter-janet-simple = prev.tree-sitter-janet-simple.override {
      excludeBrokenTreeSitterJson = false;
    };
    tree-sitter-qmljs = prev.tree-sitter-qmljs.overrideAttrs {
      dontCheckForBrokenSymlinks = true;
    };
    tree-sitter-sql = prev.tree-sitter-sql.override {
      generate = false;
    };
    tree-sitter-strace = prev.tree-sitter-strace.override {
      excludeBrokenTreeSitterJson = false;
    };
    tree-sitter-tact = prev.tree-sitter-tact.override {
      excludeBrokenTreeSitterJson = false;
    };
    tree-sitter-tlaplus = prev.tree-sitter-tlaplus.overrideAttrs {
      dontPatch = true;
    };
    tree-sitter-vue = prev.tree-sitter-vue.override {
      excludeBrokenTreeSitterJson = false;
    };
    tree-sitter-wit = prev.tree-sitter-wit.override {
      excludeBrokenTreeSitterJson = false;
    };
    tree-sitter-yuck = prev.tree-sitter-yuck.override {
      excludeBrokenTreeSitterJson = false;
    };
  };
}).overrideAttrs
(
  _: previousAttrs: {
    pname = "steelix";
    strictDeps = true;

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
