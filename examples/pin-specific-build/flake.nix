{
  description = "Example: pin a specific Zig nightly via zignix (blueprint-style)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";

    zignix.url = "path:../..";
    zignix.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Blueprint hands each output file a `pkgs` for the right system,
  # so we never have to write a `forAllSystems` helper ourselves —
  # see `nix/devshell.nix` and `nix/packages/zig/default.nix`.
  outputs = inputs: inputs.blueprint { inherit inputs; prefix = "nix"; };
}
