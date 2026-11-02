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

  # Pin: 0.18.0-dev.828+9da287565 (2026-11-02)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.828+9da287565";
    sha256 = {
      x86_64-linux   = "sha256-w3Oyi/H7VuGw9ecGtamEw1UD6k8P02Y4vdgeqMTEcJU=";
      aarch64-linux  = "sha256-Xg7z62+NXUee2X6lGxANy25h/2XM+ANCmfbI49rUq2U=";
      x86_64-darwin  = "sha256-TA7crUzaHE29K1T7a/T8nUZh7zG2XY4uXvUyGBjdBMI=";
      aarch64-darwin = "sha256-pVR5D7HOKUXE1gaj+7QOhvycu0hFxqj1bRVhkNYOXY8=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
