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

  # Pin: 0.17.0-dev.2018+ab30a0b9a (2026-09-07)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2018+ab30a0b9a";
    sha256 = {
      x86_64-linux   = "sha256-fVkcQbKbRjwiZmG7u05PlWdu2TGKMfe/r8GZXGmpkSk=";
      aarch64-linux  = "sha256-JapohSWll+4QzxuvwVmYf3+Z5L90hKsYRCy1W3DKhkE=";
      x86_64-darwin  = "sha256-ZLBVwfAEFPg6kiblkgWNoE40nsAZ2VvDYLC354QkWtk=";
      aarch64-darwin = "sha256-BGIkUwx3IhujVSGxJ+JnzsTsC5jm78pbhP0Sd90Vezs=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
