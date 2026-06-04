{ pkgs, system, ... }:

###========================================
##   Pinned master snapshot
#==========================================
#
# A worked example of `lib.fromBuild`. Demonstrates how downstream
# consumers can pin a specific nightly without forking zignix. To
# bump:
#
#   1. Pick a version from https://ziglang.org/download/index.json
#      (`.master.version`).
#   2. Convert the matching `<arch>-<os>.shasum` to a Nix sha256.
#   3. Run `nix build .#zig-master` to verify.
#
# This package is intentionally minimal — the project's API surface is
# `lib.fromBuild` etc., not this attribute.

let
  zignixLib = import ../../lib/default.nix {
    inherit system pkgs;
    inherit (pkgs) lib;
  };

  # Pin: 0.17.0-dev.667+0569f1f6a (2026-06-03)
  # Nix sha256 values converted from upstream shasums in:
  # https://ziglang.org/download/index.json
  pins = {
    version = "0.17.0-dev.667+0569f1f6a";
    sha256 = {
      x86_64-linux   = "sha256-mG5owYYUWLIc6SKaTQlNjBTh4c9LGmDyjk37cLFxRvc=";
      aarch64-linux  = "sha256-78+kZDW+3ZtTkHidPORgRQt31N72EcyXPnJc/ppUHA8=";
      x86_64-darwin  = "sha256-s5OaQfrNC7lrtE29GYH9bEKgOG3eUSWG42W7NRaPy7o=";
      aarch64-darwin = "sha256-5n+LN8JjKAt8AKR8/4CcyqTg8ohAELUpHYrEt4jhhK0=";
    };
  };
in
zignixLib.fromBuild {
  inherit (pins) version;
  sha256 = pins.sha256.${system} or (throw "zig-master: no pinned sha256 for ${system}");
}
