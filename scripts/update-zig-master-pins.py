#!/usr/bin/env python3
"""Update the repository's pinned Zig snapshots.

Pins the latest master build, plus the latest release of every tracked
release line (each packages/zig-<major>_<minor>/ package), and re-pins the
example project to that same master build.
"""

from __future__ import annotations

import base64
import datetime as dt
import json
import re
import sys
import urllib.request
from pathlib import Path

INDEX_URL = "https://ziglang.org/download/index.json"
README_FILE = Path("README.org")
MASTER_PIN_FILE = Path("packages/zig-master/default.nix")

# Release lines are discovered rather than listed: every
# packages/zig-<major>_<minor>/ package tracks the newest <major>.<minor>.x
# release, so adding a line needs no change to this script.
PACKAGES_DIR = Path("packages")
RELEASE_LINE_PACKAGE = re.compile(r"zig-([0-9]+)_([0-9]+)")

# The example pins its own master build, and upstream prunes /builds after
# a few weeks, so it follows the master pin rather than going stale.
EXAMPLE_PIN_FILE = Path("examples/pin-specific-build/nix/packages/zig/default.nix")
EXAMPLE_MAIN_FILE = Path("examples/pin-specific-build/src/main.zig")

SYSTEM_KEYS = {
    "x86_64-linux": "x86_64-linux",
    "aarch64-linux": "aarch64-linux",
    "x86_64-darwin": "x86_64-macos",
    "aarch64-darwin": "aarch64-macos",
}


def fetch_index() -> dict[str, object]:
    with urllib.request.urlopen(INDEX_URL, timeout=30) as response:
        return json.load(response)


def shasum_to_nix_sha256(shasum: str) -> str:
    """Convert Zig's hex shasum to a Nix-friendly SRI sha256."""
    if not re.fullmatch(r"[0-9a-f]{64}", shasum):
        raise ValueError(f"expected sha256 hex shasum, got: {shasum}")

    digest = bytes.fromhex(shasum)
    return "sha256-" + base64.b64encode(digest).decode("ascii")


def entry_pins(entry: dict[str, object], version: str) -> tuple[str, dict[str, str]]:
    hashes = {
        system: shasum_to_nix_sha256(str(entry[upstream_key]["shasum"]))
        for system, upstream_key in SYSTEM_KEYS.items()
    }
    return version, hashes


def master_entry(index: dict[str, object]) -> tuple[str, dict[str, str]]:
    master = index["master"]
    return entry_pins(master, str(master["version"]))


def release_line_pin_files() -> dict[str, Path]:
    """Map each tracked release line (e.g. "0.16") to its pin file."""
    lines = {}
    for package in sorted(PACKAGES_DIR.iterdir()):
        match = RELEASE_LINE_PACKAGE.fullmatch(package.name)
        if match:
            lines[".".join(match.groups())] = package / "default.nix"

    if not lines:
        raise RuntimeError(f"no zig-<major>_<minor> packages in {PACKAGES_DIR}")
    return lines


def latest_minor_entry(index: dict[str, object], line: str) -> tuple[str, dict[str, str]]:
    pattern = re.compile(rf"^{re.escape(line)}\.(\d+)$")
    matches = [(int(m.group(1)), key) for key in index if (m := pattern.match(key))]
    if not matches:
        raise RuntimeError(f"no released versions found for line {line}")
    _, key = max(matches)
    return entry_pins(index[key], key)


def build_pin_block(version: str, hashes: dict[str, str]) -> str:
    today = dt.datetime.now(dt.UTC).date().isoformat()

    return f'''  # Pin: {version} ({today})
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {{
    version = "{version}";
    sha256 = {{
      x86_64-linux   = "{hashes["x86_64-linux"]}";
      aarch64-linux  = "{hashes["aarch64-linux"]}";
      x86_64-darwin  = "{hashes["x86_64-darwin"]}";
      aarch64-darwin = "{hashes["aarch64-darwin"]}";
    }};
  }};'''


def update_pin_file(pin_file: Path, version: str, hashes: dict[str, str]) -> bool:
    text = pin_file.read_text()
    replacement = build_pin_block(version, hashes)

    updated, count = re.subn(
        r'  # Pin: .*?\n'
        r'(?:  # Shasums from https://ziglang\.org/download/index\.json\n|'
        r'  # Nix sha256 values converted from upstream shasums in:\n'
        r'  # https://ziglang\.org/download/index\.json\n)'
        r'  pins = \{\n'
        r'    version = "[^"]+";\n'
        r'    sha256 = \{\n'
        r'      x86_64-linux   = "(?:[0-9a-f]{64}|sha256-[A-Za-z0-9+/=]+)";\n'
        r'      aarch64-linux  = "(?:[0-9a-f]{64}|sha256-[A-Za-z0-9+/=]+)";\n'
        r'      x86_64-darwin  = "(?:[0-9a-f]{64}|sha256-[A-Za-z0-9+/=]+)";\n'
        r'      aarch64-darwin = "(?:[0-9a-f]{64}|sha256-[A-Za-z0-9+/=]+)";\n'
        r'    \};\n'
        r'  \};',
        replacement,
        text,
        count=1,
    )

    if count != 1:
        raise RuntimeError(f"could not find pin block in {pin_file}")

    if updated != text:
        pin_file.write_text(updated)
        return True

    return False


def update_readme(
    readme_file: Path,
    master_version: str,
    master_x86_64_linux_hash: str,
    release_versions: dict[str, str],
) -> bool:
    text = readme_file.read_text()

    # Matches any X.Y.Z master version, so a future major bump (e.g.
    # 0.18.0-dev) keeps updating instead of silently failing. The -dev.*
    # suffix is optional: on release day upstream reports the bare release
    # (e.g. 0.17.0) as master, that lands in the README, and requiring the
    # suffix would then fail every later run.
    master_quoted = r'[0-9]+\.[0-9]+\.[0-9]+(?:-dev\.[^"]+)?'
    master_cell = r'[0-9]+\.[0-9]+\.[0-9]+(?:-dev\.[^~]+)?'

    # fromBuild blocks that pin version + a real SRI hash (Quick Start
    # and the plain-flake example).
    updated, sri_count = re.subn(
        rf'(fromBuild \{{\n\s*)version = "{master_quoted}";\n(\s*)sha256 = "sha256-[A-Za-z0-9+/=]+";',
        rf'\1version = "{master_version}";\n\2sha256 = "{master_x86_64_linux_hash}";',
        text,
    )
    if sri_count == 0:
        raise RuntimeError(f"could not find a fromBuild SRI pin in {readme_file}")

    # fromBuild block that uses fakeHash (the bootstrap example) — keep its
    # version current even though the hash is intentionally a placeholder.
    updated, fake_count = re.subn(
        rf'(fromBuild \{{\n\s*)version = "{master_quoted}";\n(\s*sha256 = zignix\.lib\.\$\{{system\}}\.fakeHash;)',
        rf'\1version = "{master_version}";\n\2',
        updated,
    )
    if fake_count == 0:
        raise RuntimeError(f"could not find fakeHash example in {readme_file}")

    updated, master_rows = re.subn(
        rf'(\| ~zig-master~\s+\|[^|]*\| )~{master_cell}~',
        rf'\g<1>~{master_version}~',
        updated,
    )
    if master_rows == 0:
        raise RuntimeError(f"could not find zig-master row in {readme_file}")

    # Every tracked line needs its own row, so a new package cannot ship
    # without showing up in the Current pins table.
    for line, version in release_versions.items():
        package = "zig-" + line.replace(".", "_")
        updated, rows = re.subn(
            rf'(\| ~{re.escape(package)}~\s+\|[^|]*\| )~[0-9]+\.[0-9]+\.[0-9]+~',
            rf'\g<1>~{version}~',
            updated,
        )
        if rows == 0:
            raise RuntimeError(f"could not find {package} row in {readme_file}")

    if updated != text:
        readme_file.write_text(updated)
        return True

    return False


def update_example(version: str, date: str, hashes: dict[str, str]) -> bool:
    """Re-pin the example project, keeping main.zig's pin string in step.

    `date` is upstream's build date rather than today, so the files only
    change when the version does.
    """
    text = EXAMPLE_PIN_FILE.read_text()

    updated, version_count = re.subn(
        r'  # Pinned: [^\n]*\n  version = "[^"]+";\n',
        lambda _: (
            f'  # Pinned: {version} (upstream master as of {date}).\n'
            f'  version = "{version}";\n'
        ),
        text,
        count=1,
    )
    updated, hash_count = re.subn(
        r'      x86_64-linux   = "sha256-[A-Za-z0-9+/=]+";\n'
        r'      aarch64-linux  = "sha256-[A-Za-z0-9+/=]+";\n'
        r'      x86_64-darwin  = "sha256-[A-Za-z0-9+/=]+";\n'
        r'      aarch64-darwin = "sha256-[A-Za-z0-9+/=]+";\n',
        lambda _: "".join(
            f'      {system:<14} = "{hashes[system]}";\n' for system in SYSTEM_KEYS
        ),
        updated,
        count=1,
    )
    if version_count != 1 or hash_count != 1:
        raise RuntimeError(f"could not find the pin in {EXAMPLE_PIN_FILE}")

    main_text = EXAMPLE_MAIN_FILE.read_text()
    main_updated, main_count = re.subn(
        r'(const pinned_zig_version = )"[^"]+";',
        lambda m: f'{m.group(1)}"{version}";',
        main_text,
        count=1,
    )
    if main_count != 1:
        raise RuntimeError(f"could not find pinned_zig_version in {EXAMPLE_MAIN_FILE}")

    changed = False
    for path, before, after in (
        (EXAMPLE_PIN_FILE, text, updated),
        (EXAMPLE_MAIN_FILE, main_text, main_updated),
    ):
        if after != before:
            path.write_text(after)
            changed = True
    return changed


def main() -> int:
    index = fetch_index()
    master_version, master_hashes = master_entry(index)

    if len(sys.argv) > 1:
        # Test mode: update a single master pin file in place.
        update_pin_file(Path(sys.argv[1]), master_version, master_hashes)
        return 0

    update_pin_file(MASTER_PIN_FILE, master_version, master_hashes)

    release_versions = {}
    for line, pin_file in release_line_pin_files().items():
        version, hashes = latest_minor_entry(index, line)
        update_pin_file(pin_file, version, hashes)
        release_versions[line] = version

    update_readme(
        README_FILE,
        master_version,
        master_hashes["x86_64-linux"],
        release_versions,
    )
    update_example(master_version, str(index["master"]["date"]), master_hashes)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
