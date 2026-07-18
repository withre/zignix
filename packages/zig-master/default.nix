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

  # Pin: 0.17.0-dev.1417+20befa4e6 (2026-07-18)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1417+20befa4e6";
    sha256 = {
      x86_64-linux   = "sha256-DPzVbIHqM7CLgjgzHBDqk5xy4ZnOb8EfKOcNXwBIYPY=";
      aarch64-linux  = "sha256-Sv8ard95GFScHRrQ1B+QZbzzo5FK9FATbPXIixYzYxs=";
      x86_64-darwin  = "sha256-rQx5DaaqvwtLeV7MCMpOL0xQvg3Ktp2dE5d0+hBZQts=";
      aarch64-darwin = "sha256-oTpIxvDOlK6rCT8VFzWvDVjs4fF7Vf6yLe1hLaetMJY=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
