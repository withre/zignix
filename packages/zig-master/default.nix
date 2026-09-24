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

  # Pin: 0.17.0-dev.2281+83624acf6 (2026-09-24)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2281+83624acf6";
    sha256 = {
      x86_64-linux   = "sha256-kmikGqlTOLN/noBpTUWN2709l1aHwbKy1AgmEqfMHjA=";
      aarch64-linux  = "sha256-BCh9n7emeVtaJKVNCOzMrZ9D1RY6pleesPf1mVN2wxY=";
      x86_64-darwin  = "sha256-CQIVaWTKCcrmSL7xXe7cjCp2CFvCe8JXrVycoCbg/qc=";
      aarch64-darwin = "sha256-pCUJ1lQmQvbZ1wB0bbygOJ/HoAmjRAqAPL7L/95+8bY=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
