There are two open hardening obligations. All three were recorded in one commit, `f15a9c5` ("Remove --global and fix its docs (#7)"), by Gate-B cycle `aaaa1111bb`. Its ledger check reads `fixed 3, hardening owed 3`. I applied the rule in `.claude/review-gates.md` (lines 1531–1534): an obligation closes only when an outcome line for it reads a rung or `rung 0`. A `pending` line never closes one.

**The history is complete.** The repo is not a shallow clone, and `main` is the only branch, so nothing sits on another unmerged branch. The history has two commits: `03ab506` and `f15a9c5`.

### Open obligations

**1. `gate-b-quality-aaaa1111bb-pass-1:2`: open, blocked**
- **Finding:** an unknown flag is accepted silently instead of rejected
- **Source:** `gate-b` (read from the slot), quality branch, pass 1
- **Severity:** major
- **Class:** `missing-input-validation` (existing class)
- **Where the defect sat:** `tool.sh`
- **Status:** its only outcome line is `pending todos.md#validation-lint-prerequisite`, so it is blocked by that prerequisite. `todos.md` does not exist in the working tree, so the prerequisite it points to can't be found.

**2. `gate-b-quality-aaaa1111bb-pass-2:1`: open, no outcome line**
- **Finding:** a failing step's exit code is dropped by a pipeline
- **Source:** `gate-b`, quality branch, pass 2
- **Severity:** minor
- **Class:** new class `exit-code-swallowed`
- **Where the defect sat:** `scripts/run — all.sh`. The owed line quotes this path because it contains ` — `, which the rules require.

### Closed (for completeness)
- **`gate-b-spec-aaaa1111bb-pass-1:1`** (major, `docs-drift`, `README.md`, "usage line still names the removed --global flag") is closed by `hardening …: rung 2`.

That outcome line is in the same commit that recorded the obligation. The rules say hardening runs afterwards as its own change, so this is irregular. It still counts, though, because the only conditions for closing are a rung value in a non-`WIP:` commit.

One limit, which the rules themselves state: these keys are only as reliable as the nonce. If another cycle shared the nonce `aaaa1111bb`, its outcome lines could make an obligation look closed.
