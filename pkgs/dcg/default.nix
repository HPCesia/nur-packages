{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dcg";
  version = "0.14.3";

  src = fetchFromGitHub {
    owner = "Dicklesworthstone";
    repo = "destructive_command_guard";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KkdNrJvqA6jYXyeBcwd+e1wb51n3CHHJP5LDfL3YivM=";
  };

  cargoHash = "sha256-+rWsM+8ZF1hTixNm8aENwy+jS36IJWIAllUrMUjcDFU=";

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
