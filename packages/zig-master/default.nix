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

  # Pin: 0.17.0-dev.1811+6716bf52e (2026-08-19)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1811+6716bf52e";
    sha256 = {
      x86_64-linux   = "sha256-2V+7/Gwc0kCcLEj2+axU0knEI58iArwz1QAcZgqAd28=";
      aarch64-linux  = "sha256-FFqfAWm/nXbkTjoDc+M/z57Yg0M1fdUs4XuRyoxmrWw=";
      x86_64-darwin  = "sha256-L3aPJ1YbGvStRyAFH3cfkS9rAoTYVu4vaqo//8dKkwQ=";
      aarch64-darwin = "sha256-2xziN+AwMjNCHltr58THZ4RLtnB3wbf2BfYmcFq0MGA=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
