{
  description = "zignix — pin any Zig build commit, no curated sources.json required";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";
  };

  ###========================================
  ##   Outputs
  #==========================================
  #
  # Blueprint handles the standard outputs (packages, devShells, overlays)
  # auto-discovered at the repository root. On top we expose a `lib.<system>` set
  # with `fromBuild` / `fromUrl` so consumers can pin any Zig nightly
  # without waiting on a curated sources file to update.
  outputs = inputs:
    let
      bp = inputs.blueprint { inherit inputs; };
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      eachSystem = f: builtins.listToAttrs (map (s: { name = s; value = f s; }) systems);
    in
    bp // {
      lib = eachSystem (system:
        import ./lib/default.nix {
          inherit system;
          pkgs = inputs.nixpkgs.legacyPackages.${system};
          lib = inputs.nixpkgs.lib;
        });
    };
}
