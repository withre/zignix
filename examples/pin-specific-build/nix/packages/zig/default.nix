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
  # Pinned: 0.18.0-dev.1165+ce87507d5 (upstream master as of 2026-11-16).
  version = "0.18.0-dev.1165+ce87507d5";

  # Converted from .master["x86_64-linux"].shasum etc. in index.json.
  sha256 =
    {
      x86_64-linux   = "sha256-H0PByyGGgyRGdjwyaqsXirjnh8DpQqjRVAxvm+/Fn2c=";
      aarch64-linux  = "sha256-K8tN6bgk6Vv4yJM9EMrKhmT3u4rvc1rKK2imc23YRYE=";
      x86_64-darwin  = "sha256-qE6AZm7xpJsS2gVgCB/lzaTSNIJpgttu5coQe4rMQFk=";
      aarch64-darwin = "sha256-ewhZTr66KZHBGttvsw/R8mG08wxfMA+zvMmp9MrNilE=";
    }.${pkgs.stdenv.hostPlatform.system};
}
