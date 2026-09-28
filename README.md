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

## Using a kit

Published kits live at `ghcr.io/labset/docker-sandboxes`, one moving tag per
kit (`:<kit>`) plus an immutable per-version tag (`:<kit>-<version>`).

Compose a kit onto a sandbox with `sbx` (see
[Docker Docs](https://docs.docker.com/ai/sandboxes/install/) to install it):

```sh
# latest published mise
sbx run <workload> --kit ghcr.io/labset/docker-sandboxes:mise

# pinned to a specific version
sbx run <workload> --kit ghcr.io/labset/docker-sandboxes:mise-2026.9.16
```

Or use a local checkout while developing:

```sh
sbx run <workload> --kit ./kits/mise
```

Each kit's own README documents what it installs, the network access it
declares and how to extend it.

## Contributing

Adding a kit, the build/verify tooling and CI are covered in
[CONTRIBUTING.md](CONTRIBUTING.md).
