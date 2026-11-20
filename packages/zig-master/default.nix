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

  # Pin: 0.18.0-dev.1244+b5ffcbd70 (2026-11-20)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.1244+b5ffcbd70";
    sha256 = {
      x86_64-linux   = "sha256-9Xjrng+HpL5pNfeVT/zgbecWpgrso8uot/+Hbl2Gt9I=";
      aarch64-linux  = "sha256-A3naMphy7su75GGUCgD1YnZus++Vhyy5yxeqF/fPMbA=";
      x86_64-darwin  = "sha256-oRwk3cM3lkkD6e/g3Jes3T6fXVuebAsk5QJEqtuyjkM=";
      aarch64-darwin = "sha256-vB0dGueEQCrmSbTy/JelIdW9BLofPxrUJ67u+XTf6z0=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
