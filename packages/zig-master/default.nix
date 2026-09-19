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

  # Pin: 0.17.0-dev.2228+955228b68 (2026-09-19)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2228+955228b68";
    sha256 = {
      x86_64-linux   = "sha256-e6En5zrer9Ja7moWzGAISGyT6g/Oxb/518awNXhbIsM=";
      aarch64-linux  = "sha256-3vooihjKYhZNYrQFp4viLt4NCCeEHC8GBiTQ4VEbqWw=";
      x86_64-darwin  = "sha256-qzSTgndt9ExvzXYnjIx1CnZQAL3MXC7cDw/VJVe4tp8=";
      aarch64-darwin = "sha256-Q6iCrEcE0waFko08Tzx9YrTOKGqHXfiLwLIGkxvQsNE=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
