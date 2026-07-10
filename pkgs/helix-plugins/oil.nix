{
  lib,
  buildHelixPlugin,
  fetchFromGitHub,
  ...
}:
buildHelixPlugin {
  pname = "oil.hx";
  version = "0-unstable-2026-06-21";

  src = fetchFromGitHub {
    owner = "Ra77a3l3-jar";
    repo = "oil.hx";
    rev = "678a24cca321c84252f8a0812cbb6018f56ab72d";
    hash = "sha256-xZwDENGeLTH0WMa7/g8BxmW3xibGrCMpBRnwkfDm5QI=";
  };

  meta = {
    description = "File Manager in a buffer for Helix editor";
    homepage = "https://github.com/Ra77a3l3-jar/oil.hx";
    license = lib.licenses.mit;
  };
}
