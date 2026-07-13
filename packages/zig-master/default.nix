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

  # Pin: 0.17.0-dev.1397+4331ba0fb (2026-07-13)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1397+4331ba0fb";
    sha256 = {
      x86_64-linux   = "sha256-dMcST7af0xvtD2E/6Tihl5QlWJof13uqT1UBF/7kf2w=";
      aarch64-linux  = "sha256-5FivSvKvrOiy1pp96LF8vkU3vkgEyYMixwPZjeVpFTU=";
      x86_64-darwin  = "sha256-v+Y+f5IfelAMkEylJnC+thqwf8oD7Ma2Q5b6WkAFn5U=";
      aarch64-darwin = "sha256-Anp1HJlLXU5ljAmZw09dcEgpqi2/hiF4s37n/T3eGIc=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
