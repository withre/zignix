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

  # Pin: 0.17.0-dev.1267+300116b02 (2026-07-07)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1267+300116b02";
    sha256 = {
      x86_64-linux   = "sha256-lwhZDEdhqPs3sS9iQD0P4naMU4D+yxBgQZkOM29fTK4=";
      aarch64-linux  = "sha256-jC/6EBhdlX1DvDBfEjU/WYJK9D8vg3rtw97tOjgYANo=";
      x86_64-darwin  = "sha256-eyawhm/QGn7xPvVtAVGYgu+ga4aFhW/V78SMFtwlxKA=";
      aarch64-darwin = "sha256-oFbjkSw85IsfQ98q84lo//nu69DQKK8x+zH+dNsJ67s=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
