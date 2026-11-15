#!/usr/bin/env python3
"""Rewrite Huawei's macOS home literals in place: replacements are NUL padded
so offsets stay fixed, and leading slashes keep the $HOME join shape."""

import argparse
import json
import os
import sys


def rules(library_map):
    """(binary rules, JS rules) derived from the shared macOS-to-XDG map."""
    caches = library_map["Library/Caches/Huawei"]
    huawei = library_map["Library/Huawei"]
    config = library_map["Library/Application Support/Huawei"]
    logs = library_map["Library/Logs/Huawei"]
    binary = [
        # ~/Library/Caches/Huawei/Emulator<version>/.emu_config
        ("Library/Caches/Huawei/Emulator", caches + "/Emulator"),
        # ~/Library/Huawei/Sdk, the default emulator image root.
        ("Library/Huawei/Sdk", huawei + "/Sdk"),
        # ~/Library/Application Support/Huawei/DevEcoStudio{5.0,}
        (
            "/Library/Application Support/Huawei/DevEcoStudio5.0/emulator",
            "/" + config + "/DevEcoStudio5.0/emulator",
        ),
        (
            "/Library/Application Support/Huawei/DevEcoStudio5.0/options",
            "/" + config + "/DevEcoStudio5.0/options",
        ),
        (
            "/Library/Application Support/Huawei/DevEcoStudio",
            "/" + config + "/DevEcoStudio",
        ),
        # ~/Library/Logs/Huawei/DevEcoStudio
        (
            "/Library/Logs/Huawei/DevEcoStudio",
            "/" + logs + "/DevEcoStudio",
        ),
    ]
    # TRACE_MAC_LOG_PATH / TRACE_MAC_REGION_PATH are used whenever the host
    # is not Windows, so Linux falls through to the macOS values.
    text = [
        ('"Library/Caches/Huawei"', '"' + caches + '"'),
        ('"Library/Application Support/Huawei"', '"' + config + '"'),
    ]
    return (
        {"emulator/Emulator": [(o.encode(), n.encode(), 1) for o, n in binary]},
        {
            "ohpm/lib/core/audit/TracePathConfig.js": [
                (o.encode(), n.encode(), 1) for o, n in text
            ]
        },
    )


def forbidden(library_map, binary_rules):
    """NUL terminated macOS roots the patched binary must not contain."""
    roots = set()
    for old, _, _ in binary_rules:
        for key in library_map:
            encoded = key.encode()
            for form in (encoded, b"/" + encoded):
                if old.startswith(form):
                    roots.add(form)
    return [b"\x00" + root for root in sorted(roots)]


def fail(message):
    print("patch-emulator-paths: error: %s" % message, file=sys.stderr)
    return 1


def patch_binary(path, rules, forbidden_roots):
    with open(path, "rb") as handle:
        data = bytearray(handle.read())
    if data[:4] != b"\x7fELF":
        return fail("%s is not an ELF binary" % path)
    size = len(data)

    for old, new, expected in rules:
        if len(new) > len(old):
            return fail("replacement %r is longer than %r" % (new, old))
        needle = old + b"\x00"
        found = data.count(needle)
        if found != expected:
            return fail(
                "expected %d NUL terminated %r in %s, found %d"
                % (expected, old, path, found)
            )
        offset = data.find(needle)
        data[offset : offset + len(needle)] = new + b"\x00" * (len(needle) - len(new))
        print(
            "patched %s: %r -> %r at 0x%x" % (os.path.basename(path), old, new, offset)
        )

    if len(data) != size:
        return fail("size changed while patching %s" % path)
    for leftover in forbidden_roots:
        if data.count(leftover):
            return fail("%r still present in %s" % (leftover, path))

    with open(path, "r+b") as handle:
        handle.write(data)
        handle.truncate()
    return 0


def patch_text(path, rules):
    with open(path, "rb") as handle:
        data = handle.read()
    for old, new, expected in rules:
        found = data.count(old)
        if found != expected:
            return fail(
                "expected %d occurrences of %r in %s, found %d"
                % (expected, old, path, found)
            )
        data = data.replace(old, new)
        print("patched %s: %r -> %r" % (os.path.basename(path), old, new))
    with open(path, "wb") as handle:
        handle.write(data)
    return 0


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "root", metavar="CLI_ROOT", help="command-line-tools payload directory"
    )
    parser.add_argument(
        "--library-map",
        required=True,
        metavar="JSON",
        help="macOS-to-XDG directory map, see pkgs/harmonyos-cmdline-tools/library-paths.nix",
    )
    args = parser.parse_args(argv[1:])

    try:
        with open(args.library_map, "rb") as handle:
            library_map = json.load(handle)
        binary_rules, text_rules = rules(library_map)
        forbidden_roots = forbidden(library_map, binary_rules["emulator/Emulator"])
    except (OSError, ValueError, KeyError, AttributeError) as error:
        return fail("bad library map: %s" % error)

    for relative, entries in sorted(binary_rules.items()):
        path = os.path.join(args.root, relative)
        if not os.path.isfile(path):
            return fail("%s not found" % path)
        status = patch_binary(path, entries, forbidden_roots)
        if status:
            return status
    for relative, entries in sorted(text_rules.items()):
        path = os.path.join(args.root, relative)
        if not os.path.isfile(path):
            return fail("%s not found" % path)
        status = patch_text(path, entries)
        if status:
            return status
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
