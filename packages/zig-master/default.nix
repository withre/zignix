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

  # Pin: 0.17.0-dev.1275+59a628c6d (2026-07-08)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1275+59a628c6d";
    sha256 = {
      x86_64-linux   = "sha256-BOi63dBJcEKInT7prlMjjgZVwrl3cDmCexMUh6dGXRY=";
      aarch64-linux  = "sha256-hBbBSUieZE+B/LUX6c8KHil1+8wOBWOWcQVL7du+/Ls=";
      x86_64-darwin  = "sha256-pPc8+97okWjrST613x+6Txt+6tN21WqfKkwkKsE8xyU=";
      aarch64-darwin = "sha256-yr+NuSw4G9paFg/aj6VP+mTwlkMWwNWx3DhadDfhaRs=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
