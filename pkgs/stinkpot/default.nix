{
  lib,
  buildGoModule,
  fetchFromTangled,
}:
buildGoModule {
  pname = "stinkpot";
  version = "0-unstable-2026-09-06";

  src = fetchFromTangled {
    did = "did:plc:wqstj3k5tslmm246baaf3tpa";
    rev = "9bc8ad17ddf66095b28f3a9bb9ca3a01c1e2092d";
    hash = "sha256-grsoctCXQf7uzf6jmPQpfT+O7imnLQIp66/tPMeT3dY=";
  };

  passthru.updateScript = [(toString ./update.sh)];

  vendorHash = "sha256-IVPACl1oWnBKGzcXvG5gzev8MwhzIKNI7zwEKJjhFc8=";

  env.CGO_ENABLED = "0";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "sqlite-backed shell history";
    homepage = "https://tangled.org/oppi.li/stinkpot";
    mainProgram = "stinkpot";
    platforms = lib.platforms.unix;
  };
}
