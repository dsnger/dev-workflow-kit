# Kit shrink verification — 2026-10-12

Authority: Daniel's keep-list B1–B10 and addendum 1 (11:35 via `dev-workflow-kit-d4`).
Rollback: `pre-shrink` at `6b15993`. Draft PR: https://github.com/dsnger/dev-workflow-kit/pull/62.
Worktree: `/Users/daniel/DEVELOPMENT/APPS/dev-workflow-kit-shrink`, branch `kit-shrink`.

## Changes and coverage

Sizes and coverage below reflect Fix round 1; the earlier battery result is retained as history.

The binding gate rules now implement B1–B10 in both copies. The large working-record,
closure-ordering and replay procedures were deleted; new/copy exceptions are individually
traced in [the strike-list](strike-list-2026-10-12.md).
Harden-finding retains lint/test routes; intake's amendment route retains condition
accounting and its exact closed-set template. The plugin minor version is 0.24.0
above main's 0.23.0; the changelog and describing text were updated.

| File | Before bytes | After bytes | Original / covered lines |
|---|---:|---:|---:|
| `.claude/review-gates.md` | 139111 | 6401 | 1665 / 1665 |
| `plugins/dev-workflow/commands/workflow-init.md` | 232086 | 101771 | 3143 / 3143 |
| `plugins/dev-workflow/skills/harden-finding/SKILL.md` | 11921 | 10201 | 193 / 193 |
| `plugins/dev-workflow/skills/intake/SKILL.md` | 32932 | 23501 | 519 / 519 |
| `AGENTS.md` | 23397 | 23368 | 301 / 301 |
| `CLAUDE.md` | 12045 | 11699 | 146 / 146 |
| `docs/PRD.md` | 2988 | 3018 | 43 / 43 |
| `docs/ARCHITECTURE.md` | 10324 | 10421 | 153 / 153 |
| `plugins/dev-workflow/CHANGELOG.md` | 62660 | 63484 | 848 / 848 |
| `plugins/dev-workflow/.claude-plugin/plugin.json` | 490 | 492 | 12 / 12 |
| `scripts/check-invariants.sh` | 57717 | 57720 | 976 / 976 |
| `scripts/check-invariants.test.sh` | 72845 | 72924 | 1284 / 1284 |
| `plugins/dev-workflow/commands/process-pr-review.md` | 14624 | 14626 | 232 / 232 |

An independent Python read of the strike-list's ranges confirmed every line appears
exactly once, with no gaps or overlaps (exit 0). It also compared AGENTS.md's entire
Key invariants section with `pre-shrink` and checked the changed-path list: invariants,
hook and tests, Python reports, examples, source-files, docs/superpowers and todos.md
are unchanged. Neither commits nor staging included `.context/`.

The history directory deliberately adds archived bytes; this is a reduction of binding
rule text, not a claim that the repository's total byte count decreased.

## Archives and parity

Each archive has the required one-line header. The body after that header was compared
with the corresponding `pre-shrink` blob (for workflow-init, its exact template body).
These four actual commands all exited 0 with empty output:

```sh
cmp /tmp/kit-shrink-original-review-gates /tmp/kit-shrink-archive-review-gates
cmp /tmp/kit-shrink-original-workflow-init-2.1a /tmp/kit-shrink-archive-workflow-init-2.1a
cmp /tmp/kit-shrink-original-harden-finding /tmp/kit-shrink-archive-harden-finding
cmp /tmp/kit-shrink-original-intake /tmp/kit-shrink-archive-intake
```

`diff .claude/review-gates.md /tmp/kit-shrink-extracted-template.md` exited 0,
with empty output. Known scaffolding differences inside the extracted content: **none**.
The command's section heading, setup prose and outer four-backtick fence are outside
that content, so neither copy inherits the other's scaffolding.

Separate source-text checks confirmed the retained intake/harden-finding lines are
literal original text, including whole-sentence deletion at line boundaries (exit 0).
Nonblank rule-line counts: B1 3/6, B5 4/8, B6 6/6, B7 9/10, B8 2/3, B9 1/3, B10 2/3.
B2/B3 retain the requested review prompts; B4 retains the exact findings format.

## Initial-round checks (HEAD 5731c45)

- `git diff --check`: exit 0.
- `sh scripts/check-invariants.sh`: exit 0 (`invariant checks: ok`).
- `sh scripts/check-invariants.test.sh`: exit 0 (`all passed (268 assertions)`).
- Full quality battery: exit 0, including shellcheck, both hook shells, invariant and
  version-bump checks, all six report suites and `claude plugin validate . --strict`.
- Check 4h mutation: removing only check 4h in a scratch copy made the suite exit 1;
  exactly 28 reject assertions flipped (240 passed), all belonging to 4h, with no
  accept assertion changed. The mutation-analysis driver exited 0.

Only check 4h's dispositions enum and the corresponding shared test fixture changed:
`fixed | accepted, not repaired | declined`, as B5 requires. All seven required record
forms remain checked. The other six lines, region checks and failure behavior are retained.
This is the keep-list-over-contradiction rule from addendum 1, not a weakening of the
seven-record requirement. No other checker behavior was amended.

The exact quality command extracted from AGENTS.md and run through `sh`:

```sh
shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && shellcheck --shell=sh scripts/check-invariants.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && shellcheck --shell=sh scripts/check-version-bump.sh && shellcheck --shell=sh scripts/check-version-bump.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/ledger-metrics.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/run-analytics.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/loop-usefulness.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/spec-delta.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/live-effort.test.sh && shellcheck --shell=sh --exclude=SC2015 scripts/status-view.test.sh && HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh && HOOK_SH=dash dash plugins/dev-workflow/hooks/codex-gate.test.sh && sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh && sh scripts/check-version-bump.test.sh && sh scripts/check-version-bump.sh main && sh scripts/ledger-metrics.test.sh && sh scripts/run-analytics.test.sh && sh scripts/loop-usefulness.test.sh && sh scripts/spec-delta.test.sh && sh scripts/live-effort.test.sh && sh scripts/status-view.test.sh && claude plugin validate . --strict
```

Final battery output (last 15 lines):

```text
PASS c19:valid ledger lines leave records and cycles unchanged
PASS c19:the cycle keeps its provenance and curve
PASS c19:the skip record keeps its reason
PASS driver exited 0
PASS mutant none-for-unknown caught by c5
PASS mutant first-record-only caught by c14
PASS mutant reread-everything caught by c9
PASS mutant keep-raw-model caught by c12
PASS mutant mentions-count caught by c13
135 passed, 0 failed
Validating marketplace manifest: /Users/daniel/DEVELOPMENT/APPS/dev-workflow-kit-shrink/.claude-plugin/marketplace.json

✔ Validation passed

QUALITY_EXIT=0
```

## Prompt checklist review

All 12 items were considered against the changed prompts: target/tool naming, completion,
stops, output form, structure, rationale, consistency, brevity, positive instructions,
diagnostics, enforcement claims and emphasis. Target model declarations in the two skills
and command remain unchanged; gate prompts explicitly name Codex tools. Findings and
record forms are explicit; the cap is a human stop, and incomplete passes do not count.
The approved deletion brief deliberately removes surrounding rationale and procedures;
no extra rationale was added merely to satisfy checklist item 6. Legacy descriptions in
out-of-scope files are not asserted to match the new workflow (item 7 boundary).
No text claims the unchanged hook enforces the new floor/cap or disposition behavior.

Current prompting references consulted for item 1:
[Anthropic best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
and [OpenAI prompting](https://learn.chatgpt.com/docs/prompting).
This was a self-review, not an independent Gate A or Gate B.

## Remaining review boundary

No unresolved question from the brief/addendum remains. The requested separate Claude
session still reviews the strike-list. Hook message/threshold changes remain the separate
story specified by the brief; existing report parsers and out-of-scope workflow descriptions
were not rewritten. No release, merge or independent review is claimed here.

No Gate B on this change by Daniel's decision 2026-10-12; verification = strike-list review by a separate Claude session.

Final base refresh: `git fetch origin` exited 0; `origin/main` remains `6b15993`
(plugin 0.23.0). The version bump is therefore 0.24.0.

## Fix round 1

Requested after the separate Claude verdict on `5731c45`: fix findings 1–10 in one
round, keep PR #62 as a draft, and run the complete battery again. This section
supersedes the earlier "remaining review boundary" for those ten findings.

| Finding | Change |
|---|---|
| 1 | Restored harden-finding's full original description line verbatim from its archive. |
| 2 | Restored all of template 2.2 verbatim from pre-shrink, including Columns and the full Superseded-rows convention. |
| 3 | Removed deleted section names from both CLAUDE.md §5 pointers; both point to the rules file without stale section names. |
| 4 | process-pr-review's ledger pointer now names Closing act. |
| 5 | Manifest description now says lint/test hardening instead of escalation ladder. |
| 6 | Kept only describing changes in CLAUDE.md (delete the stale mandatory-plan workflow sentence, fix the pointer) and ARCHITECTURE.md (describe history/ in the layout). No other differences exist against pre-shrink in those files, so no unrelated edit needed reverting. |
| 7 | Rebuilt coverage with exact old-to-new contiguous ranges and an explicit trace for every inserted/partial line; added NEW rows for all 13 changelog lines and the architecture line. The nonexistent two-blank KEPT block is gone. |
| 8 | Removed only the dangling `5. ` before intake's retained condition-accounting rule. |
| 9 | Replaced NEW B2/B3 prompt paraphrases with 11 original excerpts, preserving their text verbatim; recorded KEPT source ranges. The one B2 excerpt differing between original copies is COPIED from the repo original under addendum 1. Both current copies remain identical. |
| 10 | Version stays 0.24.0; it must be re-bumped at rebase time if ticket-skill merges first. |

The source coverage now includes process-pr-review.md: **9,515 / 9,515 original lines
across 13 files**, with no gaps or overlaps. Every KEPT block is contiguous in the new
file, and every new-file line outside such a block has exactly one explicit trace row.
All DESCRIBING edits are listed separately in the strike-list.

### Fix-round checks

Full battery: **exit 0**. The command is exactly the quality row reproduced above,
extracted again from AGENTS.md and run with `sh /tmp/kit-shrink-fix1-quality.sh`.
Both hook shells passed; invariants: 268 assertions; version checker: 36 assertions;
report suites: 37, 33, 15, 18, 11 and 135 passed; plugin validation passed.

Final output:

```text
PASS c19:valid ledger lines leave records and cycles unchanged
PASS c19:the cycle keeps its provenance and curve
PASS c19:the skip record keeps its reason
PASS driver exited 0
PASS mutant none-for-unknown caught by c5
PASS mutant first-record-only caught by c14
PASS mutant reread-everything caught by c9
PASS mutant keep-raw-model caught by c12
PASS mutant mentions-count caught by c13
135 passed, 0 failed
Validating marketplace manifest: /Users/daniel/DEVELOPMENT/APPS/dev-workflow-kit-shrink/.claude-plugin/marketplace.json

✔ Validation passed

QUALITY_EXIT=0
```

Targeted read-back checks: exit 0. Independently parsed every old-range and new-range
from the strike-list; verified 9,515 original lines exactly once, every KEPT block
byte-for-byte at its stated output range, and every remaining output line exactly once
in the insertion/partial-line trace. Compared all 11 B2/B3 excerpts with the original,
the whole restored template 2.2 and description line with pre-shrink, and the precise
allowed CLAUDE.md/ARCHITECTURE.md changes with their originals.

Four actual `cmp` calls on the archive bodies against pre-shrink exited 0 with empty
output (`/tmp/kit-shrink-fix1-original-<name>` versus
`/tmp/kit-shrink-fix1-archive-<name>` for review-gates, workflow-init-2.1a,
harden-finding and intake). `diff .claude/review-gates.md /tmp/kit-shrink-fix1-template.md` also exited 0 with empty output.
`git diff --check` and `sh scripts/check-invariants.sh` exited 0.
No checker changed in this fix round; the existing 4h mutation result was not re-run.
No Gate A or Gate B was run; no merge was performed.

Version coordination: **keep 0.24.0 now; re-bump at rebase time if ticket-skill merges first.**

Fix-round final fetch: `origin/main` remains `6b15993` (0.23.0); version stays 0.24.0.
