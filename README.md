# Personal editors

This repository builds Mitos and a Neovim nightly directly from the Neovim
GitHub source. GitHub Actions checks the build, and Nix can download successful
builds from my Cachix cache.

## Install

You need Nix with flakes enabled. NixOS usually has this already; if needed,
enable `nix-command` and `flakes` in your NixOS configuration. For other Linux
distributions and macOS, use the [Nix installation guide](https://nix.dev/install-nix).

To try an editor once without installing it into your profile:

```sh
nix run --accept-flake-config github:gtsaqib/nix-editors#mitos
nix run --accept-flake-config github:gtsaqib/nix-editors#neovim-nightly
```

Mitos runs as `ms`; Neovim runs as `nvim`.

To install Neovim nightly into your Nix profile:

```sh
nix profile install --accept-flake-config github:gtsaqib/nix-editors#neovim-nightly
```

Replace `neovim-nightly` with `mitos` to install Mitos.

## Use Neovim nightly in NixOS

Add this input to your NixOS system's `flake.nix`:

```nix
inputs.nix-editors.url = "github:gtsaqib/nix-editors";
```

Pass the input to your configuration module by adding `specialArgs` to the
existing `nixosSystem` call in your flake:

```nix
nixosConfigurations.YOUR_HOSTNAME = nixpkgs.lib.nixosSystem {
  # Keep the rest of your existing options and modules.
  specialArgs = { inherit nix-editors; };
  modules = [ ./configuration.nix ];
};
```

Then in the configuration module:

```nix
{ pkgs, nix-editors, ... }:
{
  environment.systemPackages = [
    nix-editors.packages.${pkgs.system}.neovim-nightly
  ];
}
```

To use the Cachix cache in your NixOS builds, add this to a NixOS module:

```nix
nix.settings = {
  extra-substituters = [ "https://gtsaqib.cachix.org" ];
  extra-trusted-public-keys = [
    "gtsaqib.cachix.org-1:2o0uyw7seQ59glhJ9Epk8isXlFbvN+oL5YElsZFOMZ8="
  ];
};
```

## Get a newer nightly on your system

There are two updates:

1. GitHub Actions checks Neovim's source every day. It updates this
   repository's `flake.lock`, builds the new revision on supported systems,
   publishes successful builds to Cachix, then commits the lockfile directly
   to the default branch. It does not open a pull request.
2. In your NixOS configuration repository, run:

   ```sh
   nix flake update nix-editors
   sudo nixos-rebuild switch --flake .#YOUR_HOSTNAME
   ```

The first update changes the editor build; the second updates your system's
locked copy of this repository and installs it.

GitHub Actions builds on x86_64 Linux, ARM Linux, and Apple silicon macOS.
Intel Macs are excluded because the pinned Nixpkgs release no longer supports
that architecture.

For build, cache, and maintenance details, see [AGENTS.md](AGENTS.md).
