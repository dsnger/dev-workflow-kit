Two hardening obligations are still open. Both come from cycle `aaaa1111bb`, recorded in commit `6c0eea9` ("Remove --global and fix its docs (#7)").

**How I checked.** `.claude/review-gates.md` says an owed line stays open until some outcome line for the same `<SLOT>:<n>` reads `rung <RUNG>` or `rung 0 — <CHECK>`. That outcome line has to be in a non-`WIP:` commit. A `pending` line never closes an obligation; it only marks it as blocked by its ref. The check covers the history of the current branch and `main`. Here they are the same branch, there are no other branches, and the clone is not shallow, so the result is complete.

**What `6c0eea9` records:** the ledger check reads `fixed 3, hardening owed 3`, with three owed lines.
- `gate-b-spec-aaaa1111bb-pass-1:1` has the outcome line `rung 2`, so it is **closed**. It was the README.md usage line still naming the removed `--global` flag.
- The other two are open, as follows.

### 1. `gate-b-quality-aaaa1111bb-pass-1:2`: open, blocked by a pending prerequisite
- **Finding:** an unknown flag is accepted silently instead of rejected
- **Source:** `gate-b` (Codex Gate B, quality branch, pass 1, finding line 2, cycle `aaaa1111bb`)
- **Severity:** major
- **Where the defect sat:** `tool.sh`
- **Class:** `missing-input-validation` (an existing class)
- **Status:** the outcome line is `pending todos.md#validation-lint-prerequisite`. It stays open and can't be closed with a rung until that prerequisite is done.

### 2. `gate-b-quality-aaaa1111bb-pass-2:1`: open, no outcome line at all
- **Finding:** a failing step's exit code is dropped by a pipeline
- **Source:** `gate-b` (Codex Gate B, quality branch, pass 2, finding line 1, cycle `aaaa1111bb`)
- **Severity:** minor
- **Where the defect sat:** `scripts/run — all.sh`. The record puts this in quotes only because the filename itself contains ` — `, the field separator.
- **Class:** `new class exit-code-swallowed`, so harden-finding would add a new class to the taxonomy rather than match an existing one.

**Something you might want to check:** the `rung 2` line that closes the first obligation is in the same commit as the owed lines. The rules say hardening "runs afterwards, as its own change with its own gate", but they only require an outcome line to sit in a non-`WIP:` commit. So that line still counts and the obligation is closed. It's just unusual that it was recorded at the same time as the obligation.
