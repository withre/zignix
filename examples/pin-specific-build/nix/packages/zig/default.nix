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
#     | jq '.master | { version, x86_64_linux: ."x86_64-linux".shasum,
#                       aarch64_linux: ."aarch64-linux".shasum,
#                       x86_64_macos:  ."x86_64-macos".shasum,
#                       aarch64_macos: ."aarch64-macos".shasum }'
#
# Don't know the sha yet? Set it to `pkgs.lib.fakeHash` and run
# `nix build` once — Nix will fail with the real hash, which you
# paste back here. Same trick works for any upstream build that has
# not yet been mirrored into a curated overlay.

inputs.zignix.lib.${pkgs.stdenv.hostPlatform.system}.fromBuild {
  # Pinned: 0.17.0-dev.607+456b2ec07 (upstream master as of 2026-05-29).
  version = "0.17.0-dev.607+456b2ec07";

  # From .master["x86_64-linux"].shasum etc. in index.json.
  sha256 =
    {
      x86_64-linux   = "19275107de7b89ec33d29b50f00997c1381c524d1e33b728472dcbd551da2e33";
      aarch64-linux  = "96a1465b932e23eebcd9598c82d319d316b41529b6e0ef1bcff48eaf5e3cb15a";
      x86_64-darwin  = "3315ff00c1d90d2472c1bef7b583e3a1adb4b9160b3452aad828b077ad7dd5fa";
      aarch64-darwin = "4f3143fa5a9723754b9516be6f9bc23fda2743abf1144570ae67ac875f5d2a09";
    }.${pkgs.stdenv.hostPlatform.system};
}
