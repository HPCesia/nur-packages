{
  lib,
  buildGoModule,
  fetchFromTangled,
}:
buildGoModule {
  pname = "stinkpot";
  version = "0-unstable-2026-08-18";

  src = fetchFromTangled {
    did = "did:plc:wqstj3k5tslmm246baaf3tpa";
    rev = "63594fa4893cc4d00a6c952430dc05be523882f9";
    hash = "sha256-HwBtYIwtj5HkUwAv5haoei0Be6dXdLKilbA/A76L46c=";
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
