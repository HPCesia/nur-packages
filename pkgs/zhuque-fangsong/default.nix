{
  lib,
  stdenvNoCC,
  fetchzip,
  installFonts,
  nix-update-script,
}: let
  version = "0.212";
in
  stdenvNoCC.mkDerivation {
    pname = "zhuque-fangsong";
    inherit version;

    src = fetchzip {
      url = "https://github.com/TrionesType/zhuque/releases/download/v${version}/ZhuqueFangsong-v${version}.zip";
      hash = "sha256-see78H4ClZON4pujyUxvCjphFrKG73qBVEyhRoSxZ0Y=";
    };

    nativeBuildInputs = [installFonts];

    passthru.updateScript = nix-update-script {};

    preferLocalBuild = true;

    meta = {
      homepage = "https://github.com/TrionesType/zhuque";
      description = "Open-source Chinese Fangsong typeface";
      license = lib.licenses.ofl;
      platforms = lib.platforms.all;
    };
  }
