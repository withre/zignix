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

  # Pin: 0.17.0-dev.2163+89ff10d56 (2026-09-18)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2163+89ff10d56";
    sha256 = {
      x86_64-linux   = "sha256-nNkHDBMjcCAvV5J3f5V6w8wU2wY1ldsMOr7euvMWqhI=";
      aarch64-linux  = "sha256-BNzYlB5rIOqGAkhPYK5MaYrbgkD4dOfMQhACwO8tC/s=";
      x86_64-darwin  = "sha256-mk5O89vqqI7TOyKWg18bYaT2bL7e9IW/q5W4PhBy/g8=";
      aarch64-darwin = "sha256-lhO4Z/IYohvndg9xTPs/GM42/shdIFH0wmNitJXy+s4=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
