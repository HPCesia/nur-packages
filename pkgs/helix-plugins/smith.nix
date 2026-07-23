{
  lib,
  buildHelixPlugin,
  fetchFromGitHub,
  ...
}:
buildHelixPlugin {
  pname = "smith.hx";
  version = "0-unstable-2026-07-12";

  src = fetchFromGitHub {
    owner = "kn66";
    repo = "smith.hx";
    rev = "a5ddb240aad6999b7c095ceb352b90a12167034e";
    hash = "sha256-ccLoMI9E3v8BLPLKtrjg1c0UK5VgdBH6L/d59HaQ4yg=";
  };

  meta = {
    description = "A declarative Helix plugin manager";
    homepage = "https://github.com/kn66/smith.hx";
    license = lib.licenses.mit;
  };
}
