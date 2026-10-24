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

  # Pin: 0.18.0-dev.470+6817928c3 (2026-10-24)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.470+6817928c3";
    sha256 = {
      x86_64-linux   = "sha256-cV+QYCLQDO3vxIvXS+fyW/O9HBeFtaOCwWUSMH+Qm0M=";
      aarch64-linux  = "sha256-/mgaFGUHrIixkh7M645Nt1jGGyCpMuYcgq5gRSXmnQ8=";
      x86_64-darwin  = "sha256-0cPQ0M5SonBYkZ1P4bDd3mTU6/Ey7uDoGe1qnkCbfLk=";
      aarch64-darwin = "sha256-r6IKRxQseTJ7L0G7jw1OYZsAWNAuYKeZ+YWfvkdnq3Q=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
