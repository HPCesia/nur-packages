{
  lib,
  stdenv,
  fetchFromGitHub,
  zellij,
  writeShellScript,
  makeWrapper,
  installShellFiles,
  bash,
  coreutils,
  yazi ? null,
  nnn ? null,
  broot ? null,
  lf ? null,
  fff ? null,
  felix ? null,
  lazygit ? null,
}:
stdenv.mkDerivation (
  finalAttrs: {
    pname = "zide";
    version = "3.2.0";
    src = fetchFromGitHub {
      owner = "josephschmitt";
      repo = "zide";
      rev = "a0903f9a503f2261e768aa7c23628921c027a88e";
      sha256 = "0wlwywl5cai4b685il3hhk0wlmv31w4gwn0labn51hdmcwkg9sad";
    };

    nativeBuildInputs = [
      makeWrapper
      installShellFiles
    ];

    buildInputs = [
      bash
      coreutils
    ];

    passthru = {
      defaultLayout = "default";
      defaultFilePicker = "yazi";
      layoutDir = null;
      alwaysName = false;
      useYaziConfig = true;
      useLfConfig = true;
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/zide
      mkdir -p $out/bin

      cp -r . $out/share/zide/

      for script in bin/zide bin/zide-pick bin/zide-edit bin/zide-rename; do
        if [[ -f "$script" ]]; then
          scriptName=$(basename "$script")
          makeWrapper "$out/share/zide/$script" "$out/bin/$scriptName" \
            --set ZIDE_DIR "$out/share/zide" \
            --prefix PATH : "${lib.makeBinPath (
        [
          zellij
          bash
          coreutils
        ]
        ++ lib.optional (yazi != null) yazi
        ++ lib.optional (nnn != null) nnn
        ++ lib.optional (broot != null) broot
        ++ lib.optional (lf != null) lf
        ++ lib.optional (fff != null) fff
        ++ lib.optional (felix != null) felix
        ++ lib.optional (lazygit != null) lazygit
      )}" \
            --set ZIDE_DEFAULT_LAYOUT "${finalAttrs.passthru.defaultLayout}" \
            --set ZIDE_FILE_PICKER "${finalAttrs.passthru.defaultFilePicker}" \
            ${lib.optionalString (finalAttrs.passthru.layoutDir != null)
        "--set ZIDE_LAYOUT_DIR \"${finalAttrs.passthru.layoutDir}\""} \
            ${lib.optionalString finalAttrs.passthru.alwaysName
        "--set ZIDE_ALWAYS_NAME \"true\""} \
            ${lib.optionalString (!finalAttrs.passthru.useYaziConfig)
        "--set ZIDE_USE_YAZI_CONFIG \"false\""} \
            ${lib.optionalString (!finalAttrs.passthru.useLfConfig)
        "--set ZIDE_USE_LF_CONFIG \"false\""}
        fi
      done


      chmod +x $out/bin/*

      runHook postInstall
    '';
    meta = {
      description = "Group of configuration files and scripts to create an IDE-like experience in zellij";
      homepage = "https://github.com/josephschmitt/zide";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [HPCesia];
      platforms = lib.platforms.unix;
      mainProgram = "zide";
    };
  }
)
