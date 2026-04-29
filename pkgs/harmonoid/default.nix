{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  dpkg,
  gtk3,
  mpv,
  xdg-utils,
  zenity,
}:
stdenvNoCC.mkDerivation rec {
  pname = "harmonoid";
  version = "0.3.22";

  src =
    if stdenvNoCC.isAarch64
    then
      fetchurl {
        url = "https://github.com/alexmercerind2/harmonoid-releases/releases/download/v${version}/harmonoid-linux-aarch64.tar.gz";
        hash = "sha256-jXN5i+LudsODNZUzb5SXClqgQxYzanrbZCqB8X0pJRQ=";
      }
    else
      fetchurl {
        url = "https://github.com/alexmercerind2/harmonoid-releases/releases/download/v${version}/harmonoid-linux-x86_64.tar.gz";
        hash = "sha256-+fEx30uu0rZiORrtE00xG2piJzpFbfxSZw3OjrhLJyg=";
      };

  dontStrip = true;

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
    dpkg
  ];

  buildInputs = [
    gtk3
    mpv
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
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [mpv]}:$out/share/harmonoid/lib"
  '';

  meta = {
    description = "Plays & manages your music library. Looks beautiful & juicy.";
    homepage = "https://harmonoid.com/";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux" "aarch64-linux"];
  };
}
