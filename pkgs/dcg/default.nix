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
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "Dicklesworthstone";
    repo = "destructive_command_guard";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ogu8weoxf2tmMHtoL8W1vyI7hNX7HTnnc/yg6U6dJdA=";
  };

  cargoHash = "sha256-O6lo+CDHSN51uwO/00aUu3UIf6Whs+OYmr9NBSTYhQs=";

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
