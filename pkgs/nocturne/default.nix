# Modifed from https://forge.kruemmelspalter.org/communix/nur-packages/src/branch/main/pkgs/nocturne/default.nix
# Also in NUR https://github.com/nix-community/nur-combined/blob/4c3b2c48edfcb14533c0989fbfd3ba7f68200f9a/repos/Baum/pkgs/nocturne/default.nix
{
  lib,
  stdenv,
  python3,
  fetchFromGitHub,
  fetchFromGitLab,
  gtk4,
  shared-mime-info,
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
}: let
  gtk4New = gtk4.overrideAttrs (old: rec {
    version = "4.22.1";
    nativeBuildInputs = old.nativeBuildInputs ++ [shared-mime-info];
    src = fetchFromGitLab {
      domain = "gitlab.gnome.org";
      owner = "GNOME";
      repo = "gtk";
      tag = version;
      hash = "sha256-MTW5qCq3Sj0aSGPfGQphN1t4cs4rPbLPBc7BRgOktDE=";
    };
  });
  libadwaitaNew = (
    (libadwaita.overrideAttrs (_: rec {
      version = "1.9.0";
      src = fetchFromGitLab {
        domain = "gitlab.gnome.org";
        owner = "GNOME";
        repo = "libadwaita";
        tag = version;
        hash = "sha256-JAKP8CjLCKGZvHoB26ih/J3xAru4wiVf/ObG0L8r4pY=";
      };
    })).override
    {
      gtk4 = gtk4New;
    }
  );
in
  stdenv.mkDerivation {
    pname = "nocturne";
    version = "1.1.1";

    src = fetchFromGitHub {
      owner = "Jeffser";
      repo = "Nocturne";
      rev = "74f1420a9a2171e48440686f083720ba49a554aa";
      hash = "sha256-7B9wtuxfsF6brtLkIEeWII4IvXwdJHnZ1Wr3uLfoqHU=";
    };

    nativeBuildInputs = [
      (blueprint-compiler.override {
        libadwaita = libadwaitaNew;
      })
      desktop-file-utils
      gobject-introspection
      meson
      ninja
      pkg-config
      wrapGAppsHook4
    ];

    buildInputs = [
      gst_all_1.gstreamer
      gtk4New
      libadwaitaNew
      libsecret
      xdg-user-dirs
      (python3.withPackages (py:
        with py; [
          colorthief
          (callPackage ./mpris-server.nix {})
          requests
          syncedlyrics
          tinytag
        ]))
    ];

    preFixup = ''
      gappsWrapperArgs+=(
        --prefix GI_TYPELIB_PATH : "${gtk4New}/lib/girepository-1.0"
        --prefix GI_TYPELIB_PATH : "${libadwaitaNew}/lib/girepository-1.0"
        --prefix PATH : "${lib.getBin xdg-user-dirs}/bin"
      )
    '';

    meta = with lib; {
      description = "An Adwaita Music Player / Library Manager ";
      homepage = "https://github.com/Jeffser/Nocturne";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
    };
  }
