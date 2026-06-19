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

  # Pin: 0.17.0-dev.892+54537285c (2026-06-19)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.892+54537285c";
    sha256 = {
      x86_64-linux   = "sha256-B2liSaBzEsKejObNdASVUvz7f8bWeXMMS2w8P0OUhFU=";
      aarch64-linux  = "sha256-knvxBoacbu3YcjTNzTrQJVDW9BE/5vzWJODGGfUPz2Y=";
      x86_64-darwin  = "sha256-EynUvLJrLbCAGlNcx5h4nzf8BYJcHZQuObWEsNu1BPI=";
      aarch64-darwin = "sha256-1JIB+Tie9X6HJYERSXldmYSQ/y/6CzeUafzdwDFnKMw=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
