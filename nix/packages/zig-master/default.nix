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
#   2. Drop in the matching `<arch>-<os>.shasum` value below.
#   3. Run `nix build .#zig-master` to verify.
#
# This package is intentionally minimal — the project's API surface is
# `lib.fromBuild` etc., not this attribute.

let
  zignixLib = import ../../lib/default.nix {
    inherit system pkgs;
    inherit (pkgs) lib;
  };

  # Pin: 0.17.0-dev.607+456b2ec07 (2026-05-29)
  # Shasums from https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.607+456b2ec07";
    sha256 = {
      x86_64-linux   = "19275107de7b89ec33d29b50f00997c1381c524d1e33b728472dcbd551da2e33";
      aarch64-linux  = "96a1465b932e23eebcd9598c82d319d316b41529b6e0ef1bcff48eaf5e3cb15a";
      x86_64-darwin  = "3315ff00c1d90d2472c1bef7b583e3a1adb4b9160b3452aad828b077ad7dd5fa";
      aarch64-darwin = "4f3143fa5a9723754b9516be6f9bc23fda2743abf1144570ae67ac875f5d2a09";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
