{
  lib,
  fetchFromGitHub,
  flutter347,
  pkg-config,
  alsa-lib,
  gst_all_1,
  libnotify,
  mpv-unwrapped,
  copyDesktopItems,
  makeDesktopItem,
}:
flutter347.buildFlutterApplication rec {
  pname = "musly-player";
  version = "2.0.3";

  passthru.updateScript = [(toString ./update.sh)];

  src = fetchFromGitHub {
    owner = "dddevid";
    repo = "Musly";
    tag = "v${version}";
    hash = "sha256-Zr8mXs2Tk9LXX08/AO0VxlTuIat/W+VHp3OoB4PRwac=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  gitHashes = {
    audioplayers_tizen = "sha256-sxEsVxye+riy4WS+8qGy65opPog+AjlLMbkaOgSiHEk=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    libnotify
  ];

  extraWrapProgramArgs = ''
    --prefix LD_LIBRARY_PATH : $out/app/${pname}/lib:${lib.makeLibraryPath [mpv-unwrapped]}
  '';

  postFixup = ''
    mv "$out/bin/musly" "$out/bin/${pname}"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Musly";
      exec = pname;
      icon = "${src}/assets/logo.png";
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
