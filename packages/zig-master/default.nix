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

  # Pin: 0.17.0-dev.1893+78e3b1c73 (2026-08-28)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1893+78e3b1c73";
    sha256 = {
      x86_64-linux   = "sha256-VvrUoSJwnTpdC7HTTqJyZjOHDqMU5yagpxdNwp7ZXkA=";
      aarch64-linux  = "sha256-y1XcCTVJDct1K+1aPTESmDK91p2DsvNHcahlqaedci4=";
      x86_64-darwin  = "sha256-IYmc8z2koCZWGzTevxP5sAVf7jUTRE4K/p4qodQtQWc=";
      aarch64-darwin = "sha256-EjwwBa4wU3qxcxrD6M80/DSnivwxL7x4KtiTexSGpjo=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
