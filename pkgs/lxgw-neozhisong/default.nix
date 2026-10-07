{
  lib,
  stdenvNoCC,
  fetchurl,
  installFonts,
  nix-update-script,
}: let
  version = "1.067";

  main = fetchurl {
    url = "https://github.com/lxgw/LxgwNeoZhiSong/releases/download/v${version}/LXGWNeoZhiSong.ttf";
    hash = "sha256-MrOY+cYnjE7TT0Ewd63SwvPIQDTUY68rnLmPEsTCxs0=";
  };

  plus = fetchurl {
    url = "https://github.com/lxgw/LxgwNeoZhiSong/releases/download/v${version}/LXGWNeoZhiSongPlus.ttf";
    hash = "sha256-Y5WVxlABhy0NoW2srrfeO6OWxkw3twoW/rFTYJG7bB8=";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "lxgw-neozhisong";
    inherit version;

    src = main;

    dontUnpack = true;

    nativeBuildInputs = [installFonts];

    preInstall = ''
      install -m644 ${main} LXGWNeoZhiSong.ttf
      install -m644 ${plus} LXGWNeoZhiSongPlus.ttf
    '';

    passthru = {
      inherit plus;
      updateScript = nix-update-script {
        extraArgs = ["--custom-dep" "plus"];
      };
    };

    preferLocalBuild = true;

    meta = {
      homepage = "https://github.com/lxgw/LxgwNeoZhiSong";
      description = "Chinese serif font derived from IPAex Mincho and IPAmj Mincho";
      license = lib.licenses.ipa;
      platforms = lib.platforms.all;
    };
  }
