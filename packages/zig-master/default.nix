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

  # Pin: 0.17.0-dev.1609+11e2bb391 (2026-08-08)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1609+11e2bb391";
    sha256 = {
      x86_64-linux   = "sha256-vhmyNMR68B8DM/y3ISpZhAwro1Me2TdM15s2lcSKZsk=";
      aarch64-linux  = "sha256-xsJdojCHI/otlWyfIQAjfWmq3TKXwoaFHskoovwwm1Q=";
      x86_64-darwin  = "sha256-6rI1DY8JUEzgoS3DjsT3aQoKzNFt8DAyfje9SohPmus=";
      aarch64-darwin = "sha256-ex4pKCjTPE8fwsoELIS2vZgLVuD7Y48x8RGAnSQ9co4=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
