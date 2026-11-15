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
  version = "0.3.40";

  passthru.updateScript = [(toString ./update.sh)];
  preferLocalBuild = true;

  src =
    if stdenvNoCC.isAarch64
    then
      fetchurl {
        url = "https://github.com/alexmercerind2/harmonoid-releases/releases/download/v${version}/harmonoid-linux-aarch64.tar.gz";
        hash = "sha256-v+hxv5KNXQmMJx08hkO9V009OY01xWA0xBWP0zUWO4Y=";
      }
    else
      fetchurl {
        url = "https://github.com/alexmercerind2/harmonoid-releases/releases/download/v${version}/harmonoid-linux-x86_64.tar.gz";
        hash = "sha256-cFeatg566QWsYNZbJzezPIpEMgxDAISXzdRJLQAg8Nk=";
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
