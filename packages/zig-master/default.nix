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

  # Pin: 0.17.0-dev.2264+230c63650 (2026-09-23)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2264+230c63650";
    sha256 = {
      x86_64-linux   = "sha256-eY4eOpDU3PLqzIcdZA/g6lEe2NVOlcIlH9HPhTEGnVA=";
      aarch64-linux  = "sha256-fZSRWdnYFeWLwMy4yhUrMpxi9GPk1opo2C/rJqJDGP0=";
      x86_64-darwin  = "sha256-pwvfILOMwJYcHeys6DNNtVLEDxqFhLO95mQHW55XmUo=";
      aarch64-darwin = "sha256-bVH4H08b0UTFEet4EUgJje0CETJjRl4G5AsvfYOv3KQ=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
