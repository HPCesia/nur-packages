{
  lib,
  stdenv,
  fetchurl,
  unzip,
  fetchFromGitHub,
  flutter344,
  libappindicator,
  mpv-unwrapped,
  copyDesktopItems,
  makeDesktopItem,
}:
let
  updateScript = [(toString ./update.sh)];
in
flutter344.buildFlutterApplication rec {
  pname = "sylvakru";
  version = "3.6.0";

  passthru = {inherit updateScript;};

  src = fetchFromGitHub {
    owner = "AfalpHy";
    repo = "sylvakru";
    tag = "v${version}";
    hash = "sha256-uOmn8FYTgdb8rszHwJeqU1m+YSy5mPvkVGWUtFSYXSY=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  riveLinuxLibs = fetchurl {
    url = "https://rive-flutter-artifacts.rive.app/rive_native_versions/0.1.10%2B2/rive_native_artifacts_linux.zip";
    hash = "sha512-5420epvMhyfbth0au+OhOiNQG1sU7hnRjnaAdGQmKumOKJmVN2zVbq2NVwlM9vL9ZzgW41jiM+S/T3e95zkhEg==";
  };

  customSourceBuilders = {
    sqlite3_flutter_libs = {
      version,
      src,
      ...
    }:
      stdenv.mkDerivation {
        pname = "sqlite3_flutter_libs";
        inherit version src;
        inherit (src) passthru;

        installPhase = ''
          runHook preInstall

          cp -r . $out

          runHook postInstall
        '';
      };
    sqlcipher_flutter_libs = {
      version,
      src,
      ...
    }:
      stdenv.mkDerivation {
        pname = "sqlcipher_flutter_libs";
        inherit version src;
        inherit (src) passthru;

        installPhase = ''
          runHook preInstall

          cp -r . $out

          runHook postInstall
        '';
      };
    rive_native = {
      version,
      src,
      ...
    }:
      stdenv.mkDerivation {
        pname = "rive_native";
        inherit version src;
        inherit (src) passthru;

        nativeBuildInputs = [unzip];

        postPatch = ''
          pushd ${src.passthru.packageRoot}
          mkdir -p linux/bin
          unzip -q ${riveLinuxLibs} -d linux/bin
          touch linux/rive_marker_linux_development
          popd
        '';

        installPhase = ''
          runHook preInstall

          cp -r . $out

          runHook postInstall
        '';
      };
  };

  gitHashes = let
    media-kit-hash = "sha256-6dDr1PeAQc3tkHB9Cjrw2GIytSo/97Z6Vj/3zxyg4hI=";
  in {
    audio_service_win = "sha256-wbE9F2GruM6yl7Xa5XuTPnfqy5YBqCOUObTCA1zI8iY=";
    file_picker = "sha256-oMacfNTrKSnkjqEB6JWD9Yc8ANRIZT0TwHLdZI+bq4Q=";
    media_kit = media-kit-hash;
    media_kit_libs_android_audio = media-kit-hash;
    media_kit_libs_ios_audio = media-kit-hash;
    media_kit_libs_macos_audio = media-kit-hash;
    media_kit_libs_windows_audio = media-kit-hash;
    tray_manager = "sha256-JvT62iBbTVr2CAyCoAVpAoIywCqjxx4TkTgljH6BnYE=";
    window_manager = "sha256-Xt9m+YzLTVKDF5Gk165MVy6yx81O/1Arqqk0caTGoXc=";
  };

  postPatch = ''
    substituteInPlace pubspec.yaml \
      --replace-fail "flutter: 3.44.8" "flutter: ^3.44.8"

    # Don't statically link mimalloc into the main executable: its global
    # operator new override trips a libc++ assertion in Flutter >= 3.44
    # (exceptions-disabled build), crashing the app.
    # https://github.com/flutter/flutter/issues/188877
    substituteInPlace linux/CMakeLists.txt \
      --replace-fail 'target_link_libraries(''${BINARY_NAME} PRIVATE ''${MIMALLOC_LIB})' ""
  '';

  nativeBuildInputs = [copyDesktopItems];

  buildInputs = [
    libappindicator
  ];

  extraWrapProgramArgs = ''
    --prefix LD_LIBRARY_PATH : $out/app/sylvakru/lib:${lib.makeLibraryPath [mpv-unwrapped]}
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "sylvakru";
      exec = pname;
      icon = "${src}/assets/app_icon.png";
      genericName = "Music Player";
      desktopName = "Sylvakru";
      categories = ["AudioVideo" "Audio" "Player" "Music"];
    })
  ];

  meta = {
    description = "A cross-platform music player for local and self-hosted libraries";
    homepage = "https://github.com/AfalpHy/sylvakru";
    license = with lib.licenses; [asl20];
    platforms = lib.platforms.linux;
  };
}
