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

  # Pin: 0.18.0-dev.738+ae9a8acc7 (2026-10-30)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.738+ae9a8acc7";
    sha256 = {
      x86_64-linux   = "sha256-Aisqa37s2Vp4brqMYocHzjxj3VYUBSPCmnYVbn0msXQ=";
      aarch64-linux  = "sha256-OSuESxnUBiZz5zRjV5OG4WQxg0xb3WQ+rvFQ9y9F5H8=";
      x86_64-darwin  = "sha256-J4/zIpS1ipOAiXfPAAXPtVDjwWGXFCnZHb7qPzdBXKo=";
      aarch64-darwin = "sha256-xIl4Q3CfMHMCKAoJg9x6lGjzyz/MkHzfvOBvWFcccCY=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
