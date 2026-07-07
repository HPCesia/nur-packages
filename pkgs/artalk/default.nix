{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  versionCheckHook,
  stdenv,
  nixosTests,
  callPackage,
  artalk-frontend ? callPackage ./frontend.nix {},
}: let
  pname = "artalk";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "ArtalkJS";
    repo = "artalk";
    tag = "v${version}";
    hash = "sha256-gzagE3muNpX/dwF45p11JAN9ElsGXNFQ3fCvF1QhvdU=";
  };
in
  buildGoModule {
    inherit src pname version;

    vendorHash = "sha256-oAqYQzOUjly97H5L5PQ9I2SO2KqiUVxdJA+eoPrHD6Q=";

    ldflags = [
      "-s"
      "-w"
    ];

    preBuild = ''
      cp -r ${artalk-frontend}/* ./public
    '';

    nativeBuildInputs = [installShellFiles];

    postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd artalk \
        --bash <($out/bin/artalk completion bash) \
        --fish <($out/bin/artalk completion fish) \
        --zsh <($out/bin/artalk completion zsh)
    '';

    doInstallCheck = true;
    nativeInstallCheckInputs = [versionCheckHook];
    versionCheckProgramArg = "-v";

    passthru.tests = {
      inherit (nixosTests) artalk;
    };

    meta = {
      description = "Self-hosted comment system";
      homepage = "https://github.com/ArtalkJS/Artalk";
      changelog = "https://github.com/ArtalkJS/Artalk/releases/tag/v${version}";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [moraxyc];
      mainProgram = "artalk";
    };
  }
