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
          rev = neovim-src.shortRev or "dirty";
        in (pkgs.neovim-unwrapped.overrideAttrs (old: {
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
        }));
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
