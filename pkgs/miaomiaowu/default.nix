{
  lib,
  buildGoModule,
  fetchFromGitHub,
  callPackage,
  miaomiaowu-frontend ? callPackage ./frontend.nix {},
}: let
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "iluobei";
    repo = "miaomiaowu";
    tag = "v${version}";
    hash = "sha256-n4im/FSue9k7rewEHXTVoK29Uv7MRIAhS/4VrXvfLEI=";
  };
in
  buildGoModule (finalAttrs: {
    pname = "miaomiaowu";
    inherit version src;

    passthru.updateScript = [(toString ./update.sh)];

    vendorHash = "sha256-UD0K16fU4T1eUm523yj9uzKIwfYnc+obr4rhmwojY3c=";

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
