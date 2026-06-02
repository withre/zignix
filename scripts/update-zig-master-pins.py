#!/usr/bin/env python3
"""Update the repository's pinned Zig master snapshot."""

from __future__ import annotations

import datetime as dt
import json
import re
import sys
import urllib.request
from pathlib import Path

INDEX_URL = "https://ziglang.org/download/index.json"
PIN_FILE = Path("nix/packages/zig-master/default.nix")

SYSTEM_KEYS = {
    "x86_64-linux": "x86_64-linux",
    "aarch64-linux": "aarch64-linux",
    "x86_64-darwin": "x86_64-macos",
    "aarch64-darwin": "aarch64-macos",
}


def fetch_master() -> dict[str, object]:
    with urllib.request.urlopen(INDEX_URL, timeout=30) as response:
        return json.load(response)["master"]


def build_pin_block(master: dict[str, object]) -> str:
    version = str(master["version"])
    today = dt.datetime.now(dt.UTC).date().isoformat()

    hashes = {
        system: str(master[upstream_key]["shasum"])
        for system, upstream_key in SYSTEM_KEYS.items()
    }

    return f'''  # Pin: {version} ({today})
  # Shasums from https://ziglang.org/download/index.json
  pins = {{
    version = "{version}";
    sha256 = {{
      x86_64-linux   = "{hashes["x86_64-linux"]}";
      aarch64-linux  = "{hashes["aarch64-linux"]}";
      x86_64-darwin  = "{hashes["x86_64-darwin"]}";
      aarch64-darwin = "{hashes["aarch64-darwin"]}";
    }};
  }};'''


def main() -> int:
    pin_file = Path(sys.argv[1]) if len(sys.argv) > 1 else PIN_FILE
    text = pin_file.read_text()
    replacement = build_pin_block(fetch_master())

    updated, count = re.subn(
        r'  # Pin: .*?\n  # Shasums from https://ziglang\.org/download/index\.json\n  pins = \{\n'
        r'    version = "[^"]+";\n'
        r'    sha256 = \{\n'
        r'      x86_64-linux   = "[0-9a-f]+";\n'
        r'      aarch64-linux  = "[0-9a-f]+";\n'
        r'      x86_64-darwin  = "[0-9a-f]+";\n'
        r'      aarch64-darwin = "[0-9a-f]+";\n'
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

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
