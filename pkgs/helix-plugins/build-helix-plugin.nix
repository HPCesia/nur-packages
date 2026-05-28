{
  lib,
  stdenv,
  steel,
  cargo,
  rustc,
  rustPlatform,
}: {
  pname,
  version,
  src,
  name ? "helixplugin-${pname}-${version}",
  ...
} @ attrs:
stdenv.mkDerivation (finalAttrs:
    attrs
    // {
      inherit name;

      nativeBuildInputs =
        [steel]
        ++ (lib.optionals (lib.hasAttr "cargoDeps" attrs) [
          cargo
          rustc
          rustPlatform.cargoSetupHook
        ]);

      buildPhase = ''
        runHook preBuild

        export STEEL_HOME=$TMPDIR/target_steel
        mkdir -p $STEEL_HOME
        forge install

        mv $STEEL_HOME ./

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/cogs

        if [ -z "$(find ./target_steel/native -maxdepth 0 -empty)" ]; then
          cp -r ./target_steel/native $out/
        fi

        plugin_name=$(cd ./target_steel/cogs && ls -1 | head -n1)
        ln -s "${finalAttrs.src}" "$out/cogs/$plugin_name"

        runHook postInstall
      '';
    })
