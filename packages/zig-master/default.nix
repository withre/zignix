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

  # Pin: 0.18.0-dev.852+efa5bfa9b (2026-11-03)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.852+efa5bfa9b";
    sha256 = {
      x86_64-linux   = "sha256-0oUNuObukb8sDxmzNUqN6Z+j8xmLTeoVfpWgaAD9Cr8=";
      aarch64-linux  = "sha256-0TKXTZyRMO8H4v8ZDb5kOo6Rpl9dD4DtxO6NXRyz5ag=";
      x86_64-darwin  = "sha256-V1wyJTG9jYC7HN7LVpZB/I67GnaOV9VEurEe6HaJe6w=";
      aarch64-darwin = "sha256-7OLzsN9MgQoE4dquoRP+xBr6BCBbp+ESFPH2qMeYOJ0=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
