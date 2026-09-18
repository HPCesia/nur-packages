{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  libcosmicAppHook,
  pkg-config,
  libxkbcommon,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cosmic-enroll";
  version = "1.2.7";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "enroll";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rbdXwY8Kklv3exr4o+hX0xZR/XzvSSwT8FS0BQNdSwg=";
  };

  cargoHash = "sha256-+58g91LTdLuYOP2kBp0rHiCoW4JQoOHrGxQDj0+z+Zk=";
  doCheck = false;

  nativeBuildInputs = [
    libcosmicAppHook
    pkg-config
  ];

  buildInputs = [libxkbcommon];

  env.VERGEN_GIT_SHA = finalAttrs.src.tag;

  installPhase = ''
    runHook preInstall

    install -Dm0755 "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/cosmic-utils-enroll" \
      "$out/bin/cosmic-utils-enroll"
    install -Dm0644 resources/org.cosmic_utils.enroll.desktop \
      "$out/share/applications/org.cosmic_utils.enroll.desktop"
    install -Dm0644 resources/org.cosmic_utils.enroll.metainfo.xml \
      "$out/share/metainfo/org.cosmic_utils.enroll.metainfo.xml"
    install -Dm0644 resources/icons/hicolor/scalable/apps/enroll.svg \
      "$out/share/icons/hicolor/scalable/apps/org.cosmic_utils.enroll.svg"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "COSMIC GUI for enrolling fingerprints with fprintd";
    homepage = "https://github.com/cosmic-utils/enroll";
    license = lib.licenses.mpl20;
    mainProgram = "cosmic-utils-enroll";
    platforms = lib.platforms.linux;
  };
})
