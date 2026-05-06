{
  lib,
  fetchFromGitHub,
  fetchurl,
  stdenv,
  python3,
  python3Packages,
  wineWow64Packages,
  unzip,
  makeWrapper,
  protontricks,
  killall,
}: let
  mo2-lint-src = fetchFromGitHub {
    owner = "Furglitch";
    repo = "modorganizer2-linux-installer";
    rev = "9901250df943d4c478ad98b2e4cc8e0193a07973";
    hash = "sha256-Y6lkg3sCNKkudsrZnm0kyw9c/KFpfVhbh0DjRwjb7vw=";
  };

  python-embed = fetchurl {
    url = "https://www.python.org/ftp/python/3.13.0/python-3.13.0-embed-amd64.zip";
    hash = "sha256-AcMtBzdDIkCtzwu8HTIyfwl206HhQnd0vI/ryPHAMRE=";
  };

  get-pip-script = fetchurl {
    url = "https://raw.githubusercontent.com/pypa/get-pip/refs/tags/26.1.1/public/get-pip.py";
    hash = "sha256-ZpBLzLh442PbYjbqkA5pNeUH3LiH6fF49iEu3+f0anY=";
  };

  windows-python-deps = stdenv.mkDerivation {
    name = "mo2-win-pip-wheels";

    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-Oa7kncQpU4HXv/aq7cXrJ5xW+MiNG8P14NJw8Kp2cXA=";

    nativeBuildInputs = [python3 python3Packages.pip];

    buildCommand = ''
      mkdir -p $out
      export PIP_CACHE_DIR=$TMPDIR/pip-cache

      pip download \
        --platform win_amd64 \
        --python-version 3.13 \
        --only-binary=:all: \
        --dest $out \
        pyinstaller loguru pyyaml pip pefile pywin32-ctypes colorama win32-setctime
    '';
  };

  mo2-redirector = stdenv.mkDerivation {
    name = "mo2-redirector.exe";

    src = mo2-lint-src;

    nativeBuildInputs = [wineWow64Packages.stable unzip];

    buildPhase = ''
      runHook preBuild

      export XDG_CACHE_HOME=$TMPDIR/.cache
      export FONTCONFIG_CACHE=$XDG_CACHE_HOME/fontconfig
      mkdir -p $FONTCONFIG_CACHE

      export WINEPREFIX=$TMPDIR/wine
      export WINEARCH=win64
      export WINEDEBUG=-all

      wineboot --init
      wineserver -w

      mkdir -p $WINEPREFIX/drive_c/python313

      unzip -q ${python-embed} -d $WINEPREFIX/drive_c/python313
      sed -i 's/#import site/import site/' $WINEPREFIX/drive_c/python313/python313._pth

      wine "C:\\python313\\python.exe" Z:${get-pip-script} --no-index \
        --find-links=Z:${windows-python-deps} \
        --no-warn-script-location

      wine "C:\\python313\\python.exe" -m pip install --no-index \
        --find-links=Z:${windows-python-deps} \
        pyinstaller loguru pyyaml

      wine "C:\\python313\\python.exe" -m PyInstaller \
        --onefile \
        --noconsole \
        --name mo2-redirector.exe \
        --paths src \
        --hidden-import loguru \
        --hidden-import yaml \
        --hidden-import configparser \
        --add-data "configs;cfg" \
        --icon Z:$PWD/.github/README/logo.ico \
        Z:$PWD/src/redirector/__init__.py

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/dist
      cp dist/mo2-redirector.exe $out/dist/

      runHook postInstall
    '';
  };

  runtime-python-deps = python3.withPackages (ps:
    with ps; [
      certifi
      click
      python-dotenv
      inquirerpy
      loguru
      patool
      psutil
      pydantic
      pyyaml
      requests
      send2trash
      websockets
      (python3Packages.toPythonModule protontricks)
    ]);

  mo2-lint = stdenv.mkDerivation (finalAttrs: {
    name = "mo2-lint";
    pname = "mo2-lint";
    version = "0-unstable-2026-03-24";
    src = mo2-lint-src;

    nativeBuildInputs = [makeWrapper];

    postPatch = ''
      sed -i 's/Path(__file__)/Path(__file__).parent/g' src/mo2-lint/util/internal_file.py || true
      sed -i 's/copy2(src, dest)/copy2(src, dest); import os; os.chmod(dest, 0o644)/g' src/mo2-lint/__init__.py
      sed -i 's/copy2(internal_path, output)/copy2(internal_path, output); import os; os.chmod(output, 0o644)/g' src/mo2-lint/util/nexus/install_handler.py
      sed -i '1s/^/import sys; sys.argv[0] = "${finalAttrs.pname}"\n/' src/mo2-lint/__init__.py
    '';

    buildPhase = ''
      runHook preBuild

      mkdir -p dist
      ln -s ${mo2-redirector}/dist/mo2-redirector.exe dist/

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/mo2-lint
      cp -r src configs dist $out/share/mo2-lint/
      ln -s $out/share/mo2-lint/configs $out/share/mo2-lint/src/mo2-lint/util/cfg
      ln -s $out/share/mo2-lint/dist $out/share/mo2-lint/src/mo2-lint/util/dist

      mkdir -p $out/bin
      makeWrapper ${runtime-python-deps}/bin/python $out/bin/${finalAttrs.pname} \
        --add-flags "$out/share/mo2-lint/src/mo2-lint/__init__.py" \
        --chdir "$out/share/mo2-lint" \
        --prefix PYTHONPATH : "$out/share/mo2-lint/src" \
        --set MEIPASS "$out/share/mo2-lint" \
        --set _MEIPASS2 "$out/share/mo2-lint" \
        --set-default LOGURU_LEVEL "INFO"
      makeWrapper ${runtime-python-deps}/bin/python $out/share/mo2-lint/dist/nxm-handler \
        --add-flags "$out/share/mo2-lint/src/nxm-handler/__init__.py" \
        --chdir "$out/share/mo2-lint" \
        --prefix PYTHONPATH : "$out/share/mo2-lint/src" \
        --set MEIPASS "$out/share/mo2-lint" \
        --set _MEIPASS2 "$out/share/mo2-lint" \
        --set-default LOGURU_LEVEL "INFO"

      runHook postInstall
    '';

    meta = {
      description = "An easy-to-use Mod Organizer 2 installer for Linux, rewrited in Python.";
      homepage = "https://github.com/Furglitch/modorganizer2-linux-installer/tree/rewrite";
      licence = lib.licenses.gpl3Only;
      platforms = ["x86_64-linux"];
    };
  });
in
  mo2-lint
