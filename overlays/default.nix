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
#                           # (one attribute per release line)
final: prev:
let
  inherit (prev) lib;

  zignixLib = import ../lib/default.nix {
    system = prev.stdenv.hostPlatform.system;
    pkgs = prev;
    inherit lib;
  };

  pkgsFor = flake.packages.${prev.stdenv.hostPlatform.system} or { };

  # Every zig-<major>_<minor> package becomes pkgs.zignix."<major>.<minor>",
  # so adding a release line needs no change here.
  releaseLines = lib.concatMapAttrs (
    name: pkg:
    let
      line = builtins.match "zig-([0-9]+)_([0-9]+)" name;
    in
    lib.optionalAttrs (line != null) { ${lib.concatStringsSep "." line} = pkg; }
  ) pkgsFor;
in
{
  zignix = zignixLib
    // lib.optionalAttrs (pkgsFor ? zig-master) { master = pkgsFor.zig-master; }
    // releaseLines;
}
