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

  # Pin: 0.18.0-dev.1186+9dd2c8c88 (2026-11-18)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.1186+9dd2c8c88";
    sha256 = {
      x86_64-linux   = "sha256-V4pkZoPF5z0EzMwNATmch9+38j5i/K07/WpFxq0gcpg=";
      aarch64-linux  = "sha256-S1LkWARQutP8VhsXmhw5nK+BmyGM+V+lyKKjnfTXFsY=";
      x86_64-darwin  = "sha256-e3UV73FkiM4gy9SO/4iyR1o/VZkwCVBubN8GXtWm+PM=";
      aarch64-darwin = "sha256-wXdsexWIFLWcc/jo/bAMtzDI7oIwCCFjzhPqSJsIjgE=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
