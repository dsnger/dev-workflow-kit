# Over-engineering check — Implementation Plan

**Story:** `docs/superpowers/stories/2026-10-08-overengineering-check-story.md` (read its profile fresh)
**Spec:** `docs/superpowers/specs/2026-10-08-overengineering-check-design.md` (Gate-A spec cycle `vjplpucfn1` closed at `c9fce5e`)

**Plan form.** This plan is compact, per `CLAUDE.md` §4 "Spec, plan and code", which outranks
`writing-plans` where the two differ. Each task states:
- its outcome;
- its files and what it reuses;
- its prerequisites and settled decisions;
- its test situations, with expected outcomes;
- the implementer's decision space.

It contains no function bodies and no complete test code.

**Execution:** one implementer, tasks in order, on branch `overengineering-check`. Tasks 1–3 are
independent of each other in content. Task 4 needs Task 1, and Task 5 needs all four.

**Handover boundary:** the completed story. That is the Gate-B closing act on this branch, plus
the PR. No earlier boundary is chosen. If a session must end before that, the Gate-B resume rules
in `.claude/review-gates.md` apply, not this plan.

## Global constraints

- Budget: **150,000 characters**, this repository's budget, not a client limit (spec §5.2).
- Measured: exactly `CLAUDE.md` + `AGENTS.md` at the repository root, in characters under a UTF-8 locale (spec §5.1, §2). No import lock (spec §5.3).
- Nothing under `plugins/` changes, so no version bump (spec §1). `sh scripts/check-version-bump.sh main` must still pass.
- POSIX `sh`, and `shellcheck --shell=sh` passes on both changed scripts (AGENTS.md invariant 4 and § Commands).
- No saving claim, and no "benefit" wording, anywhere in the delivered text (spec §1, §5.4).

## Review focus

These are failure modes the spec implies and that a reviewer should look for. Each line names
the task whose tests pin it.

1. A check that **fails open**: no locale, a missing or unreadable file, or an empty count read as zero. Expected: each one is a named failure, never a pass (Task 1).
2. **Fixture isolation:** the suite's fixture repos have no `CLAUDE.md` or `AGENTS.md`. A fail-closed 4g would turn every existing case red for the wrong reason. Expected: the shared initializer writes small valid copies, the same way it already does for 4c, 4d and 4e (Task 1).
3. A **directory or symlink** named `CLAUDE.md`. Expected: a directory fails as missing or unreadable; a symlink to a readable file is counted like a file (Task 1).
4. **Off-by-one at the budget:** counting newlines. Expected: exactly the budget passes, and one character over fails (Task 1).
5. A **counter-check that fails for the wrong reason:** another check failing on historical content. Expected: 4g's budget line is the only failure, or every other failure is reported and explained (Task 4).

---

### Task 1: Check 4g and its tests

**Outcome:** `sh scripts/check-invariants.sh` fails, with the sum and the budget in its message, when
`CLAUDE.md` + `AGENTS.md` exceed 150,000 characters. It fails closed on every condition under which
it cannot count. The regression suite pins this with reject/accept pairs.

**Files:**
- `scripts/check-invariants.sh`: a new marked block `# --- BEGIN check 4g ---` … `# --- END check 4g ---` after `# --- END check 4f ---` (`:807`) and before the final `rc` report (`:809`). Its header comment states what it measures, the unit, the budget and its basis (spec §5.2), and what it does not measure (spec §5.3).
- `scripts/check-invariants.sh` header, `:24-27`: the mutation-procedure sentence that lists the marked checks, plus the `chk=` sequence comment, gain 4g.
- `scripts/check-invariants.test.sh`:
  - `init_prompt_fixtures` (`:31`) writes a small `CLAUDE.md` and `AGENTS.md` into every fixture root, with a comment giving the same isolation reason as the existing 4c, 4d and 4e lines;
  - a new section of 4g cases after the 4e section;
  - the mutation-evidence block (`:396-425`) gains a 4g line.

**Reuse:**
- 4e's UTF-8 locale probe and its `wc -m` count (`scripts/check-invariants.sh:713-725`).
- The script's `fail` reporting (`:97`).
- 4e's case-builder pattern in the suite (`te_case`, `:871`): a case-specific builder that sets up a valid fixture, replaces only what the case varies, and asserts both the exit status and a diagnostic substring.

**Settled:**
- The message names the sum and the budget, so a reject case can assert on them.
- A failure to count is reported as untrustworthy, never as a pass.
- Before comparing, 4g checks that the count is a non-negative integer and that the step reading the files succeeded. An empty or non-numeric count, or a failed read, is a named failure. Why: in POSIX `sh`, `[ "" -gt N ]` is an error that evaluates false, so an unchecked empty count would pass silently.
- The failure cases reuse existing suite patterns and add no new harness: `inject_case` (`:688`) for a tool that fails on a matching argument, and the `chmod 000` lock used by the 4c case at `:850`, skipped as root like the existing fixture at `:638`. For the empty and non-numeric count cases, the existing PATH-stub pattern (`:659-672`, a fake tool placed in `fakebin`) is extended only as far as these two cases need: a stub that answers the locale probe and the read as the real tools would, and returns empty or non-numeric output for the count. How the stub tells the probe from the count is the implementer's choice, provided each case reaches 4g's count check and not an earlier failure (asserted by 4g's message).

**Test situations (reject must also carry its diagnostic):**

| Case | Expected |
|---|---|
| combined size exactly 150,000 characters | accepted |
| combined size 150,001 characters | rejected; message carries `150001` and `150000` |
| split across the two files (for example 100,000 + 50,001) | rejected; it is the sum that counts, not each file |
| multi-byte content: 150,000 two-byte characters in total | accepted; characters are counted, not bytes |
| `CLAUDE.md` missing | rejected, naming the missing file |
| `AGENTS.md` missing | rejected, naming the missing file |
| `CLAUDE.md` is a directory | rejected (missing or unreadable), never counted as zero |
| `CLAUDE.md` is a symlink to a readable file | counted like the file it points to |
| `AGENTS.md` unreadable (`chmod 000`; skipped as root) | rejected, naming the unreadable file |
| no UTF-8 locale: `inject_case` makes `wc -m` fail, so the probe finds no locale | rejected with 4g's no-locale message (4e fails too; the case asserts 4g's diagnostic) |
| reading the files fails: `inject_case` on the tool that receives the file names | rejected as an untrustworthy count, never read as 0 |
| count output empty, while the locale probe and the file read succeed | rejected with 4g's untrustworthy-count message |
| count output non-numeric (for example `x`), probe and read succeeding | rejected with 4g's untrustworthy-count message |
| both files present and empty: a legitimate count of 0 | accepted; 0 is a number, not an empty result |
| the real repository (`sh scripts/check-invariants.sh` at the root) | `invariant checks: ok` |
| every pre-existing case | unchanged outcome after the initializer change |

**Mutation:** run the procedure at `scripts/check-invariants.sh:24-56` with `chk=4g`. Expected:
- the baseline is green;
- the mutant is red;
- the flipped set is the 4g reject cases, including its `inject_case` and lock cases, and no accept case.

A human confirms the flipped set, as that procedure requires. Because the shared initializer
changed, re-measure 4a–4f the same way and record all seven numbers in the evidence block. Write
only measured numbers, never carried-over ones.

**Decision space:** helper names; whether 4g shares the locale probe with 4e through a small shared
helper or repeats the two-line probe; how the files are read and counted, provided the reading step's failure is observable to the `inject_case` the suite uses; the exact wording of messages, within the rule that the sum,
the budget and the cause are named.

### Task 2: `AGENTS.md`

**Outcome:** `AGENTS.md` names 4g, and states its boundary in one sentence.

**Files:** `AGENTS.md`:
- the "invariant checks" row in § Commands (`:308`): its label gains "repo instruction size";
- one sentence after the table, in the paragraphs that already explain the battery, with the boundary: the two files, characters, the 150,000 repo budget, and that other loaded content is outside the measurement.

**Settled:** no new invariant. The `## Architecture` tree comment for `scripts/check-invariants.sh`
(`:38`) and `docs/architecture.md:19` already omit 4e. Whether they need 4g is left to the Gate-B
standing lens. Changing them is not required by the spec.

**Test situation:** the battery passes. 4g still passes on the grown `AGENTS.md`. Record its new
total for the report.

**Decision space:** the exact sentence and where it goes after the table.

### Task 3: `todos.md` notes

**Outcome:** the dated notes of spec §4, each on an existing row, with no new row.

**Rows and content** (line numbers as of `fd4c1de`; the notes themselves move later rows):
- **"The arms-race remedy exists as an observation and not as a procedure"** (`:221`):
  - #50 Gate B as story §1 now reads it: the class was generalised in passes 5–6, and passes 7–10 concerned further environment sources and the order of the checks; that this was an arms race is not established;
  - candidate: a method or alternatives statement at the existing halt, with its limits (#50 does not carry it; canvas A5/T2a is unverified here);
  - the row's story is unchanged.
- **"EXPERIMENTAL — proportionality for findings whose subject is a test instrument"** (`:269`): fic2 as motivation only, with its path; the trigger is still not shown.
- **G3c** (`:687-690`): the kit-side gap. 4e measures only the template, so nothing keeps a project's `AGENTS.md` within budget. Add canvas `AGENTS.md` at 126,332 bytes as problem evidence, with its source. The canvas cleanup itself is outside the kit's backlog (spec §4).
- **"Over-engineering check"**: replace "each repair spawning an adjacent case" with a reading that matches story §1. This discharges the dependency the story's change record lists as blocking Gate B. Then add a pointer to the report path.

**Settled:** every note is dated 2026-10-08 and links to the spec instead of copying it (story AC-7).

**Test situation:** a reading check. Each note's claim matches story §1 and spec §4. `grep -n 'adjacent case' todos.md` returns nothing.

### Task 4: Counter-check on the historical contents

**Outcome:** observed evidence that 4g fails on the `b18e7db` contents for the expected reason,
and passes on the current tree.

**Procedure:**
- take a scratch copy of the current tree with Task 1 applied (the scratchpad or `mktemp -d`, not `.context/`);
- replace only `CLAUDE.md` and `AGENTS.md` with `git show b18e7db:<file>`;
- run `sh scripts/check-invariants.sh` there;
- run it on the unmodified copy as well.

**Expected:**
- historical: non-zero exit, and 4g's budget line naming **151,246** and 150,000;
- current tree: `invariant checks: ok`.

If any other check also fails on the historical copy, report its line and explain it. Never hide
it by filtering.

**Recorded where:** the full output lines go into the report (Task 5) and into the evidence entry
of the closing commit. Nothing is claimed before it has run.

### Task 5: Report, battery, Gate B

**Outcome:** `docs/field-reports/2026-10-08-overengineering-check.md` exists; the battery is green;
the Gate-B cycle runs to closure.

**Report content (spec §6):**
- the results;
- the evidence: Task 4's output, the test and mutation numbers;
- the size of the two files before (`a9743c4`: 38,452 characters) and after;
- the limits, from spec §5.3 and §1;
- the observations a later reader can make: a future 4g failure, and `status-view`'s "rule files" group in bytes and lines. These are observations, not a benefit.

The report links to spec §3, §4 and §7 and to the `todos.md` rows instead of copying them.

**Battery:** the full quality command in `AGENTS.md` § Commands, run after the work is committed
as the Gate-B `WIP:` snapshot, so `check-version-bump.sh main` compares commits.

**Gate B:**
- `mcp__codex__review`, `reviewType: full`;
- `baseSha` = the merge-base with `main`, so the range includes `781d9d4`, the story commits and the spec;
- `headSha` = the explicit 40-character HEAD;
- the floor and the lens sets derived from the story's profile, read fresh at each pass;
- the evidence entry (battery result, Task 4's counter-check, the test pairs) is quoted verbatim in each call, with the story path.

No triviality skip.

**Closing:** amend the `WIP:` commit with the evidence entry, the provenance line and the curve,
following `.claude/review-gates.md` Mechanics. Then push and open the PR.

## Sources and impact boundary

**Read for this plan:**
- the spec;
- the story and its change record;
- `scripts/check-invariants.sh`: the header `:1-97`, 4e `:650-730`, the end `:807-810`;
- `scripts/check-invariants.test.sh`: `:1-60`, `:118-150`, `:392-430`, `:855-895`;
- `AGENTS.md`: § Commands and the lines naming the checker (`:38`, `:78`, `:203`, `:216`, `:308`);
- `README.md:162`, `docs/architecture.md:19`;
- `.github/workflows/ci.yml:64-117`.

**Impact boundary:**
- changed: the checker and its suite; `AGENTS.md` (which the new check itself measures); `todos.md`; one new report.
- unchanged: no plugin file, no template, no hook, no gate rule.

**Not read:** the remaining 4a–4f test sections beyond their shared initializer. They are affected
only through that initializer, which is why Task 1 re-measures their mutation numbers.
