{ system, pkgs, lib }:

###========================================
##   zignix library
#==========================================
#
# Helpers for building Zig derivations from arbitrary upstream tarballs.
#
# The headline use case: pin any nightly `master` build by version+sha256
# without waiting for a curated sources file. Two entry points:
#
#   fromBuild  — for builds on ziglang.org/builds (URL derived from version)
#   fromUrl    — for arbitrary tarball URLs (mirrors, custom builds)
#
# Both return a stdenv derivation that drops the upstream tarball into
# $out, matching the layout the mitchellh/zig-overlay produces so consuming
# projects can swap drop-in.

let

  ###----------------------------------------
  ##   System → (arch, os) for URL synthesis
  #------------------------------------------
  systemMap = {
    "x86_64-linux"   = { arch = "x86_64";  os = "linux"; ext = "tar.xz"; };
    "aarch64-linux"  = { arch = "aarch64"; os = "linux"; ext = "tar.xz"; };
    "x86_64-darwin"  = { arch = "x86_64";  os = "macos"; ext = "tar.xz"; };
    "aarch64-darwin" = { arch = "aarch64"; os = "macos"; ext = "tar.xz"; };
  };

  sysInfo =
    if systemMap ? ${system} then systemMap.${system}
    else throw "zignix: unsupported system '${system}'. Supported: ${
      lib.concatStringsSep ", " (lib.attrNames systemMap)
    }";

  ###----------------------------------------
  ##   Core derivation builder
  #------------------------------------------
  #
  # Mirrors mitchellh/zig-overlay's `mkBinaryInstall` shape so the result
  # is API-compatible. Patches `/usr/bin/env` in std/zig/system.zig to the
  # nixpkgs coreutils env binary for sandbox-friendliness.
  mkZig = { version, url, sha256 }:
    pkgs.stdenvNoCC.mkDerivation {
      pname = "zig";
      inherit version;

      src = pkgs.fetchurl { inherit url sha256; };

      dontConfigure = true;
      dontBuild = true;
      dontFixup = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/{bin,lib}
        cp -r ./lib/* $out/lib/
        if [ -d ./doc ]; then
          cp -r ./doc $out/doc
        fi
        install -m755 ./zig $out/bin/zig

        # Make Zig's system-info path work under pure Nix builders.
        if [ -f "$out/lib/std/zig/system.zig" ]; then
          substituteInPlace $out/lib/std/zig/system.zig \
            --replace "/usr/bin/env" "${lib.getExe' pkgs.coreutils "env"}"
        fi

        runHook postInstall
      '';

      meta = {
        description = "Zig compiler, pinned by zignix";
        homepage = "https://ziglang.org";
        license = lib.licenses.mit;
        mainProgram = "zig";
        platforms = lib.attrNames systemMap;
      };
    };

  ###----------------------------------------
  ##   URL synthesis from a version string
  #------------------------------------------
  #
  # Modern Zig tarballs (>= 0.14) live at:
  #   https://ziglang.org/builds/zig-<arch>-<os>-<version>.<ext>
  #
  # Tagged releases ALSO follow this pattern at /download/<version>/
  # rather than /builds/. We default to /builds/ which matches dev
  # nightlies; consumers wanting a tagged release should pass an explicit
  # `url` via `fromUrl`, or override `urlBase`.
  mkUrl = { version, urlBase ? "https://ziglang.org/builds" }:
    "${urlBase}/zig-${sysInfo.arch}-${sysInfo.os}-${version}.${sysInfo.ext}";

in
{

  ###----------------------------------------
  ##   fromBuild — pin by version + sha256
  #------------------------------------------
  #
  # Example:
  #   zignix.lib.${system}.fromBuild {
  #     version = "0.17.0-dev.657+2faf8debf";
  #     sha256  = "sha256-9CBhMgHNzXZ4NWCZ8M12zlEZMdth7rHyptmhVjFq6io=";
  #   }
  #
  # The sha256 can be set to `lib.fakeHash` while bootstrapping; Nix will
  # error out with the real hash for you to paste back.
  fromBuild =
    { version
    , sha256
    , urlBase ? "https://ziglang.org/builds"
    }:
    mkZig {
      inherit version sha256;
      url = mkUrl { inherit version urlBase; };
    };

  ###----------------------------------------
  ##   fromUrl — arbitrary tarball
  #------------------------------------------
  #
  # For mirrors, self-hosted builds, or tagged releases at
  # /download/<version>/ (the older URL shape).
  #
  # Example:
  #   zignix.lib.${system}.fromUrl {
  #     version = "0.16.0";
  #     url     = "https://ziglang.org/download/0.16.0/zig-x86_64-linux-0.16.0.tar.xz";
  #     sha256  = "sha256-cOSWZKdDdLSLUebz/fv0N/Y5XUJQkFBYi9SavlK6PQA=";
  #   }
  fromUrl = { version, url, sha256 }: mkZig { inherit version url sha256; };

  ###----------------------------------------
  ##   fromTagged — tagged release sugar
  #------------------------------------------
  #
  # Convenience wrapper that constructs the /download/<version>/ URL used
  # by tagged releases. Saves spelling the full URL.
  #
  # Example:
  #   zignix.lib.${system}.fromTagged {
  #     version = "0.16.0";
  #     sha256  = "sha256-cOSWZKdDdLSLUebz/fv0N/Y5XUJQkFBYi9SavlK6PQA=";
  #   }
  fromTagged = { version, sha256 }:
    mkZig {
      inherit version sha256;
      url = mkUrl {
        inherit version;
        urlBase = "https://ziglang.org/download/${version}";
      };
    };

  ###----------------------------------------
  ##   withName — expose a zig under a custom command name
  #------------------------------------------
  #
  # Every zignix package installs a binary called `zig`, so two of them
  # on the same profile would collide on PATH. `withName` returns a
  # package that exposes the same compiler under a different command
  # name, letting several Zig versions coexist.
  #
  # Zig locates its bundled `lib/` relative to the resolved executable
  # path, so a symlink to the real binary keeps `zig build` working.
  #
  # Example (Home Manager):
  #   home.packages = [
  #     (zignix.lib.${system}.withName "zig"      pkgs.zignix.master)
  #     (zignix.lib.${system}.withName "zig-0.16" pkgs.zignix."0.16")
  #   ];
  withName = name: zig:
    pkgs.runCommandLocal "${name}-${zig.version or "zig"}"
      {
        meta = (zig.meta or { }) // { mainProgram = name; };
      }
      ''
        mkdir -p $out/bin
        ln -s ${lib.getExe zig} $out/bin/${name}
      '';

  ###----------------------------------------
  ##   Re-exports for downstream consumers
  #------------------------------------------
  inherit systemMap;
  fakeHash = lib.fakeHash;
}
