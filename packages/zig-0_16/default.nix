{ pkgs, system, ... }:

###========================================
##   Pinned 0.16 release line
#==========================================
#
# A worked example of `lib.fromTagged`. Tracks the latest tagged release
# in the 0.16 line. To bump:
#
#   1. Pick a version from https://ziglang.org/download/index.json
#      (a tagged `0.16.x` key).
#   2. Convert the matching `<arch>-<os>.shasum` to a Nix sha256.
#   3. Run `nix build .#zig-0_16` to verify.
#
# This is kept current by scripts/update-zig-master-pins.py alongside the
# master pin.

let
  zignixLib = import ../../lib/default.nix {
    inherit system pkgs;
    inherit (pkgs) lib;
  };

  # Pin: 0.16.0 (2026-06-14)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.16.0";
    sha256 = {
      x86_64-linux   = "sha256-cOSWZKdDdLSLUebz/fv0N/Y5XUJQkFBYi9SavlK6PQA=";
      aarch64-linux  = "sha256-6ksJv7IuxvbGzqxXq2PvtrRuF6sI0h9p86SLOOFTTxc=";
      x86_64-darwin  = "sha256-A4dVftGHe8ai4YAsg5GVO63bp2CBh2MBxSL1KXe1K6c=";
      aarch64-darwin = "sha256-sj1w3qqHm1wtSG7TMW9+qlPoSs9vycx0feFSRQ1AFIk=";
    };
  };
in
zignixLib.fromTagged {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-0_16: no pinned sha256 for ${system}");
}
