{
  rustPlatform,
  fetchFromGitHub,
  fetchpatch,
  helix-unwrapped,
}:
helix-unwrapped.overrideAttrs (
  finalAttrs: _: {
    pname = "steelix-unwrapped";

    version = "0-unstable-2026-10-09";

    src = fetchFromGitHub {
      owner = "mattwparas";
      repo = "helix";
      rev = "c16fac096a9dd162d46f53bf2411f36251d755f3";
      hash = "sha256-FMC6m2RNL//Wd3HUdLrRUGDS0hZgQf8H5QC3SjK6/Is=";
    };

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit (finalAttrs) src pname version;
      hash = "sha256-h4HkOppmseHzX1gHUGO1XSwrg4uCJ4PjmI/3WsYp2C4=";
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
