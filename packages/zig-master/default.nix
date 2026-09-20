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

  # Pin: 0.17.0-dev.2234+80fe9b2b7 (2026-09-20)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2234+80fe9b2b7";
    sha256 = {
      x86_64-linux   = "sha256-LyOX7BRl5CYIIqsAs/ubx4uxqb/1ZCYMv0chWPWgShU=";
      aarch64-linux  = "sha256-QnF9vV4ruzjlsCFqkx0d1azLeS3hpA26PnhfHGJu7F8=";
      x86_64-darwin  = "sha256-Slxhi6+JkTg7+JtSp/z/DBfwk/7AfP5cXsJ8c2BsG9M=";
      aarch64-darwin = "sha256-rzZfkzSXbfG1q9C4riJ1ar/t0hGOHNjFOsHUtD+c7MQ=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
