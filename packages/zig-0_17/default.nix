{ pkgs, system, ... }:

###========================================
##   Pinned 0.17 release line
#==========================================
#
# A worked example of `lib.fromTagged`. Tracks the latest tagged release
# in the 0.17 line. To bump:
#
#   1. Pick a version from https://ziglang.org/download/index.json
#      (a tagged `0.17.x` key).
#   2. Convert the matching `<arch>-<os>.shasum` to a Nix sha256.
#   3. Run `nix build .#zig-0_17` to verify.
#
# This is kept current by scripts/update-zig-master-pins.py alongside the
# master pin.

let
  zignixLib = import ../../lib/default.nix {
    inherit system pkgs;
    inherit (pkgs) lib;
  };

  # Pin: 0.17.1 (2026-11-13)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.1";
    sha256 = {
      x86_64-linux   = "sha256-NYGGPjy8/Q/ODvxoLOfp6T2pZmipd3kdNWom0qfpsXo=";
      aarch64-linux  = "sha256-oVRtVkbrGEQ3kY1mNcprdioOiJ6sCc73IO56HtP+d5U=";
      x86_64-darwin  = "sha256-mvB7IDGfvQyS7katI+gdangrGq6iz7jcv/NfHSx927c=";
      aarch64-darwin = "sha256-dfG8eh6YUvF+yaDBiV92fE7FbUa8ioNJIO7OHQNZ3Y0=";
    };
  };
in
zignixLib.fromTagged {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-0_17: no pinned sha256 for ${system}");
}
