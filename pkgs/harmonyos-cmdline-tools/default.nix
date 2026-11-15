{
  lib,
  stdenv,
  requireFile,
  unzip,
  autoPatchelfHook,
  makeWrapper,
  bzip2,
  db5,
  ffmpeg_7,
  fontconfig,
  freetype,
  libGL,
  libdrm,
  libice,
  libpng,
  libpulseaudio,
  libsm,
  libx11,
  libxcb,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-wm,
  libxcrypt-legacy,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxkbcommon,
  libxrandr,
  libxrender,
  mesa,
  ncurses,
  ncurses5,
  openssl,
  patchelf,
  python312,
  sqlite,
  wayland,
  xz,
  zlib,
}: let
  paths = import ./library-paths.nix;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "harmonyos-cmdline-tools";
    version = "26.0.0.865";

    src = requireFile {
      name = "commandline-tools-linux-x64-${finalAttrs.version}.zip";
      hash = "sha256-5f2n037vESY1iCA9ck0bcjgCc9PAdTW7fTYaHQ6VzzQ=";
      message = ''
        This nix expression requires that commandline-tools-linux-x64-${finalAttrs.version}.zip
        is already part of the Nix store.

        Download "Command Line Tools" for linux-x64 from

          https://developer.huawei.com/consumer/en/download/

        A Huawei developer account is required, and the download link is signed
        and expires quickly, so the file cannot be fetched automatically.

        Add the downloaded file to the Nix store with

          nix-store --add-fixed sha256 /path/to/commandline-tools-linux-x64-${finalAttrs.version}.zip

        The file name must stay unchanged. Building this package afterwards keeps
        the archive reachable from a garbage collector root.
      '';
    };

    nativeBuildInputs = [
      unzip
      autoPatchelfHook
      makeWrapper
      patchelf
      python312
    ];

    buildInputs = [
      (lib.getLib stdenv.cc.cc)
      bzip2
      db5
      ffmpeg_7
      fontconfig
      freetype
      libGL
      libdrm
      libice
      libpng
      libpulseaudio
      libsm
      libx11
      libxcb
      libxcb-image
      libxcb-keysyms
      libxcb-render-util
      libxcb-wm
      libxcrypt-legacy
      libxcursor
      libxext
      libxi
      libxinerama
      libxkbcommon
      libxrandr
      libxrender
      mesa
      ncurses
      ncurses5
      openssl
      sqlite
      wayland
      xz
      zlib
    ];

    # Unzipped straight into $out; stripping breaks the arm device libraries
    # and the node build.
    dontUnpack = true;
    dontStrip = true;

    # Wanted by the previewer, emulator and taihe python; nixpkgs dropped some
    # of these sonames and the archive does not ship the rest.
    autoPatchelfIgnoreMissingDeps = [
      "libcrypto.so.1.1"
      "libffi.so.6"
      "libgdbm.so.5"
      "libreadline.so.7"
      "libshared_libz.so"
      "libssl.so.1.1"
      "libxml2.so.2"
    ];

    installPhase = ''
      runHook preInstall

      payload=$out/libexec/command-line-tools
      mkdir -p "$out/libexec" "$out/bin"
      unzip -q "$src" -d "$out/libexec"
      chmod -R u+w "$payload"

      for tool in ohpm hvigorw codelinter arktsdoc hstack; do
        makeWrapper "$payload/bin/$tool" "$out/bin/$tool"
      done

      # libX11 dlopen()s libXcursor by soname, which ld.so.cache cannot resolve.
      makeWrapper "$payload/bin/Emulator" "$out/bin/Emulator" \
        --prefix LD_LIBRARY_PATH : "${lib.getLib libxcursor}/lib"

      ln -s "$payload/sdk/default/openharmony/toolchains/hdc" "$out/bin/hdc"

      runHook postInstall
    '';

    # libglfw dlopen()s libX11/Wayland, which autoPatchelf cannot see: set its
    # rpath, then run the hook now so the smoke test can execute the emulator.
    postFixup = ''
      payload=$out/libexec/command-line-tools

      patchelf --set-rpath "${lib.makeLibraryPath [
        libxkbcommon
        wayland
        libx11
        libxcursor
        libxext
        libxi
        libxinerama
        libxrandr
        libxrender
        libxcb
      ]}" "$payload/emulator/libglfw.so.3"

      # The emulator and ohpm would create ~/Library; rewrite their constants.
      ${python312}/bin/python3.12 ${./patch-emulator-paths.py} \
        --library-map ${paths.json} "$payload"

      autoPatchelf "$out"
      export dontAutoPatchelf=1

      # Offline smoke test; -license only writes the config file.
      smoke_home=$(mktemp -d)
      (
        cd "$smoke_home"
        unset XDG_CACHE_HOME XDG_CONFIG_HOME
        export HOME="$smoke_home" QT_QPA_PLATFORM=offscreen
        "$payload/emulator/Emulator" -version | grep -q 'HarmonyOS Emulator'
        "$payload/emulator/Emulator" -help >/dev/null 2>&1
        "$payload/emulator/Emulator" -license accept >/dev/null 2>&1
      )
      find "$smoke_home/.cache/Huawei" -name .emu_config | grep -q .
      if test -e "$smoke_home/Library"; then
        echo "patch-emulator-paths: emulator still creates ~/Library:" >&2
        find "$smoke_home/Library" >&2
        exit 1
      fi
    '';

    preferLocalBuild = true;

    # The unpacked tools tree, consumed by deveco-studio.
    passthru.payload = "${finalAttrs.finalPackage}/libexec/command-line-tools";

    meta = {
      description = "Command line tools and SDK for HarmonyOS and OpenHarmony application development";
      homepage = "https://developer.huawei.com/consumer/en/download/";
      platforms = ["x86_64-linux"];
      license = lib.licenses.unfree;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  })
