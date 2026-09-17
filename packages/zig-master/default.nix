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

  # Pin: 0.17.0-dev.2151+2ec5523d5 (2026-09-17)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2151+2ec5523d5";
    sha256 = {
      x86_64-linux   = "sha256-Y5OBi34xi9T/o0WnNqCS14Dfm6JXsue1bNY2anpAWEs=";
      aarch64-linux  = "sha256-TBAjkHMhrf3JDwR/HPeLfmBHU17RjcZEoZpIh6NVFtE=";
      x86_64-darwin  = "sha256-85Lzd7H33C3DejQN3nDahZ4ISx21R/lXISXE5taERYY=";
      aarch64-darwin = "sha256-01qBEoiFUasTyBgpjLsQGkqVjom/5SNKe8JjIfsOfvs=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
