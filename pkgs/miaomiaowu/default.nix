{
  lib,
  buildGoModule,
  fetchFromGitHub,
  callPackage,
  nix-update-script,
}: let
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "iluobei";
    repo = "miaomiaowu";
    tag = "v${version}";
    hash = "sha256-NEiGug/JyyuQhY0OYnua8H3YU6N9+MrE0sb6dLVgSv0=";
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

    vendorHash = "sha256-2tAsjajbptKrCV8B0j2R3Tw1BPP5ARH9Nq4MrG5CmCk=";

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
