{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "elio";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "elio-fm";
    repo = "elio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-E4MEr/Hz7CJvnbqTyrf+rVp9CCJLJN7hWRW+DHNCavg=";
  };

  cargoHash = "sha256-Ejk1CJxjKljIhf/Fa12LYCzeubzZ7HGNAh9eo1dK/9I=";
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
