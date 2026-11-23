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

  # Pin: 0.18.0-dev.1273+1ba843088 (2026-11-23)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.1273+1ba843088";
    sha256 = {
      x86_64-linux   = "sha256-4m7FkO9me/JEcelU1XJQj4R/Xy65a0QxneN90xNIcTM=";
      aarch64-linux  = "sha256-vfHeiHPbI+rZNXH59ppo0k6mc/WB4jE6nba9EpAEGiw=";
      x86_64-darwin  = "sha256-Xhah7rbrcEKF8AQDEIvdVTOy0yZbMng2mxx1N/RD5wA=";
      aarch64-darwin = "sha256-2Xef8iwyon2Gtzfw5MGDfgs2VliULh7JBN/4DyaI/b8=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
