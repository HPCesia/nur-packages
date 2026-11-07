{
  lib,
  buildGoModule,
  fetchFromGitHub,
  callPackage,
  nix-update-script,
}: let
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "iluobei";
    repo = "miaomiaowu";
    tag = "v${version}";
    hash = "sha256-ppZIbbuN1YS6gLMu5hgP7ynmYgpKoiEY467vttwzfYY=";
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

    vendorHash = "sha256-5tSHbKuudl/AI+xff0H4ojExNLahZXEpgtmRNBpYBnA=";

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
