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

  # Pin: 0.17.0-dev.1770+5d7cf3f34 (2026-08-16)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1770+5d7cf3f34";
    sha256 = {
      x86_64-linux   = "sha256-8x8FRT5Fb0bZEOybk1TIV8OLOLjxUa8efWEXaZxmmDc=";
      aarch64-linux  = "sha256-LrIAiLxcPIO6/PUoEU5iOZK7ts+Cnj5L+Mwkm/IgB+M=";
      x86_64-darwin  = "sha256-wQXBD+6xVPlQKfu45N9Qr17+OVtUmp2fy7kb6CWTIs0=";
      aarch64-darwin = "sha256-KcFNaD6It8BqOmkdGDK+7fPsn2+siiclqhtSATul3M4=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
