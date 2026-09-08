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

  # Pin: 0.17.0-dev.2056+79a9897cd (2026-09-08)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.2056+79a9897cd";
    sha256 = {
      x86_64-linux   = "sha256-c9ARUBM7R3hTt6AZ7pkbg5LxyuFzlqIvGDDxq2GR1Rw=";
      aarch64-linux  = "sha256-tM5in57eKmQe8dTJLbbe/LTPFF1gIYPES1OPUqBMQTw=";
      x86_64-darwin  = "sha256-vbabpYC1O1Jq3BOqG7oJ6LrKHXNp0axDhVNm/HiNPus=";
      aarch64-darwin = "sha256-BKuznATGpr+ICtmmXSj5HeXenah6YK5ZsYF6ZL2ECKU=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
