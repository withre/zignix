#!/usr/bin/env python3
"""Update the repository's pinned Zig snapshots (latest master + latest 0.16)."""

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

# Which 0.x release line the `zig-0_16` package tracks, and its pin file.
MINOR_LINE = "0.16"
MINOR_PIN_FILE = Path("packages/zig-0_16/default.nix")

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
    minor_version: str,
) -> bool:
    text = readme_file.read_text()

    updated, count = re.subn(
        r'(fromBuild \{\n\s*)version = "0\.17\.0-dev\.[^"]+";\n(\s*)sha256 = "sha256-[A-Za-z0-9+/=]+";',
        rf'\1version = "{master_version}";\n\2sha256 = "{master_x86_64_linux_hash}";',
        text,
    )
    if count == 0:
        raise RuntimeError(f"could not find Quick Start pin in {readme_file}")

    updated, master_rows = re.subn(
        r'(\| ~zig-master~\s+\|[^|]*\| )~0\.17\.0-dev\.[^~]+~',
        rf'\g<1>~{master_version}~',
        updated,
    )
    if master_rows == 0:
        raise RuntimeError(f"could not find zig-master row in {readme_file}")

    updated, minor_rows = re.subn(
        r'(\| ~zig-0_16~\s+\|[^|]*\| )~[0-9]+\.[0-9]+\.[0-9]+~',
        rf'\g<1>~{minor_version}~',
        updated,
    )
    if minor_rows == 0:
        raise RuntimeError(f"could not find zig-0_16 row in {readme_file}")

    if updated != text:
        readme_file.write_text(updated)
        return True

    return False


def main() -> int:
    index = fetch_index()
    master_version, master_hashes = master_entry(index)
    minor_version, minor_hashes = latest_minor_entry(index, MINOR_LINE)

    if len(sys.argv) > 1:
        # Test mode: update a single master pin file in place.
        update_pin_file(Path(sys.argv[1]), master_version, master_hashes)
        return 0

    update_pin_file(MASTER_PIN_FILE, master_version, master_hashes)
    update_pin_file(MINOR_PIN_FILE, minor_version, minor_hashes)
    update_readme(
        README_FILE,
        master_version,
        master_hashes["x86_64-linux"],
        minor_version,
    )

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
