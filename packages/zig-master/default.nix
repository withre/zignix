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

  # Pin: 0.17.0-dev.704+b8cb78023 (2026-06-08)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.704+b8cb78023";
    sha256 = {
      x86_64-linux   = "sha256-F+rOqhtxh+0026hqlHFR0K0MXl2gECk0c9UZ2iU1toI=";
      aarch64-linux  = "sha256-FMbs+J+70hCsLQ82onTLmyvSHGfPjI90z/EkLvgHyhw=";
      x86_64-darwin  = "sha256-8uGkNQA8nzsGFSwfQeHPwNA4k9L/A4egQjAyeMAfC1o=";
      aarch64-darwin = "sha256-wHVtTAsRZCX3qiVNP+G1kngTsk/ktEMFxb3sI1rJjOQ=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
