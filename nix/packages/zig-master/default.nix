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

  # Pin: 0.17.0-dev.657+2faf8debf (2026-06-03)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.657+2faf8debf";
    sha256 = {
      x86_64-linux   = "sha256-9CBhMgHNzXZ4NWCZ8M12zlEZMdth7rHyptmhVjFq6io=";
      aarch64-linux  = "sha256-c/RJzp2B74X+MRspOFW2A+2LcsBvH9qcRC6t/622xuo=";
      x86_64-darwin  = "sha256-YmXw6bZ1+GpHd7AJwfefl3SuCWJqzoIjjyf+bhuqRg8=";
      aarch64-darwin = "sha256-cKTqoBLbEX4jiGNbsrf4wXwubND8pK2fuxtq4dFtkGc=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
