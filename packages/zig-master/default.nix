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

  # Pin: 0.17.0-dev.1282+c0f9b51d8 (2026-07-11)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1282+c0f9b51d8";
    sha256 = {
      x86_64-linux   = "sha256-bYHewBUvbxH4oSqEpzU1tlBw/gGxShznVCOHDWWz8nA=";
      aarch64-linux  = "sha256-Qo2sb2l7kIpfZLTDg9V+081AyJaOZEDXL1kXgZ85x64=";
      x86_64-darwin  = "sha256-+BA/K7F470wrvK5ipUgMIyfnrr1KbcATRYN2Rb5DPPQ=";
      aarch64-darwin = "sha256-biViT9hxp20mBM98WrCYTGRbgQCGB8bqPZdKO2hAWYg=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
