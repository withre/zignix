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

  # Pin: 0.17.0-dev.1099+7db2ef610 (2026-07-01)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1099+7db2ef610";
    sha256 = {
      x86_64-linux   = "sha256-jzDYQFphI/DHERyKTFrufnMBcxNcXdzJQkUnpDxbvXs=";
      aarch64-linux  = "sha256-F006L2fDvAX6R7lQnM00Dy8C+Vlm6SNGx84eZwqBLWY=";
      x86_64-darwin  = "sha256-k2mawsPJ63rN7tKRS0NhzaWtKdQKIcVVD9iiuFljlVs=";
      aarch64-darwin = "sha256-gpgiOmFQ+0LCkqsqt5NAWq+nR1SKEzq4wVy7zT1AEuM=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
