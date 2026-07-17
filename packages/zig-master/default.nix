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

  # Pin: 0.17.0-dev.1415+64dfaa568 (2026-07-17)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1415+64dfaa568";
    sha256 = {
      x86_64-linux   = "sha256-2yfBXLuXl2Cl4xzBDEUfJ7LHnAJWB3auP4MRYVhLCZ0=";
      aarch64-linux  = "sha256-Dt/2ARKcci8xUcYQecqah4BYwQ6OLKkrE81mf/VY4+c=";
      x86_64-darwin  = "sha256-QsTyCdQMDaPDYaDaoqvP1CIMy1Rb/HWrCtEK6kgfI3A=";
      aarch64-darwin = "sha256-xRF4b3Xt9T5BqidKeg+AERL4BjbslNTbEi+xU9D66MI=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
