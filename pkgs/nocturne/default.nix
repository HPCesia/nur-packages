# Modifed from https://forge.kruemmelspalter.org/communix/nur-packages/src/branch/main/pkgs/nocturne/default.nix
# Also in NUR https://github.com/nix-community/nur-combined/blob/4c3b2c48edfcb14533c0989fbfd3ba7f68200f9a/repos/Baum/pkgs/nocturne/default.nix
{
  lib,
  stdenv,
  python3,
  fetchFromGitHub,
  gtk4,
  libadwaita,
  libsecret,
  meson,
  ninja,
  blueprint-compiler,
  pkg-config,
  wrapGAppsHook4,
  desktop-file-utils,
  gst_all_1,
  gobject-introspection,
  xdg-user-dirs,
}:
stdenv.mkDerivation {
  pname = "nocturne";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "Jeffser";
    repo = "Nocturne";
    rev = "469023d6c96450d3954364c961819ed0858d4d81";
    hash = "sha256-Hh4ix8w0z+s3QC5/UOZKtiAqmJ8yGqrkQnBqThTAFSo=";
  };

  nativeBuildInputs = [
    blueprint-compiler
    desktop-file-utils
    gobject-introspection
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gst_all_1.gstreamer
    gtk4
    libadwaita
    libsecret
    xdg-user-dirs
    (python3.withPackages (py:
      with py; [
        colorthief
        mpris-server
        requests
        syncedlyrics
        tinytag
      ]))
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix GI_TYPELIB_PATH : "${gtk4}/lib/girepository-1.0"
      --prefix GI_TYPELIB_PATH : "${libadwaita}/lib/girepository-1.0"
      --prefix PATH : "${lib.getBin xdg-user-dirs}/bin"
    )
  '';

  meta = with lib; {
    description = "An Adwaita Music Player / Library Manager ";
    homepage = "https://github.com/Jeffser/Nocturne";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
