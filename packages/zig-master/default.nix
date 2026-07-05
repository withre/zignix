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

  # Pin: 0.17.0-dev.1252+e4b325c19 (2026-07-05)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1252+e4b325c19";
    sha256 = {
      x86_64-linux   = "sha256-2eYHScUuF0ZNQbeh3F2kbEv/t7MXGx+sZ4K8LsPiiXc=";
      aarch64-linux  = "sha256-7EJPUT20msNBN6E5FFu5LTIqBl02b6JZ56kxwWGiemc=";
      x86_64-darwin  = "sha256-Fpg2GA8fG77Dp0JKW25jc5NO3hS/u6/hzMUgj/LR0vY=";
      aarch64-darwin = "sha256-ww+QRG7SPUWf03dIDsjGBhk7tVyVMSVJ02hE55hU3ic=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
