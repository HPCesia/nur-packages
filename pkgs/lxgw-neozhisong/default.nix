{
  lib,
  stdenvNoCC,
  fetchurl,
  installFonts,
  nix-update-script,
}: let
  version = "1.071";

  main = fetchurl {
    url = "https://github.com/lxgw/LxgwNeoZhiSong/releases/download/v${version}/LXGWNeoZhiSong.ttf";
    hash = "sha256-/VhW+eQ1E6se1uUKvQV7N7UPFfquH/KSwCgEnxaMtE8=";
  };

  plus = fetchurl {
    url = "https://github.com/lxgw/LxgwNeoZhiSong/releases/download/v${version}/LXGWNeoZhiSongPlus.ttf";
    hash = "sha256-AEJqITko3aA9LdV869Ks2jABk9YN4oR3F5shO8KYf/o=";
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
