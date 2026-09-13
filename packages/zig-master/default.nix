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

  # Pin: 0.17.0-dev.2127+e90365cd5 (2026-09-13)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2127+e90365cd5";
    sha256 = {
      x86_64-linux   = "sha256-cZ9WEv3bWO78M3NWluO1NADyeU4rUyR5bcT5ThL9XwU=";
      aarch64-linux  = "sha256-xTsFwW/KnIVVi+WPVBrhb4fzZxW5Au1nm90NxgE1A20=";
      x86_64-darwin  = "sha256-RuXGaNSgP+65L4hHbMWut6lamQIlGuXHAmiQc1ffOXs=";
      aarch64-darwin = "sha256-W47Xx83ih32xV6wlRBcEYe4OrzgjWmj1GQfpvBERgq8=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
