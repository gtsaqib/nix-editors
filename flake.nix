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

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, mitos, neovim-nightly-overlay, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      pkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ neovim-nightly-overlay.overlays.default ];
      });
    in {
      packages = forAllSystems (system: {
        mitos = mitos.packages.${system}.default;
        neovim-nightly = pkgsFor.${system}.neovim;
        default = self.packages.${system}.mitos;
      });
    };
}
