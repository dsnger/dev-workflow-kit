# Gate A — plan — pass 2 dispositions

11 findings, 10 Major, 1 Minor. Down from 19/13. All 11 accepted; none dismissed.

**Ten of the eleven are one class:** a verification block that reports a failure and then exits
0, or that cannot see the failure at all. In a plan whose deliverable includes the
`verification-masks-failure` hardening, that is the round committing its own subject matter —
found by a reviewer, not by the sweep I ran before committing.

## The cluster

- **2 (MAJOR)** — every verification block printed its verdict and ended on an `echo`, so shell
  status was 0 on every mismatch. Nine blocks affected. All now accumulate into `rc` and end with
  `exit "$rc"`, or use an explicit failing branch. A new Global Constraint states the rule.
- **3 (MAJOR)** — the cited-story loop ran in a pipeline subshell, so `rc=1` inside it was
  discarded; the check could print `MISS` and still report `todos exit=0`. Rewritten to read from
  a redirected file, and it now also asserts exactly four distinct paths and rejects symlinks.
- **5, 6 (MAJOR)** — `applied()` and `FIRST_WIP` were defined in one fenced block and consumed in
  later ones. Agentic workers run each block in a fresh shell, so neither was in scope. The guard
  is now written out per step, and the squash recomputes and re-validates its anchor inside the
  same block that resets.
- **4 (MAJOR)** — marker counts cannot distinguish "already applied, identical" from "partially
  applied or independently edited". The guard now compares the whole intended block,
  whitespace-normalized, with three explicit branches.
- **8 (MAJOR)** — mirror parity extracted matches from whole files without checking cardinality,
  so duplicates or two empty extractions would report equivalence. Cardinality is now asserted
  first. Placement under the corresponding heading is confirmed by reading, and the plan says so
  rather than implying the grep establishes it.

## Path handling

- **9 (MAJOR)** — a symlink whose target held identical text was eligible for reuse; `git add`
  would stage the link, and every shape check would follow the target and pass. A symlink is now
  an unconditional stop, tested before `[ -e ]`, which is false for a dangling link and true for
  a live one.
- **10 (MAJOR, medium)** — reserving an empty placeholder with `set -C` closed the
  check-to-create race and opened a create-to-write one. Replaced with write-to-temp then `ln`,
  which fails if the target exists, so content is installed atomically.
- **11 (MINOR)** — every creation failure was reported as a concurrent writer. The failure branch
  now re-stats the path and names a collision only when an entry exists, otherwise surfacing the
  real cause — the `prompt-diagnostic-cause-unnamed` class in this repo's own taxonomy.

## Claims the plan could not support

- **7 (MAJOR)** — the plan told the engineer to record counts "the run actually printed" for
  shellcheck and the hook suite, which print none. Established by running them: the hook suite
  prints `all passed` with no total (467 `ok` lines when counted); the invariants and version-bump
  suites print `all passed (123 assertions)` and `(36 assertions)`; shellcheck prints nothing.
  The evidence template now asks for each suite's terminal line verbatim and labels the
  hook-suite count as **derived**, with the deriving command — which was run before being
  written down, per "Never document a command that wasn't run".
- **1 (MAJOR)** — the no-PR story's inheritance inventory marked one trigger alternative moved and
  omitted the other ("or a project reporting an empty ledger across cycles that fixed findings").
  A dropped condition in the inventory whose whole purpose is to drop none. Added and marked
  **kept**, since it did not fire.

## Sweep after fixing

38 fenced blocks: all parse under `sh -n` and `dash -n`; none uses `${var:o:l}`, `[[ ]]`,
`<(...)`, `local` or `declare`; none accumulates `rc` inside a pipeline subshell; every block
that can fail exits nonzero when it does.
