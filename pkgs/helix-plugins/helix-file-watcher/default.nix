{
  lib,
  buildHelixPlugin,
  fetchFromGitHub,
  rustPlatform,
}:
buildHelixPlugin {
  pname = "helix-file-watcher";
  version = "unstable-2026-03-08";

  src = fetchFromGitHub {
    owner = "mattwparas";
    repo = "helix-file-watcher";
    rev = "e36434634b0a862280dc832921c9aa0d62198964";
    hash = "sha256-kIJ3bjtiXK5RCUO0vWWVZa+rlMaunTyAcSIMh4JljXM=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "steel-core-0.8.2" = "sha256-lqtx1q/AHntbZvF3rpWbicvxE3NGZU+VPMueECaVdSA=";
    };
  };
  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  meta = {
    description = "Helix file watcher plugin";
    homepage = "https://github.com/mattwparas/helix-file-watcher";
    license = lib.licenses.unfree; # Unclear licensing status. Marked as unfree.
  };
}
