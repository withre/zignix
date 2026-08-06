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

  # Pin: 0.17.0-dev.1564+97ced1272 (2026-08-06)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1564+97ced1272";
    sha256 = {
      x86_64-linux   = "sha256-vJLouZ7u93HHRP5Bc+eWC+58BhWNWXefoebteV3Mxqw=";
      aarch64-linux  = "sha256-lsOtWsBvkgtFOaOtnk8cUV7uJnpgnhXr1wtH/jV3yGk=";
      x86_64-darwin  = "sha256-y3i6dElQ1v8NAiRp/lpADATBnifJi0TRV8GOgptY7/M=";
      aarch64-darwin = "sha256-0ThlpO50bHnQj8H5ob0aeIwUIyBepTVEA61A0Threu0=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
