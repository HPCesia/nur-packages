# Modify from https://github.com/bet4it/nur-packages/blob/cad7c4585ef10f189352ca894866d345081a44ce/pkgs/kelivo/package.nix
{
  lib,
  flutter338,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  gst_all_1,
  keybinder3,
  libappindicator,
}:
flutter338.buildFlutterApplication {
  pname = "kelivo";
  version = "1.1.13";

  src = fetchFromGitHub {
    owner = "Chevey339";
    repo = "kelivo";
    rev = "7acbdc3d70c649076edceeaa9570ec7c6fa893ac";
    hash = "sha256-87uAF9Tm+cZwbc2WS9g9+RpYCZuLJMwNKF/pCZSJQtU=";
  };

  pubspecLock = lib.importJSON ./pubspec.lock.json;

  nativeBuildInputs = [
    copyDesktopItems
  ];

  buildInputs = [
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    keybinder3
    libappindicator
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "com.psyche.kelivo";
      exec = "kelivo";
      icon = "com.psyche.kelivo";
      desktopName = "Kelivo";
      startupWMClass = "com.psyche.kelivo";
      comment = "An LLM chat client";
      categories = [
        "Network"
        "Chat"
      ];
    })
  ];

  postInstall = ''
    install -Dm644 assets/app_icon.png \
      $out/share/icons/hicolor/512x512/apps/com.psyche.kelivo.png
    ln -s com.psyche.kelivo.png \
      $out/share/icons/hicolor/512x512/apps/kelivo.png
  '';

  meta = {
    description = "LLM chat client";
    homepage = "https://github.com/Chevey339/kelivo";
    license = lib.licenses.agpl3Plus;
    platforms = ["x86_64-linux" "aarch64-linux"];
  };
}
