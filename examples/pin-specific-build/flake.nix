{
  description = "Example: pin a specific Zig nightly via zignix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    zignix.url = "path:../..";
    zignix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, zignix }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Pin any Zig build. To bump:
      #   curl -s https://ziglang.org/download/index.json | jq '.master'
      zig = zignix.lib.${system}.fromBuild {
        version = "0.17.0-dev.607+456b2ec07";
        sha256 = "19275107de7b89ec33d29b50f00997c1381c524d1e33b728472dcbd551da2e33";
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ zig ];
      };

      packages.${system}.default = zig;
    };
}
