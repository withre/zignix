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

  # Pin: 0.17.0-dev.1970+67f39b551 (2026-09-03)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1970+67f39b551";
    sha256 = {
      x86_64-linux   = "sha256-h4MjoquvwQF0HOSPavmDIXcmn2wyYczB0icttdGoOrI=";
      aarch64-linux  = "sha256-fzti19Mbr3saajvqx7WmdmTQzQRJawv2fkdg+pnuA0w=";
      x86_64-darwin  = "sha256-bmEx+AuSteR8RU4sXy3Wl8EmNOqlwQ7/McgevSm2Mws=";
      aarch64-darwin = "sha256-C4z0f0BCoaBD0+r+G69rEvPDROCPwFd0NLnwKAEq8B0=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
