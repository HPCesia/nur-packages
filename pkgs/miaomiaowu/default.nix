{
  lib,
  buildGoModule,
  fetchFromGitHub,
  callPackage,
  nix-update-script,
}: let
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "iluobei";
    repo = "miaomiaowu";
    tag = "v${version}";
    hash = "sha256-2TIOo2KYL587rQ7/lcJOfZwbZD9KyVE0LDp5j+IT8fY=";
  };

  frontend = callPackage ./frontend.nix {inherit version src;};
in
  buildGoModule (finalAttrs: {
    pname = "miaomiaowu";
    inherit version src;

    passthru = {
      inherit frontend;
      updateScript = nix-update-script {extraArgs = ["--subpackage" "frontend"];};
    };

    vendorHash = "sha256-POjHwoelPdMYJaetVyGLGHyAhy73CVP/Ev4VW/P8cYk=";

    subPackages = ["./cmd/server"];

    ldflags = ["-s" "-w"];

    postPatch = ''
      mkdir -p internal/web/dist
      cp -r ${frontend}/* internal/web/dist/
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
