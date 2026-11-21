# Repository maintenance notes

These notes are for contributors and coding agents working on this repository.
Keep `README.md` focused on installing and using the editors.

## Flake outputs

- `.#mitos` uses the package exported by the Mitos upstream flake.
- `.#neovim-nightly` builds the `neovim-src` flake input directly using the
  Nixpkgs `neovim-unwrapped` package as its build recipe. Do not add a
  `neovim-nightly-overlay` input.
- The flake targets x86_64 Linux, ARM Linux, and Apple silicon macOS. The
  pinned Nixpkgs 26.11 release dropped x86_64-darwin support.
- The `nixConfig` section configures the public `gtsaqib` Cachix substituter
  and its signing key. Builds that rely on flake-provided Nix settings must
  pass `--accept-flake-config`.

## Updating inputs

`.github/workflows/update-neovim.yml` updates only the direct `neovim-src`
input daily, builds the result on all supported systems, then commits the
updated `flake.lock` directly to the default branch after successful builds.
It does not open a pull request. Run `nix flake update neovim-src` to update
that input manually. Run `nix flake update mitos` to update Mitos. Review and
commit the resulting `flake.lock` with manual changes.

## GitHub Actions and Cachix

`.github/workflows/build.yml` builds supported editor/architecture pairs on
push, pull request, and manual dispatch. The scheduled update workflow also
builds its refreshed source before committing. CI reads from the public Cachix cache
without credentials. To upload newly built paths, configure a Cachix write
token as the repository Actions secret `CACHIX_AUTH_TOKEN`. Never place that
token in the flake or another tracked file. The free open-source Cachix tier
has a storage limit; older paths may be evicted.

Use `nix build --accept-flake-config --print-build-logs .#mitos` or the
`.#neovim-nightly` equivalent to reproduce a CI build locally.
