# See https://github.com/NixOS/nixpkgs/blob/4d086f5972639c94a1e805a8aa9c4ddd024bc2c1/pkgs/development/compilers/dart/package-source-builders/sqlite3/default.nix
{
  lib,
  stdenv,
  fetchurl,
  writeScript,
  sqlite,
}: {
  version,
  src,
  ...
}: let
  sqlcipher = let
    system-alias = {
      x86_64-linux = "x64.linux";
      aarch64-linux = "arm64.linux";
    };
  in
    stdenv.mkDerivation {
      name = "libsqlcipher.so";
      src = fetchurl {
        url = "https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-${version}/libsqlcipher.${
          system-alias.${stdenv.hostPlatform.system}
          or (throw "Unsupported system for pub 'sqlite3' ('sqlcipher' dependency)")
        }.so";
        sha256 =
          {
            _3_6_0-x86_64-linux = "sha256-zQkSbJ6FGR8rT1fmwLzSMsdIH1b7HWWbeTdMytIb/vk=";
            _3_6_0-aarch64-linux = "sha256-MHt26xqayuRRfM6iJTAiC6Pe7ez7FuWiY1ZLaqEwwp8=";
          }
          .${
            "_" + (lib.replaceStrings ["."] ["_"] version) + "-" + stdenv.hostPlatform.system
          }
          or (throw "Unsupported version of pub 'sqlite3' ('sqlcipher' dependency '${version}')");
      };
      unpackPhase = ":";
      installPhase = "mkdir -p $out/lib && cp $src $out/lib/libsqlcipher.so";
    };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "sqlite3";
    inherit version src;
    inherit (src) passthru;

    setupHook = writeScript "${finalAttrs.pname}-setup-hook" ''
      sqliteFixupHook() {
        runtimeDependencies+=('${lib.getLib sqlite}')
        runtimeDependencies+=('${lib.getLib sqlcipher}')
      }

      preFixupHooks+=(sqliteFixupHook)
    '';

    postPatch = ''
      substituteInPlace lib/src/hook/compile/description.dart \
        --replace-fail "return fromGitHub(LibraryType.sqlite3);" "return LookupSystem('sqlite3');"
      substituteInPlace lib/src/hook/compile/description.dart \
        --replace-fail "return fromGitHub(LibraryType.sqlcipher);" "return LookupSystem('sqlcipher');"
    '';

    installPhase = ''
      runHook preInstall

      cp --recursive . "$out"

      runHook postInstall
    '';
  })
