# Personal editor builds

This flake builds Mitos and Neovim nightly. The flake lock file pins both
upstream sources and nixpkgs after the first `nix flake lock`.

```sh
nix build .#mitos
nix build .#neovim-nightly
```

GitHub Actions builds all four common Linux and macOS architectures on pushes,
pull requests, and manual runs. Run `nix flake update` when you want to pin
new upstream revisions, then commit the resulting `flake.lock`.

## Binary cache

The flake and workflow use the public `gtsaqib` Cachix cache for downloads. Nix
may ask you to accept the flake's cache settings the first time you build; use
`--accept-flake-config` to accept them from the command line. To let trusted
push builds upload new outputs, add a Cachix write token as the repository
secret `CACHIX_AUTH_TOKEN`. Pull requests from forks can still read the public
cache but do not receive the write secret. Cachix's free open source tier
currently has a 5 GB limit, so old paths may be evicted as the editors change.

If the repository is public, standard GitHub-hosted Actions runners are free.
Private repositories use the included monthly minutes for their account plan.
