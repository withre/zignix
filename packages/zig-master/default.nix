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

  # Pin: 0.17.0-dev.857+2b2b85c5f (2026-06-14)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.857+2b2b85c5f";
    sha256 = {
      x86_64-linux   = "sha256-VJia/PIs+EMM6RErOQ7GMuWUI5p1w/5ia0U4F0jXLiM=";
      aarch64-linux  = "sha256-yG8fsXUA1j7UeRiSJBKjWwgArY0ieV5nJXZc1BME/2A=";
      x86_64-darwin  = "sha256-+VbgU6OcD13/YULSFT3KXkILwZ/DUUy610cuCizQPiU=";
      aarch64-darwin = "sha256-4EpSe6bRCHnP8SEFy9STg0fDGlQjpLpNjJB9dZUhFo8=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
