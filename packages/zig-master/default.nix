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

  # Pin: 0.18.0-dev.954+60635c2bd (2026-11-10)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.954+60635c2bd";
    sha256 = {
      x86_64-linux   = "sha256-6uAxzwA1Ude9fGua5eK1lGZ/kTiOxw7z/dKsFg9NPc8=";
      aarch64-linux  = "sha256-uC8jHVnsI7fxEw5highnMFw7Rox2wKlyNA1CCccCpik=";
      x86_64-darwin  = "sha256-qRPdDaONnrwSIZrsbDasd6pGb/wbQRIfdxD36LORNuw=";
      aarch64-darwin = "sha256-MFhltnnHpnCW42BVyi3M1VXw6twqM1YF31oicJSktYQ=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
