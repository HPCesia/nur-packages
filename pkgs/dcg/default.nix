{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dcg";
  version = "0.14.4";

  src = fetchFromGitHub {
    owner = "Dicklesworthstone";
    repo = "destructive_command_guard";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XFSIn+hN4A9bWKabJoqc3mCsfQtGqJDRAXAKSpJVJGg=";
  };

  cargoHash = "sha256-GfCQIiAURkEKKTQwRBGPWwuwRX+Rc2ivswxCQSZ/ngY=";

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
