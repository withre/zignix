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

  # Pin: 0.17.0-dev.1767+63cfe88f0 (2026-08-16)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1767+63cfe88f0";
    sha256 = {
      x86_64-linux   = "sha256-HFjdHQOwdBC7hlJA3ER5nNt9jr/s06nflCeUQEtlb8E=";
      aarch64-linux  = "sha256-fRZI1VnhzJj3+VTaKeEUU1mc65rSUYAmm1LC/BbgvUg=";
      x86_64-darwin  = "sha256-7Q80Gn5J4X1EbMK3Ho8XxKM7AKbXpsTpnRktN1ygWXo=";
      aarch64-darwin = "sha256-eEzZfHipmbAbb+zMTvFTQGVE2CZDw7107QShMUxnPeQ=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
