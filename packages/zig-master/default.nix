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

  # Pin: 0.17.0-dev.986+f3544a707 (2026-06-27)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.986+f3544a707";
    sha256 = {
      x86_64-linux   = "sha256-2Dvn9Vdy9IwUExJwy0xgWPTWHXE8Rc7Crxyy3XVHLqo=";
      aarch64-linux  = "sha256-7Q/okAz5Zlm2T47hVK+2rdnOCnktrKqUZBEF71gr8vo=";
      x86_64-darwin  = "sha256-kdyV2StrEmJ9zVbD6ykrZ8dtvC7ZD8+r9frjpkA2zlw=";
      aarch64-darwin = "sha256-/eqSnZ4Yg6JyH4y4d/ub3iALQUOoFjapG6M5NPTSotg=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
