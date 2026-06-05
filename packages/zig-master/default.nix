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

  # Pin: 0.17.0-dev.690+c5a61e899 (2026-06-05)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.690+c5a61e899";
    sha256 = {
      x86_64-linux   = "sha256-FHRNWDS5yQO2qGmvvgjEeOphoBQUtNPEqWbCsfzcKLc=";
      aarch64-linux  = "sha256-7RHuHE10Cj9CBcHeHUf5MqN5TGJuaEu001XWZEsBi3s=";
      x86_64-darwin  = "sha256-uV/aoU0q8oo83MRadMvYLfRtF4K5myrsVB/TJXbjUFU=";
      aarch64-darwin = "sha256-XyfxrTeXYPirCUb49KLE6gO1NDMT8D7vWzyYSFMGVwM=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
