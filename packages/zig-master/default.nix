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

  # Pin: 0.18.0-dev.1295+1fb0e6330 (2026-11-25)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.1295+1fb0e6330";
    sha256 = {
      x86_64-linux   = "sha256-QkBjPo8LMKwQ+CyoLbdRcjt0RSabLiNctEca6pn8usA=";
      aarch64-linux  = "sha256-zLPtt8PIuqYOZIRgzJmu0jQxMkwsktXwDyOGGPnJWWQ=";
      x86_64-darwin  = "sha256-ohX2IanpiP2add0VF5YyEUkXAzn8fvggh8ixFxtef8c=";
      aarch64-darwin = "sha256-rjHVy6cpXyn+9pVdG46Krcbb0hNFCOOtEQU2fo/RMWQ=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
