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

  # Pin: 0.17.0-dev.1456+2b1c6633a (2026-07-24)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1456+2b1c6633a";
    sha256 = {
      x86_64-linux   = "sha256-fKBLiRtsjtNxP/zoLcne+8H6M9DYmFvibxf4DC3G5eg=";
      aarch64-linux  = "sha256-gveVjAjf+CCgGBchMlxy/caUvH2MQpKmlRQLrcrHBts=";
      x86_64-darwin  = "sha256-qsJ7CDbWg4ujAG4f90dqDst7Vn9TF2XoycAH+NFFnkc=";
      aarch64-darwin = "sha256-iY6Rmbr2lW2klCHHJIAWVjbmF3LR7YSPOzbcp+zDnlU=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
