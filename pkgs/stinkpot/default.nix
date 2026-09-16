{
  lib,
  buildGoModule,
  fetchFromTangled,
}:
buildGoModule {
  pname = "stinkpot";
  version = "0-unstable-2026-09-16";

  src = fetchFromTangled {
    did = "did:plc:wqstj3k5tslmm246baaf3tpa";
    rev = "71ecf8b2ebcb0a0509040fba7622205ea243627a";
    hash = "sha256-Ku4xDZwvtGcMADQ0xrzznyHLQjEttDJTF2jzP8Yhgv8=";
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
