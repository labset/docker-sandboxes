# mise

`mise` is on PATH at `/usr/local/bin/mise`.

- This kit does not ship or manage a `mise.toml` / `.tool-versions` itself —
  that belongs to the project you're working in, or to a task-specific config
  you create yourself. What it does do is run `mise install` on every boot,
  so if the workspace already has a config, its tools are installed and
  ready before you start — no need to run `mise install` by hand. Adding or
  editing tool versions is still on you: `mise use <tool>@<version>`, or edit
  the config directly, then `mise install` picks it up (immediately if you
  run it, automatically on the next boot).
- `mise` is a router to many upstream tool registries (GitHub releases, npm,
  PyPI, crates.io, RubyGems, the Go module proxy, arbitrary asdf/vfox plugin
  git repos, direct HTTP URLs, …), and which ones a given `mise install` needs
  depends entirely on which tools and backends you ask for. The network
  policy this kit declares only covers `mise`'s own operation — self-update
  and the GitHub-backed backends (core, aqua, ubi, asdf, vfox) most tools use.
  If `mise install <tool>` fails on a network refusal for some other
  registry (npm, PyPI, a custom plugin host, …), that is the sandbox's
  network boundary doing its job — the fix is to add that host to the
  composed workload's policy, not to work around it here.
- Unauthenticated calls to the GitHub API are rate-limited; if you hit
  `mise`'s GitHub rate limit, that's expected for anonymous use and not a
  bug in this kit.
