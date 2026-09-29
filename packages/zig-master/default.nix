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

  # Pin: 0.17.0-dev.2329+1b7a78122 (2026-09-29)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2329+1b7a78122";
    sha256 = {
      x86_64-linux   = "sha256-BmNdwznseqZSCHudluW6k8i+a0+Ki8i6yhZwkC0gBxg=";
      aarch64-linux  = "sha256-syMg14CZJux+ScEkrwLOqg0xIKcLQyomX2OIfFXzVRE=";
      x86_64-darwin  = "sha256-1nXP35AyBvS70U1W4riqWATzIfGWLq68U1wIJm4PhCc=";
      aarch64-darwin = "sha256-6RumO1fpwPxsSiYSFpCBbYtFy3qNFxGQTZ9CESKelPY=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
