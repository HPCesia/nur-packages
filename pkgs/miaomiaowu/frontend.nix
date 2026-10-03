{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  jq,
}: let
  version = "0.8.7";

  src = fetchFromGitHub {
    owner = "iluobei";
    repo = "miaomiaowu";
    tag = "v${version}";
    hash = "sha256-i5aaldpXZrZDUdCmO4XERHxSpq6xEUClhvtHVxPkDWg=";
  };
in
  buildNpmPackage {
    pname = "miaomiaowu-frontend";
    inherit version;
    src = "${src}/miaomiaowu";

    npmDepsHash = "sha256-h9saokJ2o1pPzwlYKv3VV+a69iynnXtn9G1f9+WVFik=";
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
