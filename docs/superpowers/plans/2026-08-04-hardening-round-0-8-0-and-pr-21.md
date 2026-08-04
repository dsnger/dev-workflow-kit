# Hardening round — the 0.8.0 cycle and PR #21 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Land four hardenings from the 0.8.0 cycle and PR #21 as text, record them in four ledger rows, park what has no repair, and open four split stories — without changing any skill file.

**Architecture:** Three one-sentence additions to `CLAUDE.md` §5, each mirrored into the inline template in `plugins/dev-workflow/commands/workflow-init.md`; one clause appended to an existing `AGENTS.md` Don't; one new taxonomy class; four appended ledger rows; seven `todos.md` row changes; four new story files. No executable code changes.

**Tech Stack:** Markdown prompts and POSIX shell checks. The quality battery in `AGENTS.md § Commands` is the test cycle — there is no unit test for prose.

**Spec:** `docs/superpowers/specs/2026-08-03-hardening-round-0-8-0-and-pr-21-design.md` (Gate A closed at nine passes, `b9111a2`).

**Story:** `docs/superpowers/stories/2026-08-03-hardening-round-0-8-0-and-pr-21-story.md` — read its profile header fresh at every Gate-B pass; no value from it is copied here.

## Deliverables checklist

Everything this round ships. A task is not done until its rows here are true.

- [ ] **Three §5 sentences** — Gate-B lens, Profiles counterfactual, Gate-A pass procedure (Task 1)
- [ ] **Three template mirrors** of those sentences in `workflow-init.md` (Task 1)
- [ ] **Version 0.8.1** in the manifest — committed with the first plugin change, not later (Task 1)
- [ ] **One `AGENTS.md` Don't amendment** — the 2026-07-19 gate-claims Don't (Task 2)
- [ ] **One taxonomy class** — `mechanical-check-skipped-before-review` (Task 3)
- [ ] **Four split stories**, unprofiled, six `##` sections each, with a profile-confirmation first criterion and (for the three that replace a backlog row) an inheritance inventory (Tasks 4–5)
- [ ] **Seven `todos.md` row changes** — one new parked row plus six existing rows updated (Task 6)
- [ ] **Four ledger rows** — A, B, C, D (Task 7)
- [ ] **A `## 0.8.1` CHANGELOG entry** (Task 8)
- [ ] **Validation evidence** written to a named file, then folded into the closing commit body (Task 9)

## Global Constraints

Copied verbatim from the spec and `AGENTS.md`. Every task's requirements implicitly include this section.

- **Each §5 edit is one sentence at the exact existing site.** A finding needing a paragraph is a finding whose home is wrong (spec D5).
- **`CLAUDE.md` and `workflow-init.md` change in the same commit**, and their inserted sentences must be **equivalent under whitespace normalization** — identical word sequences, with only line wrapping and leading indentation permitted to differ, because the two files wrap at different widths and nest at different depths. Byte identity is not the requirement and no check in this plan asserts it.
- **No skill file is edited.** `plugins/dev-workflow/skills/**` is out of scope (spec D7). If a step seems to need a skill edit, stop and surface.
- **POSIX `sh` only** (invariant 4). No `<(...)`, no `[[ ]]`, no arrays, no `${var:offset:length}`, no `local`. `sh -n` is a *parse* check and will not catch `${var:0:3}` — it fails at runtime under `dash` with `Bad substitution`. Test any new snippet with `dash -c`, not only `sh -n`.
- **`grep -c` exits 1 when the count is zero.** Every expected-zero check in this plan captures the count and asserts the number; none relies on grep's exit status.
- **Every verification block is self-contained and exits nonzero when it fails.** Two rules, both learned the hard way:
  - **Self-contained:** a block defines every function and variable it uses. Agentic workers run each fenced block in a fresh shell, so a helper defined in one block and called in another simply is not there.
  - **Fails loudly:** a block that prints `MISMATCH` and then ends on an `echo` exits 0, and any wrapper trusting exit status walks straight through the stop path. Every check accumulates into `rc` and ends with `exit "$rc"`.
  - **No pipeline subshells for accumulation:** `... | while read x; do rc=1; done` sets `rc` in a subshell and discards it. Redirect from a file or use a here-document instead.
- **Version is `0.8.1`**, committed in Task 1 alongside the first `plugins/` change. The battery includes `check-version-bump.sh main`, which fails on any committed `plugins/` change without a bump — so deferring the bump would make every intervening battery run fail by construction.
- **The ledger is append-only.** Never edit an existing row.
- **Escape a literal `|` inside a ledger field as `\|`.** This round avoids guard quotations containing pipes rather than relying on an unstated rule for the `ref` column.
- **The four stories are unprofiled** — no `**Risk:**`/`**Security:**`/`**Validation:**` line — each has exactly six `##` sections, and each carries the profile-confirmation criterion first.
- **No `Co-Authored-By: Claude` or `Generated with` trailers** on any commit.
- **`git add` and `git commit` are always separate calls.** The gate hook derives its docs-only file list at `PreToolUse`; a compound `git add && git commit` presents an empty index and fires a spurious Gate-B STOP.
- **Quality battery** (what CI runs), from `AGENTS.md § Commands`:

```
shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && shellcheck --shell=sh scripts/check-invariants.sh && shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && shellcheck --shell=sh scripts/check-version-bump.sh && shellcheck --shell=sh scripts/check-version-bump.test.sh && HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh && HOOK_SH=dash dash plugins/dev-workflow/hooks/codex-gate.test.sh && sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh && sh scripts/check-version-bump.test.sh && sh scripts/check-version-bump.sh main && claude plugin validate . --strict
```

- **`check-invariants.sh` scans the working tree, not the tracked set.** Move any untracked scratch directory aside before running the battery, or it can fail on text it merely quotes.

---

## Task 0: Cross-finding conflict check

The spec requires this **before applying any edit**, so it runs first rather than at validation time.

- [ ] **Step 1: Confirm no two hardenings contend for one site**

List the four sites and confirm each hardening writes to a distinct one:

| Hardening | Site |
|---|---|
| §5.1 lens sentence | `CLAUDE.md` §5 Gate-B paragraph opening `**Standing lens, every Gate-B call:` |
| §5.2 counterfactual sentence | `CLAUDE.md` §5 Profiles paragraph containing `Either route owes the` |
| §5.3 sweep sentence | `CLAUDE.md` §5 Gate-A bullet at `Each pass: validate, revise, re-run.` |
| §5.4 Don't clause | `AGENTS.md` Don't closing sentence `delete any part of the sentence that outruns it` |

Expected verdict: **no conflict** — four distinct sites, and none rewrites text another needs. If two findings pull one artifact in opposite directions, **stop and surface** rather than choosing. Repeat this check if a Gate-B fix changes any hardening's site or direction.

---

### Task 1: The three §5 sentences, their mirrors, and the version bump

**Files:**
- Modify: `CLAUDE.md` (three sites)
- Modify: `plugins/dev-workflow/commands/workflow-init.md` (the same three sites in the inline template)
- Modify: `plugins/dev-workflow/.claude-plugin/plugin.json` (version 0.8.0 → 0.8.1)

**Interfaces:**
- Consumes: nothing.
- Produces: the three sentences that ledger rows A, C and D cite as their `ref` (Task 7). Their wording is fixed here; Task 7 quotes it.

**Anchors, verified at `8fc145d`.** Line numbers locate the paragraph; **match on the quoted text**, since a citation by line is the C3 defect this round hardens.

| Sentence | `CLAUDE.md` | `workflow-init.md` |
|---|---|---|
| Gate-B lens | ~247, paragraph opening `**Standing lens, every Gate-B call:` | ~441, same opening |
| Profiles counterfactual | ~342, sentence `Either route owes the` | ~532, same |
| Gate-A pass procedure | ~224, `Each pass: validate, revise, re-run.` | ~419, same |

- [ ] **Step 1: Append the lens sentence in `CLAUDE.md`**

Find the paragraph opening `**Standing lens, every Gate-B call: "which existing statements does this diff falsify?"**`. Append at the end of that paragraph, after the sentence ending `plus two user-facing docs teaching a rule the same change had just narrowed.`:

```
  **Name what this diff changes the size, value or position of** — a list, a count, a
  version, an identifier, a cited line — and grep for where each is described elsewhere,
  because asked as an open question alone this lens missed three such statements in one
  cycle while being carried with unusual force.
```

Match the surrounding indentation — this paragraph is a two-space-indented sub-bullet of the Gate-B item.

- [ ] **Step 2: Append the counterfactual sentence in `CLAUDE.md`**

Find the paragraph containing `Either route owes the **counterfactual**: the observation against the prior state.` Append after the sentence ending `A fabricated test satisfies nothing.`:

```
**Name the observation that would exist if the claim were false, and confirm the wiring could
have produced it** — a check that supplies its own input, runs where the defect cannot appear,
or uses a fixture that never reaches the branch it covers reports success because of how it was
wired, not because the thing it checks succeeded.
```

- [ ] **Step 3: Add the Gate-A sweep sentence in `CLAUDE.md`**

Find `Each pass: validate, revise, re-run. (Large/high-risk artifact: optional focused` and insert immediately after `Each pass: validate, revise, re-run.`, before the parenthetical:

```
Before each read pass, settle mechanically what the artifact asserts and a machine can decide
without side effects — cited paths, quoted passages, stated counts, the syntax of standalone
fenced blocks — inspecting quoted commands rather than running them, since a command quoted in
a spec may be destructive or an intentional failure.
```

- [ ] **Step 4: Mirror all three into `workflow-init.md`**

Apply Steps 1–3 at the three corresponding sites in the inline template. The word sequence must match what landed in `CLAUDE.md`; line wrapping and leading indentation may differ, per Global Constraints.

- [ ] **Step 5: Bump the manifest**

In `plugins/dev-workflow/.claude-plugin/plugin.json`, change `"version": "0.8.0",` to `"version": "0.8.1",`. This lands here rather than at the end because `check-version-bump.sh main` — part of the battery — fails on any committed `plugins/` change without it.

- [ ] **Step 6: Verify mirror equivalence**

```bash
cd "$(git rev-parse --show-toplevel)"
rc=0
for pat in 'Name what this diff changes[^.]*\.' \
           'Name the observation that would exist[^.]*\.' \
           'Before each read pass[^.]*\.' ; do
  a=$(tr '\n' ' ' < CLAUDE.md | tr -s ' ' | grep -o "$pat" || true)
  b=$(tr '\n' ' ' < plugins/dev-workflow/commands/workflow-init.md | tr -s ' ' | grep -o "$pat" || true)
  na=$(printf '%s' "$a" | grep -c . || true)
  nb=$(printf '%s' "$b" | grep -c . || true)
  if [ "$na" != "1" ] || [ "$nb" != "1" ]; then
    rc=1
    printf 'CARDINALITY: expected exactly one match per file, got CLAUDE=%s TEMPLATE=%s for %s\n' "$na" "$nb" "$pat"
  elif [ "$a" = "$b" ]; then
    printf 'EQUIVALENT: %.55s...\n' "$a"
  else
    rc=1
    printf 'MISMATCH\n  CLAUDE  : %s\n  TEMPLATE: %s\n' "$a" "$b"
  fi
done
echo "parity exit=$rc"
exit "$rc"
```

Expected: three `EQUIVALENT:` lines, `parity exit=0`, and **shell status 0**.

Three things in that block are load-bearing. The **cardinality check** comes before the comparison: two empty extractions compare equal, and two duplicated copies compare equal, so equality alone reports a match that proves nothing — the `verification-masks-failure` shape this round hardens. `printf '%.55s'` is used rather than `${a:0:55}`, a bash-ism that fails under `dash` at runtime while passing `sh -n`. And the block **ends with `exit "$rc"`**, because a block that prints `MISMATCH` and then ends on an `echo` exits 0.

**Placement is not checked mechanically here.** Cardinality proves each sentence appears once per file; that it sits under the corresponding heading is confirmed by reading, at Steps 1–4. A grep cannot cheaply establish "under the same heading" in two files that nest at different depths, and claiming otherwise would overstate what the check compares.

- [ ] **Step 7: Verify the manifest**

```bash
cd "$(git rev-parse --show-toplevel)"
v=$(grep -o '"version": *"[^"]*"' plugins/dev-workflow/.claude-plugin/plugin.json | head -1)
echo "$v"
if [ "$v" = '"version": "0.8.1"' ]; then echo "version OK"; exit 0; else echo "version WRONG — stop and surface"; exit 1; fi
```

Expected: `version OK`.

- [ ] **Step 8: Run the battery**

Run the quality command from Global Constraints. Expected: exit 0. It passes because the bump landed in Step 5 — `check-version-bump.sh main` compares committed state, and on `main` the merge-base is HEAD, so it passes trivially; CI runs it against the PR's base ref.

- [ ] **Step 9: Commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md plugins/dev-workflow/.claude-plugin/plugin.json
```

```bash
git commit -m "WIP: three §5 sentences, their template mirrors, and the 0.8.1 bump"
```

Two separate calls, per Global Constraints. Named `WIP:` deliberately — the hook treats a `wip`-prefixed message as cycle-internal, so it neither fires a Gate-B STOP nor resets the pass counters. Task 9 replaces it by amend.

---

### Task 2: The `AGENTS.md` Don't amendment

**Files:**
- Modify: `AGENTS.md` (the 2026-07-19 Don't, closing sentence around line 218)

**Interfaces:**
- Consumes: nothing.
- Produces: the rule ledger row B cites as its `ref` (Task 7).

- [ ] **Step 1: Extend the Don't's closing sentence**

In `AGENTS.md § Don'ts`, inside `**Never describe what a gate proves without checking what it actually compares.**`, find:

```
  underlying rule is the check itself: for every sentence about a gate, name the exact
  comparison the code performs, and delete any part of the sentence that outruns it.
```

Replace the trailing `outruns it.` so the sentence continues:

```
  underlying rule is the check itself: for every sentence about a gate, name the exact
  comparison the code performs, and delete any part of the sentence that outruns it — and
  where the sentence says what the mechanism does *not* cover, name the axes it was checked
  against and state whether that list is exhaustive, because an enumeration read as complete
  guarantees the axes it omits.
```

- [ ] **Step 2: Verify the amendment rejects its own motivating case**

Read the amended sentence and apply it to `It bounds the **scan**, not memory`:

- Does it name the axes it was checked against? Yes — scan and memory.
- Does it state whether that list is exhaustive? **No.**
- Therefore it fails the amended rule. ✔

Expected: **fails on the exhaustiveness requirement.** If it passes, the wording is wrong — a rule asking only for the axes checked would approve the very sentence this amendment exists to reject. **Stop and surface** rather than proceeding.

- [ ] **Step 3: Confirm `AGENTS.md` holds exactly one operative copy**

```bash
cd "$(git rev-parse --show-toplevel)"
n=$(tr '\n' ' ' < AGENTS.md | tr -s ' ' | grep -c 'delete any part of the sentence that outruns it' || true)
echo "AGENTS.md operative copies: $n"
if [ "$n" = "1" ]; then echo "OK"; exit 0; else echo "UNEXPECTED — stop and surface"; exit 1; fi
```

Expected: `1` and `OK`. The rule is repo-local and is **not** mirrored into the scaffolded template, so no second operative copy needs the amendment. The spec and this plan both quote the phrase; those are quotations of the rule, not copies of it, and are deliberately not searched here — a repository-wide grep would report them and send the executor to a stop branch with nothing wrong.

- [ ] **Step 4: Run the battery**

Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
git add AGENTS.md
```

```bash
git commit -m "WIP: extend the gate-claims Don't to coverage enumerations"
```

---

### Task 3: The taxonomy class

**Files:**
- Modify: `docs/hardening-taxonomy.md` (append under `## Classes`, before the `**Promotion candidate.**` paragraph)

**Interfaces:**
- Consumes: nothing.
- Produces: the fingerprint string `mechanical-check-skipped-before-review`, used by ledger row D (Task 7).

- [ ] **Step 1: Add the class**

Insert as the last entry under `## Classes`, immediately before the `**Promotion candidate.**` paragraph:

```markdown
- `mechanical-check-skipped-before-review` — an artifact carrying machine-checkable assertions
  goes to an expensive read pass before anything parses it, so attention is spent on what a
  tool decides in seconds. Aliases: `sh -n` after the fact, the parser would have caught it,
  read pass before the sweep, manual review of machine-decidable claims.

  **Not `verification-masks-failure`.** There a check ran and could not fail; here the cheap
  check never ran at all. Grep this one when the sentence is "a parser would have found it
  immediately"; grep the other when it is "the check passed and proved nothing".
```

- [ ] **Step 2: Confirm the class did not land in the shipped skill**

```bash
cd "$(git rev-parse --show-toplevel)"
n=$(grep -c "mechanical-check-skipped-before-review" plugins/dev-workflow/skills/harden-finding/SKILL.md || true)
echo "occurrences in SKILL.md: $n"
if [ "$n" = "0" ]; then echo "OK — invariant 10 holds"; exit 0; else echo "VIOLATION — stop and surface"; exit 1; fi
```

Expected: `0` and `OK`. The count is captured and compared numerically because `grep -c` exits 1 on zero, which would otherwise abort the step on the correct result.

Invariant 10 keeps project classes out of the shipped skill. This class is stack-neutral and lands in the project file anyway, because the skill instructs minting there — the file's own `**Promotion candidate.**` note records the same of several existing classes.

- [ ] **Step 3: Run the battery**

Expected: exit 0.

- [ ] **Step 4: Commit**

```bash
git add docs/hardening-taxonomy.md
```

```bash
git commit -m "WIP: mint mechanical-check-skipped-before-review"
```

---

### Task 4: The `harden-finding` precheck split story

**Files:**
- Create: `docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md`

**Interfaces:**
- Consumes: nothing.
- Produces: the story path `todos.md`'s scope-blind row points at (Task 6).

- [ ] **Step 1: Classify the path (read-only)**

```bash
cd "$(git rev-parse --show-toplevel)"
p=docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md
if [ -L "$p" ]; then
  echo "SYMLINK at target — stop and surface"; exit 1
elif [ -d "$p" ]; then
  echo "DIRECTORY at target — stop and surface"; exit 1
elif [ -e "$p" ]; then
  echo "REGULAR FILE exists — compare bytes against Step 2; identical means reuse, different means stop"; exit 0
else
  echo "ABSENT — Step 2 will create it"; exit 0
fi
```

**A symlink is an unconditional stop, never a reuse candidate**, even if its target currently holds byte-identical text: `git add` would stage a link rather than the durable story bytes, and every shape check in Step 3 would follow the target and pass while another checkout receives a dangling or retargeted path. `[ -L ]` is tested first because `[ -e ]` is false for a dangling symlink and true for a live one, so `-e` alone cannot tell either case from a regular file.

- [ ] **Step 2: Write the story, installing it atomically**

Write the text below to a temporary file in the same directory, then link it into place. `ln` fails if the target exists, so creation is atomic against another writer — unlike reserving an empty placeholder and filling it later, which leaves a window in which the placeholder can be modified and then silently overwritten.

```bash
cd "$(git rev-parse --show-toplevel)"
p=docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md
tmp="$(dirname "$p")/.tmp-$$-story.md"
# (write the full story text of this step into "$tmp" here)
if [ -e "$p" ] || [ -L "$p" ]; then
  if cmp -s "$tmp" "$p"; then echo "IDENTICAL — reusing existing file"; rm -f "$tmp"; exit 0
  else echo "DIFFERENT content at target — stop and surface"; rm -f "$tmp"; exit 1; fi
fi
if ln "$tmp" "$p" 2>/dev/null; then
  rm -f "$tmp"; echo "INSTALLED $p"; exit 0
fi
rm -f "$tmp"
if [ -e "$p" ] || [ -L "$p" ]; then
  echo "COLLISION: an entry appeared at $p between the check and the install — stop and surface"
else
  echo "CREATE FAILED and no entry exists — investigate permissions, a missing parent directory, or a full or read-only filesystem"
fi
exit 1
```

The failure branch **re-stats the path before naming a cause**. Reporting every install failure as a concurrent writer would send the engineer hunting for another session when the real cause is a permission or a missing directory — the `prompt-diagnostic-cause-unnamed` class in this repo's own taxonomy.

The story text:

- [ ] **Step 2: Write the story**

```markdown
# `harden-finding`'s recurrence rule is scope-blind — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately.** This story is a split from a designed round, not a raw idea, so
it did not pass through `dev-workflow:intake` — intake excludes items that have moved into
solution design. A profile is proposed and human-confirmed at intake time. Writing one here
would produce a header that **looks** confirmed and is not, and nothing would reveal that:
`CLAUDE.md` §5 stops on a profile that is malformed or internally inconsistent, not on one
whose values are well-formed but unconfirmed. That is exactly why the debt is carried as
acceptance criterion 1 rather than by fabricating a header.

## 1. Problem statement

`harden-finding`'s recurrence step tells you to re-read the ledger, and then decides from the
fingerprint and the latest matching row's rung. It never lets that row's **stated guard**
control the verdict. So a later in-class defect outside the guarded spelling is proposed for a
stronger rung than anything justifies — which the 2026-07-26 rows warn about by name, in ledger
prose the decision branch does not consult.

The 2026-08-03 hardening round applied the missing precheck by hand, on a standing instruction
from Daniel, and still reached a wrong verdict twice by reading one prior row's guard and
stopping. Landing the rule in the skill turned out to require decisions a rule paragraph cannot
carry, which is why it is here rather than in that round.

## 2. Desired outcome

A recurrence proposal states which prior rows it read, what each guards, and whether this
finding falls inside or outside — and a later reader can check that reasoning against the
ledger. Escalation follows from a guard that failed, never from a count.

## 3. Acceptance criteria

- [ ] Before design resumes on this story, whoever picks it up proposes both axes and the mode
      derived from them, pauses for Daniel's confirmation, and writes the confirmed profile into
      this header. Design continues only after that.
- [ ] A recurrence decision names every prior matching row it considered, not only the latest,
      and records what each guards.
- [ ] The record a decision leaves behind is sufficient for a later reader to reach the same
      inside/outside verdict without re-deriving it.
- [ ] The rule states what happens when a same-fingerprint row appears mid-run, including when
      that row is `pending` or its guard cannot be determined.
- [ ] Whether automatic escalation on recurrence is kept, narrowed, or dropped is settled
      explicitly, with a stated reason.
- [ ] The `AGENTS.md` Don't "Never replace a decision procedure without accounting for its old
      conditions" is satisfied for every condition the current step 3 and step 7 carry.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "10. **The base taxonomy stays
  stack-neutral.** Project vocabulary — tables, auth helpers, framework APIs — goes only in
  that project's `docs/hardening-taxonomy.md`, never into the `harden-finding` skill. Otherwise
  one project leaks into every other."
- `## Key invariants` → `### Prompts and scaffolding` — "11. **Prompt changes pass
  `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent
  definition, hook message, or scaffolded template."
- `## Key invariants` → `### Packaging` — "12. **A plugin change requires a version bump.**"
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old
  conditions.** List what the previous prose required, then mark each one kept, moved, or
  deliberately dropped."

## 5. Open questions

Six, each paired with the failure that raised it:

- A verdict was reached by reading one prior row's guard and stopping, when an older row's guard
  covered the case. **Which prior rows must a recurrence be judged against before "outside" is
  safe?**
- A reader cannot tell whether a past rung choice followed from a guard reading or from a count,
  because nothing durable records the reading. **What does a later reader need, and where does
  it belong?**
- Guards are frequently exact spellings containing regex alternation, and the ledger's stated
  escaping rule covers the `finding` column. **How does a guard citation survive a Markdown
  table without changing what the columns mean?**
- Step 7 re-reads the ledger and then appends, so a row landing after that read is not seen, and
  a row seen at the read is treated as a duplicate without anyone consulting what it guards.
  **What should happen when a row appears mid-run?**
- Widening the branch condition from "latest matching row is a real rung" to "a matching row
  exists at a real rung" makes it fire when the latest row is `pending`, bypassing the
  prerequisite rule. **How do a guard scan and a prerequisite block compose?**
- The old step-3 text required proposing one rung stronger on recurrence, and a replacement
  choosing "the rung that fits the repair" does not carry it. **Is automatic escalation kept,
  narrowed, or deliberately dropped?**

## 6. Suggested size

`story` — one skill file, one decision procedure, one spec → plan → PR. Above a chore because
the six questions above are real design; below an epic because they all concern one procedure
in one file.
```

- [ ] **Step 3: Verify shape**

```bash
cd "$(git rev-parse --show-toplevel)"
p=docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md
prof=$(grep -c '^\*\*Risk:\*\*\|^\*\*Security:\*\*\|^\*\*Validation:\*\*' "$p" || true)
crit=$(tr '\n' ' ' < "$p" | tr -s ' ' | grep -c 'proposes both axes and the mode derived from them' || true)
sect=$(grep -c '^## ' "$p" || true)
printf 'profile lines=%s (want 0)  criterion=%s (want 1)  sections=%s (want 6)\n' "$prof" "$crit" "$sect"
if [ "$prof" = 0 ] && [ "$crit" = 1 ] && [ "$sect" = 6 ]; then echo OK; exit 0; else echo "WRONG — stop and surface"; exit 1; fi
```

Expected: `OK`.

- [ ] **Step 4: Commit**

```bash
git add docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md
```

```bash
git commit -m "WIP: split story for the harden-finding guard-scope precheck"
```

---

### Task 5: The three trigger stories

**Files:**
- Create: `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`
- Create: `docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md`
- Create: `docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md`

**Interfaces:**
- Consumes: nothing.
- Produces: three story paths `todos.md` rows point at (Task 6).

Each replaces a parked `todos.md` row carrying settled analysis, so each holds an inheritance inventory marking every condition of its source row **kept, moved, or deliberately dropped** — `AGENTS.md`'s "Never replace a decision procedure without accounting for its old conditions" applies to that replacement. The inventory is a `###` subsection of §1 so the story keeps exactly six `##` sections.

**Classify each path immediately before its own write**, using the Task 4 Step 1 procedure verbatim with that story's path substituted. A single up-front classification of all three is stale by construction for the second and third.

- [ ] **Step 1: Classify, then write the ledger-supersession story**

Run Task 4 Steps 1 and 2's blocks (classify, then atomic install) with `p=docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`, then write:

```markdown
# The hardening ledger has no supersession convention — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately** — a split from a designed round, so it bypassed
`dev-workflow:intake`, which excludes work already in solution design. A profile written now
would look confirmed without being confirmed, and nothing would reveal that; acceptance
criterion 1 carries the debt instead.

## 1. Problem statement

`docs/hardening-log.md`'s header says never edit a row, and one row per hardening. When a row's
"what this does NOT do" narration is later falsified by a feature change, neither move is
sanctioned: editing breaks the first rule, appending breaks the second.

This is live. The 2026-07-20 row describes pre-0.8.0 counting behaviour as current, and a reader
who trusts it is misled about how the gate hook counts today. That is the second falsified row,
which is the condition the parked backlog row named as its trigger.

### Conditions inherited from the source row

From `todos.md`, "**The hardening ledger has no supersession convention.**":

| Condition | Disposition |
|---|---|
| Never edit a row | **kept** — any solution must preserve it |
| One row per hardening | **kept** — any solution must preserve it |
| The 2026-07-20 row now describes pre-0.8.0 behaviour as current | **kept** as the motivating instance |
| The 2026-07-20 *spec* took a version-qualified supersession note and it worked | **kept** as prior art the design should evaluate first |
| Alternative: an explicit "rows are historical, read the newest row for current behaviour" header statement | **kept** as a candidate |
| Trigger: the next row falsified by a later change — this is the second | **moved** — fired, and recorded here |

## 2. Desired outcome

A reader who opens any ledger row can tell whether it still describes current behaviour, and a
row falsified by a later change can be marked as such without breaking either standing rule.

## 3. Acceptance criteria

- [ ] Before design resumes on this story, whoever picks it up proposes both axes and the mode
      derived from them, pauses for Daniel's confirmation, and writes the confirmed profile into
      this header. Design continues only after that.
- [ ] The 2026-07-20 row no longer reads as current behaviour, and it was not edited.
- [ ] The append-only rule and the one-row-per-hardening rule both still hold after the change.
- [ ] A reader can determine, from the ledger alone, which row to trust for current behaviour.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "8. **`/workflow-init`'s templates stay
  inline** in the command body."
- `## Key invariants` → `### Prompts and scaffolding` — "9. **`/workflow-init` never overwrites
  silently.** Idempotent: missing → write; identical → report unchanged; present and different →
  show the diff and ask; additive files (`.gitattributes`, `.mcp.json`, …) → merge."
- **Conditional, if the design reaches the scaffolded template** — `## Key invariants` →
  `### Prompts and scaffolding` — "11. **Prompt changes pass `docs/prompt-standards.md`** — all
  12 checklist items, for any skill, command, agent definition, hook message, or scaffolded
  template." — and `### Packaging` — "12. **A plugin change requires a version bump.**" Both
  bind only if the convention must reach `/workflow-init`'s inline ledger header, which is §5's
  open question.

## 5. Open questions

- Which artifacts must the convention reach before a reader can trust any row — this repo's
  ledger alone, or every ledger `/workflow-init` scaffolds? A repo-only fix ships a rule this
  kit's ledger obeys and every scaffolded one does not.

## 6. Suggested size

`story` — one file's header convention plus possibly one inline template, one spec → plan → PR.
```

- [ ] **Step 2: Classify, then write the no-PR ledger route story**

Run Task 4 Steps 1 and 2's blocks (classify, then atomic install) with `p=docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md`, then write:

```markdown
# A route from a fixed finding to the ledger, for projects that never open PRs — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately** — a split from a designed round, so it bypassed
`dev-workflow:intake`. A profile written now would look confirmed without being confirmed;
acceptance criterion 1 carries the debt instead.

## 1. Problem statement

The only mandated ledger check lives in `/dev-workflow:process-pr-review` step 5, so a project
that never opens a pull request never reaches it. One project has 51 Gate-A pass files and
**zero** ledger rows: findings were raised, validated and fixed, and none was ever considered
for hardening.

### Conditions inherited from the source row

From `todos.md`, "**Finding A — a route from a fixed finding to the ledger for projects that
never open PRs.**":

| Condition | Disposition |
|---|---|
| Scope must match `process-pr-review` step 5 **exactly** — check every accepted actionable fixed finding, but invoke `harden-finding` only when a class matches or a new one is clearly warranted | **kept** — every approximating draft got this wrong |
| Cannot rest on same-session memory: a compaction, interruption or handoff loses the fixed-finding set and nothing detects the loss | **kept** |
| A durable handoff needs real design — identity, deduplication, consumption semantics | **kept**, and it is why this is a story rather than a mid-round addition |
| It mints `mandatory-step-anchored-to-optional-path` when it lands; minting earlier leaves a class no row uses | **kept** — the class is minted by the change that uses it |
| Evidence: canvas has 51 Gate-A pass files and 0 ledger rows | **kept** as the motivating instance |
| Trigger, first alternative: the next round that touches §5 | **moved** — fired by the 2026-08-03 round, recorded here |
| Trigger, second alternative: a project reporting an empty ledger across cycles that fixed findings | **kept** — it did not fire, and it remains the condition that would raise this independently if the first had not |

## 2. Desired outcome

A project that fixes review findings without opening a pull request still reaches the ledger
check, and a fixed finding that warrants hardening is not lost to a compaction, an interruption
or a handoff.

## 3. Acceptance criteria

- [ ] Before design resumes on this story, whoever picks it up proposes both axes and the mode
      derived from them, pauses for Daniel's confirmation, and writes the confirmed profile into
      this header. Design continues only after that.
- [ ] A project with no pull requests reaches a ledger check on the findings it fixed.
- [ ] The route does not depend on same-session memory.
- [ ] The check's scope matches `process-pr-review` step 5 exactly — no wider, no narrower.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "11. **Prompt changes pass
  `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent
  definition, hook message, or scaffolded template."
- `## Key invariants` → `### Packaging` — "12. **A plugin change requires a version bump.**"

## 5. Open questions

- What has to be true for a fixed finding to reach the ledger in a project that never opens a
  pull request?

## 6. Suggested size

`story` — one route, one spec → plan → PR.
```

- [ ] **Step 3: Classify, then write the §5 version stamp story**

Run Task 4 Steps 1 and 2's blocks (classify, then atomic install) with `p=docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md`, then write:

```markdown
# A §5 version stamp, so a scaffolded CLAUDE.md can tell it lags the plugin — Story

**Date:** 2026-08-04 · **Size:** story

**Unprofiled, deliberately** — a split from a designed round, so it bypassed
`dev-workflow:intake`. A profile written now would look confirmed without being confirmed;
acceptance criterion 1 carries the debt instead.

## 1. Problem statement

`/workflow-init` scaffolds `CLAUDE.md` §5 from an inline template. When the plugin's §5 changes,
every previously scaffolded copy silently lags, and nothing in the scaffolded file tells its
reader so. One known-stale instance exists and is being re-synced by hand.

### Conditions inherited from the source row

From `todos.md`, "**Finding B — a §5 version stamp, so a scaffolded CLAUDE.md can tell it lags
the installed plugin.**":

| Condition | Disposition |
|---|---|
| A semantic §5 locator is needed — `/workflow-init` may append the section renumbered, so "no §5 heading" can misread a valid section and append a duplicate | **kept** |
| Per-state merge semantics: invariant 9 forbids a silent overwrite, and "re-run init to sync" promises what the command cannot give | **kept** |
| Stamp cardinality: absent, duplicate, malformed | **kept** |
| The binding must be real on **every** push path; the version-bump coupling first proposed was false, since invariant 12's checker is `pull_request`-only | **kept** — the false coupling is recorded so it is not re-proposed |
| A stamp is a **wire format**: shipping a provisional one writes legacy into every scaffolded file | **kept** — it is why a provisional stamp is unacceptable |
| The one known-stale instance is being re-synced by hand, so this carries no schedule pressure | **kept** — the work is not urgent |
| Trigger: the next round that touches the §5 template | **moved** — fired by the 2026-08-03 round, recorded here |

## 2. Desired outcome

A reader of a scaffolded `CLAUDE.md` can tell whether its §5 matches the installed plugin's,
without comparing the two by hand.

## 3. Acceptance criteria

- [ ] Before design resumes on this story, whoever picks it up proposes both axes and the mode
      derived from them, pauses for Daniel's confirmation, and writes the confirmed profile into
      this header. Design continues only after that.
- [ ] A scaffolded `CLAUDE.md` whose §5 lags the installed plugin is detectable as such.
- [ ] Re-running `/workflow-init` on a stale file behaves per invariant 9 — it does not silently
      overwrite accumulated content.
- [ ] Whatever binding the design chooses holds on every push path, not only on pull requests.

## 4. Affected AGENTS.md invariants

- `## Key invariants` → `### Prompts and scaffolding` — "8. **`/workflow-init`'s templates stay
  inline** in the command body. Claude Code does not expand `${CLAUDE_PLUGIN_ROOT}` inside
  command markdown (verified), and the cache path is not an API."
- `## Key invariants` → `### Prompts and scaffolding` — "9. **`/workflow-init` never overwrites
  silently.**"
- `## Key invariants` → `### Prompts and scaffolding` — "11. **Prompt changes pass
  `docs/prompt-standards.md`** — all 12 checklist items."
- `## Key invariants` → `### Packaging` — "12. **A plugin change requires a version bump.**"

## 5. Open questions

- How can a scaffolded `CLAUDE.md` tell its reader that it lags the installed plugin?

## 6. Suggested size

`story` — one stamp format and its detection, one spec → plan → PR. Not a chore: a wire format
shipped provisionally cannot be taken back.
```

- [ ] **Step 4: Verify all three**

```bash
cd "$(git rev-parse --show-toplevel)"
rc=0
for p in docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md \
         docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md \
         docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md ; do
  prof=$(grep -c '^\*\*Risk:\*\*\|^\*\*Security:\*\*\|^\*\*Validation:\*\*' "$p" || true)
  crit=$(tr '\n' ' ' < "$p" | tr -s ' ' | grep -c 'proposes both axes and the mode derived from them' || true)
  sect=$(grep -c '^## ' "$p" || true)
  inv=$(grep -c '^### Conditions inherited from the source row' "$p" || true)
  printf '%-58s profile=%s crit=%s sections=%s inventory=%s\n' "$(basename "$p")" "$prof" "$crit" "$sect" "$inv"
  [ "$prof" = 0 ] && [ "$crit" = 1 ] && [ "$sect" = 6 ] && [ "$inv" = 1 ] || rc=1
done
echo "stories exit=$rc"
exit "$rc"
```

Expected: three rows reading `profile=0 crit=1 sections=6 inventory=1`, and `stories exit=0`.

- [ ] **Step 5: Commit**

```bash
git add docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md
```

```bash
git commit -m "WIP: three split stories for the fired triggers"
```

---

### Task 6: `todos.md` — one new row, six existing rows

**Files:**
- Modify: `todos.md`

**Interfaces:**
- Consumes: the four story paths from Tasks 4–5.
- Produces: the parked C4/C5 row ledger row B cross-references (Task 7).

**Every mutation is idempotent, and idempotence is decided on the whole block, not on a marker.** Before each mutation, run the guard below with that step's marker and its full intended text. A marker count alone cannot tell an identical completed mutation from a partial or independently edited one, and skipping on a marker hit would leave `todos.md` semantically wrong while the final count check still passed.

The guard is written out in each step rather than defined once, because **agentic workers run each fenced block in a fresh shell** — a helper defined in one block is not in scope in the next.

```bash
# Guard template. MARKER is a regex identifying the block; INTENDED is a file
# holding the exact text this step would add.
cd "$(git rev-parse --show-toplevel)"
n=$(tr '\n' ' ' < todos.md | tr -s ' ' | grep -c 'MARKER' || true)
if [ "$n" = "0" ]; then
  echo "ABSENT — apply this step"; exit 0
elif [ "$n" != "1" ]; then
  echo "MARKER APPEARS $n TIMES — stop and surface"; exit 1
fi
# present exactly once: compare the whole intended block, whitespace-normalized
have=$(tr '\n' ' ' < todos.md | tr -s ' ')
want=$(tr '\n' ' ' < INTENDED | tr -s ' ')
if printf '%s' "$have" | grep -qF "$want"; then
  echo "ALREADY APPLIED, identical — skip this step"; exit 0
else
  echo "PRESENT BUT DIFFERENT — stop and surface"; exit 1
fi
```

- [ ] **Step 1: Add the parked C4/C5 compliance row**

Guard: `applied 'The gate-claims Don.t is correct and was not followed, twice'` must be `0`. Add under `### Parked (trigger-gated)`:

```markdown
- [ ] **The gate-claims Don't is correct and was not followed, twice.** PR #21's C4 (an
      unqualified jq-parity criterion that outran what `field()` compares for a malformed outer
      document) and C5 (a README claim that a typo cannot quietly unhook a gate) both fall
      inside the 2026-07-19 `AGENTS.md` Don't, whose operative instruction already requires
      exactly what they omitted — name the exact comparison the code performs, and delete any
      part of the sentence that outruns it. **No textual repair exists**, which is why these are
      parked rather than logged: a ledger row would have to name a hardening, and a rule needing
      no change means the failure was compliance, not wording. The 2026-08-04 amendment covers
      coverage enumerations (F8's shape) and reaches neither a positive parity claim nor a
      positive prevention claim. *Trigger: a third compliance miss against that Don't, or a
      feasible mechanical rung emerging from
      `docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md`.*
```

- [ ] **Step 2: Record evidence case 3 on the scope-blind row**

Guard: `applied 'Evidence case 3 \(2026-08-04\)'` must be `0`. In `**`harden-finding`'s recurrence rule is scope-blind.**`, insert before its `*Trigger:*` sentence:

```
      **Evidence case 3 (2026-08-04):** the 2026-08-03 hardening round ran the precheck as a
      standing manual instruction from Daniel — which is this row's own diagnosis, since a rule
      that exists only in chat is not one the skill carries — and still reached a wrong verdict
      twice by reading a single prior row's guard and stopping. Split to
      `docs/superpowers/stories/2026-08-04-harden-finding-guard-scope-precheck-story.md`; this
      row stays open because the fix it sketches has not landed.
```

- [ ] **Step 3: Mark Finding A's row fired**

Guard: `applied 'TRIGGER FIRED \(2026-08-04\): the 2026-08-03 hardening round edits §5\.'` must be `0`. In `**Finding A — a route from a fixed finding to the ledger for projects that never open PRs.**`, append:

```
      **TRIGGER FIRED (2026-08-04):** the 2026-08-03 hardening round edits §5. Story:
      `docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md`, which
      carries this row's conditions with each marked kept, moved or dropped.
```

- [ ] **Step 4: Mark Finding B's row fired**

Guard: `applied 'edits the §5 inline template'` must be `0`. In `**Finding B — a §5 version stamp, so a scaffolded CLAUDE.md can tell it lags the installed plugin.**`, append:

```
      **TRIGGER FIRED (2026-08-04):** the 2026-08-03 hardening round edits the §5 inline
      template. Story:
      `docs/superpowers/stories/2026-08-04-section-5-version-stamp-story.md`, which carries this
      row's conditions with each marked kept, moved or dropped.
```

- [ ] **Step 5: Mark the ledger-supersession row fired**

Guard: `applied 'the second falsified row this trigger names'` must be `0`. In `**The hardening ledger has no supersession convention.**`, append:

```
      **TRIGGER FIRED (2026-08-04):** the 2026-07-20 row now teaches pre-0.8.0 counting
      behaviour as current — the second falsified row this trigger names. Story:
      `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`.
```

- [ ] **Step 6: Record that the slot-collision row did NOT fire**

Guard: `applied 'NOT FIRED \(2026-08-04\)'` must be `0`. In `**Each Gate cycle destroys the previous cycle's review record.**`, append:

```
      **NOT FIRED (2026-08-04):** the 2026-08-03 hardening round edits §5 prose and its template
      mirror, and changes no part of the §5 **file protocol** this row's trigger names — not the
      slot names, not the pre-call delete, not the terminator or acceptance rules. Recorded so a
      later reader can check the reading rather than re-derive it.
```

- [ ] **Step 7: Append the env-var observation, leaving the row open**

Guard: `applied 'OBSERVATION \(2026-08-04\)'` must be `0`. In `**`/workflow-init` preflight checks `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS`.**`, append:

```
      **OBSERVATION (2026-08-04), and the row stays open.** With the variable set to `0`, five
      Gate-A passes of the 2026-08-03 round ran 458 s, 550 s, 757 s, 663 s and 780 s; all five
      stayed in the foreground and returned ordinary `success: true` envelopes the hook could
      read. **No control run was made** with the variable unset, so this is a correlation
      observed under one setting, not a demonstration that the variable held those calls in the
      foreground. What it does establish is that calls well past 120 s can return as ordinary
      foreground results here. The row's deliverable — a `/workflow-init` preflight check — is
      unbuilt, so the row is not discharged by this.
```

- [ ] **Step 8: Verify all seven changes landed exactly once, and every cited story exists**

```bash
cd "$(git rev-parse --show-toplevel)"
n=$(tr '\n' ' ' < todos.md | tr -s ' ')
rc=0
for spec in \
  'parked C4/C5 row=The gate-claims Don.t is correct and was not followed, twice' \
  'scope-blind evidence case 3=Evidence case 3 \(2026-08-04\)' \
  'Finding A fired=hardening round edits §5\. Story' \
  'Finding B fired=edits the §5 inline template' \
  'ledger-supersession fired=the second falsified row this trigger names' \
  'slot-collision not fired=NOT FIRED \(2026-08-04\)' \
  'env-var observation=OBSERVATION \(2026-08-04\)' ; do
  label=${spec%%=*}; pat=${spec#*=}
  c=$(printf '%s' "$n" | grep -c "$pat" || true)
  printf '%-30s %s (want 1)\n' "$label" "$c"
  [ "$c" = "1" ] || rc=1
done

echo "--- every cited story path exists, and there are exactly four ---"
grep -o 'docs/superpowers/stories/2026-08-04-[a-z0-9-]*\.md' todos.md | sort -u > /tmp/cited-stories.txt
cited=$(grep -c . /tmp/cited-stories.txt || true)
printf 'distinct cited story paths=%s (want 4)\n' "$cited"
[ "$cited" = "4" ] || rc=1
while IFS= read -r sp; do
  if [ -f "$sp" ] && [ ! -L "$sp" ]; then echo "OK   $sp"; else echo "MISS or NOT A REGULAR FILE: $sp"; rc=1; fi
done < /tmp/cited-stories.txt
rm -f /tmp/cited-stories.txt

echo "todos exit=$rc"
exit "$rc"
```

Expected: seven `1 (want 1)` lines, `distinct cited story paths=4`, four `OK` lines, `todos exit=0`, and **shell status 0**.

The loop reads from a redirected file rather than a pipeline, because `... | while read` runs the loop body in a subshell and discards every `rc=1` set inside it — the check would print `MISS` and still report `todos exit=0`. A `todos.md` pointing at a story that does not exist is the docs-drift class this round hardens, so the check has to be able to fail.

- [ ] **Step 9: Run the battery**

Expected: exit 0.

- [ ] **Step 10: Commit**

```bash
git add todos.md
```

```bash
git commit -m "WIP: park the compliance recurrence and record the fired triggers"
```

---

### Task 7: The four ledger rows

**Files:**
- Modify: `docs/hardening-log.md` (append four rows)

**Interfaces:**
- Consumes: the three §5 sentences (Task 1), the `AGENTS.md` amendment (Task 2), the taxonomy class (Task 3), the parked row (Task 6).
- Produces: nothing downstream.

Append in order A, B, C, D at the end of the table. Each row is **one line** — the blocks below are single lines that this document wraps for display; write each as one line with no internal newline.

- [ ] **Step 1: Re-read the log and require exact fingerprint counts**

```bash
cd "$(git rev-parse --show-toplevel)"
rc=0
expect() {
  fp=$1; want=$2
  got=$(grep -cE "^\| *[0-9-]{10} *\| *$fp *\|" docs/hardening-log.md || true)
  printf '%-42s got=%s want=%s\n' "$fp" "$got" "$want"
  if [ "$got" != "$want" ]; then
    rc=1
    echo "  --- rows found, for the stop report ---"
    grep -nE "^\| *[0-9-]{10} *\| *$fp *\|" docs/hardening-log.md | cut -c1-160
  fi
}
expect docs-drift 5
expect unverified-enforcement-claim 5
expect verification-masks-failure 1
expect mechanical-check-skipped-before-review 0
echo "ledger precondition exit=$rc"
exit "$rc"
```

Expected: `ledger precondition exit=0`.

**Any inequality — higher or lower — stops the task.** Higher means a row appeared since this plan was written; lower means a row this plan's premise depends on was removed or rewritten. Either invalidates the reviewed precondition. **Stop and surface, naming the rows the command printed.** Do not append. Resolving a mid-run collision is the split story's subject (Task 4), and inventing the procedure here would re-import what was split out.

- [ ] **Step 2: Append row A**

```
| 2026-08-04 | docs-drift | fifth occurrence: three statements the 0.8.0 diff falsified — AGENTS.md's prerequisites list omitting `dash` while the battery invokes it twice, a plan's "four script runs" for a block holding five, and a spec citing a hook line the same rewrite had moved — all found by a PR bot, none by the standing Gate-B lens | bot | major | P std | CLAUDE.md §5 Gate-B lens + the same block in the workflow-init inline template: the lens now asks what the diff changes the size, value or position of, and to grep for where each is described elsewhere. PRIOR ROW: 2026-07-27 docs-drift (P std), guard "which existing statements does this diff falsify?" — this finding is INSIDE that guard, so it is a regression repaired at the same rung, not an escalation: the lens was carried on the 0.8.0 cycle (the execution notes record it under "Standing lens, with unusual force") and missed all three. WHAT CHANGED AND WHY THE OLD FORM MISSED IT: the open question asks for recall; all three cases are a fact recorded elsewhere that the diff changed — a list's membership, a count, a position — and enumerating those needs a search. STILL INSTRUCTION-BACKED: nothing runs the grep or validates the answer, so this raises the floor and does not close the class |
```

- [ ] **Step 3: Append row B**

```
| 2026-08-04 | unverified-enforcement-claim | fifth occurrence: "It bounds the **scan**, not memory" named one uncovered axis and left the reader to infer the others were covered — the bound was a size bound, the work was quadratic in size, and the runtime it was read as bounding held only for the shapes that had been measured | gate-a | major | 1 prose | AGENTS.md Don't "Never describe what a gate proves without checking what it actually compares", closing rule extended: where a sentence says what a mechanism does NOT cover, name the axes it was checked against and state whether that list is exhaustive. PRIOR ROW: 2026-07-19 (1 prose), the same Don't, whose operative instruction covers "every sentence about a gate" — INSIDE it, so this is a regression, and the amendment closes a gap the comparison-focused wording left open. GUARD, exactly: the exhaustiveness statement. The motivating sentence names two axes and gives each a verdict, so a rule asking only for the axes checked would approve it; declaring the list exhaustive or not is what it never does. NOT LOGGED HERE: PR #21's C4 and C5 fall inside the same Don't but need nothing it does not already say, so no repair exists to name — they are parked in todos.md as a compliance recurrence with their own trigger. STILL INSTRUCTION-BACKED: no checker reads a coverage claim |
```

- [ ] **Step 4: Append row C**

```
| 2026-08-04 | verification-masks-failure | second occurrence, four cases in one cycle: a dry run that defined `$EVIDENCE` itself, proving the git mechanics and never that the plan defines the variable; a regression test that only ever ran under macOS `sh` while the defect it guards appears under `dash`; timed rows whose single-record fixtures never reach the record accumulator's quadratic path; and release evidence claiming `dash` coverage from a run that executed the harness under `dash` and the hook under `/bin/sh` | gate-b | major | P std | CLAUDE.md §5 Profiles counterfactual + the same block in the workflow-init inline template: name the observation that would exist if the claim were false, and confirm the wiring could have produced it. GUARD, exactly: the second half — a check that supplies its own input, runs where the defect cannot appear, or uses a fixture that never reaches the branch it covers. Each of the four cases fails on it. PRIOR ROW: 2026-07-20 (1 prose), whose ref states its own scope — "nothing checks new plans for the same shape" — so all four are OUTSIDE it and this is the fitting rung rather than an escalation on the count. RUNG P NOT 1: the artifact is a prompt; the rung follows the artifact, not the count. SOURCE: two gate-a cases and two gate-b, so the tie-break applies — the triggering case is the `dash` release evidence, which is gate-b. STILL INSTRUCTION-BACKED: nothing tests whether a check could have failed |
```

- [ ] **Step 5: Append row D**

```
| 2026-08-04 | mechanical-check-skipped-before-review | NEW CLASS, minted this change: eight read-only Gate-A passes over one plan missed eight defects that thirteen machine checks then found in a single sweep, including a rollback that would have byte-verified against the wrong hook | manual | major | P std | CLAUDE.md §5 Gate-A pass procedure + the same block in the workflow-init inline template: before each read pass, settle mechanically what the artifact asserts and a machine can decide without side effects — cited paths, quoted passages, stated counts, the syntax of standalone fenced blocks — inspecting quoted commands rather than running them, since a command quoted in a spec may be destructive or an intentional failure. Class added to docs/hardening-taxonomy.md in this same change, with its boundary against verification-masks-failure stated: there a check ran and could not fail; here the cheap check never ran at all. NO PRIOR ROW — this is the first occurrence. STILL INSTRUCTION-BACKED: nothing runs the sweep, records that it ran, or checks what it settled |
```

- [ ] **Step 6: Verify the appended rows**

```bash
cd "$(git rev-parse --show-toplevel)"
rc=0
echo "--- the four new rows: 7 fields, 8 pipes, one line each ---"
tail -4 docs/hardening-log.md | awk -F'|' '{
  pipes = gsub(/\|/,"|")
  printf "row %d: fields=%d pipes=%d\n", NR, NF-2, pipes
  if (NF-2 != 7 || pipes != 8) exit_code=1
} END { exit exit_code+0 }' || rc=1
echo "--- fingerprint counts after append ---"
for pair in "docs-drift 6" "unverified-enforcement-claim 6" "verification-masks-failure 2" "mechanical-check-skipped-before-review 1"; do
  fp=${pair% *}; want=${pair#* }
  got=$(grep -cE "^\| *[0-9-]{10} *\| *$fp *\|" docs/hardening-log.md || true)
  printf '%-42s got=%s want=%s\n' "$fp" "$got" "$want"
  [ "$got" = "$want" ] || rc=1
done
echo "ledger exit=$rc"
exit "$rc"
```

Expected: four rows each `fields=7 pipes=8`; counts `6 / 6 / 2 / 1`; `ledger exit=0`.

- [ ] **Step 7: Run the battery**

Expected: exit 0. `check-invariants.sh` excludes `docs/hardening-log.md` from checks 4a/4b — a ledger that quotes defects would otherwise self-reject.

- [ ] **Step 8: Commit**

```bash
git add docs/hardening-log.md
```

```bash
git commit -m "WIP: four ledger rows for the 0.8.0 and PR #21 hardenings"
```

---

### Task 8: The CHANGELOG entry

**Files:**
- Modify: `plugins/dev-workflow/CHANGELOG.md` (new `## 0.8.1` section directly above `## 0.8.0`)

The manifest bump already landed in Task 1. This task adds the entry describing what shipped, which is only writable once the content exists.

- [ ] **Step 1: Add the entry**

Insert immediately above `## 0.8.0`:

```markdown
## 0.8.1

- **Three sentences added to the §5 gate protocol, and to the template `/workflow-init`
  scaffolds.** The Gate-B standing lens now asks what a diff changes the size, value or position
  of, and to grep for where each is described elsewhere — asked as an open question alone it
  missed three such statements in one cycle while being carried with unusual force. The Profiles
  counterfactual now asks for both halves: name the observation that would exist if the claim
  were false, and confirm the wiring could have produced it. The Gate-A pass procedure now asks
  for a mechanical sweep before each read pass, inspecting quoted commands rather than running
  them, since a command quoted in a spec may be destructive.
- **None of the three is a check.** Nothing runs the grep, tests whether a check could have
  failed, or records that a sweep happened. They sharpen questions a reader asks; the ledger
  rows say so rather than implying otherwise.
- **No skill changed.** The `harden-finding` guard-scope precheck — the change this round set out
  to make — turned out to need decisions about durable records, ledger format and mid-run
  collisions that a rule paragraph cannot carry. It is split to its own story.
```

- [ ] **Step 2: Verify**

```bash
cd "$(git rev-parse --show-toplevel)"
h=$(grep -c '^## 0\.8\.1' plugins/dev-workflow/CHANGELOG.md || true)
v=$(grep -o '"version": *"0\.8\.1"' plugins/dev-workflow/.claude-plugin/plugin.json | head -1)
printf 'changelog headings=%s (want 1)  manifest=%s\n' "$h" "$v"
if [ "$h" = 1 ] && [ -n "$v" ]; then echo OK; exit 0; else echo "WRONG — stop and surface"; exit 1; fi
```

Expected: `OK`.

- [ ] **Step 3: Run the battery**

Expected: exit 0.

- [ ] **Step 4: Commit**

```bash
git add plugins/dev-workflow/CHANGELOG.md
```

```bash
git commit -m "WIP: 0.8.1 changelog entry"
```

---

### Task 9: Validation evidence and the Gate-B cycle

**Files:**
- Create: `.context/evidence-0.8.1.md` — the durable evidence record. `.context/` is git-ignored, so it never enters the diff; its content is folded into the closing commit body at Step 8.

**Interfaces:**
- Consumes: every prior task.
- Produces: the final commit.

- [ ] **Step 1: Create the evidence file with its full structure**

```bash
cd "$(git rev-parse --show-toplevel)"
EVIDENCE="$(git rev-parse --show-toplevel)/.context/evidence-0.8.1.md"
mkdir -p "$(dirname "$EVIDENCE")"
cat > "$EVIDENCE" <<'EOF'
# Validation evidence — hardening round 0.8.1

Story: docs/superpowers/stories/2026-08-03-hardening-round-0-8-0-and-pr-21-story.md

## battery
command: (the quality command from AGENTS.md § Commands)
exit status: <fill>
terminal line, hook suite under sh:   <fill: expect "all passed">
terminal line, hook suite under dash: <fill: expect "all passed">
terminal line, invariants suite:      <fill: expect "all passed (N assertions)">
terminal line, version-bump suite:    <fill: expect "all passed (N assertions)">
claude plugin validate --strict:      <fill>
derived hook-suite assertion counts (the suite prints none):
  HOOK_SH=sh   sh   plugins/dev-workflow/hooks/codex-gate.test.sh 2>&1 | grep -c '^ok '  -> <fill>
  HOOK_SH=dash dash plugins/dev-workflow/hooks/codex-gate.test.sh 2>&1 | grep -c '^ok '  -> <fill>

## check (named verification), with its counterfactual
§5.2 applied to the four cases in spec §10 — each must FAIL on the wiring half:
  1. $EVIDENCE dry run          -> <fill: FAIL/PASS + one line why>
  2. single-shell regression     -> <fill>
  3. timed regression row        -> <fill>
  4. dash release evidence       -> <fill>
§5.4 applied to "It bounds the scan, not memory" — must FAIL on exhaustiveness:
                                   <fill>
counterfactual: all four were reviewed during the 0.8.0 cycle under the §5 text as it
read before this change and each was accepted by at least one review looking for exactly
this; one (the single-shell test) reached the released artifact.

## prompt conformance
workflow-init.md (invariant 11 surface) — all 12 items: <fill: pass/exception per item>
CLAUDE.md, AGENTS.md (not on invariant 11's list) — items 6,7,8,9,11,12: <fill>
four split stories — in-spirit brief review: <fill>

## mirror parity
Task 1 Step 6 re-run result: <fill>

## cross-finding conflict check
Task 0 verdict: <fill>
EOF
echo "created: $EVIDENCE"
if [ -s "$EVIDENCE" ]; then echo "non-empty OK"; exit 0; else echo "EMPTY — stop and surface"; exit 1; fi
```

`$EVIDENCE` is defined here, in this step, before any later step reads it. A dry run that assigns the variable itself would prove the shell mechanics and never that this plan defines it — the `verification-masks-failure` case row C records.

- [ ] **Step 2: Squash the WIP commits into one snapshot**

Inspect first. This block is read-only and prints the hash the next block needs:

```bash
cd "$(git rev-parse --show-toplevel)"
n=$(git log --format='%s' | grep -c '^WIP: three §5 sentences' || true)
echo "matching WIP anchors: $n (want exactly 1)"
if [ "$n" != "1" ]; then
  echo "AMBIGUOUS OR MISSING ANCHOR — stop and surface"; exit 1
fi
first_wip=$(git log --format='%H %s' | awk '/ WIP: three §5 sentences/{print $1}')
echo "first WIP: $first_wip"
echo "its parent: $(git rev-parse "$first_wip"^)"
echo "--- commits that will be squashed ---"
git log --oneline "$first_wip"^..HEAD
exit 0
```

Expected: `matching WIP anchors: 1`, one hash, its parent, and a log listing exactly the WIP commits from Tasks 1–8. If a resumed or repeated task produced two matching subjects, **stop and surface** — a reset against an ambiguous anchor rewrites history at the wrong point.

Then squash, **recomputing and re-validating the anchor inside the same block that resets**, because the variable above does not survive into a fresh shell and a reset against an empty target would rewrite from the wrong commit:

```bash
cd "$(git rev-parse --show-toplevel)"
n=$(git log --format='%s' | grep -c '^WIP: three §5 sentences' || true)
[ "$n" = "1" ] || { echo "ANCHOR NO LONGER UNIQUE — stop"; exit 1; }
first_wip=$(git log --format='%H %s' | awk '/ WIP: three §5 sentences/{print $1}')
[ -n "$first_wip" ] || { echo "ANCHOR EMPTY — stop"; exit 1; }
git reset --soft "$first_wip"^
```

```bash
git commit -m "WIP: hardening round — the 0.8.0 cycle and PR #21"
```

Expected afterwards: `git log --oneline -2` shows the single WIP snapshot on top of the pre-round HEAD.

- [ ] **Step 3: Run the full battery and record the real numbers**

Run the quality command and record, under `## battery`, its exit status plus **each suite's terminal line verbatim**. What the battery actually emits, established by running it:

| Component | What it prints on success |
|---|---|
| `shellcheck` (six invocations) | nothing |
| hook suite, `HOOK_SH=sh` | `all passed` — **no assertion count** |
| hook suite, `HOOK_SH=dash` | `all passed` — **no assertion count** |
| `check-invariants.test.sh` | `all passed (N assertions)` |
| `check-version-bump.test.sh` | `all passed (N assertions)` |
| `check-invariants.sh` | `invariant checks: ok` |
| `claude plugin validate . --strict` | its own success line |

**Do not write a number you did not read from output.** The hook suite prints no total, so if a count is wanted it must be **derived**, and the evidence template labels it as derived:

```bash
cd "$(git rev-parse --show-toplevel)"
HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh 2>&1 | grep -c '^ok '
```

That command was run while writing this plan and returned `467`; it is recorded here because `AGENTS.md`'s "Never document a command that wasn't run" applies to plans as much as to the Commands table. Expect the count to change as the suite grows — record what your run prints, not this number.

- [ ] **Step 4: Run the named verification and record it**

Apply §5.2's sentence, exactly as it now reads in `CLAUDE.md`, to the four cases in spec §10. Each must **fail** on the second half. Then apply §5.4's appended clause to `It bounds the **scan**, not memory` — it must fail on exhaustiveness. Write all five verdicts into `$EVIDENCE`.

If any case passes the sentence written to reject it, that sentence is miswired: **stop and surface**, do not proceed to Gate B.

- [ ] **Step 5: Run the prompt-conformance reviews and record them**

`plugins/dev-workflow/commands/workflow-init.md` is the only changed file inside invariant 11's enumerated surface. Review it against all 12 items of `docs/prompt-standards.md`; all 12 must pass, with an exception only where the checklist item itself authorizes one (items 9 and 12 do), recorded with that item's stated reason.

`CLAUDE.md` and `AGENTS.md` are not on that list — neither carries a `Target model:` line, because neither is executed against a named model. Review their edits against items 6, 7, 8, 9, 11 and 12. §5.4's clause continues an existing prohibition; item 9's own text exempts rules whose subject is the prohibition, so cite that exemption rather than assuming it.

Give each of the four split stories a recorded in-spirit brief review — success criteria, stop conditions, verified claims — without asserting the mandatory 12 apply.

Write all results into `$EVIDENCE`.

- [ ] **Step 6: Re-run mirror parity and record it**

Re-run Task 1 Step 6's block and write the result into `$EVIDENCE`. Parity is checked here, again after every Gate-B fix, and once more immediately before Step 8 — a review fix can touch only `CLAUDE.md` or only the template and otherwise reach the final commit unnoticed.

- [ ] **Step 7: Run Gate B**

Per CLAUDE.md §5. Tool: `mcp__codex__review`, `reviewType: full`, `baseSha` = the parent of the WIP commit. Delete both branch target files first and confirm they are gone. Carry the story path and `$EVIDENCE`'s content verbatim in `additionalContext`, plus the standing lens.

Minimum three passes, final pass clean. Re-review after every fix — a fix changes the diff. Every pass writes to `.context/codex-reviews/gate-b-<spec|quality>-pass-<p>.md` and is validated before it is read: terminator exact, count matching, nothing but finding lines, both branch files present.

After each fix: re-run the battery, re-run mirror parity, and update `$EVIDENCE` before the next call.

- [ ] **Step 8: Close the cycle by amend**

```bash
cd "$(git rev-parse --show-toplevel)"
EVIDENCE="$(git rev-parse --show-toplevel)/.context/evidence-0.8.1.md"
[ -r "$EVIDENCE" ] && [ -s "$EVIDENCE" ] || { echo "EVIDENCE missing or empty — stop"; exit 1; }
grep -q '<fill' "$EVIDENCE" && { echo "EVIDENCE still has unfilled placeholders — stop"; exit 1; }
echo "evidence ready"
```

Then amend with the real message plus the evidence body:

```bash
git commit --amend -m "Harden four classes from the 0.8.0 cycle and PR #21" -m "$(cat "$EVIDENCE")"
```

The amend replaces the WIP message wholesale, so an entry written only into the WIP body is destroyed exactly when the cycle closes. The `<fill` guard is what stops a template shipping as evidence.

- [ ] **Step 9: Open the PR**

```bash
git push -u origin HEAD
```

```bash
gh pr create --title "Harden four classes from the 0.8.0 cycle and PR #21" --body "$(cat "$EVIDENCE")"
```

Then run `/dev-workflow:process-pr-review` once the bots report.

---

## Self-Review

**Spec coverage.** §5.1 → Task 1 Step 1. §5.2 → Task 1 Step 2. §5.3 → Task 1 Step 3. §5.4 → Task 2. §6 rows A–D → Task 7. §6.4 collision behaviour → Task 7 Step 1. §6.5 class → Task 3. §8 four stories → Tasks 4–5, each path classified immediately before its own write. §9 deliverables → Task 6 (todos), Task 1 Step 5 (version), Task 8 (CHANGELOG), Task 3 (taxonomy). §10 validation → Task 9, recorded in `.context/evidence-0.8.1.md`. §10 cross-finding conflict check → **Task 0**, before any edit, as the spec requires. Decision D7 (no skill file) → Global Constraints and Task 3 Step 2.

**Placeholder scan.** No `TBD`, no "add appropriate handling", no "similar to Task N". Every ledger row, story, CHANGELOG entry and the evidence template is written out in full. The only `/path/to/` style references are gone: the evidence artifact has a real path, and the commit and PR bodies are generated from it.

**Type consistency.** `mechanical-check-skipped-before-review` is identical in Task 3 (minting) and Task 7 Steps 1, 5, 6. The four story paths are identical in Tasks 4, 5, 6 and their verification steps. The three §5 sentence openings used in Task 1 Step 6's parity patterns match the sentences inserted in Steps 1–3. `$EVIDENCE` is defined in Task 9 Step 1 and read in Steps 3–9.

**POSIX conformance.** Every fenced block parses under `sh -n` **and** avoids the constructs `sh -n` does not catch: no `${var:offset:length}`, no `<(...)`, no `[[ ]]`, no arrays. Truncation uses `printf '%.Ns'`. Every `grep -c` is captured with `|| true` and compared numerically, because it exits 1 on a zero count.

**Battery orderability.** The manifest bump lands in Task 1 with the first `plugins/` change, so `check-version-bump.sh main` — part of the battery every task runs — passes from that point on. Deferring it would have made Tasks 2–7 fail by construction.
