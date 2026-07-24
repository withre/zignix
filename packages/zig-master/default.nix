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

  # Pin: 0.17.0-dev.1454+5faa79730 (2026-07-24)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1454+5faa79730";
    sha256 = {
      x86_64-linux   = "sha256-VVuJKHvj8YfzimqXJ4AZhsUUAt7zion0Smz0BNvng3w=";
      aarch64-linux  = "sha256-W7sY2k/6ZmosQtL6wgnUa2WKflD0dl8mq9Oh0eLKHlc=";
      x86_64-darwin  = "sha256-eyiZ5VJlq/ODH97ppGTL+RXkwFCo6RgaaDo5NKivFR0=";
      aarch64-darwin = "sha256-84hk14A2dmRCbYujuH2rIAXZyhrdVVijIdYhGLqHuWs=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
