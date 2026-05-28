{
  lib,
  buildHelixPlugin,
  fetchFromGitHub,
  rustPlatform,
}:
buildHelixPlugin rec {
  pname = "helix-fcitx-focus";
  version = "unstable-2026-05-06";

  src = fetchFromGitHub {
    owner = "mtul0729";
    repo = "helix-fcitx-focus";
    rev = "d0797824239a8e7254c7e8ed8d686d14c7657b0f";
    hash = "sha256-VmJV2uy4uiTJSzUszaTJjkcmQI8fc1i6HPk+phT/36Q=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-LVNwdhn2h50un3r391JwPJiPhlTmRPl863rqB595RKo=";
  };

  meta = {
    description = "Steel native module for Helix fcitx5 focus and mode switching";
    homepage = "https://github.com/mtul0729/helix-fcitx-focus";
    license = with lib.licenses; [
      mit
      asl20
    ];
  };
}
