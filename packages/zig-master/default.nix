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

  # Pin: 0.17.0-dev.702+18b3c78a9 (2026-06-06)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.702+18b3c78a9";
    sha256 = {
      x86_64-linux   = "sha256-RRAt+1rZtluy2t+LBfKJ9ofFaEUPrS/iL8m+RW+PEak=";
      aarch64-linux  = "sha256-aRJ8tnHu2lM9iKwOUx7L1pVrHBPcxBgi38x7E7YPTlA=";
      x86_64-darwin  = "sha256-YQIFxqsuheMoW78t8xp0bDIaXe9mzWQnVDvkbiUHdec=";
      aarch64-darwin = "sha256-+FHaybypJeKTT4+F/18XsZE6Juqm0b7kmZMXa88Dk/k=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
