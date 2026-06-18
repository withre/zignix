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

  # Pin: 0.17.0-dev.877+a3ae499dc (2026-06-18)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.877+a3ae499dc";
    sha256 = {
      x86_64-linux   = "sha256-XIQ8CxH6qV8BKM+J0l2PKo97pT/+frvX7WzKZSNq6tw=";
      aarch64-linux  = "sha256-eQzhXcl3huxcOWikigntaWghjqTL1ULr4qoZ4Pg/uTU=";
      x86_64-darwin  = "sha256-7JsF73+6MGi6wWe7iz8fkxoyxLWmavACZrn35T5heuw=";
      aarch64-darwin = "sha256-XH6ABlUDk6fmWnJFAHfB8F/5xJY880zYOqPDLg21FVM=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
