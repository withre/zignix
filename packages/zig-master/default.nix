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

  # Pin: 0.18.0-dev.1153+c62948217 (2026-11-16)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.1153+c62948217";
    sha256 = {
      x86_64-linux   = "sha256-64MlCjl+4IoL7D4D1B+7qU1ve1MH0THyrP0IOYl2ZIk=";
      aarch64-linux  = "sha256-ayIyQF0Gzgps8OH7kIrE+x7EFQ/hnNyTzIa7xr0JC0o=";
      x86_64-darwin  = "sha256-K91LXTS/PCN9PWI0JyMbwncSUg0zwLh8droOKWFcWNQ=";
      aarch64-darwin = "sha256-0V9jazZ1xPtPlzv8roEYknNnZ296p7O+IOCaRJCwxZ8=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
