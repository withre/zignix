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

  # Pin: 0.17.0-dev.956+2dca73595 (2026-06-25)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.956+2dca73595";
    sha256 = {
      x86_64-linux   = "sha256-EdmV9H+EfDOUu4VV19iEHmhqxqyMUhyM5ipmFubrC0g=";
      aarch64-linux  = "sha256-LARYO4OqJe82As0m+3tjqLq3h7JaHnMa4Md1KKg2BS4=";
      x86_64-darwin  = "sha256-sfe5PgLrh49I5ztvRWf6VE6DvfkeI9BDrmn+qDZ9mBg=";
      aarch64-darwin = "sha256-e4XhJu2pxkCFy9Y0NgVcxOBTW3Q9jHU5GPzJS36ZO7g=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
