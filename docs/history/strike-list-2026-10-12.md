# Shrink preflight — stopped before deletion

The brief's escalation rule was reached at base `6b15993` on 2026-10-12.
No rule text has been changed. This is a pending strike-list, not a completed deletion audit.

## Open question

May B7's cap answer `close` be added as NEW, and may B6's cap rule be copied
from the repository rules into scaffold template 2.1a, despite the deletion-only constraint?

Evidence:
- `.claude/review-gates.md:325–336` defines the cap stop and explicitly says
  `It never closes the cycle` (sentence starts at line 332).
  B7 instead requires a cap answer `close` to permit the closing act.
- `plugins/dev-workflow/commands/workflow-init.md:853–871` lists three suspensions,
  with no pass-cap stop. The repository copy lists four, including that stop.
  The scaffold therefore lacks B6's cap rule; deletion cannot add it.

The brief permits NEW content only for B1's high-risk plan rule and B10 in its
escalation clause. Its general NEW allowance and this narrower stop clause need
reconciliation for B6/B7 before implementation.

## Unchanged source sizes and line totals

| File | Before bytes | After bytes | Original lines | Deleted lines |
|---|---:|---:|---:|---:|
| `.claude/review-gates.md` | 139111 | 139111 | 1665 | 0 |
| `plugins/dev-workflow/commands/workflow-init.md` | 232086 | 232086 | 3143 | 0 |
| `plugins/dev-workflow/skills/harden-finding/SKILL.md` | 11921 | 11921 | 193 | 0 |
| `plugins/dev-workflow/skills/intake/SKILL.md` | 32932 | 32932 | 519 | 0 |
| `AGENTS.md` | 23397 | 23397 | 301 | 0 |
| `docs/PRD.md` | 2988 | 2988 | 43 | 0 |
| `plugins/dev-workflow/CHANGELOG.md` | 62660 | 62660 | 848 | 0 |
| `plugins/dev-workflow/.claude-plugin/plugin.json` | 490 | 490 | 12 | 0 |

Kept/deleted range classification: not performed; no completed coverage claim.
Archives and archive cmp: not created or run, because escalation preceded deletion.
Quality battery: not run. Check amendments: none. Plugin version: unchanged, 0.23.0.
No Gate A or Gate B was run. No `.context/` content is included.

Read-only preflight commands (all exit 0): `git log -1 --oneline main`,
`git worktree list`, targeted `rg`/`sed` of both rule copies,
`git fetch origin`, `git log -1 --oneline origin/main`, `gh auth status`.
Setup commands (both exit 0): `git tag pre-shrink main` and
`git worktree add ../dev-workflow-kit-shrink -b kit-shrink main`.

No Gate B on this change by Daniel's decision 2026-10-12; verification = strike-list review by a separate Claude session.
