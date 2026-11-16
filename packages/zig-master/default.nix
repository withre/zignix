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

  # Pin: 0.18.0-dev.1156+0aab22eb3 (2026-11-16)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.1156+0aab22eb3";
    sha256 = {
      x86_64-linux   = "sha256-a+0u9c8ZsNq3NRnwNhdtwiJuhOEQZpJPI11a4+boc8E=";
      aarch64-linux  = "sha256-ZzG3Yv+PQ0cRoIJRr9+rPds5wL5TkDPi6x5jWiTtE54=";
      x86_64-darwin  = "sha256-tzk0BumTpTDKHPWRKFlRFej0rWfGFa5zV/1jwQUO9+U=";
      aarch64-darwin = "sha256-REXpJrT3XE4DXJQlKTPS06dvTaaaxoV5mw0R3Ij0y+A=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
