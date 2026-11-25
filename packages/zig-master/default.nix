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

  # Pin: 0.18.0-dev.1279+81de6a1c6 (2026-11-25)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.1279+81de6a1c6";
    sha256 = {
      x86_64-linux   = "sha256-k5s+K9S2iW5d51yG+j5bx+ROMaVA2/dpNydI6EigWxk=";
      aarch64-linux  = "sha256-75yn8M+i3O7i3/LcxI61HGuLVQlPH4OVr5ymuKJtDJg=";
      x86_64-darwin  = "sha256-8bEu0hEkBLQE+8BECx5blv6ylvgxJG+FrSe+N5cy8cc=";
      aarch64-darwin = "sha256-yh35btpD80JZfmWwKmSr+4EMQ/pmEaTITa2qAANDeAA=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
