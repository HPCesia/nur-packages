{
  lib,
  buildHelixPluginWithNative,
  fetchFromGitHub,
}:
buildHelixPluginWithNative {
  pname = "helix-fcitx-focus";
  version = "0-unstable-2026-06-29";

  src = fetchFromGitHub {
    owner = "mtul0729";
    repo = "helix-fcitx-focus";
    rev = "d2572a926b9c71ee1f61666cff27a76096d1b323";
    hash = "sha256-Uo24YqtguCZD1nJL16+cI3GNJQfssFP2rRgUBSBNUxM=";
  };

  cargoHash = "sha256-LVNwdhn2h50un3r391JwPJiPhlTmRPl863rqB595RKo=";

  meta = {
    description = "Steel native module for Helix fcitx5 focus and mode switching";
    homepage = "https://github.com/mtul0729/helix-fcitx-focus";
    license = with lib.licenses; [
      mit
      asl20
    ];
  };
}
