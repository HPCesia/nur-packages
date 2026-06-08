{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage {
  pname = "elio";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "elio-fm";
    repo = "elio";
    rev = "64e4768c6837b78998bb134e23475382dd0f5c7f";
    hash = "sha256-r7/LT0wGs8G9UN7H89WBBYGdKhCU6FXJx+UXNWfIZDc=";
  };

  cargoHash = "sha256-x9qeMsNLELZu+23pQZNwNgOxlx7c+aHCIpzagHO/Hbg=";
  doCheck = false;

  meta = {
    description = "Snappy, batteries-included terminal file manager with rich previews, inline images, bulk actions, and trash support";
    homepage = "https://github.com/elio-fm/elio";
    license = lib.licenses.mit;
    mainProgram = "elio";
    platforms = lib.platforms.linux;
  };
}
