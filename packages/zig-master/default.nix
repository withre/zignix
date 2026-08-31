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

  # Pin: 0.17.0-dev.1941+71115f0ab (2026-08-31)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1941+71115f0ab";
    sha256 = {
      x86_64-linux   = "sha256-svay+izUYsEMhvuxYAmcHIhI0tW8DB4MLcKKczE5Av8=";
      aarch64-linux  = "sha256-KnIpRjgmw12TdYLMqg7NRE0POmw+H5NvLYqCCBueEWk=";
      x86_64-darwin  = "sha256-DNwI+t7LEdOr14wL4AagLP0DzY5WX/HIThLPnZkWuvc=";
      aarch64-darwin = "sha256-diS+9MV91GCJMPdzNKh3ePkzWoBR1WK3tD7LJU1oNIk=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
