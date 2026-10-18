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

  # Pin: 0.18.0-dev.349+d924f83bf (2026-10-18)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.349+d924f83bf";
    sha256 = {
      x86_64-linux   = "sha256-N3da6bZVDwJkKl5SwkqlnwOsoHJshtrhU0mc2/jg7X4=";
      aarch64-linux  = "sha256-7/NU7cXoKQ0t8UQqiGH029v4JcQC4Y6rZuovHAN1lpw=";
      x86_64-darwin  = "sha256-N5Qo6D9FPGZ5xe20UuuClUAREMWqDM9r/Ig0Ukz/DBI=";
      aarch64-darwin = "sha256-yP/aRYp3CGzzuaasfAkJtkIz3x1K9zGrMqfxAZ33rqQ=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
