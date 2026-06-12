#!/usr/bin/env python3
"""Generate a package table and inject it into README.md."""

import json
import os
import subprocess
import sys
from pathlib import Path
from tempfile import NamedTemporaryFile

REPO_DIR = Path(__file__).resolve().parent.parent
README = REPO_DIR / "README.md"
SYSTEM = os.environ.get("NIX_SYSTEM", "x86_64-linux")
CONFIG_PATH = Path(__file__).resolve().parent / "gen-readme-config.json"


def load_config():
    default = {"expand_attrs": {}}
    if CONFIG_PATH.exists():
        with open(CONFIG_PATH) as f:
            cfg = json.load(f)
        raw = cfg.get("expand_attrs", {})
        if isinstance(raw, list):
            default["expand_attrs"] = {k: {"heading": True} for k in raw}
        elif isinstance(raw, dict):
            default["expand_attrs"] = {
                k: (v if isinstance(v, dict) else {"heading": v})
                for k, v in raw.items()
            }
    return default


NIX_EXPR = """
let
  flake = builtins.getFlake (toString {repo_dir});
  pkgs = flake.legacyPackages."{system}";

  reserved = [
    "lib" "nixosModules" "overlays"
    "homeModules" "darwinModules" "flakeModules"
    "callPackage" "newScope" "overrideScope" "packages"
    "override" "overrideDerivation"
  ];

  resolveLic = lic:
    let
      go = l:
        if l == null then {{ shortName = null; spdxId = null; url = null; }}
        else if builtins.isList l then go (builtins.head l)
        else if builtins.isString l then {{ shortName = l; spdxId = null; url = null; }}
        else {{
          shortName = l.shortName or null;
          spdxId = l.spdxId or null;
          url = l.url or null;
        }};
    in go lic;

  getLic = meta:
    resolveLic (meta.license or meta.licence or null);

  isDer = x: builtins.isAttrs x && x ? type && x.type == "derivation";
  isScope = x: builtins.isAttrs x && x ? callPackage && x ? newScope && !isDer x;

  reservedSet = builtins.listToAttrs (builtins.map (n: {{ name = n; value = true; }}) reserved);

  collect = prefix: attrs:
    let
      names = builtins.filter (n: !(reservedSet.${{n}} or false)) (builtins.attrNames attrs);
    in
      builtins.concatMap (name:
        let
          v = attrs.${{name}};
          fullPrefix = if prefix == "" then name else "${{prefix}}.${{name}}";
          pkgInfo = {{
            path = fullPrefix;
            pname = v.pname or v.name or "";
            version = v.version or "";
            homepage = v.meta.homepage or "";
            description = v.meta.description or "";
            license = getLic v.meta;
          }};
        in
          if isDer v then [ pkgInfo ]
          else if isScope v then collect fullPrefix v
          else []
      ) names;
in
  collect "" pkgs
"""


def eval_packages():
    expr = NIX_EXPR.format(repo_dir=json.dumps(str(REPO_DIR)), system=SYSTEM)
    result = subprocess.run(
        ["nix", "eval", "--impure", "--expr", expr, "--json"],
        capture_output=True,
        text=True,
        cwd=REPO_DIR,
    )
    if result.returncode != 0:
        print(f"nix eval failed: {result.stderr}", file=sys.stderr)
        sys.exit(1)
    return json.loads(result.stdout)


def fmt_license(lic):
    spdx = lic.get("spdxId")
    url = lic.get("url")
    short = lic.get("shortName")
    if spdx:
        if url and len(url) > 0:
            return f"[{spdx}]({url})"
        return spdx
    if short == "unfree":
        return "**Unfree**"
    if short:
        if url and len(url) > 0:
            return f"[{short}]({url})"
        return short
    return "Not specified"


def fmt_name(pname, homepage):
    if pname and homepage:
        return f"[{pname}]({homepage})"
    return pname


def fmt_version(version):
    if version:
        return f"`{version}`"
    return "-"


def fmt_row(item):
    path = item["path"]
    pname = item.get("pname", "")
    homepage = item.get("homepage", "")
    version = item.get("version", "")
    license_info = item.get("license", {})
    description = item.get("description", "")
    return f"| `{path}` | {fmt_name(pname, homepage)} | {fmt_version(version)} | {fmt_license(license_info)} | {description} |"


HEADER = "| Path | Name | Version | License | Description |"
SEPARATOR = "| --- | --- | --- | --- | --- |"


def mk_table(items):
    lines = [HEADER, SEPARATOR]
    lines.extend(fmt_row(item) for item in items)
    lines.append("")
    return "\n".join(lines)


def group_packages(pkgs):
    groups = {}
    for item in pkgs:
        first_seg = item["path"].split(".")[0]
        groups.setdefault(first_seg, []).append(item)
    return groups


def generate_markdown(pkgs, config):
    expand_attrs = config["expand_attrs"]  # {attr_name: {heading: bool}}

    groups = group_packages(pkgs)
    common_items = []
    named_sections = []  # List of (section_name, items)

    for group_key, items in groups.items():
        count = len(items)
        desc_set = {item.get("description", "") for item in items}
        desc_count = len(desc_set)

        if group_key in expand_attrs:
            if expand_attrs[group_key].get("heading", True):
                named_sections.append((group_key, items))
            else:
                common_items.extend(items)
        elif count == 1:
            common_items.append(items[0])
        elif desc_count <= 1:
            common_items.append(
                {
                    "path": group_key,
                    "pname": group_key,
                    "version": "",
                    "homepage": items[0].get("homepage", ""),
                    "description": items[0].get("description", ""),
                    "license": items[0].get("license", {}),
                }
            )
        else:
            named_sections.append((group_key, items))

    output_parts = []
    if common_items:
        output_parts.append("### Common\n")
        output_parts.append(mk_table(common_items))

    for section_name, items in named_sections:
        output_parts.append(f"### {section_name}\n")
        output_parts.append(mk_table(items))

    return "\n".join(output_parts)


BEGIN_MARKER = "<!-- BEGIN_PACKAGE_TABLE -->"
END_MARKER = "<!-- END_PACKAGE_TABLE -->"


def inject_into_readme(table_md):
    if README.exists():
        content = README.read_text()
    else:
        content = ""

    if BEGIN_MARKER in content and END_MARKER in content:
        before = content.split(BEGIN_MARKER)[0]
        after = content.split(END_MARKER, 1)[1]
        # Preserve trailing content after END_MARKER marker properly
        if after.startswith("\n"):
            after = after[1:]
        new_content = f"{before}{BEGIN_MARKER}\n{table_md}\n{END_MARKER}\n{after}"
    else:
        new_content = f"{content}\n\n{BEGIN_MARKER}\n{table_md}\n{END_MARKER}\n"

    README.write_text(new_content)


def main():
    print("==> Evaluating package metadata via nix...")
    pkgs = eval_packages()
    print(f"==> Found {len(pkgs)} derivations")

    config = load_config()

    print("==> Generating markdown tables...")
    table_md = generate_markdown(pkgs, config)

    print("==> Injecting table into README...")
    inject_into_readme(table_md)

    print(f"==> Done. README updated at {README}")


if __name__ == "__main__":
    main()
