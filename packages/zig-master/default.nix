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

  # Pin: 0.18.0-dev.1005+75d48dfff (2026-11-11)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.1005+75d48dfff";
    sha256 = {
      x86_64-linux   = "sha256-oH7uG70k2/NOFgndyQS+xhCiFsCw2ZZUtal2pfZQyJU=";
      aarch64-linux  = "sha256-hOz2fPfeeKX5MbbxMzt56TMPg4aVsv3k+gMyxYpZrWk=";
      x86_64-darwin  = "sha256-G5pdlF/obWMD6phiL20URGn6fv/J6PZ8RASonOjxYSU=";
      aarch64-darwin = "sha256-NBVK+hU7lltph2t8dAbt/uxrVTAHK+Fk7JzFI5j3BW8=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
