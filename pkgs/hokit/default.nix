{
  lib,
  pkgs,
  fetchurl,
  appimageTools,
  nix-update-script,
}: let
  pname = "hokit";
  version = "1.8.10";

  src = fetchurl {
    url = "https://github.com/yabi-zzh/HoKit/releases/download/v${version}/HoKit-linux-x86_64-${version}.AppImage";
    hash = "sha256-Wf7Le/B9oL63admSLtNuaErlQAuvOdddC+DziRDpvdk=";
  };

  # sharp 0.34.5 bundles a libvips that statically links GLib, which crashes
  # the HAP parser utility process once system GLib is loaded.
  # Rebuild the matching 8.17 ABI against system GLib.
  vips = pkgs.vips.overrideAttrs (old: {
    version = "8.17.3";
    src = pkgs.fetchFromGitHub {
      owner = "libvips";
      repo = "libvips";
      tag = "v8.17.3";
      hash = "sha256-yxjfkb2R3JPHbz0vCG4hkW9Davoc9MUPHL9Cqc+Ik0Y=";
      postFetch = "rm -r $out/test/test-suite/images/";
    };
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace libvips/include/vips/memory.h \
          --replace-fail '(void) F((S));' 'F((S));'
      '';
  });

  appimageContents = appimageTools.extract {
    inherit pname version src;
    # App's runtime chmod fails on the read-only store.
    postExtract = ''
      rm -f $out/resources/app.asar.unpacked/node_modules/@img/sharp-libvips-linux-x64/lib/libvips-cpp.so.8.17.3
      ln -s ${lib.getLib vips}/lib/libvips-cpp.so.42 $out/resources/app.asar.unpacked/node_modules/@img/sharp-libvips-linux-x64/lib/libvips-cpp.so.8.17.3

      chmod +x \
        $out/resources/assets/tools/jre/bin/* \
        $out/resources/assets/tools/jre/lib/jexec \
        $out/resources/assets/tools/jre/lib/jspawnhelper \
        $out/resources/assets/tools/hdc/hdc
    '';
  };
in
  appimageTools.wrapAppImage {
    inherit pname version;
    contents = appimageContents;

    passthru = {
      inherit src;
      updateScript = nix-update-script {};
    };
    preferLocalBuild = true;

    extraInstallCommands = ''
      install -m 444 -D ${appimageContents}/ho-kit.desktop $out/share/applications/ho-kit.desktop
      install -d $out/share/icons
      cp -r ${appimageContents}/usr/share/icons/hicolor $out/share/icons/

      substituteInPlace $out/share/applications/ho-kit.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=${pname}'

      # Under XWayland the portal cannot export the window handle, so the
      # file picker fails.
      # Chromium only auto-selects libsecret for known desktops; elsewhere
      # it falls back to plaintext (e.g. niri, sway, Hyprland).
      mv $out/bin/${pname} $out/bin/.${pname}-wrapped
      cat > $out/bin/${pname} <<'EOF'
      #!@runtimeShell@
      case "''${XDG_CURRENT_DESKTOP:-}" in
        *KDE*) exec @out@/bin/.@pname@-wrapped --ozone-platform-hint=auto "$@" ;;
        *) exec @out@/bin/.@pname@-wrapped --ozone-platform-hint=auto --password-store=gnome-libsecret "$@" ;;
      esac
      EOF
      substituteInPlace $out/bin/${pname} \
        --replace-fail '@runtimeShell@' "${pkgs.runtimeShell}" \
        --replace-fail '@out@' "$out" \
        --replace-fail '@pname@' '${pname}'
      chmod +x $out/bin/${pname}
    '';

    meta = {
      description = "All-in-one HarmonyOS NEXT app development toolkit";
      homepage = "https://github.com/yabi-zzh/HoKit";
      license = lib.licenses.unfree;
      mainProgram = pname;
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
