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

  # Pin: 0.17.0-dev.1426+58a94eaae (2026-07-20)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1426+58a94eaae";
    sha256 = {
      x86_64-linux   = "sha256-kSgb896qHYBVsK17OxDCnn8fnbZm+19RgkQLHx0+cis=";
      aarch64-linux  = "sha256-M3xexGOH7AP8+73yyny/OG2My19H3RwfovH0xVg8OtM=";
      x86_64-darwin  = "sha256-9dKxzfwEghQxb6W56MkVqrgCp7rTLZXieJGL5DlTj8s=";
      aarch64-darwin = "sha256-zxOMYUrZFvt8DDUH5dXVTre8RWlXhbxj2ft/QQfRLso=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
