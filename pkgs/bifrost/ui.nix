# Ported from https://github.com/maximhq/bifrost/blob/transports/v2.4.0/nix/packages/bifrost-ui.nix
{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "bifrost-ui";
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "maximhq";
    repo = "bifrost";
    tag = "transports/v${finalAttrs.version}";
    hash = "sha256-tEZq6gyrdY8tIg8F7oDHFbyQE8yajEzOuM2TG/MZy4M=";
  };

  sourceRoot = "source/ui";

  npmDepsHash = "sha256-GBxwxHmvAlMMS9WtTC7ITLvLNuLjcE8IxaHbHXd7qM8=";

  # The `build` script copies the output into the Go tree, which is outside
  # the sandbox cwd; `build-enterprise` stops after the Vite build + typecheck.
  npmBuildScript = "build-enterprise";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/ui"
    cp -R --no-preserve=mode,ownership,timestamps out/. "$out/ui/"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex" "transports/v(.*)" ];
  };

  meta = {
    description = "Web UI for the Bifrost AI gateway";
    homepage = "https://github.com/maximhq/bifrost";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
  };
})
