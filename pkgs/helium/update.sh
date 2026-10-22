#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl -p jq -p nix
# shellcheck shell=bash
set -euo pipefail

REPO_URL="https://github.com/imputnet/helium-linux"

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PKG_FILE="$SCRIPT_DIR/default.nix"
PKG_NAME="helium"

OLD_VERSION=$(sed -n 's/.*version = "\([^"]*\)";.*/\1/p' "$PKG_FILE" | head -1)
NEW_VERSION=$(curl -fsSL "${REPO_URL}/releases.atom" | sed -n 's#.*releases/tag/\([^"<]*\).*#\1#p' | head -1)

if [ "$NEW_VERSION" = "$OLD_VERSION" ]; then
	exit 0
fi

X86_64_HASH=$(nix store prefetch-file --json "${REPO_URL}/releases/download/${NEW_VERSION}/helium-${NEW_VERSION}-x86_64_linux.tar.xz" | jq -r .hash)
AARCH64_HASH=$(nix store prefetch-file --json "${REPO_URL}/releases/download/${NEW_VERSION}/helium-${NEW_VERSION}-arm64_linux.tar.xz" | jq -r .hash)

sed -i "s/version = \"$OLD_VERSION\";/version = \"$NEW_VERSION\";/" "$PKG_FILE"

awk -v x86="$X86_64_HASH" -v arm="$AARCH64_HASH" '
  /helium-\$\{version\}-arm64_linux/ { print; getline; sub(/hash = "[^"]*"/, "hash = \"" arm "\""); print; next }
  /helium-\$\{version\}-x86_64_linux/ { print; getline; sub(/hash = "[^"]*"/, "hash = \"" x86 "\""); print; next }
  { print }
' "$PKG_FILE" >"$PKG_FILE.tmp" && mv "$PKG_FILE.tmp" "$PKG_FILE"

echo "$PKG_NAME: $OLD_VERSION -> $NEW_VERSION"
