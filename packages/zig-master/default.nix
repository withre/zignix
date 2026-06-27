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

  # Pin: 0.17.0-dev.978+a078d55a2 (2026-06-27)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.978+a078d55a2";
    sha256 = {
      x86_64-linux   = "sha256-pHYcBbA59pVOFbfYql9l33xY/06/LrPszXeGQwsRFFw=";
      aarch64-linux  = "sha256-7fsksaatQj2bhKCo36FVzhSE7Prs+apR3k5cE7pSctM=";
      x86_64-darwin  = "sha256-kLw7tHKl8xVUUMA0GnNm4joGjGQqCW7y/5oHp1kmHYg=";
      aarch64-darwin = "sha256-jft8X028XbL5jBclEjsmnFK9HwuucYOzUcAl0zeI+Uo=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
