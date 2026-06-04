{ pkgs, inputs, ... }:

###========================================
##   Pinned Zig nightly via zignix
#==========================================
#
# This is the smallest useful zignix consumer: a single derivation
# pinned to a specific Zig master build. Because blueprint hands us
# `pkgs` already bound to the right system, we read the system off
# `pkgs.stdenv.hostPlatform.system` and never enumerate systems
# ourselves.
#
# ───────────────────────────────────────────────────────────────
#  Where do `version` and `sha256` come from?
# ───────────────────────────────────────────────────────────────
#
# Both values are published by upstream Zig at
#
#   https://ziglang.org/download/index.json
#
# under the `.master` key. The keys you want are:
#
#   .master.version                  → the `version` field below
#   .master["x86_64-linux"].shasum   → the per-system sha256
#   .master["aarch64-linux"].shasum
#   .master["x86_64-macos"].shasum
#   .master["aarch64-macos"].shasum
#
# Concretely, to bump to whatever upstream master is right now:
#
#   curl -s https://ziglang.org/download/index.json \
#     | jq -r '.master."x86_64-linux".shasum' \
#     | xargs nix hash convert --hash-algo sha256 --to sri
#
# Don't know the sha yet? Set it to `pkgs.lib.fakeHash` and run
# `nix build` once — Nix will fail with the real hash, which you
# paste back here. Same trick works for any upstream build that has
# not yet been mirrored into a curated overlay.

inputs.zignix.lib.${pkgs.stdenv.hostPlatform.system}.fromBuild {
  # Pinned: 0.17.0-dev.607+456b2ec07 (upstream master as of 2026-05-29).
  version = "0.17.0-dev.607+456b2ec07";

  # Converted from .master["x86_64-linux"].shasum etc. in index.json.
  sha256 =
    {
      x86_64-linux   = "sha256-GSdRB957iewz0ptQ8AmXwTgcUk0eM7coRy3L1VHaLjM=";
      aarch64-linux  = "sha256-lqFGW5MuI+682VmMgtMZ0xa0FSm24O8bz/SOr148sVo=";
      x86_64-darwin  = "sha256-MxX/AMHZDSRywb73tYPjoa20uRYLNFKq2Ciwd6191fo=";
      aarch64-darwin = "sha256-TzFD+lqXI3VLlRa+b5vCP9onQ6vxFEVwrmesh19dKgk=";
    }.${pkgs.stdenv.hostPlatform.system};
}
