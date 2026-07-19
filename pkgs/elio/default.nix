{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "elio";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "elio-fm";
    repo = "elio";
    rev = "754f8457b12608025e5eb6051a749e7ca8c89f8e";
    hash = "sha256-SrYRn+JZXSy7F3Jfx1u2ht/lL31FG+BtxzuIu4kHeek=";
  };

  cargoHash = "sha256-W7C3e8pRCPoorxQhs1jkpnTKNn3oTEOhI1tG3HZFxpw=";
  doCheck = false;

  meta = {
    description = "Snappy, batteries-included terminal file manager with rich previews, inline images, bulk actions, and trash support";
    homepage = "https://github.com/elio-fm/elio";
    license = lib.licenses.mit;
    mainProgram = "elio";
    platforms = lib.platforms.linux;
  };
}
