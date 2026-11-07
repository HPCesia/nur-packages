{
  lib,
  buildNpmPackage,
  jq,
  version,
  src,
}: let
  source = "${src}/miaomiaowu";
in
  buildNpmPackage {
    pname = "miaomiaowu-frontend";
    inherit version;
    src = source;

    npmDepsHash = "sha256-pBL5W518hP16JBt2JbMcUYPs+2MQa4Wxey4zn1l70FU=";
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
