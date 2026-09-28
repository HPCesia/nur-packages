{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  jq,
}: let
  version = "0.8.6";

  src = fetchFromGitHub {
    owner = "iluobei";
    repo = "miaomiaowu";
    tag = "v${version}";
    hash = "sha256-2rJBouOw8Y5piCUUktvzXNCDOQGQJSG3brYOwWrAGt0=";
  };
in
  buildNpmPackage {
    pname = "miaomiaowu-frontend";
    inherit version;
    src = "${src}/miaomiaowu";

    npmDepsHash = "sha256-93nZ1CK4afOrGZgRkuM9lLAVGngRvyE4/mU0SKcfqlk=";
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
