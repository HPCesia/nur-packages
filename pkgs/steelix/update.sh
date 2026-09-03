#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git -p jq -p nix -p python3 -p nurl
# shellcheck shell=bash
set -euo pipefail

REPO_URL="https://github.com/mattwparas/helix"
BRANCH="steel-event-system"

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PKG_FILE="$SCRIPT_DIR/unwrapped.nix"
OLD_VERSION=$(sed -n 's/.*version = "\([^"]*\)";.*/\1/p' "$PKG_FILE" | head -1)
PKG_NAME="steelix"

OLD_REV=$(sed -n 's/.*rev = "\([0-9a-f]\{40\}\)".*/\1/p' "$PKG_FILE")
NEW_REV=$(git ls-remote "$REPO_URL" "refs/heads/$BRANCH" | awk '{print $1}')

if [ "$NEW_REV" = "$OLD_REV" ]; then
	exit 0
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMPDIR/repo"
NEW_DATE=$(git -C "$TMPDIR/repo" show -s --format=%cs HEAD)

NEW_HASH=$(nix store prefetch-file --json --unpack "https://github.com/mattwparas/helix/archive/$NEW_REV.tar.gz" | jq -r .hash)
NEW_VERSION="0-unstable-$NEW_DATE"

sed -i \
	-e "s/version = \"[^\"]*\";/version = \"$NEW_VERSION\";/" \
	-e "s/rev = \"$OLD_REV\";/rev = \"$NEW_REV\";/" \
	-e "/src = fetchFromGitHub {/,/^    };/ s|hash = \"sha256-[^\"]*\";|hash = \"$NEW_HASH\";|" \
	"$PKG_FILE"

CARGO_DEPS_HASH=$(nix-build --no-out-link --expr "
  let pkgs = import <nixpkgs> {};
      unwrapped = import \"$PKG_FILE\" {
        inherit (pkgs) rustPlatform fetchFromGitHub fetchpatch helix-unwrapped;
      };
  in unwrapped.cargoDeps.vendorStaging.overrideAttrs (_: { outputHash = \"\"; outputHashAlgo = \"sha256\"; })
" 2>&1 | grep -o 'got:.*sha256-[A-Za-z0-9+/=]*' | tail -1 | sed 's/got:.*\(sha256-[A-Za-z0-9+/=]*\)/\1/' || true)

if [ -z "$CARGO_DEPS_HASH" ]; then
	echo "failed to extract cargoDeps hash" >&2
	exit 1
fi

awk -v hash="$CARGO_DEPS_HASH" '
  /inherit \(finalAttrs\) src pname version;/ { print; getline; sub(/hash = "[^"]*"/, "hash = \"" hash "\""); print; next }
  { print }
' "$PKG_FILE" >"$PKG_FILE.tmp" && mv "$PKG_FILE.tmp" "$PKG_FILE"

python3 "$SCRIPT_DIR/generate_grammars.py" "$TMPDIR/repo/languages.toml" -o "$SCRIPT_DIR/grammars.json"

echo "$PKG_NAME: $OLD_VERSION -> $NEW_VERSION"
