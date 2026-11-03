# Ported from https://github.com/maximhq/bifrost/blob/transports/v2.4.0/nix/packages/bifrost-http.nix
{
  lib,
  buildGo127Module,
  fetchFromGitHub,
  pkg-config,
  gcc,
  sqlite,
  callPackage,
  nix-update-script,
}: let
  version = "2.4.0";

  src = fetchFromGitHub {
    owner = "maximhq";
    repo = "bifrost";
    tag = "transports/v${version}";
    hash = "sha256-tEZq6gyrdY8tIg8F7oDHFbyQE8yajEzOuM2TG/MZy4M=";
  };

  bifrost-ui = callPackage ./ui.nix {};

  # The transports module tracks the rest of the monorepo by version. Point
  # those requirements at the sibling source trees so the gateway is built
  # from the exact revision being packaged.
  transportsLocalReplaces = ''
    if [ -f transports/go.mod ]; then
      cat >> transports/go.mod <<'EOF'

    replace github.com/maximhq/bifrost/core => ../core
    replace github.com/maximhq/bifrost/framework => ../framework
    replace github.com/maximhq/bifrost/plugins/compat => ../plugins/compat
    replace github.com/maximhq/bifrost/plugins/governance => ../plugins/governance
    replace github.com/maximhq/bifrost/plugins/logging => ../plugins/logging
    replace github.com/maximhq/bifrost/plugins/maxim => ../plugins/maxim
    replace github.com/maximhq/bifrost/plugins/mocker => ../plugins/mocker
    replace github.com/maximhq/bifrost/plugins/modelcatalogresolver => ../plugins/modelcatalogresolver
    replace github.com/maximhq/bifrost/plugins/otel => ../plugins/otel
    replace github.com/maximhq/bifrost/plugins/prompts => ../plugins/prompts
    replace github.com/maximhq/bifrost/plugins/routing => ../plugins/routing
    replace github.com/maximhq/bifrost/plugins/semanticcache => ../plugins/semanticcache
    replace github.com/maximhq/bifrost/plugins/telemetry => ../plugins/telemetry
    EOF
    fi
  '';
in
  buildGo127Module {
    pname = "bifrost-http";
    inherit version src;

    modRoot = "transports";
    subPackages = ["bifrost-http"];
    vendorHash = "sha256-tGJrPUuV2fjcbsgm0oeelBmOSYgNQfI9Ih+ss2QEmlg=";

    doCheck = false;

    overrideModAttrs = final: prev: {
      postPatch = (prev.postPatch or "") + transportsLocalReplaces;
    };

    env.CGO_ENABLED = "1";

    nativeBuildInputs = [
      pkg-config
      gcc
    ];
    buildInputs = [sqlite];

    postPatch = transportsLocalReplaces;

    preBuild = ''
      # Provide the assets for //go:embed all:ui in transports/bifrost-http.
      rm -rf bifrost-http/ui
      mkdir -p bifrost-http/ui
      cp -R --no-preserve=mode,ownership,timestamps "${bifrost-ui}/ui/." bifrost-http/ui/
    '';

    ldflags = [
      "-s"
      "-w"
      "-X main.Version=${version}"
    ];

    passthru.updateScript = nix-update-script {
      extraArgs = ["--version-regex" "transports/v(.*)"];
    };

    meta = {
      description = "High-performance AI gateway that unifies access to multiple LLM providers";
      homepage = "https://github.com/maximhq/bifrost";
      license = lib.licenses.asl20;
      mainProgram = "bifrost-http";
      platforms = lib.platforms.unix;
    };
  }
