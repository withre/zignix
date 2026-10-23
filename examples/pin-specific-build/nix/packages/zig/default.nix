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
#
# Upstream prunes /builds after a few weeks, so an old nightly pin
# stops fetching on machines that don't have it cached. In this repo
# the update workflow re-pins the example with the master pin; in your
# own project, bumping the pin is up to you.

inputs.zignix.lib.${pkgs.stdenv.hostPlatform.system}.fromBuild {
  # Pinned: 0.18.0-dev.470+6817928c3 (upstream master as of 2026-10-22).
  version = "0.18.0-dev.470+6817928c3";

  # Converted from .master["x86_64-linux"].shasum etc. in index.json.
  sha256 =
    {
      x86_64-linux   = "sha256-cV+QYCLQDO3vxIvXS+fyW/O9HBeFtaOCwWUSMH+Qm0M=";
      aarch64-linux  = "sha256-/mgaFGUHrIixkh7M645Nt1jGGyCpMuYcgq5gRSXmnQ8=";
      x86_64-darwin  = "sha256-0cPQ0M5SonBYkZ1P4bDd3mTU6/Ey7uDoGe1qnkCbfLk=";
      aarch64-darwin = "sha256-r6IKRxQseTJ7L0G7jw1OYZsAWNAuYKeZ+YWfvkdnq3Q=";
    }.${pkgs.stdenv.hostPlatform.system};
}
