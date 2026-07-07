{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "elio";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "elio-fm";
    repo = "elio";
    rev = "5e353389330423dd340dad8d09bde7e762370aef";
    hash = "sha256-/Y9KtGoqD78QHmUtAooQmmI7ZTOSNY7DdrhHYVFMj5E=";
  };

  cargoHash = "sha256-7BP/LoNBnukD2ThtjhAYN8iv0cA0tNg3+GNAjlN6yIM=";
  doCheck = false;

  meta = {
    description = "Snappy, batteries-included terminal file manager with rich previews, inline images, bulk actions, and trash support";
    homepage = "https://github.com/elio-fm/elio";
    license = lib.licenses.mit;
    mainProgram = "elio";
    platforms = lib.platforms.linux;
  };
}
