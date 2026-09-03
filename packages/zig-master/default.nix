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

  # Pin: 0.17.0-dev.1978+c961124d9 (2026-09-03)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1978+c961124d9";
    sha256 = {
      x86_64-linux   = "sha256-QgwA2EAm+LyfRvfGA96AlCmr0nQRnT6o9PmE+yp8bBA=";
      aarch64-linux  = "sha256-muic8QfVu7LDzKe0/RhxBsRHfHi9XgvC1hVsuD4XMMg=";
      x86_64-darwin  = "sha256-FeQIo3AwcqTehp4N9XxmVu26XDh8vc9dfSnxkQHJHzI=";
      aarch64-darwin = "sha256-HCpAGqFsC8FaA1MCSVcex8AujWC/PSwFu1kimkgL3aE=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
