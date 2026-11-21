{
  description = "Personal editor builds: Mitos and Neovim nightly";

  nixConfig = {
    extra-substituters = [ "https://gtsaqib.cachix.org" ];
    extra-trusted-public-keys = [
      "gtsaqib.cachix.org-1:2o0uyw7seQ59glhJ9Epk8isXlFbvN+oL5YElsZFOMZ8="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    mitos = {
      url = "github:mitos-editor/mitos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-src = {
      url = "github:neovim/neovim";
      flake = false;
    };
  };

  outputs = { nixpkgs, mitos, neovim-src, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
      });
      neovimNightlyFor = system:
        let
          pkgs = pkgsFor.${system};
          lib = nixpkgs.lib;
          rev = neovim-src.shortRev or "dirty";
          neovimDepsText = builtins.readFile "${neovim-src}/cmake.deps/deps.txt";
          depMatches = builtins.filter (match: match != null) (
            builtins.map
              (line: builtins.match "([A-Z0-9_]+)_(URL|SHA256)[[:space:]]+([^[:space:]]+)[[:space:]]*" line)
              (lib.splitString "\n" neovimDepsText)
          );
          depAttrs = builtins.foldl'
            (acc: match:
              let
                name = lib.toLower (builtins.elemAt match 0);
                key = lib.toLower (builtins.elemAt match 1);
                value = builtins.elemAt match 2;
              in acc // {
                ${name} = (acc.${name} or { }) // { ${key} = value; };
              })
            { }
            depMatches;
          neovimDeps = builtins.mapAttrs (_: dep: pkgs.fetchurl dep) depAttrs;
          treeSitterParserSources = lib.filterAttrs
            (name: _: lib.hasPrefix "treesitter_" name && !(lib.hasSuffix "_wasm" name))
            neovimDeps;
          treeSitterParsers = lib.mapAttrs'
            (name: src: lib.nameValuePair (lib.removePrefix "treesitter_" name) { inherit src; })
            treeSitterParserSources;
        in (pkgs.neovim-unwrapped.override {
          # Build parser grammars from the exact revisions pinned by Neovim.
          # Nixpkgs' parser pins can lag behind and fail Neovim's own tests.
          treesitter-parsers = treeSitterParsers;
        }).overrideAttrs (old: {
          pname = "neovim-nightly";
          version = rev;
          src = neovim-src;

          # The source reports itself as a nightly build and includes the
          # pinned source revision in `nvim --version`.
          postPatch = (old.postPatch or "") + ''
            substituteInPlace cmake.config/versiondef.h.in \
              --replace-fail '@NVIM_VERSION_PRERELEASE@' '-nightly+${rev}'
          '';

          # Keep the macOS test socket path short enough for the test runner.
          preCheck = (old.preCheck or "") + ''
            export XDG_RUNTIME_DIR="$(mktemp -d)"
          '';

          # Nixpkgs may backport a security patch already present in master.
          patches = builtins.filter
            (patch: !nixpkgs.lib.hasInfix "CVE-2026-11487" (toString patch))
            (old.patches or [ ]);

          meta = old.meta // {
            description = "Nightly build of the Neovim text editor";
            changelog = "https://github.com/neovim/neovim/commits/master";
          };
        });
    in {
      packages = forAllSystems (system:
        let
          mitosPackages = mitos.packages.${system} or { };
        in {
          neovim-nightly = neovimNightlyFor system;
        } // nixpkgs.lib.optionalAttrs (mitosPackages ? default) {
          mitos = mitosPackages.default;
          default = mitosPackages.default;
        });
    };
}
