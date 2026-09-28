# Contributing

## Adding a kit

Use the `create-kit-v3` skill from
[docker/sandbox-kit-spec](https://github.com/docker/sandbox-kit-spec/blob/main/skills/create-kit-v3/SKILL.md)
as the authoring reference — it covers choosing `workload` vs `mixin`,
capability declarations, version pinning, and the `docker buildx` / `sbx` /
`kit-tck` build-verify loop. Each new kit gets its own `kits/<name>/`
directory following this layout, with the files found by filename stem:

```text
kits/<name>/
  <name>.yaml           # the descriptor; first line `# syntax=docker/sandbox-kit:3`
  <name>.dockerfile      # the content recipe
  <name>-context.md     # agent-context body
  README.md
```

## Tooling

- **`docker buildx`** — builds a kit; nothing extra to install, BuildKit
  pulls the `docker/sandbox-kit:3` frontend from each descriptor's `# syntax=`
  line.
- **`sbx`** — runs a kit as, or composed onto, a sandbox. See
  [Docker Docs](https://docs.docker.com/ai/sandboxes/install/).
- **`kit-tck`** and **`yq`** — pinned in this repo's own `mise.toml`. Run
  `mise install` once (or use [`mise-action`](https://github.com/jdx/mise-action)
  in CI, as the workflows below do) rather than installing either by hand.

## Building a kit locally

Mirrors what the [`build-kit`](.github/actions/build-kit) action does in CI,
minus the multi-platform build. Replace `mise` with the kit you're working on.

```sh
mise install   # from the repo root, once: installs yq and kit-tck

kit=mise
descriptor=kits/$kit/$kit.yaml
version="$(yq -r '.args.version.default' "$descriptor")"

# 1. validate the descriptor (builds without exporting anything)
docker buildx build kits/$kit -f "$descriptor" --output type=cacheonly

# 2. build into a local OCI layout
docker buildx build kits/$kit -f "$descriptor" -t "$kit:$version" \
  --output type=oci,dest=/tmp/$kit-layout,tar=false

# 3. check it against the kit spec
kit-tck validate --layout /tmp/$kit-layout "$version"

# 4. compose onto a workload and try it
sbx run <workload> --kit kits/$kit --detached --name t
sbx exec t <command>   # e.g. `mise --version`
```

CI additionally builds for `linux/amd64` and `linux/arm64`; add
`--platform linux/amd64,linux/arm64` to step 2 to reproduce that (this needs
QEMU/binfmt set up for the non-native platform).

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
