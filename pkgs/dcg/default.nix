{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dcg";
  version = "0.15.3";

  src = fetchFromGitHub {
    owner = "Dicklesworthstone";
    repo = "destructive_command_guard";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wBD3y1KH9u5h3G+236erESI5zy6bq3lD2RKYIVFDBps=";
  };

  cargoHash = "sha256-mrjvFx3ziKXEQD3gRTPVAHbW7oGvdHoR6jidicC8OPU=";

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
