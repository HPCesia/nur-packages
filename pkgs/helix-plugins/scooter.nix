{
  lib,
  buildHelixPlugin,
  fetchFromGitHub,
  rustPlatform,
}:
buildHelixPlugin rec {
  pname = "scooter.hx";
  version = "unstable-2026-03-15";

  src = fetchFromGitHub {
    owner = "thomasschafer";
    repo = "scooter.hx";
    rev = "eaf2de26eed45e1405df72d22a6400709870802a";
    hash = "sha256-X2qlnNVN47Q1HEqiPC9vHZBsAcMCHsupO534XgDWZ9o=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-akUwMjHdgYd1nyFcPaoCTrpB7zarkBfMSsXUsN2S3Go=";
  };

  meta = {
    description = "Interactive find-and-replace Helix plugin";
    homepage = "https://github.com/thomasschafer/scooter.hx";
    license = lib.licenses.mit;
  };
}
