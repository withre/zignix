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

  # Pin: 0.17.0-dev.1525+91c6d8a09 (2026-08-03)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1525+91c6d8a09";
    sha256 = {
      x86_64-linux   = "sha256-eZ2ef44wSt/4lgdfAXA25iFjkl/vUkWNqOCcDaXdtaA=";
      aarch64-linux  = "sha256-7hrmtisSdqh9uJtgxbTT1h90H8N1N/Ch3lj/G/buKfM=";
      x86_64-darwin  = "sha256-Rb102YtaGLwgYxYACqgGcReGT0GhJGXcQ4Tf03CyeIY=";
      aarch64-darwin = "sha256-fZsTtoCFcTOniG3Q2EDUqdnVH7tRkRByjQLK16hrKaQ=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
