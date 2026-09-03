#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq -p nix
# shellcheck shell=bash
set -euo pipefail

REPO_URL="https://github.com/NelloKudo/spritz-wine"

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
JSON="$SCRIPT_DIR/version.json"

# stream name -> tag prefix (before the version part)
declare -A TAG_PATTERNS=(
	[cachyos]="wine-cachyos-aagl-v"
	[dwproton]="wine-dwproton-"
	[tkg]="spritz-wine-"
)

# tkg additionally used the wine-tkg-aagl-v naming for older releases.
declare -A EXTRA_TAG_PATTERNS=(
	[tkg]="wine-tkg-aagl-v"
)

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

git ls-remote --tags "$REPO_URL" | grep -v '\^{}' >"$TMPDIR/tags"

UPDATED=""
for STREAM in "${!TAG_PATTERNS[@]}"; do
	OLD_VERSION=$(jq -r ".${STREAM} | keys | .[]" "$JSON" | sort -V | tail -1)
	ASSET_PREFIX=$(jq -r ".${STREAM}[\"$OLD_VERSION\"].url" "$JSON" | sed 's#.*/##' | sed "s/-${OLD_VERSION}-x86_64.tar.xz$//")

	# Gather (version, tag) pairs from all tag namings of this stream.
	: >"$TMPDIR/versions-$STREAM"
	for PAT in "${TAG_PATTERNS[$STREAM]}" ${EXTRA_TAG_PATTERNS[$STREAM]:-}; do
		while read -r SHA TAG; do
			VER=${TAG#"refs/tags/$PAT"}
			if [ "$VER" != "$TAG" ]; then
				printf '%s\t%s\n' "$VER" "${TAG#refs/tags/}" >>"$TMPDIR/versions-$STREAM"
			fi
		done <"$TMPDIR/tags"
	done

	# All versions strictly newer than the current latest, in version order.
	NEW_VERSIONS=$(
		cut -f1 "$TMPDIR/versions-$STREAM" | sort -u -V |
			awk -v old="$OLD_VERSION" '!f { f = ($0 == old) } f && $0 != old'
	)

	for VER in $NEW_VERSIONS; do
		TAG=$(awk -F'\t' -v v="$VER" '$1 == v {print $2; exit}' "$TMPDIR/versions-$STREAM")
		URL="https://github.com/NelloKudo/spritz-wine/releases/download/$TAG/$ASSET_PREFIX-$VER-x86_64.tar.xz"
		HASH=$(nix store prefetch-file --json --unpack "$URL" | jq -r .hash)
		jq ".${STREAM}[\"$VER\"] = { url: \"$URL\", hash: \"$HASH\" }" "$JSON" >"$JSON.tmp"
		mv "$JSON.tmp" "$JSON"
		UPDATED="$UPDATED $STREAM:$VER"
	done
done

if [ -n "$UPDATED" ]; then
	echo "spritz-wine-bin:$UPDATED"
fi
