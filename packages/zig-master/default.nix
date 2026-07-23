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

  # Pin: 0.17.0-dev.1442+972627084 (2026-07-23)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1442+972627084";
    sha256 = {
      x86_64-linux   = "sha256-WgcGjO0PVDW/NQMr3EBvyfqpIVyhFapK1lrxTyEU0IE=";
      aarch64-linux  = "sha256-otlL0FjhlWYHulaPnrFAGaZ+dke/HYU4zrZBe5cVkmg=";
      x86_64-darwin  = "sha256-L66AGyiiyt1ZGow+epHy00BA1doHoN5N3GnCVAZioEQ=";
      aarch64-darwin = "sha256-jPHqoeEZXl4bGedxL+0U8AYPwcH6XOUZ+h3nMrAniok=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
