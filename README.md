# docker-sandboxes

A collection of [Docker sandbox kits](https://github.com/docker/sandbox-kit-spec)
(v3 descriptor). Each kit lives under `kits/<name>/` as a self-contained
companion pair — descriptor, content recipe, agent-context body and README —
found by filename stem:

```text
kits/<name>/
  <name>.yaml           # the descriptor; first line `# syntax=docker/sandbox-kit:3`
  <name>.dockerfile      # the content recipe
  <name>-context.md     # agent-context body
  README.md
```

## Kits

| Kit | Kind | What it adds |
|---|---|---|
| [`mise`](kits/mise) | mixin | [mise-en-place](https://mise.jdx.dev) (`mise`), the polyglot tool version/task manager, as a pinned static binary — no `mise.toml` orchestration |

## Adding a kit

Use the `create-kit-v3` skill from
[docker/sandbox-kit-spec](https://github.com/docker/sandbox-kit-spec/blob/main/skills/create-kit-v3/SKILL.md)
as the authoring reference — it covers choosing `workload` vs `mixin`,
capability declarations, version pinning, and the `docker buildx` / `sbx` /
`kit-tck` build-verify loop. Each new kit gets its own `kits/<name>/`
directory following the layout above.

## Tooling

- **`docker buildx`** — builds a kit; nothing extra to install, BuildKit
  pulls the `docker/sandbox-kit:3` frontend from each descriptor's `# syntax=`
  line.
- **`sbx`** — runs a kit as, or composed onto, a sandbox. See
  [Docker Docs](https://docs.docker.com/ai/sandboxes/install/).
- **`kit-tck`** and **`yq`** — pinned in this repo's own `mise.toml`. Run
  `mise install` once (or use [`mise-action`](https://github.com/jdx/mise-action)
  in CI, as the workflows below do) rather than installing either by hand.

## CI

Two workflows, both built from the same [`build-kit`](.github/actions/build-kit)
composite action (resolve the kit's pinned version, multi-platform build,
`kit-tck validate`):

- **[`validate-kits.yml`](.github/workflows/validate-kits.yml)** — pull
  requests and pushes to any branch but `main`. Builds and validates every
  kit; never pushes.
- **[`publish-kits.yml`](.github/workflows/publish-kits.yml)** — pushes to
  `main`. Runs the same build-and-validate gate, then pushes to
  `ghcr.io/<owner>/<repo>:<kit>-<version>` (immutable) and `:<kit>` (moving
  tag) — several kits share one repository, so the version lives in the tag
  rather than the path.
