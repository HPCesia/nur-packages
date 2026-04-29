{
  lib,
  fetchFromGitHub,
  flutter341,
  alsa-lib,
  mpv,
  copyDesktopItems,
  makeDesktopItem,
}:
flutter341.buildFlutterApplication rec {
  pname = "musly-player";
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "dddevid";
    repo = "Musly";
    tag = "v${version}";
    hash = "sha256-7Ot7pmYH85wsNF7trH34mxSvhlWWu4RB5wnEvTFTczg=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  nativeBuildInputs = [copyDesktopItems];

  buildInputs = [
    alsa-lib
  ];

  extraWrapProgramArgs = ''
    --prefix LD_LIBRARY_PATH : $out/app/musly/lib:${lib.makeLibraryPath [mpv]}
  '';

  postFixup = ''
    mv "$out/bin/musly" "$out/bin/${pname}"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Musly";
      exec = pname;
      icon = "${src}/logo.png";
      genericName = "Music Player";
      desktopName = "Musly";
      categories = ["AudioVideo" "Audio" "Player" "Music"];
    })
  ];

  meta = {
    description = "A beautiful Flutter music streaming client for Subsonic-compatible servers with a modern Apple Music-inspired UI.";
    homepage = "https://github.com/dddevid/Musly";
    licence = lib.licenses.cc-by-nc-sa-40;
    platforms = ["x86_64-linux"];
  };
}
