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
#   pkgs.zignix.master
final: prev:
let
  zignixLib = import ../lib/default.nix {
    system = prev.stdenv.hostPlatform.system;
    pkgs = prev;
    inherit (prev) lib;
  };

  master = flake.packages.${prev.stdenv.hostPlatform.system}.zig-master or null;
in
{
  zignix = zignixLib // (if master != null then { inherit master; } else { });
}
