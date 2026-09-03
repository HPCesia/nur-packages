{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  jq,
}: let
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "iluobei";
    repo = "miaomiaowu";
    tag = "v${version}";
    hash = "sha256-LEcU5v5khTGktSeOzf0CLv2iuK4NsLuQwGUCcUKEvJo=";
  };
in
  buildNpmPackage {
    pname = "miaomiaowu-frontend";
    inherit version;
    src = "${src}/miaomiaowu";

    npmDepsHash = "sha256-Hwt+vyysuk7R8srQ1H7ctjgc7J8+SV7gyg3L3BN04tk=";
    npmDepsFetcherVersion = 2;
    makeCacheWritable = true;

    postPatch = ''
      ${lib.getExe jq} '.packages["node_modules/@tailwindcss/oxide"] += {
        "resolved": "https://registry.npmjs.org/@tailwindcss/oxide/-/oxide-4.1.14.tgz",
        "integrity": "sha512-23yx+VUbBwCg2x5XWdB8+1lkPajzLmALEfMb51zZUBYaYVPDQvBSD/WYDqiVyBIo2BZFa3yw1Rpy3G2Jp+K0dw=="
      }' package-lock.json > tmp.json
      mv tmp.json package-lock.json
    '';

    installPhase = ''
      mkdir -p $out
      cp -r ../internal/web/dist/* $out/
    '';
  }
