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

  # Pin: 0.17.0-dev.1422+e863bf3be (2026-07-19)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1422+e863bf3be";
    sha256 = {
      x86_64-linux   = "sha256-ApsUzZvISzD3dmwOxWjSFMpM42BJdJt42es3u29OKM4=";
      aarch64-linux  = "sha256-RJxQeqi+LQxM8gZTzKIlayeJOJE8GD2FRBpSlkkFTEk=";
      x86_64-darwin  = "sha256-/DAUSKG4NoQJS+o+0zbOfDo/LIlYDwiIGKA5rDvyE5w=";
      aarch64-darwin = "sha256-g21WyrtI9MklDZrRIjTZWVpkTQPILEcnmSUjHmq4WvA=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
