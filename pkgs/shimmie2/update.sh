#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq -p nix
# shellcheck shell=bash
set -euo pipefail

REPO_URL="https://github.com/shish/shimmie2"

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PKG_FILE="$SCRIPT_DIR/unwrapped.nix"
PKG_NAME="shimmie2"

OLD_VERSION=$(sed -n 's/.*version = "\([^"]*\)";.*/\1/p' "$PKG_FILE" | head -1)
NEW_VERSION=$(git ls-remote --tags "$REPO_URL" | grep -v '\^{}' | sed 's#.*refs/tags/v##' | grep -v 'refs/tags' | grep -E '^[0-9]' | sort -V | tail -1)

if [ "$NEW_VERSION" = "$OLD_VERSION" ]; then
	exit 0
fi

NEW_HASH=$(nix store prefetch-file --json --unpack "${REPO_URL}/archive/refs/tags/v${NEW_VERSION}.tar.gz" | jq -r .hash)

COMPOSER_HASH=$(nix-build --no-out-link --expr "
  let pkgs = import <nixpkgs> {};
      unwrapped = import \"$PKG_FILE\" {
        inherit (pkgs) lib php fetchFromGitHub;
      };
  in unwrapped.composerVendor.overrideAttrs (_: { outputHash = \"\"; outputHashAlgo = \"sha256\"; })
" 2>&1 | grep -o 'got:.*sha256-[A-Za-z0-9+/=]*' | tail -1 | sed 's/got:.*\(sha256-[A-Za-z0-9+/=]*\)/\1/' || true)

if [ -z "$COMPOSER_HASH" ]; then
	echo "failed to extract composerVendor hash" >&2
	exit 1
fi

sed -i \
	-e "s/version = \"$OLD_VERSION\";/version = \"$NEW_VERSION\";/" \
	-e "/src = fetchFromGitHub {/,/^    };/ s|hash = \"sha256-[^\"]*\";|hash = \"$NEW_HASH\";|" \
	-e "s|vendorHash = \"sha256-[^\"]*\";|vendorHash = \"$COMPOSER_HASH\";|" \
	"$PKG_FILE"

echo "$PKG_NAME: $OLD_VERSION -> $NEW_VERSION"
