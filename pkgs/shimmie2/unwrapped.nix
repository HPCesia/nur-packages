{
  lib,
  php,
  fetchFromGitHub,
}:
(
  php.buildComposerProject2 (finalAttrs: {
    pname = "shimmie2-unwrapped";
    version = "2.12.4";

    src = fetchFromGitHub {
      owner = "shish";
      repo = "shimmie2";
      tag = "v${finalAttrs.version}";
      hash = "sha256-acB+/HWx4kKYAk6c2q3zivojNnrUVuOCx6xnPuuZvKs=";
    };

    vendorHash = "sha256-ssMc2CJjgkcVS6j3YYO9xVmwbfRuzp2YOJGGCtC+otc=";

    postInstall = ''
      mkdir -p $out/share/php/${finalAttrs.pname}/data
    '';

    meta = {
      description = "An easy-to-install community image gallery (aka booru)";
      homepage = "https://github.com/shish/shimmie2";
      licence = lib.licenses.gpl2Only;
      platforms = lib.platforms.linux;
    };
  })
).overrideAttrs (_: prev: {
  # Fix FOD nix store path reference error and non-reproducible error
  # See https://phip1611.de/blog/fixing-illegal-path-references-in-fixed-output-derivation-in-nix/
  #
  # I use overrideAttrs because composerVendor has too many default args
  composerVendor = prev.composerVendor.overrideAttrs {
    preInstall = ''
      rm -rf vendor/ifixit/php-akismet/.git
    '';
  };
})
