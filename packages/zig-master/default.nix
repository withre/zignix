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

  # Pin: 0.17.0-dev.1441+d5181a9c9 (2026-07-21)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1441+d5181a9c9";
    sha256 = {
      x86_64-linux   = "sha256-udKwaOQkWz3kseOstDohTkbzZqfLx31XPtwUJaRAPN0=";
      aarch64-linux  = "sha256-dp+MuMFL15RRC3OackfnN+zgYr9LK2O4uOQVTFTMPpU=";
      x86_64-darwin  = "sha256-tB97ftB22Eyy+XlDFvlHAXryayf1wR1dW3NZQmErTMQ=";
      aarch64-darwin = "sha256-Q1HlyX2qGuTrps999NGUtfZMbUUIhhNLNrFIoerXDH0=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
