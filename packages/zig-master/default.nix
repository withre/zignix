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

  # Pin: 0.17.0-dev.1387+01b60634c (2026-07-13)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1387+01b60634c";
    sha256 = {
      x86_64-linux   = "sha256-blfC4u/PbGsgJgllUX7BIny1bjRQawZ1mwYmVKb1HFI=";
      aarch64-linux  = "sha256-gCSfKilWtlZIZoNCA2wiknCV8kLANfzd1v2CQ/0997U=";
      x86_64-darwin  = "sha256-dp78q5k7lW+RwdjZiQI/m3TIOeohm9wItkKSDw2WTSM=";
      aarch64-darwin = "sha256-ivHCRxX5QC/2AbH3uT6HS8RGFXALgwrdyIuSuDrrig0=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
