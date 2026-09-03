#!/usr/bin/env nix-shell
#!nix-shell -i bash -p git -p jq -p nix
# shellcheck shell=bash
set -euo pipefail

REPO_URL="https://tangled.org/did:plc:wqstj3k5tslmm246baaf3tpa"
ARCHIVE_URL="${REPO_URL}/archive"

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PKG_FILE="$SCRIPT_DIR/default.nix"
OLD_VERSION=$(sed -n 's/.*version = "\([^"]*\)";.*/\1/p' "$PKG_FILE" | head -1)
PKG_NAME="stinkpot"

OLD_REV=$(sed -n 's/.*rev = "\([0-9a-f]\{40\}\)".*/\1/p' "$PKG_FILE")
NEW_REV=$(git ls-remote "$REPO_URL" HEAD | awk '{print $1}')

if [ "$NEW_REV" = "$OLD_REV" ]; then
	exit 0
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

git clone --depth 1 "$REPO_URL" "$TMPDIR/repo"
NEW_DATE=$(git -C "$TMPDIR/repo" show -s --format=%cs HEAD)

NEW_HASH=$(nix store prefetch-file --json --unpack "$ARCHIVE_URL/$NEW_REV" | jq -r .hash)
NEW_VERSION="0-unstable-$NEW_DATE"

sed -i \
	-e "s/version = \"[^\"]*\";/version = \"$NEW_VERSION\";/" \
	-e "s/rev = \"$OLD_REV\";/rev = \"$NEW_REV\";/" \
	-e "s|hash = \"sha256-[^\"]*\";|hash = \"$NEW_HASH\";|" \
	"$PKG_FILE"

echo "$PKG_NAME: $OLD_VERSION -> $NEW_VERSION"
