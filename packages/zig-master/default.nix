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

  # Pin: 0.17.0-dev.1158+1d1193aa7 (2026-07-02)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1158+1d1193aa7";
    sha256 = {
      x86_64-linux   = "sha256-5f8vznHLGV3/YkK08TbfPuGKfkVrpTM8AhbLWeN2NOs=";
      aarch64-linux  = "sha256-NnVtOZkVZ4pXLWzFZQCKm2tGmkAEr0nv7OIF8Trax0k=";
      x86_64-darwin  = "sha256-UR+t8WViNoNBlCnp03pJKEyZKds7J0agwfors9rjBuU=";
      aarch64-darwin = "sha256-bL6LXyM+N5TkQMdq5WXIj6nxLjlBBtijTby+LWWesrw=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
