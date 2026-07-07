{
  lib,
  buildHelixPlugin,
  fetchFromGitHub,
  rustPlatform,
}:
buildHelixPlugin rec {
  pname = "scooter.hx";
  version = "unstable-2026-06-22";

  src = fetchFromGitHub {
    owner = "thomasschafer";
    repo = "scooter.hx";
    rev = "49cac91f60b609a70b6f85f80c461177b1ba57e5";
    hash = "sha256-iNcnD/3J4fPivwKvLWBNcor8qvzo0EeVB3ri4ZHL3Mk=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-LrTjw3iZg33C/u+tBIMeMtq8Y6SCX7+77gc7dLht+go=";
  };

  meta = {
    description = "Interactive find-and-replace Helix plugin";
    homepage = "https://github.com/thomasschafer/scooter.hx";
    license = lib.licenses.mit;
  };
}
