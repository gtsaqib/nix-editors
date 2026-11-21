# Personal editors

This flake provides **Mitos**, a Helix editor fork, and **Neovim nightly**.

## Install

You need Nix with flakes enabled. Try either editor without installing it:

```sh
nix run github:gtsaqib/nix-editors#mitos
nix run github:gtsaqib/nix-editors#neovim-nightly
```

Install either into your Nix profile:

```sh
nix profile install github:gtsaqib/nix-editors#mitos
nix profile install github:gtsaqib/nix-editors#neovim-nightly
```

Mitos launches with `ms`, while Neovim launches with `nvim`.

## NixOS

Add to your flake's `inputs`:

```nix
nix-editors.url = "github:gtsaqib/nix-editors";
```

Add to a NixOS module:

```nix
{ pkgs, inputs, ... }: {
  environment.systemPackages = [
    inputs.nix-editors.packages.${pkgs.stdenv.hostPlatform.system}.mitos
    inputs.nix-editors.packages.${pkgs.stdenv.hostPlatform.system}.neovim-nightly
  ];
}
```

To use the Cachix binary cache, add this to a NixOS module:

```nix
nix.settings = {
  extra-substituters = [ "https://gtsaqib.cachix.org" ];
  extra-trusted-public-keys = [
    "gtsaqib.cachix.org-1:2o0uyw7seQ59glhJ9Epk8isXlFbvN+oL5YElsZFOMZ8="
  ];
};
```
