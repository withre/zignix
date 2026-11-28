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

  # Pin: 0.18.0-dev.1335+e73250965 (2026-11-28)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.1335+e73250965";
    sha256 = {
      x86_64-linux   = "sha256-sl68jpq2glaWj4zxUhFs11SavHv4IiobpTsOQIvBRZg=";
      aarch64-linux  = "sha256-nkDZmZi8kIfmQkkGUZyzzNZeHuPn6XewCH2lPaDZMrQ=";
      x86_64-darwin  = "sha256-9ofy0M0TAC5vtC9Az7aRibGB6TBY+W0EkHDdosKd334=";
      aarch64-darwin = "sha256-12eU1qH9rKHHtNrMZAoU/1Stzfhjbp9/E7oFZlOuYa4=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
