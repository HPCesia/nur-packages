{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
}: let
  pname = "navibeat";
  version = "1.0.6";

  src =
    if stdenv.hostPlatform.isAarch64
    then
      fetchurl {
        url = "https://github.com/nenadjokic/navibeat-linux/releases/download/v${version}/NaviBeat-linux-aarch64-slim.AppImage";
        hash = "sha256-zWpNQzi2wQGEvNO4IyIiEcPdgDZ7VXz/TGXrWD54EKE=";
      }
    else
      fetchurl {
        url = "https://github.com/nenadjokic/navibeat-linux/releases/download/v${version}/NaviBeat-linux-x86_64-slim.AppImage";
        hash = "sha256-CbC7YH41IQeI7C6C5gp8CY8hXA93tSWpzzGph/GXbrc=";
      };

  appimageContents = appimageTools.extract {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    passthru.updateScript = [(toString ./update.sh)];
    preferLocalBuild = true;

    extraPkgs = pkgs: [
      pkgs.vlc
    ];

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/NaviBeat.desktop $out/share/applications/NaviBeat.desktop
      install -m 444 -D ${appimageContents}/NaviBeat.png $out/share/icons/hicolor/1024x1024/apps/NaviBeat.png
      substituteInPlace $out/share/applications/NaviBeat.desktop \
        --replace-fail 'Exec=NaviBeat' 'Exec=${pname}'
    '';

    meta = {
      description = "Navidrome and Subsonic music client for Linux";
      homepage = "https://navibeat.app/linux";
      license = lib.licenses.unfree;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  }
