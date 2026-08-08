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

  # Pin: 0.17.0-dev.1622+2b242157b (2026-08-08)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1622+2b242157b";
    sha256 = {
      x86_64-linux   = "sha256-m95GRejZGOqoQL/MHIz6m2Vny2EvfV/kSWJE6G3ucC8=";
      aarch64-linux  = "sha256-0cdv6ipo2yGBVz2AuPr+uQcW0AcCVPT0n42Mv+0pS58=";
      x86_64-darwin  = "sha256-HgczSnsTFhi/moxIm9bTHm+4Y5v5Wlp+q39iIep/N9w=";
      aarch64-darwin = "sha256-M/W0CNscKZNXOrjuad5bJ/au+xTXfB/gYdXaVOq0ysk=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
