{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  autoPatchelfHook,
  cairo,
  copyDesktopItems,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libGL,
  libdrm,
  libgbm,
  libpulseaudio,
  libuuid,
  libvdpau,
  libva,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  makeDesktopItem,
  makeWrapper,
  mesa,
  nspr,
  nss,
  pango,
  pipewire,
  systemd,
  vulkan-loader,
  wayland,
  kdePackages,
}:
stdenv.mkDerivation rec {
  pname = "helium";
  version = "0.20.3.1";

  passthru.updateScript = [(toString ./update.sh)];
  preferLocalBuild = true;

  src =
    if stdenv.hostPlatform.isAarch64
    then
      fetchurl {
        url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-arm64_linux.tar.xz";
        hash = "sha256-9C/oUbJuFgTHc5lGOWhAmtaJUqOhgIeX42EYmzGk6gg=";
      }
    else
      fetchurl {
        url = "https://github.com/imputnet/helium-linux/releases/download/${version}/helium-${version}-x86_64_linux.tar.xz";
        hash = "sha256-N1nqTpW/TvSgpkd+PXNXaw8DkG8ugDVydb/Gysr7X6w=";
      };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    libdrm
    libgbm
    libpulseaudio
    libuuid
    libvdpau
    libva
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxrender
    libxscrnsaver
    libxshmfence
    libxtst
    mesa
    nspr
    nss
    pango
    pipewire
    systemd
    vulkan-loader
    wayland
    kdePackages.qtbase
  ];

  runtimeDependencies = [gtk3];

  # Qt is linked by optional KDE integration helpers only, so the browser must
  # not be wrapped with a QPA environment.
  dontWrapQtApps = true;

  autoPatchelfIgnoreMissingDeps = [
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/helium
    cp -r * $out/opt/helium

    makeWrapper $out/opt/helium/helium $out/bin/helium \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [libGL libvdpau libva pipewire alsa-lib libpulseaudio]}" \
      --add-flags "--ozone-platform-hint=auto" \
      --add-flags "--enable-features=WaylandWindowDecorations"

    install -Dm444 $out/opt/helium/product_logo_256.png \
      $out/share/icons/hicolor/256x256/apps/helium.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "helium";
      exec = "helium %U";
      icon = "helium";
      desktopName = "Helium";
      genericName = "Web Browser";
      comment = "Private, fast, and honest web browser";
      categories = ["Network" "WebBrowser"];
      mimeTypes = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
    })
  ];

  meta = {
    description = "Private, fast, and honest web browser based on ungoogled-chromium";
    homepage = "https://helium.computer/";
    license = lib.licenses.gpl3Only;
    mainProgram = "helium";
    platforms = ["x86_64-linux" "aarch64-linux"];
  };
}
