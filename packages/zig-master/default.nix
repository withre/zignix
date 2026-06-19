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

  # Pin: 0.17.0-dev.889+e6be5cfe3 (2026-06-19)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.889+e6be5cfe3";
    sha256 = {
      x86_64-linux   = "sha256-zTKcELO7+JIPSZrDTSzHlgnW9MD/WPwBcZaRIsMt99c=";
      aarch64-linux  = "sha256-ek2OIt0610RXDxtbtiq6yuhjqRBpcF0Ui/LMqac6SDs=";
      x86_64-darwin  = "sha256-jHiReXjAsZNvybFTLzesquHRxD/7ul2UTYlCeeRANfQ=";
      aarch64-darwin = "sha256-hLdjGbIrVGAsEXJ2ipa7k36pygL8JvjJr+6w4OTp1AY=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
