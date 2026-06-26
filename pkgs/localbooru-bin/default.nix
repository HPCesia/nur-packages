# Modify from https://github.com/ixhbinphoenix/nur-packages/blob/3ffe840c9c51685c355265be754a50a9c048e60d/pkgs/localbooru-bin/default.nix
{
  lib,
  fetchurl,
  stdenv,
  autoPatchelfHook,
  dpkg,
  makeWrapper,
  wrapGAppsHook3,
  mpv-unwrapped,
  xdg-user-dirs,
  zenity,
}:
stdenv.mkDerivation rec {
  pname = "localbooru-bin";
  version = "1.6.1";

  src = fetchurl {
    url = "https://github.com/resucutie/localbooru/releases/download/${version}/localbooru-linux.deb";
    hash = "sha256-N37XdomSJFu3UPYcTmtihFwwGnbb5JCSdRDMVdlsP+8=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    mpv-unwrapped
  ];

  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r * $out
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/usr/share/localbooru/localbooru $out/bin/localbooru \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : $out/usr/share/localbooru/lib:${lib.makeLibraryPath [mpv-unwrapped]} \
      --prefix PATH : ${lib.makeBinPath [xdg-user-dirs zenity]}
  '';

  meta = {
    description = "Cross platform local booru collection that exclusively works on local storage, without selfhosting";
    homepage = "https://github.com/resucutie/localbooru";
    mainProgram = "localbooru";
    platforms = ["x86_64-linux"];
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
  };
}
