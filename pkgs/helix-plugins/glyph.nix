{
  lib,
  buildHelixPlugin,
  fetchFromGitHub,
  ...
}:
buildHelixPlugin {
  pname = "glyph.hx";
  version = "0-unstable-2026-07-06";

  src = fetchFromGitHub {
    owner = "Ra77a3l3-jar";
    repo = "glyph.hx";
    rev = "1386654fb65584dc32cf394b0ab2110ade483262";
    hash = "sha256-BctBmnV5lrOXKsI89v2d0RJrvBwhIyk/jSl5rg6ruO8=";
  };

  meta = {
    description = "Shared icon library for Helix plugins";
    homepage = "https://github.com/Ra77a3l3-jar/glyph.hx";
    license = lib.licenses.mit;
  };
}
