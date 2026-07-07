{
  lib,
  buildHelixPlugin,
  fetchFromGitHub,
  ...
}:
buildHelixPlugin {
  pname = "forest.hx";
  version = "unstable-2026-07-06";

  src = fetchFromGitHub {
    owner = "Ra77a3l3-jar";
    repo = "forest.hx";
    rev = "1eaec95ab85ac89848422ae378b022b5c44d6a6f";
    hash = "sha256-MhsJcKKvHfGAH6/HpuE5U7EWeDDRTQnrpOmhwSkWvBQ=";
  };

  meta = {
    description = "A file explorer tree for Helix";
    homepage = "https://github.com/Ra77a3l3-jar/forest.hx";
    license = lib.licenses.mit;
  };
}
