{ pkgs, system, ... }:

###========================================
##   zignix development shell
#==========================================
#
# Tools for working on zignix itself. Drops you into a shell with the
# pinned master Zig (so you can sanity-check it works) plus the usual
# Nix tooling.

let
  zigMaster = import ./packages/zig-master/default.nix { inherit pkgs system; };
in
pkgs.mkShell {
  packages = [
    zigMaster
    pkgs.jq
    pkgs.curl
    pkgs.nixpkgs-fmt
  ];
}
