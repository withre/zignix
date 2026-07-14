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

  # Pin: 0.17.0-dev.1398+cb5635714 (2026-07-14)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1398+cb5635714";
    sha256 = {
      x86_64-linux   = "sha256-sc47cdfqxRZV/euJBX5qLGxomyXD4MmVocqh1aX1zVc=";
      aarch64-linux  = "sha256-ArshFLSQ64tMDPG/eTul/SWDqOKAIVpqUWzppmPl3LQ=";
      x86_64-darwin  = "sha256-y7WBYgqM1cOnfSr23TM+Y1b3+FM+IDiMrmUUQYX1rxw=";
      aarch64-darwin = "sha256-GFfJnO7C1PHlNsaMB+cnDuBqgxH4F1H4FCQlNlc0sFw=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
