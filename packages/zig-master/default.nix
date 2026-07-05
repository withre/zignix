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

  # Pin: 0.17.0-dev.1245+efd6f190f (2026-07-05)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.1245+efd6f190f";
    sha256 = {
      x86_64-linux   = "sha256-rsq+JEkmBIeQbGQR5wfjxUJtybj5wyhkC3pbxnwmJJI=";
      aarch64-linux  = "sha256-TSBaGreFpKOJJHBUsKi4omHaPsx36XJkhbdEnHzu7WA=";
      x86_64-darwin  = "sha256-ygls7k8r1b4Fa3shzvsUCqdber8oQcaxP8ndIcKYxs8=";
      aarch64-darwin = "sha256-2Oph5fFrE/L63xQg8r+k/13KWlA4U8ax5nS0TLiDfzA=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
