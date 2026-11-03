{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "elio";
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "elio-fm";
    repo = "elio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tHfkNnt5o91VVKHCCRUEJEcdLMYYy5QQC5+E0zT1veQ=";
  };

  cargoHash = "sha256-hNyR4uEJIs01+ztzAMFmY35FKWJpP4ETQ24mpBKnK+A=";
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
