{ pkgs, inputs, ... }:

let
  zig = import ../zig/default.nix { inherit pkgs inputs; };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "zignix-example-hello";
  version = "0.1.0";

  src = ../../..;

  nativeBuildInputs = [ zig ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild
    export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-global-cache
    export ZIG_LOCAL_CACHE_DIR=$TMPDIR/zig-local-cache
    zig build -Doptimize=ReleaseSafe
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 zig-out/bin/zignix-example $out/bin/hello
    runHook postInstall
  '';

  meta.mainProgram = "hello";
}
