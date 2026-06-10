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

  # Pin: 0.17.0-dev.813+2153f8143 (2026-06-10)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.813+2153f8143";
    sha256 = {
      x86_64-linux   = "sha256-sNRv/EWHuejdC1JO5bxNoeZ/KLulXnxTTOxkry8tenQ=";
      aarch64-linux  = "sha256-qme0GNUL3eMEPP52UBbVOHojM7UUraLFfyS6rkAFwzE=";
      x86_64-darwin  = "sha256-OTjEauS8o8E/QjsJUD4+8Au0t+8SuLweUSLt42YFels=";
      aarch64-darwin = "sha256-Nmc9JROvpKlshngGSLpQS+7dfwRROJCRz51T441bSEA=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
