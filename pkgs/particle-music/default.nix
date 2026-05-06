{
  lib,
  fetchFromGitHub,
  flutter341,
  libappindicator,
  mpv-unwrapped,
  copyDesktopItems,
  makeDesktopItem,
}:
flutter341.buildFlutterApplication rec {
  pname = "particle-music";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "AfalpHy";
    repo = "ParticleMusic";
    tag = "v${version}";
    hash = "sha256-b6c5ZDmbTo0nRvoVMhAq+xbfTw0tpAwHE0cbW0qWXlU=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  gitHashes = {
    audio_service_win = "sha256-MkZj8EmIe6WQmDFT+lBLdHTBLjLwh1YonZoZYPG4W7I=";
    audio_tags_lofty = "sha256-h1bflJY1SaqYWnqkz7D9thMaObXq8J0MriA6wDz0WdM=";
    media_kit_libs_android_audio = "sha256-27u8cPSThJFvYV1iMWjFMXfqrpQPtT9OwoezrKXtyt4=";
    media_kit_libs_ios_audio = "sha256-27u8cPSThJFvYV1iMWjFMXfqrpQPtT9OwoezrKXtyt4=";
    media_kit_libs_macos_audio = "sha256-27u8cPSThJFvYV1iMWjFMXfqrpQPtT9OwoezrKXtyt4=";
    media_kit_libs_windows_audio = "sha256-27u8cPSThJFvYV1iMWjFMXfqrpQPtT9OwoezrKXtyt4=";
    super_context_menu = "sha256-9D1BOJ+Deky/hktMw6zXelKVBlkmLtL5F9n7mbwHvo4=";
    tray_manager = "sha256-JvT62iBbTVr2CAyCoAVpAoIywCqjxx4TkTgljH6BnYE=";
    window_manager = "sha256-Xt9m+YzLTVKDF5Gk165MVy6yx81O/1Arqqk0caTGoXc=";
  };

  nativeBuildInputs = [copyDesktopItems];

  buildInputs = [
    libappindicator
  ];

  extraWrapProgramArgs = ''
    --prefix LD_LIBRARY_PATH : $out/app/ParticleMusic/lib:${lib.makeLibraryPath [mpv-unwrapped]}
  '';

  postFixup = ''
    mv "$out/bin/ParticleMusic" "$out/bin/${pname}"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "ParticleMusic";
      exec = pname;
      icon = "${src}/assets/app_icon.png";
      genericName = "Music Player";
      desktopName = "Particle Music";
      categories = ["AudioVideo" "Audio" "Player" "Music"];
    })
  ];

  meta = {
    description = "A cross-platform local music player based on Flutter";
    homepage = "https://github.com/AfalpHy/ParticleMusic";
    licence = with lib.licenses; [asl20];
    platforms = lib.platforms.linux;
  };
}
