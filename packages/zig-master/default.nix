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

  # Pin: 0.17.0-dev.2125+0d600e488 (2026-09-13)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2125+0d600e488";
    sha256 = {
      x86_64-linux   = "sha256-oYoaLnrldDCoZM3j+n1IsxlF++wWAEmIFeGZjnAqPpU=";
      aarch64-linux  = "sha256-zp9ByHbw7CpE6d3NatuONJ1ANbv/o0f4MtEBSMceNKw=";
      x86_64-darwin  = "sha256-12avp8WMPxzRLRah/CZOt/mg10ap2ZPF4Nz2BzU7Fe0=";
      aarch64-darwin = "sha256-6r+z/vTh5KnpsGa3d9G/w++B7YgvZ9/qx45bogs1OwU=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
