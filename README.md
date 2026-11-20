# Personal editors

Install Mitos and Neovim nightly with Nix. Nix downloads the builds from my
Cachix cache when they are available, so you usually do not need to compile
either editor yourself.

## Before you start

You need Nix with flakes enabled. NixOS users generally already have this set
up. On other Linux distributions and macOS, follow the [Nix installation
guide](https://nix.dev/install-nix).

## Try an editor

These commands run an editor once without adding it to your profile:

```sh
nix run --accept-flake-config github:gtsaqib/nix-editors#mitos
nix run --accept-flake-config github:gtsaqib/nix-editors#neovim-nightly
```

Mitos starts with the `ms` command. Neovim starts with `nvim`.

## Install an editor

To make an editor available in your shell, install it into your Nix profile:

```sh
nix profile install --accept-flake-config github:gtsaqib/nix-editors#mitos
```

For Neovim nightly, use:

```sh
nix profile install --accept-flake-config github:gtsaqib/nix-editors#neovim-nightly
```

To update installed editors after this repository updates its locked sources:

```sh
nix profile upgrade '.*'
```

## What gets built

GitHub Actions builds both editors for Linux and Apple silicon Macs. On Intel
Macs it builds Neovim nightly; the Mitos project does not currently publish a
flake package for that architecture.

Neovim is built from its nightly source, pinned to the revision in this
repository's lock file. The build changes when this repository updates that
revision; installing again does not automatically select a newer commit.

For repository maintenance and CI details, see [AGENTS.md](AGENTS.md).
