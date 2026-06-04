{ flake, ... }:

###========================================
##   Default overlay
#==========================================
#
# Exposes a `zignix` namespace on `pkgs`, so a consuming flake can do:
#
#   imports = [{ nixpkgs.overlays = [ inputs.zignix.overlays.default ]; }];
#
# and then:
#
#   pkgs.zignix.fromBuild { version = "..."; sha256 = "..."; }
#   pkgs.zignix.master      # latest master, repo-maintained
#   pkgs.zignix."0.16"      # latest 0.16 release, repo-maintained
final: prev:
let
  zignixLib = import ../lib/default.nix {
    system = prev.stdenv.hostPlatform.system;
    pkgs = prev;
    inherit (prev) lib;
  };

  pkgsFor = flake.packages.${prev.stdenv.hostPlatform.system} or { };
  master = pkgsFor.zig-master or null;
  v0_16 = pkgsFor.zig-0_16 or null;
in
{
  zignix = zignixLib
    // (if master != null then { inherit master; } else { })
    // (if v0_16 != null then { "0.16" = v0_16; } else { });
}
