# Modify from https://github.com/NixOS/nixpkgs/blob/c4e0120b295daaac44f245f1c50ec06e844fe53b/pkgs/by-name/st/steelix/package.nix
{
  lib,
  callPackage,
  helix,
  steelix-unwrapped ? callPackage ./unwrapped.nix {},
}:
(helix.override {
  helix-unwrapped = steelix-unwrapped;
}).overrideAttrs
(
  _: previousAttrs: {
    pname = "steelix";
    strictDeps = true;

    meta =
      previousAttrs.meta
      // {
        description = "Helix editor with Steel (Scheme) scripting support";
        longDescription = ''
          Steelix is a fork of the Helix editor with Steel (Scheme) scripting support.
        '';
        homepage = "https://github.com/mattwparas/helix";
        changelog = "https://github.com/mattwparas/helix/blob/${steelix-unwrapped.src.rev}/CHANGELOG.md";
        license = lib.licenses.mpl20;
        mainProgram = "hx";
      };
  }
)
