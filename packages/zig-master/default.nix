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

  # Pin: 0.17.0-dev.2131+d08989840 (2026-09-16)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2131+d08989840";
    sha256 = {
      x86_64-linux   = "sha256-5gP3slbXjR84meg2JLYJtcsEZSw2QQlIkjE3aVUVh7A=";
      aarch64-linux  = "sha256-OcTAsN4nsWE5msy02DT9rvHc2pRor1tH4XI1HXUSXlM=";
      x86_64-darwin  = "sha256-uvmowp9axMdTHukSvYv2HBTgTjjd7t/ETz1vgO9Suwk=";
      aarch64-darwin = "sha256-JO9rKi7ixpzqL76RMfGPHxvNhtioXUUXR1ECS0Jb4Bk=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
