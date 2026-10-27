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

  # Pin: 0.18.0-dev.624+b7f2c6d8f (2026-10-27)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.624+b7f2c6d8f";
    sha256 = {
      x86_64-linux   = "sha256-n4Iz7fOZUQEQjjnC3kSzg0d1DWwWnmh50fz69OHAwvI=";
      aarch64-linux  = "sha256-lDHaCO3xVLV8RaHb2P81MsDGVx4RvQ76FELOarxgu64=";
      x86_64-darwin  = "sha256-sl55co7QzBmQODjC9YbdQWlT6YxPtQsi5/uyHtgSiMI=";
      aarch64-darwin = "sha256-VIqSM9iu6bhTT5oIlMupkuol80Tt+VttWsUzON7j/r4=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
