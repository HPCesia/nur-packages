{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dcg";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "Dicklesworthstone";
    repo = "destructive_command_guard";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RW/eieMzl22YgUWUKOOkgPSU+0hJGzfF3IAkX1wG1P8=";
  };

  cargoHash = "sha256-Yl6BAqOXKVivBM1eUvs3+iDdome4ZFR/rwbUghodeBs=";

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
