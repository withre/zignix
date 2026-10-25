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

  # Pin: 0.18.0-dev.567+7f0281900 (2026-10-25)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.18.0-dev.567+7f0281900";
    sha256 = {
      x86_64-linux   = "sha256-hotDFDiMTL1cVLd9E6hguHVSIraFJP24X8j+TjzVRqg=";
      aarch64-linux  = "sha256-BbCWlq11co1pd5xMKpqKdqPRtSJnUloyLoWwbjCBGQo=";
      x86_64-darwin  = "sha256-/kCfNGMnYvVLo3I03VfYxiKnuTF7a+UXiYZguOMUq8M=";
      aarch64-darwin = "sha256-T4g5nQv3exkaIPB7FfmfxPTdCuo5py9Xnekc+5Xi/TI=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
