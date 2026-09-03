#!/usr/bin/env bash
# Update all packages with passthru.updateScript and open one PR per package.
# Intended to run inside `nix-shell shell.nix` in CI (see
# .forgejo/workflows/auto-update.yml). Expects FORGEJO_TOKEN to be set.
set -euo pipefail

FORGEJO_TOKEN="${FORGEJO_TOKEN:?FORGEJO_TOKEN not set}"

# Some packages (e.g. harmonoid, navibeat) are unfree; nix-instantiate
# refuses them without this.
export NIXPKGS_ALLOW_UNFREE=1

MAIN_BRANCH=$(git symbolic-ref --short HEAD)
REPO_REMOTE_URL=$(git remote get-url origin)

fj auth add-token "$FORGEJO_TOKEN"

case "$REPO_REMOTE_URL" in
https://*)
	git remote set-url origin "https://oauth2:${FORGEJO_TOKEN}@${REPO_REMOTE_URL#https://}"
	;;
esac

git config user.name "nur-update-bot"
git config user.email "nur-update-bot@users.noreply.git.net.trin.one"

FAILED=""
PENDING=""

for PKG in $(./scripts/update-package --list | jq -r '.[]'); do
	echo ""
	echo "=== $PKG ==="

	# Reset to a clean main state.
	git checkout -f "$MAIN_BRANCH"
	git checkout -- . 2>/dev/null || true
	git clean -fd -- pkgs/ 2>/dev/null || true

	# Skip if a PR for this package is already open (branch exists on origin).
	if git ls-remote --exit-code origin "refs/heads/update/$PKG" >/dev/null 2>&1; then
		echo ">>> $PKG: PR already open, skipping"
		PENDING="$PENDING $PKG"
		continue
	fi

	OLD_VERSION=$(nix-instantiate --eval --strict -A "$PKG.version" . 2>/dev/null | tr -d '"')

	if ! ./scripts/update-package "$PKG"; then
		echo ">>> $PKG: update script failed" >&2
		FAILED="$FAILED $PKG"
		continue
	fi

	if [ -z "$(git status --porcelain -- pkgs/)" ]; then
		echo ">>> $PKG: no changes"
		continue
	fi

	if ! nix-instantiate --show-trace -A "$PKG" . >/dev/null 2>&1; then
		echo ">>> $PKG: evaluation failed after update" >&2
		FAILED="$FAILED $PKG"
		continue
	fi

	NEW_VERSION=$(nix-instantiate --eval --strict -A "$PKG.version" . 2>/dev/null | tr -d '"')

	python3 ./scripts/gen-readme.py

	git switch -c "update/$PKG"
	git add -A
	git commit -m "$PKG: $OLD_VERSION -> $NEW_VERSION"
	git push --set-upstream origin "update/$PKG"
	fj pr create "$PKG: $OLD_VERSION -> $NEW_VERSION" \
		--body "Automated update by CI.

$PKG: \`$OLD_VERSION\` -> \`$NEW_VERSION\`"
done

if [ -n "$PENDING" ]; then
	echo ""
	echo "Pending (PR already open):$PENDING"
fi
if [ -n "$FAILED" ]; then
	echo ""
	echo "Finished with failures:$FAILED" >&2
	exit 1
fi
echo ""
echo "All packages up to date."
