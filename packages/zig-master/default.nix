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

  # Pin: 0.18.0-dev.610+720939f8c (2026-10-26)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.610+720939f8c";
    sha256 = {
      x86_64-linux   = "sha256-HuoVuR1pkLKtrjMEsJZbdbK6Fgdqt64pxjqzEDxVFaQ=";
      aarch64-linux  = "sha256-qS442h8vep0cgSAJ4w7b/rmet3I1fbIVgTmCxVdxj5U=";
      x86_64-darwin  = "sha256-5WLJqIoMqWdzLj/INcV7lFizLNPK8BKaElEfx7T6zlc=";
      aarch64-darwin = "sha256-aqLCw8L+jVQkMMBqmQuMsKKYjd2RhW4djvKywqDDe78=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
