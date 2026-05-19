#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
README="$REPO_DIR/README.md"
TEMP_TABLE="${TMPDIR:-/tmp}/nur-packages-readme-table.md"
SYSTEM="${NIX_SYSTEM:-x86_64-linux}"

echo "==> Evaluating package metadata via nix..."

json=$(nix eval --impure --expr "
let
  flake = builtins.getFlake (toString $REPO_DIR);
  pkgs = flake.legacyPackages.\"${SYSTEM}\";

  reserved = [
    \"lib\" \"nixosModules\" \"overlays\"
    \"homeModules\" \"darwinModules\" \"flakeModules\"
    \"callPackage\" \"newScope\" \"overrideScope\" \"packages\"
    \"override\" \"overrideDerivation\"
  ];

  resolveLic = lic:
    let
      go = l:
        if l == null then { shortName = null; spdxId = null; url = null; }
        else if builtins.isList l then go (builtins.head l)
        else if builtins.isString l then { shortName = l; spdxId = null; url = null; }
        else {
          shortName = l.shortName or null;
          spdxId = l.spdxId or null;
          url = l.url or null;
        };
    in go lic;

  getLic = meta:
    resolveLic (meta.license or meta.licence or null);

  isDer = x: builtins.isAttrs x && x ? type && x.type == \"derivation\";
  isScope = x: builtins.isAttrs x && x ? callPackage && x ? newScope && !isDer x;

  reservedSet = builtins.listToAttrs (builtins.map (n: { name = n; value = true; }) reserved);

  collect = prefix: attrs:
    let
      names = builtins.filter (n: !(reservedSet.\${n} or false)) (builtins.attrNames attrs);
    in
      builtins.concatMap (name:
        let
          v = attrs.\${name};
          fullPrefix = if prefix == \"\" then name else \"\${prefix}.\${name}\";
          pkgInfo = {
            path = fullPrefix;
            pname = v.pname or v.name or \"\";
            version = v.version or \"\";
            homepage = v.meta.homepage or \"\";
            description = v.meta.description or \"\";
            license = getLic v.meta;
          };
        in
          if isDer v then [ pkgInfo ]
          else if isScope v then collect fullPrefix v
          else []
      ) names;
in
  collect \"\" pkgs
" --json 2>/dev/null)

echo "==> Found $(echo "$json" | jq length) derivations"

echo "==> Generating markdown tables..."

echo "$json" | jq -r '

  def fmt_license:
    if .spdxId then
      if .url and (.url | length > 0) then "[\(.spdxId)](\(.url))"
      else .spdxId end
    elif .shortName then
      if .shortName == "unfree" then "**Unfree**"
      elif .url and (.url | length > 0) then "[\(.shortName)](\(.url))"
      else .shortName end
    else "Not specified"
    end;

  def fmt_name($pname; $homepage):
    if ($pname | length > 0) and ($homepage | length > 0) then "[\($pname)](\($homepage))"
    else $pname end;

  def fmt_version:
    if . and (. | length > 0) then "`\(.)`" else "-" end;

  def fmt_row($item):
    "| `\($item.path)` | \(fmt_name($item.pname; $item.homepage)) | \($item.version | fmt_version) | \($item.license | fmt_license) | \($item.description) |";

  def mk_table($items):
    "| Path | Name | Version | License | Description |",
    "| --- | --- | --- | --- | --- |",
    ($items[] | fmt_row(.)),
    "";

  # Group by first path segment
  (reduce .[] as $item ({}; .[$item.path | split(".")[0]] += [$item])
  | to_entries
  | map(
      .key as $group_key
      | .value as $items
      | ($items | length) as $count
      | ($items | map(.description) | unique | length) as $desc_count
      | if $count == 1 then
          { section: "Common", items: $items }
        elif $desc_count <= 1 then
          {
            section: "Common",
            items: [{
              path: $group_key,
              pname: $group_key,
              version: "-",
              homepage: $items[0].homepage,
              description: $items[0].description,
              license: $items[0].license
            }]
          }
        else
          { section: $group_key, items: $items }
        end
      )
  ) as $groups

  # Combine all Common items
  | ($groups | map(select(.section == "Common") | .items[]) ) as $common
  | ($groups | map(select(.section != "Common"))) as $named

  # Generate output
  | (if ($common | length > 0) then
       "### Common\n", mk_table($common)
     else empty end),
    ($named[] |
       "### \(.section)\n", mk_table(.items))
' > "$TEMP_TABLE"

echo "==> Injecting table into README..."

if grep -q '<!-- BEGIN_PACKAGE_TABLE -->' "$README" 2>/dev/null; then
  awk -v tmp="$TEMP_TABLE" '
    BEGIN          { printing = 1 }
    /<!-- BEGIN_PACKAGE_TABLE -->/ {
      print
      while ((getline line < tmp) > 0) print line
      close(tmp)
      printing = 0
      next
    }
    /<!-- END_PACKAGE_TABLE -->/ {
      printing = 1
      print
      next
    }
    printing       { print }
  ' "$README" > "${README}.tmp" && mv "${README}.tmp" "$README"
else
  {
    head -n -0 "$README"
    echo ""
    echo "<!-- BEGIN_PACKAGE_TABLE -->"
    cat "$TEMP_TABLE"
    echo "<!-- END_PACKAGE_TABLE -->"
  } > "${README}.tmp" && mv "${README}.tmp" "$README"
fi

rm -f "$TEMP_TABLE"

echo "==> Done. README updated at $README"
