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

  # Pin: 0.17.0-dev.1936+5a625d5f3 (2026-08-30)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1936+5a625d5f3";
    sha256 = {
      x86_64-linux   = "sha256-OGIMBspXsXX32rj2XIAB+aZ7D/GYfDRNTmTMtytXF08=";
      aarch64-linux  = "sha256-bFWf9Lyj6E+797athSHOcLs+RgNxs9iAMRI1P7jOcMw=";
      x86_64-darwin  = "sha256-irnw0BWrt1wMnAOfcZFxGnovxyyYRFj1U5JnJXlHkd0=";
      aarch64-darwin = "sha256-4I1EhcltLTGozjroCli63sICkgtnUUmtaww7l07HwAU=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
