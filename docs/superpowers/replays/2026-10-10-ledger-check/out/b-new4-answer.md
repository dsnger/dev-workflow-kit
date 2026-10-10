There are two open hardening obligations in this repository's history. The rule in `.claude/review-gates.md` (around lines 1524–1546) treats an obligation as open when it has an owed line but no outcome line giving a rung or `rung 0`. A `pending` line doesn't close one.

**What I searched:** the history of `main`, which is the only branch. The clone is not shallow, so the result is complete. Every hardening line comes from one cycle, `aaaa1111bb`, recorded in commit `31c2918` ("Remove --global and fix its docs (#7)"). That commit lists 3 repaired findings, all 3 owing hardening:

| Key | Owed line | Outcome line | Status |
|---|---|---|---|
| `gate-b-spec-aaaa1111bb-pass-1:1` | major, docs-drift, README.md | `rung 2` | **Closed** |
| `gate-b-quality-aaaa1111bb-pass-1:2` | major, missing-input-validation, tool.sh | `pending todos.md#validation-lint-prerequisite` | **Open** (blocked) |
| `gate-b-quality-aaaa1111bb-pass-2:1` | minor, new class exit-code-swallowed | none | **Open** |

## Intake for `dev-workflow:harden-finding`

**1. `gate-b-quality-aaaa1111bb-pass-1:2`**
- **Finding:** an unknown flag is accepted silently instead of rejected
- **Source:** `gate-b` (Gate B quality branch, pass 1, finding 1:2)
- **Severity:** major
- **Defect location:** `tool.sh`
- **Class:** missing-input-validation (an existing class)
- **Blocked by:** `todos.md#validation-lint-prerequisite`. No `todos.md` exists in the working tree, so whoever picks this up can't find what the block refers to. That needs settling before this one can move.

**2. `gate-b-quality-aaaa1111bb-pass-2:1`**
- **Finding:** a failing step's exit code is dropped by a pipeline
- **Source:** `gate-b` (Gate B quality branch, pass 2, finding 2:1)
- **Severity:** minor
- **Defect location:** `scripts/run — all.sh`. The commit quoted this path because it contains ` — `, the field separator. No such file is tracked in the repo now.
- **Class:** new class `exit-code-swallowed`. It is not yet in `docs/hardening-taxonomy.md` or `docs/hardening-log.md`.

## One irregularity
The rules say hardening "runs afterwards, as its own change with its own gate". Here, the `rung 2` line that closes `pass-1:1` sits in the same commit as the owed lines, not in a later hardening change. The closing rule itself only asks for an outcome line in a commit that isn't a `WIP:` commit, and this one qualifies, so I've counted it as closed. However, `docs/hardening-log.md` has no row for that finding: its only row is an older bot finding dated 2026-09-01. Nothing in the repo backs up the claimed rung-2 hardening, so it's worth checking whether it actually happened.
