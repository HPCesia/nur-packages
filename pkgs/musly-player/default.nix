{
  lib,
  fetchFromGitHub,
  flutter341,
  pkg-config,
  alsa-lib,
  libnotify,
  mpv-unwrapped,
  copyDesktopItems,
  makeDesktopItem,
}:
flutter341.buildFlutterApplication rec {
  pname = "musly-player";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "dddevid";
    repo = "Musly";
    tag = "v${version}";
    hash = "sha256-NQm4BEgquCxzt1DJoU8KmTv8FxByz9ZvZhWnpx2dBoc=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  nativeBuildInputs = [
    copyDesktopItems
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    libnotify
  ];

  extraWrapProgramArgs = ''
    --prefix LD_LIBRARY_PATH : $out/app/musly/lib:${lib.makeLibraryPath [mpv-unwrapped]}
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
