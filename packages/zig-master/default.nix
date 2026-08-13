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

  # Pin: 0.17.0-dev.1737+de207594e (2026-08-13)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1737+de207594e";
    sha256 = {
      x86_64-linux   = "sha256-po35VEnhUteK05QGQ/sWuSXSc0ERZClc+hKkYh6Fsdo=";
      aarch64-linux  = "sha256-frRTxQlT4W1qorW3vM5lFJH/8lrqQxNVn2hbla2LvxU=";
      x86_64-darwin  = "sha256-168YaRDqcYeosoNJd7e59le0esqVISDCvygLKhShNLk=";
      aarch64-darwin = "sha256-ePufDg8Z94muReisXRxWuISZ4NR2rAjwBLot5Hd+H5E=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
