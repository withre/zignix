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

  # Pin: 0.17.0-dev.1756+613c03321 (2026-08-15)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1756+613c03321";
    sha256 = {
      x86_64-linux   = "sha256-ga9rChdJSfGnwZfl8eoaTvX4Z9PDzjWAtNaEYxpRaac=";
      aarch64-linux  = "sha256-elVjihrfUihb4vENrT9fBb71pRme+nVkgvnvIn7LTL4=";
      x86_64-darwin  = "sha256-tT1EaJWaX6MczwEHrX4knuG5KrLi5M9kRduYnHsj6t4=";
      aarch64-darwin = "sha256-MWXOdteiWyRgifBddrzUw3Hu/EAA4VHqOSFAdI+NYWE=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
