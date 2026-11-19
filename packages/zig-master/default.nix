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

  # Pin: 0.18.0-dev.1192+5149e39a7 (2026-11-19)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.1192+5149e39a7";
    sha256 = {
      x86_64-linux   = "sha256-f4rgvGJJ/uP6RVsqlTitCoJodLzOD9a9jsB9zYIdMMU=";
      aarch64-linux  = "sha256-r1xXBGymWgcGHGpsruwYnGgDe/jmZqoN8NHOkFNRITE=";
      x86_64-darwin  = "sha256-Q5+pXBhqVCzpjLhaqO9nvHh1Gi/U1V3d7Yo8OW4QZtQ=";
      aarch64-darwin = "sha256-7zJ034uo1rEB8x/wqD3sYZ7Z4zFI6RUg/xpLE9houDQ=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
