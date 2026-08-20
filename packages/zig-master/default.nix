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

  # Pin: 0.17.0-dev.1818+7051f8e73 (2026-08-20)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1818+7051f8e73";
    sha256 = {
      x86_64-linux   = "sha256-XkyKzqa57qMpSAtQCtPOKK/1Ruic03J2tjBhQs9+59I=";
      aarch64-linux  = "sha256-bzYQJ40yibaVmfaakn5PYcUE4FVRUV3uHQxdHhGH+nw=";
      x86_64-darwin  = "sha256-agl7RFXRrozt9Uid7OODdWHWFr1SECcuX4Alt0FBlww=";
      aarch64-darwin = "sha256-smMV2DNIDM9db1ys++iKo4p4+7sBTuF2hgLE57Rm8ro=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
