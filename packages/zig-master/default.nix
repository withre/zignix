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

  # Pin: 0.17.0-dev.1606+a06534d73 (2026-08-07)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1606+a06534d73";
    sha256 = {
      x86_64-linux   = "sha256-Jbywz44xMUt5jyuTGOHM0T6ovSHwMMc0kj8mNXi41SA=";
      aarch64-linux  = "sha256-lo3LL2oI4d428XoqBreEuC8WpuxoqDMih29U2AJ1qRc=";
      x86_64-darwin  = "sha256-Dwt0UUDlWZImkFLVlCXO9j0ENB/Phw9paRfV+nOgTKo=";
      aarch64-darwin = "sha256-Vii4SIZ7nU6IlSagAAHhOLI2D1ntvb7kLdMJYGV3PHc=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
