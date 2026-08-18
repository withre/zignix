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

  # Pin: 0.17.0-dev.1778+767d25269 (2026-08-18)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1778+767d25269";
    sha256 = {
      x86_64-linux   = "sha256-2DJsvXT4SlTXB91WJgTw0iHFNtq10DSXK5wx1jM/TUw=";
      aarch64-linux  = "sha256-RqWr5cJqinCtGeVJyc21mNzKFDTNV8Rf4UwNpq2Jru4=";
      x86_64-darwin  = "sha256-ov1zw/zfWU15oy6fbKgE1OP0YzcE5VA95R29Wz5AucM=";
      aarch64-darwin = "sha256-nWSew6tjmi6yWgEzPHMitDLbBXjJz/LbT3nLMN+1Wwc=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
