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

  # Pin: 0.17.0-dev.1683+5ceec001b (2026-08-13)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1683+5ceec001b";
    sha256 = {
      x86_64-linux   = "sha256-5uXH4INGJr3tkM14bRSL6/IR3ICwE6/v1jFHK1e0H3c=";
      aarch64-linux  = "sha256-sYvZxht1HsZJgjWfhcPUrsM0f0mIue2/wVoUwFVFLu4=";
      x86_64-darwin  = "sha256-KxVLR85TlsAAJgwGyM8BikvyLdX4WPyFOOJ/IBLYZTY=";
      aarch64-darwin = "sha256-EIGgMYqX9JKqyht2xOb+HOXNWGohLuLA2zZLBaKbWHA=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
