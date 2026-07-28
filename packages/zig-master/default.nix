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

  # Pin: 0.17.0-dev.1471+ff10b90bc (2026-07-28)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1471+ff10b90bc";
    sha256 = {
      x86_64-linux   = "sha256-YNg+QpW3BXo4LsjbxBaw3FmRiBjAtQELBJHOxlzNmU8=";
      aarch64-linux  = "sha256-afTxNGjdo9BsioFVvbjpNHQmxlSLGYkxQ/DagweDej8=";
      x86_64-darwin  = "sha256-3cptKGPlgxGQvzAR6r/bXvGczUGfxJEPDc3xv5HzODk=";
      aarch64-darwin = "sha256-NUSCqvJLan9p2LgYOZnCOxhMbYC5PPf2KZWRny7m5kI=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
