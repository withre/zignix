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

  # Pin: 0.17.0-dev.2122+3e15e99e6 (2026-09-12)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2122+3e15e99e6";
    sha256 = {
      x86_64-linux   = "sha256-Dwo2MbMkb37lzX2eQs7NYI/e4f9izm+7ZNI5bAN1lyw=";
      aarch64-linux  = "sha256-4lP2owNMMkZzbSygT0/KE9QLsC6tf0uF1bfa3XDX2MM=";
      x86_64-darwin  = "sha256-62ciht0P18AC2jxC8C0mQt1/VNhPu1PVGgfy4SQeWvE=";
      aarch64-darwin = "sha256-w3I9aHT9hBeR08xp+owZ72GodlIeKggKg9AIQfZG5MQ=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
