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
stdenv.mkDerivation (attrs
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

      mkdir -p $out
      cp -r ./target_steel/* $out

      runHook postInstall
    '';
  })
