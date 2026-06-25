{
  lib,
  buildHelixPlugin,
  fetchFromGitHub,
}:
buildHelixPlugin {
  pname = "file-tree.hx";
  version = "unstable-2026-05-01";

  src = fetchFromGitHub {
    owner = "mattwparas";
    repo = "file-tree.hx";
    rev = "e84e92f6ab62d4436768d70639ca0ba7ec72c073";
    hash = "sha256-AHvL0wQJqtaPDJpR+XByFWI/q9NNZfNdpMt4XXC4NMY=";
  };

  meta = {
    description = "File tree for helix, using Steel.";
    homepage = "https://github.com/mattwparas/file-tree.hx";
    # license = lib.licenses.unfree; # Unclear licensing status. Marked as unfree.
  };
}
