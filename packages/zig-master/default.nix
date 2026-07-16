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

  # Pin: 0.17.0-dev.1413+addc3c3b8 (2026-07-16)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1413+addc3c3b8";
    sha256 = {
      x86_64-linux   = "sha256-cwWaeLlvIWkaQtga2WTBk4pVqSqmXUe3lyXUoKXh7BE=";
      aarch64-linux  = "sha256-khp54F+Opy5SxtOpIs4chYI9+TCnpcVwpMmnh4Na2CE=";
      x86_64-darwin  = "sha256-ldddbDfzGvDHY52KAbYWpOXNkctg5uNVAIe7duIez0M=";
      aarch64-darwin = "sha256-d6oMbDcZ6+DCyUtdB5QdGyiV6Ns2Ft0xBz5pLJsJTHU=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
