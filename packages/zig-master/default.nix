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

  # Pin: 0.17.0-dev.947+36069a2a7 (2026-06-23)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.947+36069a2a7";
    sha256 = {
      x86_64-linux   = "sha256-XuEKXZ1+Osb57bsl5RsAwJEqn6pMVbJFWyokrIY15s8=";
      aarch64-linux  = "sha256-YfiSdmIM8Isy6XQkWzTLDjoQGiOHd1Si/VQsm/Dv15M=";
      x86_64-darwin  = "sha256-u8qH95N55LZDFFKHBwFST9QCDZL5HGKkbuq9nrWS9yA=";
      aarch64-darwin = "sha256-KDlNx0NrImhsiDRG+ZL7UdqjXzB/pZsNHsYZX0cVfBI=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
