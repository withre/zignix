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
  # Blueprint handles packages, devShells, and checks auto-discovered at the
  # repository root. Two outputs are wired by hand on top, letting consumers
  # pin any Zig nightly without waiting on a curated sources file to update:
  #
  # - `lib.<system>` deliberately *overrides* blueprint's own `lib`.
  #   Blueprint imports lib/default.nix with `{ flake, inputs }`, but ours
  #   is per-system and takes `{ system, pkgs, lib }`, so blueprint's
  #   version would fail if evaluated.
  # - `overlays.default` is a plain addition: blueprint does not scan an
  #   `overlays/` directory, so without this line the output is missing.
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

      # `overlays/default.nix` is a `{ flake, ... }: final: prev: …` overlay; it
      # reads `flake.packages.<system>` to expose `pkgs.zignix.master` /
      # `pkgs.zignix."0.16"` alongside the lib helpers.
      overlays.default = import ./overlays/default.nix { flake = bp; };
    };
}
