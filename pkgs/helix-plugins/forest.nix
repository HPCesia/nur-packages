{
  lib,
  buildHelixPlugin,
  fetchFromGitHub,
  ...
}:
buildHelixPlugin {
  pname = "forest.hx";
  version = "unstable-2026-07-08";

  src = fetchFromGitHub {
    owner = "Ra77a3l3-jar";
    repo = "forest.hx";
    rev = "3c599e23c05af95b799f8560c2489cc2821d9c91";
    hash = "sha256-scg0cV4yQoyf/9MzMNvWnDi5cbjTqLO7KGANc6DqAt0=";
  };

  meta = {
    description = "A file explorer tree for Helix";
    homepage = "https://github.com/Ra77a3l3-jar/forest.hx";
    license = lib.licenses.mit;
  };
}
