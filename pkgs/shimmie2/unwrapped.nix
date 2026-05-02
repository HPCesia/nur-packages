{
  lib,
  php,
  fetchFromGitHub,
}:
(
  php.buildComposerProject2 (finalAttrs: {
    pname = "shimmie2-unwrapped";
    version = "2.12.2";

    src = fetchFromGitHub {
      owner = "shish";
      repo = "shimmie2";
      tag = "v${finalAttrs.version}";
      hash = "sha256-hhQ37nrnndBgv5NRZ8wuwqCSPNNk4LlhLBlRdf+vlGE=";
    };

    vendorHash = "sha256-tSDAv+/2ftciOBaFGk1chvAztijiOHKhQfgdItzo9i0=";

    postInstall = ''
      mkdir -p $out/share/php/${finalAttrs.pname}/data
    '';

    meta = {
      description = "An easy-to-install community image gallery (aka booru)";
      homepage = "https://github.com/shish/shimmie2";
      licence = lib.licenses.gpl2;
      platforms = lib.platforms.linux;
    };
  })
).overrideAttrs (_: prev: {
  # Fix FOD nix store path reference error
  # See https://phip1611.de/blog/fixing-illegal-path-references-in-fixed-output-derivation-in-nix/
  composerVendor = prev.composerVendor.overrideAttrs {
    preInstall = ''
      rm -rf vendor/ifixit/php-akismet/.git/hooks
    '';
  };
})
