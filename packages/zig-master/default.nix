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

  # Pin: 0.17.0-dev.864+3deb86baf (2026-06-16)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.864+3deb86baf";
    sha256 = {
      x86_64-linux   = "sha256-UndSpOYV3WeiznMyRq7DC9MwO4uVlTJUCWP5AMJ/lLc=";
      aarch64-linux  = "sha256-WLu97MCwAImr3H8AaxwtxmDkv5Ru2pSktmGPb9ZYW3U=";
      x86_64-darwin  = "sha256-SOsyyX4RySHE/RE5vRXC6zOu6prwA5R2h3PQ19NhEHE=";
      aarch64-darwin = "sha256-QsS6QPtrrU4JJxddR8bTxgoXTelRg398H+A8yfF3340=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
