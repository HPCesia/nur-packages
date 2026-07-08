{
  lib,
  buildHelixPlugin,
  fetchFromGitHub,
  ...
}:
buildHelixPlugin {
  pname = "forest.hx";
  version = "unstable-2026-07-07";

  src = fetchFromGitHub {
    owner = "Ra77a3l3-jar";
    repo = "forest.hx";
    rev = "612036f93b2bbff6b4c68022544d8f0d8480c4fd";
    hash = "sha256-km3DCDyPd9RGZ7ekbWplSoG40+zpRQvYKIpPGGyBPzU=";
  };

  meta = {
    description = "A file explorer tree for Helix";
    homepage = "https://github.com/Ra77a3l3-jar/forest.hx";
    license = lib.licenses.mit;
  };
}
