{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  dpkg,
  xdg-utils,
  mpv,
  zenity,
}:
stdenvNoCC.mkDerivation rec {
  pname = "harmonoid";
  version = "0.3.10";

  src =
    if stdenvNoCC.isLinux
    then
      fetchurl {
        url = "https://github.com/alexmercerind2/harmonoid-releases/releases/download/v${version}/harmonoid-linux-x86_64.tar.gz";
        hash = "sha256-GTF9KrcTolCc1w/WT0flwlBCBitskFPaJuNUdxCW9gs=";
      }
    else if stdenvNoCC.isDarwin # Darwin version is not tested.
    then
      fetchurl {
        url = "https://github.com/alexmercerind2/harmonoid-releases/releases/download/v${version}/harmonoid-macos-universal.dmg";
        hash = "sha256-m2Ifm/updeGKPk7ovnSBONd2MOKbXb5aTmZFZf8FFv8=";
      }
    else throw "Unsupported platform";

  dontStrip = true;

  nativeBuildInputs =
    [makeWrapper]
    ++ lib.optionals stdenvNoCC.isLinux [autoPatchelfHook dpkg];

  buildInputs = lib.optionals stdenvNoCC.isLinux [
    mpv
    xdg-utils
    zenity
  ];

  sourceRoot =
    if stdenvNoCC.isDarwin
    then "Harmonoid"
    else ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out

    if [ "$system" = "x86_64-linux" ]; then
      cp -r usr/* $out/
    fi

    if [ "$system" = "x86_64-darwin" ] || [ "$system" = "aarch64-darwin" ]; then
      mkdir -p $out/Applications
      cp -r Harmonoid.app $out/Applications/
      mkdir -p $out/bin
      ln -s $out/Applications/Harmonoid.app/Contents/MacOS/Harmonoid $out/bin/harmonoid
    fi

    runHook postInstall
  '';

  postFixup = lib.optionalString stdenvNoCC.isLinux ''
    wrapProgram $out/bin/harmonoid \
      --prefix PATH : ${lib.makeBinPath buildInputs} \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [mpv]}:$out/share/harmonoid/lib"
  '';

  meta = {
    description = "Plays & manages your music library. Looks beautiful & juicy.";
    homepage = "https://harmonoid.com/";
    license = lib.licenses.unfree;
    platforms = ["x86_64-linux" "x86_64-darwin" "aarch64-darwin"];
    maintainers = with lib.maintainers; [HPCesia];
  };
}
