{
  lib,
  buildGoModule,
  fetchFromGitHub,
  callPackage,
  miaomiaowu-frontend ? callPackage ./frontend.nix {},
}: let
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "iluobei";
    repo = "miaomiaowu";
    tag = "v${version}";
    hash = "sha256-UYcqNFUqwLVExPpEx7LBnTFtlrkwFebqoKpj1fcSQtM=";
  };
in
  buildGoModule (finalAttrs: {
    pname = "miaomiaowu";
    inherit version src;

    passthru.updateScript = [(toString ./update.sh)];

    vendorHash = "sha256-Ix13AFJPpUUC+ak/ixGAqOBK/tlXTfBTjLm2DR+zw50=";

    subPackages = ["./cmd/server"];

    ldflags = ["-s" "-w"];

    postPatch = ''
      mkdir -p internal/web/dist
      cp -r ${miaomiaowu-frontend}/* internal/web/dist/
    '';

    postInstall = ''
      mv $out/bin/server $out/bin/${finalAttrs.pname}
    '';

    meta = {
      description = "Personal Clash subscriptions management system";
      homepage = "https://github.com/iluobei/miaomiaowu";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  })
