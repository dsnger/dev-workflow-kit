# Kit 0.51 proof replay — report

Proof for AC-6 (spec `docs/superpowers/specs/2026-10-30-kit-051-codex-review-design.md` §8, plan T7). The answer key
`answer-key.md` was committed before any run (`103c8ba`), and its scoring rules before the first result (`0b5d378`).
One amendment was set after the run started but before any case was scored (`bd9edfc`). Driver: `replay.sh` at
`0c65f30`. Per-case evidence (findings files, evidence files, `run.txt`, `audit.txt`) is in `evidence/case-<n>/`. The
full `--json` event logs are kept locally under `.context/k051-evidence/t7-run1/` (17 MB, not committed).

## Result

| Reading | Cases 1–6 (target ≥ 4) | Cases 7–8 (extra) | All 8 |
|---|---|---|---|
| **lenient** (#43 counted) | **4 / 6 — target met** | 2 / 2 | 6 / 8 |
| **strict** (#43 not counted) | **3 / 6 — below target** | 2 / 2 | 5 / 8 |

**The target holds only under the lenient reading.** The orchestrator dev-workflow-kit-26 ruled on 2026-10-30 at
12:35 that #43 counts as found, on the condition that both numbers are shown side by side; the quotes are below.
Cases 7–8 are reported outside the target: §8's target covers the first six cases only.

Per key defect: 9 of 38 found under the lenient reading, 8 of 38 under the strict one.

## Per case

| # | PR | Verdict | Key defects found | spec / quality / risk findings | seconds spec / quality / risk |
|---|---|---|---|---|---|
| 1 | #97 | found | 2 / 8 (K97.2, K97.3) | 2 / 1 / 5 | 372 / 461 / 627 |
| 2 | #49 | found | 1 / 6 (K49.3) | 4 / 2 / 4 | 250 / 545 / 722 |
| 3 | #41 | not found | 0 / 6 | 1 / 2 / 4 | 149 / 277 / 337 |
| 4 | #56 | found | 2 / 6 (K56.1, K56.2) | 2 / 1 / 3 | 195 / 827 / 554 |
| 5 | #43 | found (lenient only) | 1 / 2 (K43.1) | 1 / 0 / 1 | 179 / 121 / 357 |
| 6 | #40 | not found | 0 / 2 | 0 / 0 / 1 | 129 / 112 / 265 |
| 7 | #99 | found | 2 / 5 (K99.1, K99.2) | 1 / 1 / 3 | 199 / 173 / 524 |
| 8 | #95 | found | 1 / 3 (K95.1) | 0 / 1 / 5 | 406 / 188 / 591 |

### Matching lines (quoted from the findings files)

- **K97.2** (risk, MAJOR): "for-each-ref includes symbolic local refs, but eligibility and checkout checks use the alias
  name while update-ref -d dereferences it; a fixture alias pointing at refs/heads/main was reported removable and
  deleted the checked-out main ref"
- **K97.3** (spec, MINOR): "delete_branch tests only grep's status rather than whether worktree list succeeded … a
  failed final worktree enumeration still permits deletion without establishing that the branch is checked out
  nowhere". The risk call repeats it.
- **K49.3** (spec, MINOR): "changed_paths and sec_growth cancel changes on blob equality alone … A chmod-only artifact
  vanishes from changed artifacts and growth"
- **K56.1** (quality, MINOR): "OWED_HEAD and OUTCOME match the leading cycle nonce and the slot nonce independently …
  These malformed records are silently skipped instead of appearing in ledger-metrics and loop-usefulness unparsed
  diagnostics"
- **K56.2** (risk, MINOR): "A relative rules directory is validated in the caller's directory at line 20 but resolved
  again after cd to the target … fails at cp after initializing git and creating directories, leaving a partial
  target"
- **K43.1** (spec, MINOR; the risk call says the same): "Freshness includes records discarded by the 24-hour
  unattributed-call filter … A call started 30 hours ago with no cycle and a result arriving now advances newest
  observed value to now even though none of its effort is displayed, making stale displayed measurements appear
  fresh". Key K43.1: "cause: freshness ('newest observed value') is computed from all scanned calls, including calls of
  closed cycles | consequence: stale open-cycle data can appear fresh". **Why the readings differ:** Greptile's hidden
  call belonged to a closed cycle, while Codex's hidden call is an expired unattributed one. The cause is the same at
  the level of the fix (freshness computed over calls the report does not show), and so is the consequence. The fix
  `f8f9d18`, "Freshness counts only the calls the report shows", repairs both.
- **K99.1** (risk, MAJOR): "The supported partial upgrade can accept the new review-gates.md while declining CLAUDE.md;
  … does not preserve the Library APIs and Ponytail sections … With Ponytail installed its required pre-review
  silently disappears"
- **K99.2** (quality, MINOR): "Closing now archives the current cycle before committing, but compact_lines still selects
  its nonce exclusively from .context/codex-reviews; compaction after the move selects an older remaining cycle or
  omits the nonce"
- **K95.1** (risk, MINOR): "The extracted URL fragment is compared literally without a percent-decoded fallback; a link
  to #caf%C3%A9 does not match the supported lowercase heading ## café"

### Near misses, not counted

- K97.6: the quality call names the cause (both status calls inherit `status.showUntrackedFiles`). It states a
  different consequence (the worktree is kept as `ignored=unknown` because `ignored_of` fails), not the bot's
  (`dirty=no`, then removal).
- K49.2: the spec and risk calls flag the same size/mtime shortcut, but for CRLF normalization, not for a same-length
  edit with a preserved mtime.
- K56.3: the spec call reports that the replay hash differs from the final rules, which is a different cause from
  unreachable amended snapshots.
- K41.6: two calls flag check 4e, but for unchecked counting-pipeline stages, not for measuring only the first fence.

### What the risk pass added

Four of the nine matches came only from the risk pass: K97.2, K56.2, K99.1 and K95.1. Without it, 5 of 38 defects match
and #95 becomes not found, so all 8 cases score 5 / 8 lenient and 4 / 8 strict. Cases 1–6 do not change, because #97
and #56 also have spec or quality matches.

## Cost

- **Codex calls:** 24, three per case (`spec`, `quality`, risk). All exited 0. No call reached the 1200 s watchdog, so
  no case was rerun.
- **Time:** 506–1576 s of call time per case (median about 1040 s), 8560 s in total. Wall time 4951 s (82.5 min) for
  all eight cases, run two at a time, from 11:36 to 12:54 CET on 2026-10-30. Machine load was high (load average
  20–39, mostly from another project's runs).
- **Tokens:** 35.8 M input + output across the 24 `turn.completed` events. Most of the input was cached; the cached
  share is in the event logs and was not summed here.
- **Model and CLI:** `codex-cli 0.162.1`; model `gpt-6-astra` from `$CODEX_HOME/config.toml` (effort `medium` for
  `spec` and `quality`, `high` for the risk pass). The event logs do not name the model, so `risk-pass.sh` recorded
  `MODEL: unknown` in each evidence file.

## Contamination audit

- **Contaminated: 0. Unverified: 0. Tainted (`factory-review` read): 0.**
- Each risk call has one flag, a read of the user's installed
  `~/.codex/plugins/cache/claude-plugins-official/superpowers/7.0.0/skills/using-superpowers/SKILL.md`. This is
  **benign** under the amendment of 11:57 (`bd9edfc`): it is Codex's own installed skill and holds no PR history, fix
  or key. Cases: all eight.
- #95 has two more flags. Both matched `report\.md` in the in-clone path
  `docs/field-reports/2026-10-23-living-docs-pilot-report.md` (`git diff` and `git show` of the pre-fix head), so they
  are not reads outside the clone.
- In every case `diff -r` of the skill copy against the kit's showed no change before the risk pass.
- **Residual exposure** (spec §8): the reviewer can read host files outside the clone. The prompt forbids it, and the
  audit covers only what the event log shows, which is the commands Codex ran, not files its harness loads itself.

## Defects in kit 0.51 that the replay exposed (for unit 3, before Gate B)

1. **False BLOCKER in every risk pass that runs a targeted test.** `risk-pass.sh` streams the live attempt
   `.events.jsonl` into `.context/codex-reviews/`, and `run-tests.sh` fingerprints that directory. Every targeted
   test therefore returns exit 4, "checkout changed", and the skill makes that a BLOCKER. Seven of the 8 risk calls reported
   it (#43 did not). The `spec` and `quality` calls, whose event logs the driver kept outside the clone, never got
   exit 4, which supports this cause.
2. **Lost test output.** In #41 (quality and risk) and #40 (risk), `run-tests.sh` reported the suite's exit 1 and
   could not read its own temporary output file. The cause has not been found (INFERRED: the suite under test,
   `check-invariants.test.sh`, may clean shared temporary paths).
3. **Limit too short for the hook suite.** In #99, Codex gave `run-tests.sh` 180 s for the hook suite, which takes
   about 9 minutes. The skill names no time guidance per suite.
4. **`MODEL: unknown`.** Codex 0.162.1's `--json` events carry no model name, so the evidence line is always unknown.
   It could be read from the configuration instead.

## Comparison note for sfx-factory (D84)

These are the numbers to set beside `factory-review`. Neither kit's material was read for the other.
- Case selection: bot-found defects that a closed Gate B had passed.
- Unit counted: a case, found when one key defect has both cause and consequence stated.
- Reviewer: three calls per case, `spec` and `quality` at the configured effort and the risk pass at `high`.
- Scores: cases 1–6, 4 / 6 lenient and 3 / 6 strict; all 8, 6 / 8 and 5 / 8; per defect, 9 / 38 and 8 / 38.
- Cost: about 18 minutes of call time and 3 calls per case.
