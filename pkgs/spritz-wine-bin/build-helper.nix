{
  stdenvNoCC,
  lib,
}: {
  name,
  version,
  src,
  ...
} @ args:
stdenvNoCC.mkDerivation (args
  // {
    name = "${name}-bin-${version}";
    installPhase = "cp -r $src $out";
    meta = {
      description = "Spritz-Wine builds for some games ";
      homepage = "https://github.com/NelloKudo/spritz-wine";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux"];
    };
  })
