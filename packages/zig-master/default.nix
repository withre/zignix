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

  # Pin: 0.17.0-dev.2307+392b17125 (2026-09-26)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2307+392b17125";
    sha256 = {
      x86_64-linux   = "sha256-oOVZhrbbQvb4G3C8LA472I5tgE/6pOzEluZh7QXmkI0=";
      aarch64-linux  = "sha256-54LO0wCOiY0BSXNxM4UHVtKemUerlhwf/poz0ehuvxQ=";
      x86_64-darwin  = "sha256-yl1zUKHdXEgB2ZvqkzPvA4r6rafoNg3xvuIDMymO7v0=";
      aarch64-darwin = "sha256-T1bxSjqCnW2/g8ISyKaDs0JVmpumJqCRSVY2owUkz5Y=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
