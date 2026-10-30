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

  # Pin: 0.18.0-dev.753+1420479be (2026-10-30)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.753+1420479be";
    sha256 = {
      x86_64-linux   = "sha256-MxuHQ48n12ZQyehSa4Rg9RPUW77I5mFjSeowYy8rN6Q=";
      aarch64-linux  = "sha256-XJPYTtMfNNDPYYdQBTD6CewPeTFnMnNchg9MaaGc7hA=";
      x86_64-darwin  = "sha256-aLUdtdbaVcDE0LCkf/WX8FzjVv6ND0hbNwX9/zYFE0Q=";
      aarch64-darwin = "sha256-D5Yb7GsFEuQDJg07hbn1q+hkmQZYUgn86qVll7U4gpA=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
