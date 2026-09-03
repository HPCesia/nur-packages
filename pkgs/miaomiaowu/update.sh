#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix-update -p jq -p nix
# shellcheck shell=bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PKG_FILE="$SCRIPT_DIR/default.nix"
FRONTEND_FILE="$SCRIPT_DIR/frontend.nix"
PKG_NAME="miaomiaowu"

OLD_VERSION=$(sed -n 's/.*version = "\([^"]*\)";.*/\1/p' "$PKG_FILE" | head -1)

nix-update "$UPDATE_NIX_ATTR_PATH"

NEW_VERSION=$(sed -n 's/.*version = "\([^"]*\)";.*/\1/p' "$PKG_FILE" | head -1)

if [ "$NEW_VERSION" = "$OLD_VERSION" ]; then
	exit 0
fi

NEW_SRC_HASH=$(sed -n 's/.*hash = "\(sha256-[^"]*\)";.*/\1/p' "$PKG_FILE" | head -1)

sed -i \
	-e "s/version = \"$OLD_VERSION\";/version = \"$NEW_VERSION\";/" \
	-e "s|hash = \"sha256-[^\"]*\";|hash = \"$NEW_SRC_HASH\";|" \
	"$FRONTEND_FILE"

NPM_HASH=$(nix-build --no-out-link --expr "
  let pkgs = import <nixpkgs> {};
      frontend = import \"$FRONTEND_FILE\" {
        inherit (pkgs) lib buildNpmPackage fetchFromGitHub jq;
      };
  in frontend.npmDeps.overrideAttrs (_: { outputHash = \"\"; outputHashAlgo = \"sha256\"; })
" 2>&1 | grep -o 'got:.*sha256-[A-Za-z0-9+/=]*' | tail -1 | sed 's/got:.*\(sha256-[A-Za-z0-9+/=]*\)/\1/' || true)

if [ -z "$NPM_HASH" ]; then
	echo "failed to extract npmDepsHash" >&2
	exit 1
fi

sed -i "s|npmDepsHash = \"sha256-[^\"]*\";|npmDepsHash = \"$NPM_HASH\";|" "$FRONTEND_FILE"

echo "$PKG_NAME: $OLD_VERSION -> $NEW_VERSION"
