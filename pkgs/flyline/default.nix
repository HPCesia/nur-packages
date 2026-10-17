# Adapted from upstream nix/package.nix: builtins.fetchGit is forbidden by the
# restrict-eval CI check, hence cargoHash; the binary is GPL-3.0-only, hence gpl3Only.
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "flyline";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "HalFrgrd";
    repo = "flyline";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nOCawyqUdOkxaqFS11Tp9IaOm7hevWhnLjpxsr5YWCo=";
  };

  cargoHash = "sha256-4ifX9N1OnIxwNRy4rWBZSqE0460G/dx+N8N4ZHInBpk=";

  patches = [./no-delete-line.patch];
  doCheck = false;

  # macOS-only: fix Mach-O reproducibility leaks and re-add -undefined
  # dynamic_lookup, which exporting RUSTFLAGS would otherwise drop.
  preConfigure = lib.optionalString stdenv.hostPlatform.isDarwin ''
    export RUSTFLAGS="--remap-path-prefix=$NIX_BUILD_TOP=/build -C link-arg=-undefined -C link-arg=dynamic_lookup -C link-arg=-Wl,-install_name,@rpath/libflyline.dylib -C link-arg=-Wl,-reproducible''${RUSTFLAGS:+ $RUSTFLAGS}"
  '';

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Bash plugin to replace readline for a modern line editing experience";
    homepage = "https://github.com/HalFrgrd/flyline";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
  };
})
