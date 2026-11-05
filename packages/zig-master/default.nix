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

  # Pin: 0.18.0-dev.861+1a0778dc2 (2026-11-05)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.861+1a0778dc2";
    sha256 = {
      x86_64-linux   = "sha256-SSJbSzFRoRNG1MRpowjd8DfTFs2iNFBbj7NCYq6d0a4=";
      aarch64-linux  = "sha256-OD5p6ehE1eGtmPtauL+lTpweuW2ftePGiijKQOG28vw=";
      x86_64-darwin  = "sha256-RAI58iHylU6+glCHqDvCVQB/Uelih+gDgRidXgGvPcc=";
      aarch64-darwin = "sha256-8/Q1/0omULK2L815mqWhIrOKnA22Dyx6QentA60XGA8=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
