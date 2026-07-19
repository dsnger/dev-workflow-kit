# Plan — CI check: a plugin change requires a version bump

Executes the approved spec (`spec.md`, Gate A spec run closed at pass 9). Branch
`harden/version-bump-check`, already created off `main` (5acd13e). One PR, merge when
green.

Order is deliberate: the canonical limitation text first (three artifacts must quote it
verbatim), then the checker and its suite, then CI wiring, then prose, then the bump —
so the last change is the one the check itself judges.

## Step 0 — the canonical limitation list

Write the seven-item list once, **before** anything quotes it, to
`$SCRATCH/limitations.txt` where `SCRATCH` is the session scratchpad
(`/private/tmp/claude-501/-Users-daniel-DEVELOPMENT-APPS-dev-workflow-kit/e378824d-945f-417d-b8e3-df7763c73241/scratchpad`).
Absolute, and outside the repo: a repo-relative `scratchpad/` would be a fourth untracked
artifact contradicting this plan's own staging audit, and could be staged by accident.
`git status --short` must stay clean of both scratch files. Step 1's script header, step 4's AGENTS.md invariant and the ledger `ref` all
paste from this file. Writing it here rather than inside step 4 avoids the trap of
authoring the header from memory, then editing an already-lint-and-mutation-verified
checker later just to align its wording.

Items: semantic correctness · direction · PR-only (direct pushes bypass) · deletion of
an *entire* plugin directory (manifest-only deletion fails closed — corrected mid-Gate-B)
· any change to which directory the marketplace entry points at (rename, copy, or
`source` repoint) · concurrent same-version collisions · release/tag status.

## Step 1 — `scripts/check-version-bump.sh`

Per spec § Mechanism. Shape, in order:

1. `set -u`; exactly-one-argument guard → usage on stderr, **exit 2** (the suite asserts
   2, so the CLI contract is pinned rather than described).
2. `cd "$(dirname "$0")/.." || exit 1` — **an explicit failure branch.** `set -u` does
   not abort on a failed `cd`; without the `||` the checker would continue in the
   caller's directory and report a clean tree from the wrong repo.
3. `git --literal-pathspecs` on every call. `die()` prints and exits non-zero;
   `fail()` accumulates a policy offender and sets `rc=1` (mirrors `check-invariants.sh`).
4. `mb=$(git merge-base "$1" HEAD)` — status captured, `die` naming the ref on failure.
5. `dirs=$(git ls-tree -d --name-only HEAD plugins/)` — status captured separately,
   `die` on non-zero.
6. A `for` loop over the enumeration with a newline-only `IFS` and globbing off —
   **not** `while IFS= read`, which on the right of a pipe runs in a subshell where
   `fail` could not accumulate into `rc`. Each basename (after stripping `plugins/`)
   must match `[A-Za-z0-9._-]+` → `die` naming the entry otherwise.
7. `git diff --quiet "$mb" HEAD -- "$d/"` → 0 skip, 1 continue, anything else `die`.
8. HEAD manifest presence via `git ls-tree HEAD -- "$m"` (non-zero → `die`; empty →
   **also `die`**: the directory is in HEAD's tree and changed, so it still ships, and a
   shipped plugin with no manifest has no version to key on. Only a whole directory
   disappearing is carved out, and that never reaches this line. Revised mid-Gate-B,
   which is why the spec and all three limitation lists changed in the same commit.)
9. Merge-base manifest presence, same call shape against `$mb`.
10. **`git show` per side only when that side's presence lookup found the manifest.**
    HEAD is always read (step 8 proved it exists); the base **only if step 9 found it** —
    unconditionally reading a known-absent base manifest would `die` and break accept
    case A4, turning the new-plugin carve-out into a failure. Status captured, `die` on
    non-zero.
11. `extract_version()`: the spec's `grep -o`; count matches, `die` unless exactly one;
    strip to the quoted value; `die` if the value contains a backslash. HEAD always; base
    only when present (absent → base version empty, differs from any real version, A4
    passes).
12. Compare; equal → `fail` naming the plugin and the version.
13. Print every offender; `exit "$rc"`.

Header comment: what it catches; **the step-0 list pasted verbatim**; the parser ceilings
(nested `version` key, multi-line JSON fails closed, spelling compared rather than parsed
value); that POSIX `sh` here is this script's own requirement and **not** invariant 4,
which is hook-scoped; and TESTED SPELLINGS ONLY, like its sibling.

**Verify:** `shellcheck --shell=sh scripts/check-version-bump.sh` → 0.

## Step 2 — `scripts/check-version-bump.test.sh`

Throwaway repos under `mktemp -d`, with the sibling suite's `work` guard and `trap`
(abort if `mktemp` produced nothing — `rm -rf "$work/r"` on an empty `work` is `rm -rf /r`).

Helpers:
- `mkrepo()` — `git init`, deterministic identity passed per-invocation
  (`git -c user.name=… -c user.email=…`), never touching the developer's global config;
  a base commit on `main`, then a branch.
- `expect_reject NAME PATTERN…` — **accepts one or more required patterns**, all of which
  must appear, plus a non-zero exit. P4 (two un-bumped plugins) passes both plugin names,
  so a first-failure implementation that names only one fails the row. A single-pattern
  contract would let exactly the defect P4 exists to catch slip through.
- `expect_accept NAME`; arity rows additionally assert **exit status 2**.
- `with_failing_git` — a wrapper early on `PATH` matching the **full argv**
  (`case "$*"`), `exec`ing the real git otherwise. Written into that case's own temp dir;
  `PATH` exported only inside the subshell that runs the checker.

Rows: P1–P4, P7–P10; O1–O18 (incl. O15b escape, O16 space, O17 C-quoted, O14/O15 arity,
and O18 manifest-only deletion, which began as accept row A6 and became a reject in
Gate B); accepts A1–A5 and A7–A10 (no A6 — it is now O18). Printed in `policy:` /
`operational:` / `accept:` groups so a mutation's effect is readable at a glance.

**Verify:** `sh scripts/check-version-bump.test.sh` → all assertions pass;
`shellcheck --shell=sh scripts/check-version-bump.test.sh` → 0 (no exclusion: this
suite has no `[ c ] && pass || fail` lines, so nothing needs excluding).

**Mutation, run and recorded — not asserted from theory:**
1. `cp scripts/check-version-bump.sh "$SCRATCH/checker.pristine"` (the same absolute
   scratchpad as step 0, never a repo-relative path); record `shasum` and `ls -l` mode.
2. Replace the version comparison with `false`; re-run the suite.
3. Confirm **exactly the P rows fail**, every O and A row green. Any other row moving
   means the suite is wrong, not the mutation.
4. Restore by copying the pristine file back, then **prove the restore with `cmp`
   against `checker.pristine`** plus a mode check. (`git diff` proves nothing here: the
   file is untracked until step 5, so it reads empty before and after any mutation —
   a safeguard that cannot fail is not a safeguard.)
5. Re-run the suite; fully green again.

## Step 3 — CI wiring (`.github/workflows/ci.yml`)

- `checkout` gains `fetch-depth: 0`; `persist-credentials: false` stays.
- The shellcheck step gains the two new files against the same pinned image. **Rename the
  step** from "Lint hook scripts (POSIX sh)" — it has covered more than the hook since
  `check-invariants.sh` — and re-scope its comment: invariant 4 is hook-scoped, so the
  hook's POSIX requirement is attributed to invariant 4 and the checkers' to their own
  CI-invocation requirement.
- **`scripts/check-invariants.sh`'s own header is corrected in the same pass**: it
  currently reads "POSIX sh, no jq (invariant 4)", the exact misattribution this step
  says must not be blurred. Leaving it would fix the new file and the CI comment while
  the older checker keeps making the claim. Re-run its shellcheck and its suite after
  the edit.
- The invariant-checks step gains `sh scripts/check-version-bump.test.sh`.
- New step, `if: github.event_name == 'pull_request'`, with
  `env: BASE_REF: ${{ github.base_ref }}` and
  `run: sh scripts/check-version-bump.sh "origin/$BASE_REF"`. Comment says why it is
  PR-only and that a direct push to main bypasses it.
- No new action, no new image → nothing new to pin (invariant 5 unaffected; the invariant
  checker itself confirms this in step 5).

**Drift sweep, repository-wide and by exact phrase** — not limited to `ci.yml` and the
README, since the same strings appear in AGENTS.md and `docs/architecture.md` and step 4
edits those for other reasons:
`four checks` · `four-check battery` · `both executables` · `second executable artifact`
· `their two suites` · `only executables` · `Invariants 5 and 6`, each searched with
`grep -rn … | grep -v source-files/`, and **every hit dispositioned** (updated, or
consciously left with a reason). Afterwards the `ci.yml` step names and comments are
re-read whole: a step *name* can go stale in ways no phrase list anticipates.

**Verify:** honestly, **nothing locally**. `claude plugin validate . --strict` does not
read `.github/workflows/ci.yml`, so it proves nothing here and must not be cited as if it
did; this repo has no pinned YAML/actions validator and adding one is outside this change.
Step 3's verification is step 6.2's observation of the actual run. Recorded as locally
unverified rather than claimed green.

## Step 4 — prose

1. `plugins/dev-workflow/CHANGELOG.md` — entries 0.4.1 … 0.1.0 per the spec's interval
   rule. **Two distinct verifications, both recorded:**
   - *Heading completeness*: the distinct manifest versions in history
     (`for c in $(git log --format=%h --reverse -- <manifest>) …`) **union the declared
     target 0.4.1** must equal the set of `##` headings. The union matters: 0.4.1 does not
     exist in history at this point, so a plain comparison would report the required
     heading as extra. **Re-run without the union after step 5.2's WIP commit**, where
     history does contain it, as the real check.
   - *Interval coverage*: for each version, `git log --oneline <prev>..<this> -- plugins/`
     and reconcile the entry's bullets against that list. Heading-set equality proves no
     release is missing; it does not prove a change landed in the right release, and
     misattribution is the likelier error.
   - **Both checks re-run after step 5.2's WIP commit**, not just the heading one: until
     that commit exists, 0.4.1's interval has no closing commit, so its entry cannot be
     reconciled against the plugin changes it actually ships. If the post-commit
     reconciliation changes the CHANGELOG, stage it, amend the WIP commit (WIP `-m`), and
     repeat both history checks before running the battery.
2. `AGENTS.md`:
   - invariant **12** under Packaging (stable global number; nothing renumbered), quoting
     step 0's list verbatim;
   - architecture tree gains `scripts/check-version-bump.sh`, its `.test.sh`, and the
     CHANGELOG;
   - § Boundaries executables sentence;
   - § Commands: `lint` and `quality` gain the new files; **`test` stays hook-only**
     (it names the hook's state-machine suite; the checkers' suites live with the
     invariant checks). Plus a **separate** row for invariant 12
     (`invariant check (12 version bump)`) rather than folding the suite into the
     existing `invariant checks (5 pinning, 6 manifest)` row. Separate, because
     invariant 12's checker takes an argument and carries a commit-derived precondition
     that rows 5/6 do not — merging them would have hidden that precondition inside a
     row that has none. The row states the precondition explicitly;
   - invariant 7 wording; the MANIFEST.md description line.
3. `docs/architecture.md`, `README.md` § Contributing — executables and CI shape.
4. `plugins/dev-workflow/examples/README.md` — the "read, don't install" clarification.
5. `docs/hardening-taxonomy.md` — mint `artifact-version-not-bumped` with alias hints.
6. `docs/hardening-log.md` — re-read, run the anchored grep, append one row, **then run
   the anchored grep again** and confirm exactly one `artifact-version-not-bumped` row
   with the intended fields. An append is a write that can go wrong; checking only
   beforehand checks the wrong moment.

**4a. Three-way identity check.** After the header, the invariant and the ledger `ref`
all exist, diff each extracted block against `$SCRATCH/limitations.txt` (step 0's
absolute session scratchpad path, not a repo-relative one) and record the
result. This list already drifted once inside the spec itself.

**4b. Prompt-standards item 11 review of the new invariant text**, recorded — the spec
assigns this deliberately (a voluntary review, not invariant 11 applicability). Every
enforcement claim in invariant 12 must name its mechanism (the checker), its event scope
(pull requests only), and carry the complete limitation list.

**Verify:** run the AGENTS.md-mandated grep
(`grep -rniE 'declare[sd]?|convention[- ]load' --include='*.md' . | grep -v source-files/`)
**before** editing AGENTS.md/`docs/architecture.md`, and read the hits rather than
trusting the count.

## Step 5 — bump, snapshot, verify, Gate B

The checker reads **commits**, so anything run before a commit exists measures the wrong
tree. Sequence is load-bearing.

1. `plugins/dev-workflow/.claude-plugin/plugin.json` → `0.4.1`.
2. **WIP commit, staged explicitly and audited.** Three of the artifacts are new
   untracked files, so `git commit -a` would silently omit them and leave the battery
   passing from the working tree while Gate B and CI saw nothing: stage the intended path
   set by name, inspect `git diff --cached --stat` and `git status --short`, commit as
   `WIP: version-bump check` (the `wip` prefix keeps the hook from reading it as a
   cycle-closing commit and discarding the pass counters), then confirm no intended
   change remains outside HEAD.
3. **Then** the quality battery — **run the updated AGENTS.md § Commands quality line
   verbatim**, not a hand-enumerated approximation (an enumeration already dropped
   `sh scripts/check-invariants.sh` once while claiming to be exhaustive). One run,
   output kept.
4. **Repository-level negative proof, committed rather than working-tree.** Record the
   pre-proof tree id (`git rev-parse HEAD^{tree}`). Edit the manifest to 0.4.0,
   **`git add plugins/dev-workflow/.claude-plugin/plugin.json`** — an amend commits the
   *index*, so an unstaged edit leaves the amended tree still bumped and the "rejection"
   run exits 0, proving nothing while looking like proof — then
   **`git commit --amend -m "WIP: version-bump check"` (every amend carries the WIP
   `-m`**, never `--no-edit`: the hook classifies from the commit command text, so a bare
   amend reads as a real commit, closes the Gate-B cycle and emits a premature STOP).
   Audit the committed manifest value (`git show HEAD:<manifest>`) before trusting the
   run. Same staging discipline on the way back. Run
   `sh scripts/check-version-bump.sh main` → must exit 1 naming `dev-workflow`. Amend back
   to 0.4.1 (same WIP message) → run again → must exit 0. Then **require the restored tree
   id to equal the recorded one** and re-run the full battery: two history rewrites sit
   between the battery and the final commit, and only the version checker would notice a
   tree that came back subtly different.
5. **Gate B**, per CLAUDE.md §5 — the full loop, not its floor:
   - Call: `mcp__codex__review` with `instruction` (the original task),
     `whatWasImplemented` (the checker, suite, CI wiring, prose, bump), `baseSha` = the
     WIP commit's parent, `headSha` = HEAD, `reviewType: full`, and `additionalContext`
     carrying: check against AGENTS.md; report **every** finding with severity and
     confidence; the one-line format
     `MAJOR | high | file:line | what | consequence | fix`; and the literal `NO FINDINGS`
     when clean.
   - Validate each finding; fix Blocker/Major; collect Minor/Nit without iterating.
   - **After each accepted fix: stage it and amend the WIP commit** (with the WIP `-m`),
     then re-review the new range. `review` reads the committed range, so re-reviewing
     without amending re-reads the stale snapshot and "passes" on unfixed code.
   - **Re-run the affected checks after each fix, and the full quality command before the
     final clean pass** — a review-driven change can invalidate the green battery.
   - Minimum three passes; the only early exit is a pass with zero findings; **pass 3 is
     not terminal while Blocker/Major remain** — continue until clean or clearly stuck.
   - A codex call that dies at the MCP tool-call timeout is **retried once** before
     surfacing; pass state lives in `.context/`, so nothing is lost.
   - **Specified-behaviour changes:** the spec is tracked at
     `docs/superpowers/specs/2026-07-19-plugin-version-bump-check.md` and this plan
     beside it, following the convention the two 2026-07-18 documents established.
     (An earlier revision of this plan asserted the repo tracks no spec file; that was
     wrong, found while running the drift grep, and corrected here.) Any Gate-B fix that
     changes specified behaviour updates that spec **and** the tracked artifacts encoding
     the same decisions — AGENTS.md invariant 12, the script header's limitation list,
     the ledger `ref` — in the same amended commit, so the next pass reviews a consistent
     set.
   - **If stuck:** `git reset --soft` back to the WIP commit's parent — index and working
     tree preserved, nothing lost — then stop and surface the unresolved findings.
     **Not** an amend to a real message: that is the cycle-closing move reserved for a
     clean final pass, and using it here would have the hook record a completed cycle,
     discard the pass counters, and leave a publishable-looking commit carrying
     unresolved Blocker/Major findings.
6. `git commit --amend` to the real message (the one non-WIP amend, closing the cycle);
   push; open the PR.

## Step 6 — PR

1. **Always** run `/dev-workflow:process-pr-review` — not only "if a bot comments".
   CodeRabbit may still be pending and Greptile can post late; the command owns the
   waiting and routing per `docs/pr-review-bots.md`, and merge-readiness is its output,
   not an inference from a quiet PR.
2. **Confirm the new CI step actually executed.** A skipped step leaves the job green, so
   a green PR does not prove the PR-only check ran. Read that step's conclusion and log on
   the PR head and confirm it invoked the checker with the expected `origin/<base>`
   argument. This — not the job colour — is the acceptance test for step 3, which has
   never run in a real `pull_request` context before this PR.
3. Merge when CI is green, step 6.2 is confirmed, and bot processing is complete.

## Risks

- **Step 3 is unverifiable locally.** Failure mode is a red PR or a visibly skipped step,
  both caught by 6.2 — not a silent pass.
- `fetch-depth: 0` on the runner: ~50 commits, negligible.
- The suite's `git` wrapper escaping its case: written into that case's temp dir, `PATH`
  exported only inside the subshell that runs the checker.
- The mutation leaving the checker neutered: guarded by the `cmp`-against-pristine restore
  check in 2.4 and the re-run in 2.5.
- Repeated WIP amends losing work: guarded by the tree-id comparison in 5.4.
