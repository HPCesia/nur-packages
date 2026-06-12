{
  lib,
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  runCommand,
  jq,
}: let
  version = "0.7.8";

  src = fetchFromGitHub {
    owner = "iluobei";
    repo = "miaomiaowu";
    tag = "v0.7.8";
    hash = "sha256-zdD2aW0zqVqBSuzJv5C5hG+hd4/SFkWJo2F5ohWzoKM=";
  };

  # @tailwindcss/oxide is missing resolved/integrity in the lockfile,
  # which causes prefetch-npm-deps to not download it.
  srcPatched =
    runCommand "miaomiaowu-source-patched" {
      nativeBuildInputs = [jq];
    } ''
      cp -r ${src} $out
      chmod -R u+w $out
      jq '.packages["node_modules/@tailwindcss/oxide"] += {
        "resolved": "https://registry.npmjs.org/@tailwindcss/oxide/-/oxide-4.1.14.tgz",
        "integrity": "sha512-23yx+VUbBwCg2x5XWdB8+1lkPajzLmALEfMb51zZUBYaYVPDQvBSD/WYDqiVyBIo2BZFa3yw1Rpy3G2Jp+K0dw=="
      }' "$out/miaomiaowu/package-lock.json" > tmp.json
      mv tmp.json "$out/miaomiaowu/package-lock.json"
    '';

  frontend = buildNpmPackage {
    pname = "miaomiaowu-frontend";
    inherit version;

    src = "${srcPatched}/miaomiaowu";

    npmDepsHash = "sha256-KwlLVo5OE77OsaYhOF7dvLfa+Q7KbdbtySo1zHIWC0w=";
    npmDepsFetcherVersion = 2;
    makeCacheWritable = true;

    installPhase = ''
      mkdir -p $out
      cp -r ../internal/web/dist/* $out/
    '';
  };

  srcWithFrontend = runCommand "miaomiaowu-source-with-frontend" {} ''
    cp -r ${src} $out
    chmod -R u+w $out
    cp -r ${frontend} $out/internal/web/dist
  '';
in
  buildGoModule (finalAttrs: {
    pname = "miaomiaowu";
    inherit version;

    src = srcWithFrontend;

    vendorHash = "sha256-Q3dpE3sncuSOVjDa2LgevNGb9VJj7mR0cn/sZiGRxjI=";

    subPackages = ["./cmd/server"];

    ldflags = ["-s" "-w"];

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
