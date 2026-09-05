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

  # Pin: 0.17.0-dev.2015+3fdcbc03d (2026-09-05)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2015+3fdcbc03d";
    sha256 = {
      x86_64-linux   = "sha256-MeKflYTBT6LVHA4cIxBRW6SBfWooB0mZo9hcS1uyKe4=";
      aarch64-linux  = "sha256-QX0Q8A1fXIM4BLcnad1JcS/oSgQq9EAy+Dx0nkVIsXo=";
      x86_64-darwin  = "sha256-tS8b5HN1Q9k+QA249Mr4erCFVZn8qEeghDX4F1WYKak=";
      aarch64-darwin = "sha256-RpHHDDftnoD+s7ip6qfh8B/pe3L+iJX+5CqVwsABmUM=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
