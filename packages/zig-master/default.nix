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

  # Pin: 0.18.0-dev.1124+2ecf4b5e2 (2026-11-14)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.1124+2ecf4b5e2";
    sha256 = {
      x86_64-linux   = "sha256-B6iInGX7DKasduHBHQup5K7uuk8MnAvXUAXjcvgrZl8=";
      aarch64-linux  = "sha256-IYfOr776KwQSF0njmOK/XLyPtk7TSNlIouHFsBj3Fsk=";
      x86_64-darwin  = "sha256-JRt6URXDKPSZ2IjaLoIj5BtAoUF6GNgQory+Y3DGaTo=";
      aarch64-darwin = "sha256-hJGoRwxaG2xK+GZUjBAxshTemVA9UvV+0ykKP0cb0JQ=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
