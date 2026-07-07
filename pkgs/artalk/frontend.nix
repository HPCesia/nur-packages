{
  fetchFromGitHub,
  nodejs,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  stdenv,
  lib,
}: let
  pname = "artalk-frontend";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "ArtalkJS";
    repo = "artalk";
    tag = "v${version}";
    hash = "sha256-gzagE3muNpX/dwF45p11JAN9ElsGXNFQ3fCvF1QhvdU=";
  };
in
  stdenv.mkDerivation (finalAttrs: {
    inherit pname version src;

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm_10
    ];

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pnpm_10;
      fetcherVersion = 3;
      hash = "sha256-dss1p/8YSR2TcT2zUoFiJnBLaUyeAA+l5wNLtJAfupo=";
    };

    buildPhase = ''
      runHook preBuild

      pnpm build:all
      pnpm build:auth

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{dist/{i18n,plugins},sidebar}

      # dist
      cp ./ui/artalk/dist/{Artalk,ArtalkLite}.{css,js} $out/dist
      cp ./ui/artalk/dist/i18n/*.js $out/dist/i18n
      cp ./ui/plugin-*/dist/*.js $out/dist/plugins

      # sidebar
      cp -r ./ui/artalk-sidebar/dist/* $out/sidebar

      runHook postInstall
    '';
  })
