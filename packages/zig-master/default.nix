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

  # Pin: 0.17.0-dev.1963+e00c6c439 (2026-09-02)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1963+e00c6c439";
    sha256 = {
      x86_64-linux   = "sha256-2SAmiPxH+TH9ZMx3sZhBKwcLIaNmnQDsRptY3zVQHn0=";
      aarch64-linux  = "sha256-Oag/rQyG3fuUfFl7XQ+3JTYlTwZ3K49rRGTCLPuUoEc=";
      x86_64-darwin  = "sha256-0ieb/z4J4ZRzh3qWkGKVFFziN9slJ4rFOJbSedJc1uQ=";
      aarch64-darwin = "sha256-veHkTlZhBBAULW/PRZJb+U6jEADFw6e27pWDnn0mxE4=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
