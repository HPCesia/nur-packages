{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  aws-lc,
  sqlite,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dcg";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "Dicklesworthstone";
    repo = "destructive_command_guard";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vjrzGrTRp4V204hF2D603uLxywOtNL8nEgXa6txfbCw=";
  };

  cargoHash = "sha256-Jwq6qgT5RobnIO1k+gEyDkfDlHKVVVW8S/H0tL7u8KU=";

  nativeBuildInputs = [pkg-config];

  buildInputs = [
    aws-lc
    sqlite
  ];

  postPatch = ''
    rm .cargo/config.toml
  '';

  doCheck = false;

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "PreToolUse hook that blocks destructive shell commands for AI coding agents";
    homepage = "https://github.com/Dicklesworthstone/destructive_command_guard";
    license = lib.licenses.unfree;
    mainProgram = "dcg";
    platforms = lib.platforms.unix;
  };
})
