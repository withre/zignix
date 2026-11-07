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
  # Pinned: 0.18.0-dev.930+1d9e7ec5a (upstream master as of 2026-11-06).
  version = "0.18.0-dev.930+1d9e7ec5a";

  # Converted from .master["x86_64-linux"].shasum etc. in index.json.
  sha256 =
    {
      x86_64-linux   = "sha256-KvdcgHZ5KRh2XqtaJNQ2zuPQdTXqyC/OHYNhr3GR/+c=";
      aarch64-linux  = "sha256-LmmWgkh9RVwjjC7YEUWj0oAKSWD0DuQfUb9F5IfOz7A=";
      x86_64-darwin  = "sha256-u/uiWxbeYyxk/aOHJI19ihT00TjErXlZejxIJiSb7kQ=";
      aarch64-darwin = "sha256-XMpGo53h6/CYa0cITyKGXbFzWRpInYysek0CnIW4ro8=";
    }.${pkgs.stdenv.hostPlatform.system};
}
