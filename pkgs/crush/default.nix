# Copied from https://github.com/NixOS/nixpkgs/blob/f05535a0efcb2134c478d1e88434fadf486d42b5/pkgs/by-name/cr/crush/package.nix
{
  lib,
  stdenv,
  buildGo127Module,
  fetchFromGitHub,
  git,
  installShellFiles,
  nix-update-script,
  procps,
  writableTmpDirAsHomeHook,
  versionCheckHook,
}:
buildGo127Module (finalAttrs: {
  pname = "crush";
  version = "0.100.0";

  src = fetchFromGitHub {
    owner = "charmbracelet";
    repo = "crush";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Eq0rXXAoF42prMjX6CwRDoskL670ecU+MTDSowvTUYk=";
  };

  patches = [
    # `--reasoning-levels` for crushrc `model add`, from
    # https://github.com/charmbracelet/crush/pull/3857.
    # TODO: drop once upstreamed.
    ./reasoning-level.patch
  ];

  vendorHash = "sha256-jICrWEmSFgfMg3gGzzuFVQuXj9r8EKG0JjuY1fo9Qo8=";

  ldflags = [
    "-s"
    "-X=github.com/charmbracelet/crush/internal/version.Version=${finalAttrs.version}"
  ];

  nativeBuildInputs = [
    installShellFiles
  ];

  checkFlags = let
    # these tests fail in the sandbox
    skippedTests = [
      "TestCoderAgent"
      "TestOpenAIClientStreamChoices"
      "TestGrepWithIgnoreFiles"
      "TestSearchImplementations"
      "TestDispatch_BinaryPassthroughExecutes"
    ];
  in ["-skip=^${builtins.concatStringsSep "$|^" skippedTests}$"];

  __darwinAllowLocalNetworking = true;

  nativeCheckInputs = [
    git
    # TestServiceDetectsRealProcess lists the process table via ps(1).
    procps
    writableTmpDirAsHomeHook
  ];

  nativeInstallCheckInputs = [versionCheckHook];
  doInstallCheck = true;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd crush \
      --bash <($out/bin/crush completion bash) \
      --fish <($out/bin/crush completion fish) \
      --zsh <($out/bin/crush completion zsh)
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Glamourous AI coding agent for your favourite terminal";
    homepage = "https://github.com/charmbracelet/crush";
    changelog = "https://github.com/charmbracelet/crush/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.fsl11Mit;
    maintainers = with lib.maintainers; [
      x123
      malik
      davinci42
    ];
    mainProgram = "crush";
  };
})
