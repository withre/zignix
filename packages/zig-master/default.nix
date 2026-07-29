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

  # Pin: 0.17.0-dev.1476+91a29d707 (2026-07-29)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1476+91a29d707";
    sha256 = {
      x86_64-linux   = "sha256-IJynJW61TP7x5gcEPQkcqZehTG4ZFUblLxje0J34bsE=";
      aarch64-linux  = "sha256-tu2hmCf6ZgiA5DfOeUY+zRfH5TIlJEfIM5JVlnX2uRc=";
      x86_64-darwin  = "sha256-bkC/nDLk8H4S8mtK8eUdz5UR5TTaGTu4B6JFlNQftq4=";
      aarch64-darwin = "sha256-51sNl4SxKTywiuPpqp7dfuIBKrtBOOPSocknhw1i98M=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
