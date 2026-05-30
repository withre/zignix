{
  description = "Example: pin a specific Zig nightly via zignix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    zignix.url = "path:../..";
    zignix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, zignix }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Per-system Zig derivation. The lib index is driven from
      # `pkgs.stdenv.hostPlatform.system` so the same expression works
      # under cross-compilation setups and on any of the supported hosts.
      zigFor = pkgs:
        zignix.lib.${pkgs.stdenv.hostPlatform.system}.fromBuild {
          # Bump: curl -s https://ziglang.org/download/index.json | jq '.master'
          version = "0.17.0-dev.607+456b2ec07";
          sha256 = "19275107de7b89ec33d29b50f00997c1381c524d1e33b728472dcbd551da2e33";
        };
    in
    {
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in {
          default = pkgs.mkShell { packages = [ (zigFor pkgs) ]; };
        });

      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system}; in {
          default = zigFor pkgs;
        });
    };
}
