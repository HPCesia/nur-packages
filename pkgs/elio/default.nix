{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "elio";
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "elio-fm";
    repo = "elio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6A/VxmRl/YpaaaMrlw3UExdKRn3yh8SVazD8ee1HETE=";
  };

  cargoHash = "sha256-6hiXp3LvKToifGkYN22H/GRSClNQ6a64cEWjqPKMhfw=";
  doCheck = false;

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Snappy, batteries-included terminal file manager with rich previews, inline images, bulk actions, and trash support";
    homepage = "https://github.com/elio-fm/elio";
    license = lib.licenses.mit;
    mainProgram = "elio";
    platforms = lib.platforms.linux;
  };
})
