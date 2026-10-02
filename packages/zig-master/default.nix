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

  # Pin: 0.17.0-dev.2384+ac77c23af (2026-10-02)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2384+ac77c23af";
    sha256 = {
      x86_64-linux   = "sha256-pBepKms6+XjptfzIqxs25k4RHR+O1Q/xeN6SkQ801lM=";
      aarch64-linux  = "sha256-DishfbE7Rpxgs+d7XaqVLAQ+UjQzl1E5a4jWnV57frw=";
      x86_64-darwin  = "sha256-4a835fvoNzauymgsaR+xAh6HMzkYCn8YfeX4SpSdlkY=";
      aarch64-darwin = "sha256-ii8P0PktCfMKVa8M3dN/Sl6TVKvboNwpTF6ZiTNib6o=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
