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

  # Pin: 0.18.0-dev.935+ead8f5a7a (2026-11-08)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.935+ead8f5a7a";
    sha256 = {
      x86_64-linux   = "sha256-diWESfEIi2+ANZlE+XNaTJbpQkblUxERVfCvZFf/jeQ=";
      aarch64-linux  = "sha256-N5Aukf+9uvPmK/lLo8dyHaE6fQ2/iaM3jTD1EA06wLI=";
      x86_64-darwin  = "sha256-lfSTm6SRlwp0ABwpG36I5z/zUF9akRXk6bmvbrn+xmA=";
      aarch64-darwin = "sha256-hpF+E7MxLTTw9Y0gaYankn3WCM4x8hcSys5HWAQ8gM4=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
