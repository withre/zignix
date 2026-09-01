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

  # Pin: 0.17.0-dev.1946+d813faaf0 (2026-09-01)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1946+d813faaf0";
    sha256 = {
      x86_64-linux   = "sha256-5d2wnnNiqnjjM/S9+nlrXH+3qZuOaL3ZuAS2WDHtitw=";
      aarch64-linux  = "sha256-T+8N55X51909N+V3xs4zW0OvYNF2BJ41vGi4jz0YalE=";
      x86_64-darwin  = "sha256-N1O3ThatQkvvfShUUUqdvtoRkjfjr1dlKPzeXmGwyGE=";
      aarch64-darwin = "sha256-TxFhuhUsWfvSfi5Uh7VfK2YSQeb4U5s3QgDDhOqIt84=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
