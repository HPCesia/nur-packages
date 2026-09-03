{pkgs ? import <nixpkgs> {}}:
pkgs.mkShellNoCC {
  packages = with pkgs; [
    forgejo-cli
    jq
    nurl
    python3
  ];
}
