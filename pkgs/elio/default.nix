{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "elio";
  version = "1.12.0";

  src = fetchFromGitHub {
    owner = "elio-fm";
    repo = "elio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FT5F3L8IgbX6vPjEd+TSudoyIZe4TX7no0FF9C75aaU=";
  };

  cargoHash = "sha256-gnUPukVYevg6JpPIVqDt/9LMtb3FmC8NNgJH6AU8fBE=";
  doCheck = false;

  meta = {
    description = "Snappy, batteries-included terminal file manager with rich previews, inline images, bulk actions, and trash support";
    homepage = "https://github.com/elio-fm/elio";
    license = lib.licenses.mit;
    mainProgram = "elio";
    platforms = lib.platforms.linux;
  };
})
