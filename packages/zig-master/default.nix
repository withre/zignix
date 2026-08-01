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

  # Pin: 0.17.0-dev.1509+bb296ab9b (2026-08-01)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1509+bb296ab9b";
    sha256 = {
      x86_64-linux   = "sha256-SMyGW4tBDshOqpflDCvXpleHGALOOqrwTdHaIpTUsoo=";
      aarch64-linux  = "sha256-fxfgm2dc/jmAXFtVGyURUfd1C534oWhTgAeJDBwA3I4=";
      x86_64-darwin  = "sha256-CHqtOP6tbAunpStds8QF5jcIxHZe2mQ9QUS55JM9ReU=";
      aarch64-darwin = "sha256-JL2DwdQ1uKthkvWK/MIvTlJSB3qTj/vDXqpMqXxb5wk=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
