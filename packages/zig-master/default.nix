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

  # Pin: 0.18.0-dev.1260+833623422 (2026-11-21)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.1260+833623422";
    sha256 = {
      x86_64-linux   = "sha256-BTsgw8fcl9jA1Xbr8Z5tt4+L3/GqTZX2YMA3zTuUufc=";
      aarch64-linux  = "sha256-iGzZwbdSg4x8h/szyf6CGZsvCCyWaOdP+lQECcnsMNs=";
      x86_64-darwin  = "sha256-WWKoRy1E4i9bCCtQsKZL2fskyF2xgtT+0u05wr1RcvA=";
      aarch64-darwin = "sha256-z+vGl+i2UPIDF6F013fXyfFQ78aIs3FGhrpknePbeAQ=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
