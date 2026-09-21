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

  # Pin: 0.17.0-dev.2248+3f6a02acd (2026-09-21)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2248+3f6a02acd";
    sha256 = {
      x86_64-linux   = "sha256-w39wy2OamuANqtoE2DzU21GHk81M4U2eLTi9MwDWMUI=";
      aarch64-linux  = "sha256-eQzVuOVxiVIj+o6fgJCkMysd1ku3qOr7PRrbaJaQpsA=";
      x86_64-darwin  = "sha256-Ylj6mAOKT2s3uXS4RGEIlxeKxO1OgmEJQOh/QXRUzis=";
      aarch64-darwin = "sha256-mPr2t349aBuye9Zbgdz8GO4hxDfruTUE6xZzHGE/15I=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
