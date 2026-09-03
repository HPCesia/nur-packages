#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl -p jq -p nix -p nix-prefetch-git -p flutter344
# shellcheck shell=bash
set -euo pipefail

REPO_URL="https://github.com/AfalpHy/sylvakru"

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
PKG_FILE="$SCRIPT_DIR/default.nix"
PKG_NAME="sylvakru"

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
	flutter pub get >/dev/null
)

LOCKFILE_CHANGED=false
if ! cmp -s "$TMPDIR/pubspec.lock.json.old" "$TMPDIR/pubspec.lock.json"; then
	LOCKFILE_CHANGED=true
	cp "$TMPDIR/pubspec.lock.json" "$SCRIPT_DIR/pubspec.lock.json"
fi

sed -i "s/version = \"$OLD_VERSION\";/version = \"$NEW_VERSION\";/" "$PKG_FILE"

awk -v hash="$NEW_HASH" '
  /src = fetchFromGitHub {/ { in_src = 1 }
  in_src && /hash = "[^"]*"/ { sub(/hash = "[^"]*"/, "hash = \"" hash "\""); in_src = 0 }
  { print }
' "$PKG_FILE" >"$PKG_FILE.tmp" && mv "$PKG_FILE.tmp" "$PKG_FILE"

if [ "$LOCKFILE_CHANGED" = true ]; then
	# media-kit family shares one hash via the media-kit-hash binding.
	MEDIA_KIT_URL=$(jq -r '.packages.media_kit.description.url' "$TMPDIR/pubspec.lock.json")
	MEDIA_KIT_REV=$(jq -r '.packages.media_kit.description."resolved-ref"' "$TMPDIR/pubspec.lock.json")
	for FAM in media_kit_libs_android_audio media_kit_libs_ios_audio media_kit_libs_macos_audio media_kit_libs_windows_audio; do
		FAM_URL=$(jq -r ".packages.$FAM.description.url" "$TMPDIR/pubspec.lock.json")
		FAM_REV=$(jq -r ".packages.$FAM.description.\"resolved-ref\"" "$TMPDIR/pubspec.lock.json")
		if [ "$FAM_URL" != "$MEDIA_KIT_URL" ] || [ "$FAM_REV" != "$MEDIA_KIT_REV" ]; then
			echo "media-kit family diverged; manual update required" >&2
			exit 1
		fi
	done
	MEDIA_KIT_HASH=$(nix-prefetch-git --url "$MEDIA_KIT_URL" --rev "$MEDIA_KIT_REV" --quiet 2>/dev/null | jq -r .sha256 | nix hash convert --hash-algo sha256 --to sri)
	sed -i "s|media-kit-hash = \"sha256-[^\"]*\";|media-kit-hash = \"$MEDIA_KIT_HASH\";|" "$PKG_FILE"

	while IFS=$'\t' read -r KEY URL REV; do
		case "$KEY" in
		media_kit | media_kit_libs_*)
			continue
			;;
		esac
		HASH=$(nix-prefetch-git --url "$URL" --rev "$REV" --quiet 2>/dev/null | jq -r .sha256 | nix hash convert --hash-algo sha256 --to sri)
		sed -i "s|\($KEY = \)\"sha256-[^\"]*\"|\1\"$HASH\"|" "$PKG_FILE"
	done < <(jq -r '.packages | to_entries[] | select(.value.source == "git") | [.key, .value.description.url, .value.description."resolved-ref"] | @tsv' "$TMPDIR/pubspec.lock.json")

	RIVE_VERSION=$(jq -r '.packages.rive_native.version // empty' "$TMPDIR/pubspec.lock.json")
	if [ -n "$RIVE_VERSION" ]; then
		RIVE_URL="https://rive-flutter-artifacts.rive.app/rive_native_versions/${RIVE_VERSION//+/%2B}/rive_native_artifacts_linux.zip"
		RIVE_HASH=$(nix store prefetch-file --json --hash-algo sha512 "$RIVE_URL" | jq -r .hash)
		sed -i \
			-e "s|rive_native_versions/[^/]*/|rive_native_versions/${RIVE_VERSION//+/%2B}/|" \
			-e "s|hash = \"sha512-[^\"]*\";|hash = \"$RIVE_HASH\";|" \
			"$PKG_FILE"
	fi
fi

echo "$PKG_NAME: $OLD_VERSION -> $NEW_VERSION"
