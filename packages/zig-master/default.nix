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

  # Pin: 0.17.0-dev.1862+40ebd8162 (2026-08-26)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1862+40ebd8162";
    sha256 = {
      x86_64-linux   = "sha256-jna8V1hfycJXxsMFOlIlAfam57qugBSQ0mnsA2x1tY0=";
      aarch64-linux  = "sha256-8r2jeaP6SfhFDRfYDKYoBUm7Fgz00a/4H1TGSsLUdL4=";
      x86_64-darwin  = "sha256-aCOwh/lWR/nrbesEO2UW30rtF3vqN0x38BAjcx+qVSs=";
      aarch64-darwin = "sha256-MusbbJ8299yPxXlUBvsxBsS7OU2VI3R8Gh4uFBWEpuY=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
