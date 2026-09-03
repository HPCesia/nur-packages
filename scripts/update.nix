/*
Runner for packages declaring `passthru.updateScript`, modeled after
nixpkgs' maintainers/scripts/update.nix.

Usage (also see scripts/update-package):

    nix-shell scripts/update.nix --argstr packages "kelivo stinkpot"
    nix-shell scripts/update.nix --argstr packages ""
*/
{
  pkgs ? import <nixpkgs> {},
  # Space-separated list of package attribute paths to update.
  # Empty string means "update everything".
  packages ? "",
  # Packages excluded from updates (see scripts/update-packages.nix).
  excludes ? [
    "artalk"
    "dwproton-bin"
    "nocturne"
  ],
}: let
  inherit (pkgs) lib;
  selected = import ./update-packages.nix {inherit pkgs packages excludes;};

  invalidSelections = builtins.filter (sel: !lib.any (p: p.attrPath == sel || lib.hasSuffix ".${sel}" p.attrPath) selected) (
    lib.filter (s: s != "") (lib.splitString " " packages)
  );

  # Pass the package list as a JSON file instead of interpolating it into
  # the shell script: updateScript commands may reference store paths that
  # are not inputs of this derivation, and embedding them as text would
  # trigger "not allowed to refer to a store path" errors.
  packagesJson = pkgs.writeText "nur-update-packages.json" (
    builtins.toJSON (
      map (p: {
        inherit (p) attrPath oldVersion;
        inherit (p) pname;
        name = p.pkgName;
        updateScript = p.script;
      })
      selected
    )
  );

  helpText = ''
    No packages with passthru.updateScript were selected.
  '';
in
  pkgs.stdenvNoCC.mkDerivation {
    name = "nur-update-script";
    nativeBuildInputs = [
      pkgs.git
      pkgs.cacert
      pkgs.jq
    ];
    buildCommand = ''
      echo ""
      echo "Not possible to run update scripts using nix-build."
      echo ""
      echo "${lib.replaceStrings ["\n"] [" "] helpText}"
      exit 1
    '';
    shellHook = ''
      unset shellHook

      ${lib.optionalString (invalidSelections != []) ''
        echo "WARNING: no updateScript found for: ${lib.concatStringsSep " " invalidSelections}" >&2
      ''}

      ${lib.optionalString (selected == []) ''
        echo "${lib.replaceStrings ["\n"] [" "] helpText}" >&2
        exit 1
      ''}

      FAILED=""
      LOGDIR=$(mktemp -d)
      trap 'rm -rf "$LOGDIR"' EXIT
      cd "${toString ./.}/.."

      MAX_JOBS="''${UPDATE_PACKAGE_JOBS:-$(nproc)}"
      declare -A JOB_ATTR=() JOB_LOG=()
      RUNNING=0

      launch() {
        local PKG="$1" ATTR_PATH OLD_VERSION LOG
        ATTR_PATH=$(jq -r .attrPath <<<"$PKG")
        OLD_VERSION=$(jq -r .oldVersion <<<"$PKG")
        LOG=$(mktemp "$LOGDIR/log.XXXXXX")
        echo ">>> $ATTR_PATH: updating ($OLD_VERSION)"
        (
          if env \
              UPDATE_NIX_ATTR_PATH="$ATTR_PATH" \
              UPDATE_NIX_PNAME="$(jq -r .pname <<<"$PKG")" \
              UPDATE_NIX_NAME="$(jq -r .name <<<"$PKG")" \
              UPDATE_NIX_OLD_VERSION="$OLD_VERSION" \
              bash -c "$(jq -r '.updateScript | map(@sh) | join(" ")' <<<"$PKG")"; then
            echo ">>> $ATTR_PATH: done"
            exit 0
          else
            echo ">>> $ATTR_PATH: FAILED" >&2
            exit 1
          fi
        ) >"$LOG" 2>&1 &
        JOB_ATTR[$!]="$ATTR_PATH"
        JOB_LOG[$!]="$LOG"
        RUNNING=$((RUNNING + 1))
      }

      reap_one() {
        local PID STATUS ATTR_PATH LOG
        PID=""
        STATUS=0
        # Requires bash >= 5.1 for `wait -n -p`
        wait -n -p PID || STATUS=$?
        ATTR_PATH="''${JOB_ATTR[$PID]}"
        LOG="''${JOB_LOG[$PID]}"
        echo ""
        cat "$LOG"
        rm -f "$LOG"
        if [ "$STATUS" -ne 0 ]; then
          FAILED="$FAILED $ATTR_PATH"
        fi
        unset "JOB_ATTR[$PID]" "JOB_LOG[$PID]"
        RUNNING=$((RUNNING - 1))
      }

      while IFS= read -r PKG; do
        while [ "$RUNNING" -ge "$MAX_JOBS" ]; do
          reap_one
        done
        launch "$PKG"
      done < <(jq -c '.[]' ${packagesJson})

      while [ "$RUNNING" -gt 0 ]; do
        reap_one
      done

      echo ""
      if [ -n "$FAILED" ]; then
        echo "Finished with failures:$FAILED" >&2
        exit 1
      fi
      echo "All update scripts finished successfully."
      exit 0
    '';
  }
