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

  # Pin: 0.17.0-dev.1745+ac8a8d0c5 (2026-08-14)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1745+ac8a8d0c5";
    sha256 = {
      x86_64-linux   = "sha256-9wemydMhGuAXywds2ZISqH1E+QLWF1FlVWJfG3iem+k=";
      aarch64-linux  = "sha256-BK5Q3P/EhuSWrqA48lqFZsvILroyH9mwKeF/XgzyptU=";
      x86_64-darwin  = "sha256-TKA411MH+zVTCE9/+N1Ww1JNBgffce/34q/pH/WJST8=";
      aarch64-darwin = "sha256-RRZoi9Ch148PoX5ahET1zoakMj/dab0Pp8BuGFWsbcY=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
