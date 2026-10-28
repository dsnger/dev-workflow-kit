# Tech stack

The tools this repository runs on, and where each one's version is pinned or stated. This page
copies no version value; the last column points to the files that hold them. Some values also
appear in a second place (the prerequisites paragraph restates the CI pins of shellcheck and the
`claude` CLI), so a bump checks both. Pinning itself is
[`AGENTS.md` invariant 5](../AGENTS.md#key-invariants). The layout is in
[`ARCHITECTURE.md`](ARCHITECTURE.md).

| Tool | Role | Where its version lives |
|---|---|---|
| POSIX `sh` and `dash` | run the hook and every shell suite; the battery runs the hook suite under both | addressed by name as system shells: [`AGENTS.md` § Commands](../AGENTS.md#commands), prerequisites paragraph |
| shellcheck | lints the hook, the three checkers and every suite the battery lists | CI: the pinned image in [`ci.yml`](../.github/workflows/ci.yml); local: the prerequisites paragraph; `scripts/local-ci.sh` refuses a local version other than the `ci.yml` pin |
| `python3` | runs the six reports and their suites | minimum stated in the prerequisites paragraph |
| git | used by the hook and the reports | minimum stated in the prerequisites paragraph |
| `claude` CLI | `claude plugin validate` in the battery and CI | [`ci.yml`](../.github/workflows/ci.yml), the npm install step; restated in the prerequisites paragraph |
| Node.js | runs the `claude` CLI in CI | [`ci.yml`](../.github/workflows/ci.yml), the `setup-node` step's `node-version` |
| Codex MCP server | the reviewer at both gates | [`.mcp.json`](../.mcp.json) |
| CI runner and actions | the CI job | [`ci.yml`](../.github/workflows/ci.yml): `runs-on` and each `uses:` ref |
| `gh` | `scripts/local-ci.sh` posts the `quality` status with it; `scripts/worktree-cleanup.sh` asks it for merged PRs when present | addressed by name as a system tool: [`AGENTS.md` § Commands](../AGENTS.md#commands), prerequisites paragraph |
| `jq` | optional; the hook falls back without it | not pinned ([`AGENTS.md` invariant 4](../AGENTS.md#key-invariants)) |
