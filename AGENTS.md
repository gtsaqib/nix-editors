# Repository maintenance notes

These notes are for contributors and coding agents working on this repository.
Keep `README.md` focused on installing and using the editors.

## Flake outputs

- `.#mitos` uses the package exported by the Mitos upstream flake.
- `.#neovim-nightly` uses `nix-community/neovim-nightly-overlay`.
- Mitos currently has no `x86_64-darwin` package. Do not add that target to a
  Mitos build without first confirming upstream adds support. The flake still
  exposes Neovim nightly for Intel Macs.
- The `nixConfig` section configures the public `gtsaqib` Cachix substituter
  and its signing key. Builds that rely on flake-provided Nix settings must
  pass `--accept-flake-config`.

## Updating inputs

Run `nix flake update neovim-nightly-overlay` to move the Neovim nightly source
forward. Run `nix flake update mitos` to update Mitos. Review and commit the
resulting `flake.lock` with the change.

## GitHub Actions and Cachix

`.github/workflows/build.yml` builds supported editor/architecture pairs on
push, pull request, and manual dispatch. It reads from the public Cachix cache
without credentials. To upload newly built paths, configure a Cachix write
token as the repository Actions secret `CACHIX_AUTH_TOKEN`. Never place that
token in the flake or another tracked file. The free open-source Cachix tier
has a storage limit; older paths may be evicted.

Use `nix build --accept-flake-config --print-build-logs .#mitos` or the
`.#neovim-nightly` equivalent to reproduce a CI build locally.
