{
  lib,
  stdenvNoCC,
  fetchzip,
  installFonts,
  nix-update-script,
}: let
  version = "1.004";
in
  stdenvNoCC.mkDerivation {
    pname = "lxgw-marker-gothic";
    inherit version;

    src = fetchzip {
      url = "https://github.com/lxgw/LxgwMarkerGothic/releases/download/v${version}/LxgwMarkerGothic-v${version}.zip";
      hash = "sha256-4tQ7P6r9YvyZa7SOTGr+CQs3mXN4PILgkm8N4gVUwYo=";
    };

    nativeBuildInputs = [installFonts];

    # fonts/gf is a Google Fonts-styled duplicate that collides with fonts/ttf in installFonts
    preInstall = "rm -r fonts/gf";

    passthru.updateScript = nix-update-script {};

    preferLocalBuild = true;

    meta = {
      homepage = "https://github.com/lxgw/LxgwMarkerGothic";
      description = "Open-source Chinese font derived from Tanugo";
      license = lib.licenses.ofl;
      platforms = lib.platforms.all;
    };
  }
