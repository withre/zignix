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

  # Pin: 0.18.0-dev.543+fa4f5b262 (2026-10-24)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.543+fa4f5b262";
    sha256 = {
      x86_64-linux   = "sha256-TcgnDyjmfYwku9diO7iSoHo18c58P2Su5icogf9urR8=";
      aarch64-linux  = "sha256-P2PRbDG2Ogl0yUEiHhh6ws9wa2yeFZLZV2JOcAwfYok=";
      x86_64-darwin  = "sha256-Byt0zj0hqBciwvUKtB9zajQ1BPMNbQuq/fRpy2dm75w=";
      aarch64-darwin = "sha256-ddV86FNsFh6gcG0uSfq6/QiwFGXyoTkx1mSS9UI6Gz4=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
