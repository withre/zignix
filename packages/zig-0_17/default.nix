{ pkgs, system, ... }:

###========================================
##   Pinned 0.17 release line
#==========================================
#
# A worked example of `lib.fromTagged`. Tracks the latest tagged release
# in the 0.17 line. To bump:
#
#   1. Pick a version from https://ziglang.org/download/index.json
#      (a tagged `0.17.x` key).
#   2. Convert the matching `<arch>-<os>.shasum` to a Nix sha256.
#   3. Run `nix build .#zig-0_17` to verify.
#
# This is kept current by scripts/update-zig-master-pins.py alongside the
# master pin.

let
  zignixLib = import ../../lib/default.nix {
    inherit system pkgs;
    inherit (pkgs) lib;
  };

  # Pin: 0.17.0 (2026-10-16)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0";
    sha256 = {
      x86_64-linux   = "sha256-HL6d+fJ+a3jRTMvKQ7ZwOkBO957xxGPekB1/CI1OICY=";
      aarch64-linux  = "sha256-no0RZh1K471XcCo4MngeI60VHd5XmOFqXM1QP2UjT/g=";
      x86_64-darwin  = "sha256-T5ocUmmqF+vaXm08K4nWy/NvfSsioDBumrmPJflVKcY=";
      aarch64-darwin = "sha256-tgfpuSNHkKAIEWrlvbccYkO4S5+0KlOp5w/eQcBsU2o=";
    };
  };
in
zignixLib.fromTagged {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-0_17: no pinned sha256 for ${system}");
}
