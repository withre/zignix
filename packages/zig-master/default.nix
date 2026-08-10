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

  # Pin: 0.17.0-dev.1662+cc6f42302 (2026-08-10)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1662+cc6f42302";
    sha256 = {
      x86_64-linux   = "sha256-WnrLz2gnlaFPrRPqwD7GfWNLeFoYGhyiGDX3YAKRst4=";
      aarch64-linux  = "sha256-DI71c94ul2xNzZz1wYpotTkbYJklZNDxDWxJW111Ztc=";
      x86_64-darwin  = "sha256-c8j6dmq7hFhW/Cb5bZ3KXG1FlFQq/mo0AAHZhRcBMEI=";
      aarch64-darwin = "sha256-hiZU7T2oI/vM3WZp/sOtw2G3xGJJVOb99Ic4TCQIm7k=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
