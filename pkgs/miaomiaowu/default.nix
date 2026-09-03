{
  lib,
  buildGoModule,
  fetchFromGitHub,
  callPackage,
  miaomiaowu-frontend ? callPackage ./frontend.nix {},
}: let
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "iluobei";
    repo = "miaomiaowu";
    tag = "v${version}";
    hash = "sha256-LEcU5v5khTGktSeOzf0CLv2iuK4NsLuQwGUCcUKEvJo=";
  };
in
  buildGoModule (finalAttrs: {
    pname = "miaomiaowu";
    inherit version src;

    vendorHash = "sha256-2w8sBHpRaSv2RqwNRxNE8Q2O1A0b96WdHsugrWrSixE=";

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
