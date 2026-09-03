#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl -p jq -p nix -p flutter341 -p python3 -p python3Packages.pyyaml
# shellcheck shell=bash
set -euo pipefail

REPO_URL="https://github.com/dddevid/Musly"

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PKG_FILE="$SCRIPT_DIR/default.nix"
PKG_NAME="musly-player"

OLD_VERSION=$(sed -n 's/.*version = "\([^"]*\)";.*/\1/p' "$PKG_FILE" | head -1)
NEW_VERSION=$(curl -fsSL "${REPO_URL}/releases.atom" | sed -n 's#.*releases/tag/v\([^"<]*\).*#\1#p' | head -1)

if [ "$NEW_VERSION" = "$OLD_VERSION" ]; then
	exit 0
fi

NEW_HASH=$(nix store prefetch-file --json --unpack "${REPO_URL}/archive/refs/tags/v${NEW_VERSION}.tar.gz" | jq -r .hash)

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

curl -fsSL "${REPO_URL}/archive/refs/tags/v${NEW_VERSION}.tar.gz" | tar xz -C "$TMPDIR" --strip-components=1
chmod -R +w "$TMPDIR"

cp "$SCRIPT_DIR/pubspec.lock.json" "$TMPDIR/pubspec.lock.json.old"

(
	cd "$TMPDIR"
	flutter pub get </dev/null >/dev/null
)

# flutter writes the YAML pubspec.lock; the package consumes a JSON one.
python3 - "$TMPDIR/pubspec.lock" <<'PY'
import json
import sys
import yaml

with open(sys.argv[1]) as f:
    data = yaml.safe_load(f)
with open(sys.argv[1] + ".json", "w") as f:
    json.dump(data, f, indent=2)
PY

if ! cmp -s "$TMPDIR/pubspec.lock.json.old" "$TMPDIR/pubspec.lock.json"; then
	cp "$TMPDIR/pubspec.lock.json" "$SCRIPT_DIR/pubspec.lock.json"
fi

sed -i "s/version = \"$OLD_VERSION\";/version = \"$NEW_VERSION\";/" "$PKG_FILE"

awk -v hash="$NEW_HASH" '
  /src = fetchFromGitHub {/ { in_src = 1 }
  in_src && /hash = "[^"]*"/ { sub(/hash = "[^"]*"/, "hash = \"" hash "\""); in_src = 0 }
  { print }
' "$PKG_FILE" >"$PKG_FILE.tmp" && mv "$PKG_FILE.tmp" "$PKG_FILE"

echo "$PKG_NAME: $OLD_VERSION -> $NEW_VERSION"
