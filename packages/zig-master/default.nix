{ pkgs, system, ... }:

###========================================
##   Pinned master snapshot
#==========================================
#
# A worked example of `lib.fromBuild`. Demonstrates how downstream
# consumers can pin a specific nightly without forking zignix. To
# bump:
#
#   1. Pick a version from https://ziglang.org/download/index.json
#      (`.master.version`).
#   2. Convert the matching `<arch>-<os>.shasum` to a Nix sha256.
#   3. Run `nix build .#zig-master` to verify.
#
# This package is intentionally minimal — the project's API surface is
# `lib.fromBuild` etc., not this attribute.

let
  zignixLib = import ../../lib/default.nix {
    inherit system pkgs;
    inherit (pkgs) lib;
  };

  # Pin: 0.18.0-dev.1240+74f654a72 (2026-11-19)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.1240+74f654a72";
    sha256 = {
      x86_64-linux   = "sha256-PcJ8uPA2nOAptHxt8/LRrCwaU+sAM1UPRj/2CRezWH4=";
      aarch64-linux  = "sha256-WZNnwEj8AWwbi0OqLEPLhKM8ervB8hYN3M93nZyDwrY=";
      x86_64-darwin  = "sha256-CvgRhozYcbQVa+65TMA5UkduP9mMMYOX5zL/6BhLSj4=";
      aarch64-darwin = "sha256-eJILZfVBkpU0vITe3XAHHBTFFmS1VR82rAnmlu/+3Kk=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
