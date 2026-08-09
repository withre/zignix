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

  # Pin: 0.17.0-dev.1640+2597da025 (2026-08-09)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1640+2597da025";
    sha256 = {
      x86_64-linux   = "sha256-tfiIBtMgot2gt5fWDmNqVSVul8HStkRShkfFbXNxc3s=";
      aarch64-linux  = "sha256-FW2zXmIx2YwBJ0a/lNvRWkoBkonRm+7F1DBULxK7QXw=";
      x86_64-darwin  = "sha256-Ew+Ef/2NOL8TRfasMG9USHnLoTTCDk68k56ayfv1IIs=";
      aarch64-darwin = "sha256-SiPOuZttXHcH2ydeMJL/MmWdTWqTteh6RN2FFMEXq80=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
