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

  # Pin: 0.17.0-dev.2294+71403f299 (2026-09-25)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2294+71403f299";
    sha256 = {
      x86_64-linux   = "sha256-owMSU4bKaJUS3koAHMjBQEaOl+MA2NEP+uFYfsXAiTM=";
      aarch64-linux  = "sha256-/oBLB49o7VMXZBk6m1twXumk2f66DtXBvKl43ywba1c=";
      x86_64-darwin  = "sha256-p3mWM1MB+zBAcONcqwoG45CEhexLTSia46jDQSoUBMU=";
      aarch64-darwin = "sha256-LAHQfgxcf3Yauc7b/o919XaWefgxfYKBf8kn0MY/N+c=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
