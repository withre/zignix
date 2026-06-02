#!/usr/bin/env python3
"""Update the repository's pinned Zig master snapshot."""

from __future__ import annotations

import base64
import datetime as dt
import json
import re
import sys
import urllib.request
from pathlib import Path

INDEX_URL = "https://ziglang.org/download/index.json"
PIN_FILE = Path("nix/packages/zig-master/default.nix")
README_FILE = Path("README.org")

SYSTEM_KEYS = {
    "x86_64-linux": "x86_64-linux",
    "aarch64-linux": "aarch64-linux",
    "x86_64-darwin": "x86_64-macos",
    "aarch64-darwin": "aarch64-macos",
}


def fetch_master() -> dict[str, object]:
    with urllib.request.urlopen(INDEX_URL, timeout=30) as response:
        return json.load(response)["master"]


def shasum_to_nix_sha256(shasum: str) -> str:
    """Convert Zig's hex shasum to a Nix-friendly SRI sha256."""
    if not re.fullmatch(r"[0-9a-f]{64}", shasum):
        raise ValueError(f"expected sha256 hex shasum, got: {shasum}")

    digest = bytes.fromhex(shasum)
    return "sha256-" + base64.b64encode(digest).decode("ascii")


def master_pins(master: dict[str, object]) -> tuple[str, dict[str, str]]:
    version = str(master["version"])
    hashes = {
        system: shasum_to_nix_sha256(str(master[upstream_key]["shasum"]))
        for system, upstream_key in SYSTEM_KEYS.items()
    }
    return version, hashes


def build_pin_block(master: dict[str, object]) -> str:
    version, hashes = master_pins(master)
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


def update_pin_file(pin_file: Path, master: dict[str, object]) -> bool:
    text = pin_file.read_text()
    replacement = build_pin_block(master)

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


def update_readme(readme_file: Path, master: dict[str, object]) -> bool:
    version, hashes = master_pins(master)
    x86_64_linux_hash = hashes["x86_64-linux"]
    text = readme_file.read_text()

    updated, count = re.subn(
        r'(fromBuild \{\n\s*)version = "0\.17\.0-dev\.[^"]+";\n(\s*)sha256 = "sha256-[A-Za-z0-9+/=]+";',
        rf'\1version = "{version}";\n\2sha256 = "{x86_64_linux_hash}";',
        text,
    )

    if count == 0:
        raise RuntimeError(f"could not find Quick Start pin in {readme_file}")

    if updated != text:
        readme_file.write_text(updated)
        return True

    return False


def main() -> int:
    pin_file = Path(sys.argv[1]) if len(sys.argv) > 1 else PIN_FILE
    master = fetch_master()

    update_pin_file(pin_file, master)

    if len(sys.argv) <= 1:
        update_readme(README_FILE, master)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
