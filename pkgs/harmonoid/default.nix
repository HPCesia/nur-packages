{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  dpkg,
  wrapGAppsHook3,
  mpv-unwrapped,
  xdg-utils,
  zenity,
}:
stdenvNoCC.mkDerivation rec {
  pname = "harmonoid";
  version = "0.3.32";

  src =
    if stdenvNoCC.isAarch64
    then
      fetchurl {
        url = "https://github.com/alexmercerind2/harmonoid-releases/releases/download/v${version}/harmonoid-linux-aarch64.tar.gz";
        hash = "sha256-j9Pveq7iULBUVF7ochHWS9VynlJlk14m3KLRyAcNKiA=";
      }
    else
      fetchurl {
        url = "https://github.com/alexmercerind2/harmonoid-releases/releases/download/v${version}/harmonoid-linux-x86_64.tar.gz";
        hash = "sha256-ICnghYC25CLf5kzB6tUC/ocKI+J5HA7zyK9dEkLOWWE=";
      };

  dontStrip = true;

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    dpkg
    wrapGAppsHook3
  ];

  buildInputs = [
    mpv-unwrapped
    xdg-utils
    zenity
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out

      cp -r usr/* $out/

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/harmonoid \
      --prefix PATH : ${lib.makeBinPath buildInputs} \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [mpv-unwrapped]}:$out/share/harmonoid/lib"
  '';

  meta = {
    description = "Plays & manages your music library. Looks beautiful & juicy.";
    homepage = "https://harmonoid.com/";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux" "aarch64-linux"];
  };
}
