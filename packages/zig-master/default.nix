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

  # Pin: 0.17.0-dev.1503+1f1bee62e (2026-07-30)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1503+1f1bee62e";
    sha256 = {
      x86_64-linux   = "sha256-FbTHueIIg0g7lKg7+doJIAwuoA5/B0F4DzurzxtGDSw=";
      aarch64-linux  = "sha256-4rYjwC0yvBjFOJagTpz0wMOng/887VpwyvTj3s6uiLE=";
      x86_64-darwin  = "sha256-j9TJ3o2XYmOI44y077Uj28ZN00UtCrg/gpQX97mfMes=";
      aarch64-darwin = "sha256-ns65ffd6rse4hz/iT3R4OtvfC4joZ1R+LqZEn3O/q2c=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
