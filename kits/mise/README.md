# mise

A [Docker sandbox kit v3](https://github.com/docker/sandbox-kit-spec) mixin
that installs [mise-en-place](https://mise.jdx.dev) (`mise`) as a pinned
static binary.

This kit doesn't write or manage a `mise.toml` itself — tool versions and
tasks are the composing workload's or the agent's business, configured with
`mise use` or a project's own config files. It does run `mise install` as a
`startup` hook on every boot, so whatever the workspace's own config declares
is installed and ready without the agent having to run it by hand. Verified
against an empty workspace: `mise install` with no config exits 0 as a no-op
("mise all tools are installed"), and it's idempotent against an unchanged
one, so this is safe on every sandbox regardless of whether it carries a
mise.toml.

All of mise's backends are available (core, aqua, asdf, vfox, npm, PyPI,
cargo, gem, go, GitHub/GitLab, …). The declared network policy covers
mise's own operation and the GitHub-backed backends most tool installs
resolve through; installing from some other registry may need its host
added to the composed workload's policy. See `mise-context.md`.

## Build & verify

`kit-tck` and `yq` are pinned in the repo root's `mise.toml` — `mise install`
once to get both rather than installing either by hand. CI runs the same
steps via [`build-kit`](../../.github/actions/build-kit).

```sh
mise install   # from the repo root, once

cd kits/mise

# validate the descriptor
docker buildx build . -f mise.yaml --output type=cacheonly

# build, exported for kit-tck
docker buildx build . -f mise.yaml -t mise:2026.9.16 \
  --output type=oci,dest=/tmp/mise-layout,tar=false
kit-tck validate --layout /tmp/mise-layout 2026.9.16

# compose onto a workload and run it
sbx run ./<workload> --kit . --detached --name t .
sbx exec t mise --version
```

## Bumping the version

Edit the `args.version.default` pin in `mise.yaml`. The Dockerfile re-checks
the installed binary's reported version against that pin and fails the build
on a mismatch, so a stale pin cannot silently ship the wrong binary.
