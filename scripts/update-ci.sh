#!/usr/bin/env bash
set -euo pipefail

FORGEJO_TOKEN="${FORGEJO_TOKEN:?FORGEJO_TOKEN not set}"

export NIXPKGS_ALLOW_UNFREE=1

MAIN_BRANCH=$(git symbolic-ref --short HEAD)
REPO_REMOTE_URL=$(git remote get-url origin)

if [[ "$FORGEJO_TOKEN" =~ ^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$ ]]; then
	IS_JWT=1
else
	IS_JWT=0
fi

fj auth add-token "$FORGEJO_TOKEN"

if [[ "$REPO_REMOTE_URL" == https://* ]]; then
	if [[ "$IS_JWT" -eq 1 ]]; then
		FORGEJO_HOST="${REPO_REMOTE_URL#https://}"
		FORGEJO_HOST="${FORGEJO_HOST%%/*}"
		git config --local "http.https://${FORGEJO_HOST}/.extraHeader" "Authorization: Bearer ${FORGEJO_TOKEN}"
	else
		git remote set-url origin "https://oauth2:${FORGEJO_TOKEN}@${REPO_REMOTE_URL#https://}"
	fi
fi

git config user.name "Ineffa"
git config user.email "ineffa@noreply.git.trin.one"

FAILED=""
PENDING=""

update_pkg() {
	local PKG="$1"
	local OLD_VERSION NEW_VERSION

	git checkout -f "$MAIN_BRANCH"
	git checkout -- . 2>/dev/null || true
	git clean -fd -- pkgs/ 2>/dev/null || true

	if git ls-remote --exit-code origin "refs/heads/update/$PKG" >/dev/null 2>&1; then
		echo ">>> $PKG: PR already open, skipping"
		PENDING="$PENDING $PKG"
		return
	fi

	OLD_VERSION=$(nix-instantiate --eval --strict -A "$PKG.version" . 2>/dev/null | tr -d '"')

	if ! ./scripts/update-package "$PKG"; then
		echo ">>> $PKG: update script failed" >&2
		FAILED="$FAILED $PKG"
		return
	fi

	if [ -z "$(git status --porcelain -- pkgs/)" ]; then
		echo ">>> $PKG: no changes"
		return
	fi

	if ! nix-instantiate --show-trace -A "$PKG" . >/dev/null 2>&1; then
		echo ">>> $PKG: evaluation failed after update" >&2
		FAILED="$FAILED $PKG"
		return
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
}

for PKG in $(./scripts/update-package --list | jq -r '.[]'); do
	echo "::group::$PKG"
	update_pkg "$PKG"
	echo "::endgroup::"
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
