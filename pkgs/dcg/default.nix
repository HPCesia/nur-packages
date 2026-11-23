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
  version = "0.17.1";

  src = fetchFromGitHub {
    owner = "Dicklesworthstone";
    repo = "destructive_command_guard";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PcAWYS4dZg/oHg+9nRkX4i0QJoa/OG0yorCEOZsx/8w=";
  };

  cargoHash = "sha256-rLIVs56qpkmHcKTtuDIUE/YBKzObGobBpeynEPGaEBY=";

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
