{
  lib,
  fetchFromGitHub,
  flutter341,
  libappindicator,
  mpv,
  copyDesktopItems,
  makeDesktopItem,
}:
flutter341.buildFlutterApplication rec {
  name = "particle-music";
  pname = "ParticleMusic";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "AfalpHy";
    repo = "ParticleMusic";
    tag = "v${version}";
    hash = "sha256-sPNln6HAAg4W7fzEb18rbZroQTm/cUw5PrvFLsnqZ+Q=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;
  gitHashes = {
    audio_service_win = "sha256-MkZj8EmIe6WQmDFT+lBLdHTBLjLwh1YonZoZYPG4W7I=";
    audio_tags_lofty = "sha256-FztC266h0z0+JtzXUIe8gEVHjVZuL6MJR1pOF1+0igk=";
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
    --prefix LD_LIBRARY_PATH : $out/app/ParticleMusic/lib:${lib.makeLibraryPath [mpv]}
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "ParticleMusic";
      exec = pname;
      icon = "ParticleMusic";
      genericName = "Music Player";
      desktopName = "Particle Music";
    })
  ];

  meta = {
    description = "A cross-platform local music player based on Flutter";
    homepage = "https://github.com/AfalpHy/ParticleMusic";
    mainProgram = "ParticleMusic";
    licence = with lib.licenses; [asl20];
    platforms = lib.platforms.linux;
  };
}
