{
  lib,
  buildHelixPlugin,
  fetchFromGitHub,
}:
buildHelixPlugin {
  pname = "wakatime.hx";
  version = "0-unstable-2026-05-01";

  src = fetchFromGitHub {
    owner = "Xerxes-2";
    repo = "wakatime.hx";
    rev = "d38516798494fbd6a2341a6b57232a26b0d9f172";
    hash = "sha256-qDvXDQFzLXGy8RHc9weL6d+t9WkxUtC2LPgvJGA/saA=";
  };

  meta = {
    description = "Wakatime plugin for Helix Steel";
    homepage = "https://github.com/Xerxes-2/wakatime.hx";
    license = lib.licenses.mit;
  };
}
