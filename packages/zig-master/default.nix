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

  # Pin: 0.17.0-dev.2375+d8aab4878 (2026-10-01)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2375+d8aab4878";
    sha256 = {
      x86_64-linux   = "sha256-8Q4Fhq+0pXkSuS7CcfbPXeWttQdjXVMQHHs6JxP52yc=";
      aarch64-linux  = "sha256-E2gVEbpEd5+cnGNAKG+JM7NWzXCFhHKkNmjfr8S5HGc=";
      x86_64-darwin  = "sha256-O2DhwDRVeO6D6AyUZG/SYV3bE+ZPqXm3vVvV1HYHLRo=";
      aarch64-darwin = "sha256-JR7wxiPlKJb36UbcEE7HUvDe5PChfk3FbZr77pOaqrI=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
