{
  rustPlatform,
  fetchFromGitHub,
  fetchpatch,
  helix-unwrapped,
}:
helix-unwrapped.overrideAttrs (
  finalAttrs: _: {
    pname = "steelix-unwrapped";

    version = "0-unstable-2026-08-31";

    src = fetchFromGitHub {
      owner = "mattwparas";
      repo = "helix";
      rev = "ba5b022c1000a0ce28d4ce1d09acdd062a83a020";
      hash = "sha256-vJ7VgxuM/Dp7vyVlu6EXjP/ES14TALy64jgzyuYZl6g=";
    };

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) src pname version;
      hash = "sha256-gxX/gXJ9cIAShQTBSZcmAcX4qahE3zoYYmKzmFHqV7E=";
    };

    cargoBuildFlags = [
      "--package"
      "helix-term"
      "--features"
      "steel,git"
    ];

    # This fork is built from Helix master, whose loader expects tree-sitter
    # grammars with the platform-native extension (`.dylib` on Darwin) since
    # helix-editor/helix#14982. We reuse the grammars from `helix.runtime`, built
    # from the last Helix *release*, which still names them `.so` on Darwin, so
    # revert that commit to make the loader look for `.so`. Remove once a Helix
    # release ships #14982 and nixpkgs' grammars switch to `.dylib`.
    patches = [
      (fetchpatch {
        name = "revert-dylib-grammar-extension.patch";
        url = "https://github.com/helix-editor/helix/commit/430914b298a32653ab1847fdfdf2177a002be04c.patch";
        revert = true;
        hash = "sha256-4KUFppkso4/XwNU+mGIgLvl+mJXHZWkmaguYMy8oTyI=";
      })
    ];

    doInstallCheck = false;
  }
)
