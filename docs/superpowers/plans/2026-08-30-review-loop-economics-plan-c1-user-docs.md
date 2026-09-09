# Plan C1 — the user-facing floor description

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Correct every sentence in `README.md` and `docs/getting-started.md` that Plan A makes
false about **where the pass floor comes from**. Nine sentences in eight replacements, two files,
one claim.

**Spec:** `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md` (revision 36).
C1 implements the part of §7 that lands in these two user-facing docs.

**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`

> **Read the profile from that header at execution time.** This plan states no risk value, no
> security value, no validation mode and no pass count derived from any of them. The evidence the
> mode requires is produced by Plan C3, which runs the one Gate-B cycle.

---

## Why this plan is small

Plan C tried to carry this rollout, the packaging, the evidence and the Gate-B cycle in one
artifact. Its Gate-A cycle **ran seven passes and never converged** — Blocker/Major stayed between
15 and 21, and the last pass was the worst. The record is
`.context/codex-reviews/gate-a-plan-planc-CLOSURE.md`. Daniel split it by statement site.

**C1 is the first of three.** C2 takes the packaging and the satisfied-message description; C3
takes the evidence, the Gate-B cycle and the close.

### The one claim this plan owns

**Three passes is not a universal or constant floor.** §5 derives the floor from the profile and
the cited set, and the `codex-gate.floor` knob moves the hook's **reminder threshold** rather than
that floor.

**Three is still the right answer in most states.** The claim being corrected is that it is
*always* the answer, and that the knob moves it. **This plan states no floor for this story** —
the value is recomputed from the story header at execution time, and a number written here would
be stale the moment that header moved.

**The rule, exactly as Plan A ships it** (byte-frozen; quoted rather than summarised because a
summary of this is what pass 1 and pass 2 both caught):

**The stop conditions come first, and they are not outvoted by the rest of the set.** A mixed
set — one unresolvable member beside several level-0 ones — **stops**; it does not fall through to
a floor. Reading a stop as 3 would turn a stop condition into a silent default, which is the one
thing Plan A says the derivation must never do.

- **No value, and the cycle stops** for: a cited profile present but **unresolvable**; governing
  headers that **disagree**; a `Story:` header that **cannot be read**.
- **Otherwise, floor 1 if and only if** the cited set is **non-empty** and **every** member is
  **profiled**, **resolvable** and at **level 0** — all four conditions, since *every member* is
  vacuously true of an empty set.
- **Otherwise, floor 3**: no story cited; any cited story unprofiled; or any resolvable member
  above level 0. There are two levels, not three — `high` takes its rigor from lens sets and
  evidence mode, not from extra passes.

One derived value governs all three cycles, because they derive from the same cited-story set.

Nine sentences state the claim wrongly, in eight replacements. They are the complete set in these
two files **as of this revision**, found by reading for the claim — every place a number of
passes, a floor, a threshold, gate satisfaction, or the knob is described. **Two of the nine were
found by review rather than by that reading** (pass 1 and pass 2 each found one), which is the
measure of how much the reading is worth.

**Task 9 is a bounded mechanical check, not a proof of completeness.** It re-runs the *numeric*
spellings and the two knob phrasings. A tenth sentence stating the claim without a number would
pass it. The plan says so at the task rather than implying otherwise here.

### What this plan does not own, so that nothing falls between the pieces

| Not here | Where | Why not here |
|---|---|---|
| `docs/getting-started.md:58`, the satisfied-message example | **C2** | It describes what the hook's message *reports* — three numbers, three meanings. A different claim in the same file. The below-floor sites at lines 35 and 44 are **not** that claim and are Tasks 3 and 5 here. |
| CHANGELOG entry, manifest bump, the item-1 n/a sentence | **C2** | Packaging. |
| The parser claim, the findings-slot rule, spec §8, the evidence pack, the Gate-B cycle, the close, the field report | **C3** | C3's site list must name the two shipped prompt copies carrying *"because the deferred metrics work parses it"* — the two sites Plan C's own claim sweep missed. |
| `docs/coding-workflow.md` — the axes sentence and the model-recording sentence | **UNASSIGNED** | Neither a C1 file, nor packaging, nor the close. |
| The skipped-cycle duty sentence in five files | **UNASSIGNED** | One claim across `process-pr-review.md`, `CLAUDE.md`, the scaffolded template and both explanatory summaries. |

**The two unassigned rows are a real gap in the split, and they block the combined close rather
than this plan.** The story requires every falsified shipped sentence corrected in the same
change, so C3 cannot close while they have no owner. Named here, routed to Daniel, and **not
absorbed** — taking them would make C1 a second Plan C, which is what the split exists to prevent.

---

## Global Constraints

- **These edits join the open cycle.** Every task amends the WIP commit with
  `-m "WIP: review-loop economics"`. `plugins/dev-workflow/hooks/codex-gate.sh:763` recognizes a
  WIP commit by grepping the Bash command string for `-m ... wip`. **An amend the hook does not
  recognize as WIP is treated as a Gate-B cycle boundary and the cycle's Gate-B state is reset —
  regardless of whether the commit itself succeeded**, since that branch cannot observe exit
  status. Gate-A state is reset by skill events, not here. **Never `git commit --amend --no-edit`.**
- **Every amend runs three cheap guards before staging**, and it is worth being exact about what
  they establish: the branch is `review-loop-economics`, `HEAD`'s subject is exactly the WIP
  subject, and `HEAD^` is not itself a WIP. **They catch the wrong branch, a closed cycle, a
  stacked WIP and a plain out-of-order run. They do not establish that `HEAD` is *this* cycle's
  WIP** — a different commit with the same subject on the same branch passes all three, and every
  amend changes the SHA, so there is no stable value to compare against without a lock this plan
  does not have. **Single-executor, single-worktree is a precondition of this plan, not something
  it verifies.**
- **Every amend inspects the index before staging.** `git commit --amend` commits the whole
  index, so a change staged by anything else would ride along, and `git add <path>` does nothing
  to prevent that. **Empty is fine and this task's own path already staged is fine** — that is
  what an interrupted add-then-amend leaves behind, and rejecting it would dead-end the resume
  path this plan advertises. **Any other staged path stops.** The scoped read is
  `git diff HEAD -- <path>`, which sees the index as well as the worktree; plain `git diff` does
  not.
- **Every git command whose output is tested has its status checked first.** `test -z "$(cmd)"`
  reads a *failed* command's empty output as a clean result, which would let a broken index or an
  unreadable repository pass a safety precondition.
- **Every amend verifies the replacement reached `HEAD`** by reading the committed blob back.
- **No ordinary commit until C3 closes the cycle.**
- **Line numbers are provenance, never instructions.**
- **Preflight and assert are different commands and every task carries both, instantiated.** The
  preflight is a state machine over the changed old and new lines where **every-new-zero means
  apply**; the assert runs after the edit, where every changed new line must appear **exactly
  once** and every replaced old line **zero** times. Reversing them would abort every task that
  has not run yet.
- **Every replacement is line-complete and every check is `grep -cxF`** — whole-line equality. A
  replacement that lands but drops a clause fails. This also removes the counting hazard a
  substring check has, where two occurrences on one line count as one.
- **A multi-line replacement asserts only the lines that change.** Task 2 carries one line
  through unaltered; asserting it would assert the file's prior state.
- **Neither file is touched by Plan A or Plan B**, so every anchor below was verified against the
  **current** tree. No simulation, and none claimed.

---

## Task 0: Checkpoint

**Runs before Task 1.** It establishes the preconditions every later task assumes, and it records
the one value a rollback needs.

- [ ] **Establish the starting state.**

```bash
git symbolic-ref --short HEAD | grep -qx 'review-loop-economics' || { echo "WRONG BRANCH — stop"; exit 1; }
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
if git log -1 --pretty=%s HEAD^ | grep -q '^WIP:'; then echo "STACKED WIP — collapse first"; exit 1; fi
st=$(git status --porcelain) || { echo "git status FAILED — stop"; exit 1; }
test -z "$st" || { echo "TREE NOT CLEAN — resolve before starting C1"; exit 1; }
echo "PRE-C1 WIP: $(git rev-parse HEAD)   <-- record this value"
```

- [ ] **Rollback, if C1 must be undone.** Only with the recorded SHA, and only while the tree is
  clean:

```bash
sha=PASTE_THE_RECORDED_PRE_C1_WIP_SHA
st=$(git status --porcelain) || { echo "git status FAILED — stop"; exit 1; }
test -z "$st" || { echo "TREE NOT CLEAN — do not reset; inspect first"; exit 1; }
git log --oneline "$sha"..HEAD   # read it: every commit here must be C1's
git rev-parse --verify "$sha^{commit}" >/dev/null 2>&1 || { echo "NOT A COMMIT — check the recorded value"; exit 1; }
git log -1 --pretty=%s "$sha" | grep -qx 'WIP: review-loop economics' || { echo "RECORDED SHA IS NOT THE WIP — stop"; exit 1; }
git reset --hard "$sha"
```

> **What this rollback does and does not cover.** It restores the branch to the recorded commit,
> and Plans A and B are behind that commit and untouched. It is **not** a general safety net: a
> clean worktree says nothing about *commits* made after the checkpoint by anything else, and
> `git status` cannot see them — so a `--hard` here would discard them. It also races anything
> writing concurrently, which is why single-executor is a precondition above.
>
> **It covers exactly one state: a clean tree whose only commits since the checkpoint are C1's.**
> Establish that by reading `git log <sha>..HEAD` before resetting. **Any other state — a dirty
> tree, a staged edit, an unfamiliar commit — is a stop, and this plan supplies no recovery for
> it**, because a recovery procedure nobody has exercised is worse than an instruction to look.

---

## Task 1: The knob row in `README.md`

**File:** `README.md`

**Site** — pasted `grep -n`:

```
README.md:130:| `codex-gate.floor` | a positive integer; moves the 3-passes-per-gate floor. |
```

> The knob never bound an agent. `$floor` appears in the hook's control flow, but that flow only
> selects which advisory message fires, and the hook exits 0 on every branch. This line was the
> clearest statement of the wrong model anywhere in the docs.

- [ ] **Preflight — a state machine over both texts, where every-new-zero is the signal to apply.**

```sh
  o1=$(grep -cxF -- '| `codex-gate.floor` | a positive integer; moves the 3-passes-per-gate floor. |' README.md)
  n1=$(grep -cxF -- '| `codex-gate.floor` | a positive integer; moves the hook'\''s reminder threshold. It does not change the floor §5 obliges, which §5 derives from the profile and the cited set. |' README.md)
if [ "$o1" -eq 1 ] && [ "$n1" -eq 0 ]; then
  :                                       # not applied — apply it
elif [ "$o1" -eq 0 ] && [ "$n1" -eq 1 ]; then
  if [ -n "$(git diff HEAD -- README.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
    # the amend step accepts this task's path already being staged, so an interrupted
    # add-then-amend resumes there rather than dead-ending on a non-empty index
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
| `codex-gate.floor` | a positive integer; moves the 3-passes-per-gate floor. |
```

NEW:

```
| `codex-gate.floor` | a positive integer; moves the hook's reminder threshold. It does not change the floor §5 obliges, which §5 derives from the profile and the cited set. |
```

- [ ] **Assert** — every changed line present exactly once, whole; every replaced line gone.

```bash
test "$(grep -cxF -- '| `codex-gate.floor` | a positive integer; moves the hook'\''s reminder threshold. It does not change the floor §5 obliges, which §5 derives from the profile and the cited set. |' README.md)" -eq 1 || { echo "NEW LINE MISSING OR DUPLICATED"; exit 1; }
test "$(grep -cxF -- '| `codex-gate.floor` | a positive integer; moves the 3-passes-per-gate floor. |' README.md)" -eq 0 || { echo "OLD LINE SURVIVES"; exit 1; }
```

- [ ] **Amend** — identity first, index empty, scoped diff read, then verify it reached `HEAD`.

```bash
git symbolic-ref --short HEAD | grep -qx 'review-loop-economics' || { echo "WRONG BRANCH — stop"; exit 1; }
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
if git log -1 --pretty=%s HEAD^ | grep -q '^WIP:'; then echo "STACKED WIP — stop"; exit 1; fi
staged=$(git diff --cached --name-only) || { echo "git diff --cached FAILED — stop"; exit 1; }
case "$staged" in
  "") : ;;
  "README.md") echo "NOTE: only this task's path is staged — an interrupted amend; continuing" ;;
  *) echo "UNEXPECTED STAGED PATHS: $staged — inspect before staging"; exit 1 ;;
esac
git diff HEAD -- README.md || { echo "git diff FAILED — stop"; exit 1; }
git add README.md || exit 1
git commit --amend -m "WIP: review-loop economics" || exit 1
test "$(git show HEAD:README.md | grep -cxF -- '| `codex-gate.floor` | a positive integer; moves the hook'\''s reminder threshold. It does not change the floor §5 obliges, which §5 derives from the profile and the cited set. |')" -eq 1 || { echo "REPLACEMENT NOT IN HEAD"; exit 1; }
```

**Read that `git diff HEAD` before staging.** It covers the worktree *and* the index, which
`git diff` alone does not — and `git commit --amend` commits the whole index, so a staged change
this task never made would ride along. The empty-index check above is what makes that observable.

---

## Task 2: The intro's account of what the hook reminds about

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:7:normally; the skills and gates structure *how Claude works*, and the hook reminds
```

> **The claim's earliest site, and the first sweep missed it.** "The hook reminds you when a gate
> isn't satisfied" presents the hook's counter as gate state. It is not: the hook reports its own
> threshold and fingerprint, and §5 decides satisfaction. Under a floor-1 cycle the hook can warn
> after the owed floor is already met; after enough counted calls it can report its threshold
> satisfied while findings are still open.
>
> **Line 1 of the replacement is unchanged** and carries no assert of its own — only the two lines
> that actually change do.

- [ ] **Preflight — a state machine over both texts, where every-new-zero is the signal to apply.**

```sh
  o1=$(grep -cxF -- 'both of you when a gate isn'\''t satisfied. Your job is the decision points —' docs/getting-started.md)
  n1=$(grep -cxF -- 'both of you when its own counter or fingerprint says a gate may not have run —' docs/getting-started.md)
  n2=$(grep -cxF -- '§5 decides whether one is satisfied. Your job is the decision points —' docs/getting-started.md)
if [ "$o1" -eq 1 ] && [ "$n1" -eq 0 ] && [ "$n2" -eq 0 ]; then
  :                                       # not applied — apply it
elif [ "$o1" -eq 0 ] && [ "$n1" -eq 1 ] && [ "$n2" -eq 1 ]; then
  if [ -n "$(git diff HEAD -- docs/getting-started.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
    # the amend step accepts this task's path already being staged, so an interrupted
    # add-then-amend resumes there rather than dead-ending on a non-empty index
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
normally; the skills and gates structure *how Claude works*, and the hook reminds
both of you when a gate isn't satisfied. Your job is the decision points —
```

NEW:

```
normally; the skills and gates structure *how Claude works*, and the hook reminds
both of you when its own counter or fingerprint says a gate may not have run —
§5 decides whether one is satisfied. Your job is the decision points —
```

- [ ] **Assert** — every changed line present exactly once, whole; every replaced line gone.

```bash
test "$(grep -cxF -- 'both of you when its own counter or fingerprint says a gate may not have run —' docs/getting-started.md)" -eq 1 || { echo "NEW LINE MISSING OR DUPLICATED"; exit 1; }
test "$(grep -cxF -- '§5 decides whether one is satisfied. Your job is the decision points —' docs/getting-started.md)" -eq 1 || { echo "NEW LINE MISSING OR DUPLICATED"; exit 1; }
test "$(grep -cxF -- 'both of you when a gate isn'\''t satisfied. Your job is the decision points —' docs/getting-started.md)" -eq 0 || { echo "OLD LINE SURVIVES"; exit 1; }
```

- [ ] **Amend** — identity first, index empty, scoped diff read, then verify it reached `HEAD`.

```bash
git symbolic-ref --short HEAD | grep -qx 'review-loop-economics' || { echo "WRONG BRANCH — stop"; exit 1; }
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
if git log -1 --pretty=%s HEAD^ | grep -q '^WIP:'; then echo "STACKED WIP — stop"; exit 1; fi
staged=$(git diff --cached --name-only) || { echo "git diff --cached FAILED — stop"; exit 1; }
case "$staged" in
  "") : ;;
  "docs/getting-started.md") echo "NOTE: only this task's path is staged — an interrupted amend; continuing" ;;
  *) echo "UNEXPECTED STAGED PATHS: $staged — inspect before staging"; exit 1 ;;
esac
git diff HEAD -- docs/getting-started.md || { echo "git diff FAILED — stop"; exit 1; }
git add docs/getting-started.md || exit 1
git commit --amend -m "WIP: review-loop economics" || exit 1
test "$(git show HEAD:docs/getting-started.md | grep -cxF -- 'both of you when its own counter or fingerprint says a gate may not have run —')" -eq 1 || { echo "REPLACEMENT NOT IN HEAD"; exit 1; }
test "$(git show HEAD:docs/getting-started.md | grep -cxF -- '§5 decides whether one is satisfied. Your job is the decision points —')" -eq 1 || { echo "REPLACEMENT NOT IN HEAD"; exit 1; }
```

**Read that `git diff HEAD` before staging.** It covers the worktree *and* the index, which
`git diff` alone does not — and `git commit --amend` commits the whole index, so a staged change
this task never made would ride along. The empty-index check above is what makes that observable.

---

## Task 3: The Gate-A loop and its counter example

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:34:three passes minimum, final pass clean — the one early exit is a pass that comes
```

> **Two sentences, one task, on purpose.** The loop description and the `1/3` example sit in one
> paragraph and state the same claim; the first sweep split them, and a substring assert could then
> pass while a load-bearing clause was dropped. Replaced together, **every resulting line is a
> complete line** and each is asserted whole.
>
> `1/3` stays as an example — the literal is the hook's own ratio. What changes is that the
> sentence now says which number is whose. "final pass clean", the zero-finding early exit and
> "not an error" are all kept.

- [ ] **Preflight — a state machine over both texts, where every-new-zero is the signal to apply.**

```sh
  o1=$(grep -cxF -- 'three passes minimum, final pass clean — the one early exit is a pass that comes' docs/getting-started.md)
  o2=$(grep -cxF -- 'back with zero findings. Hook messages like `⚠ Codex Gate A below floor (1/3)` are' docs/getting-started.md)
  o3=$(grep -cxF -- 'the counter, not an error. Your job: arbitrate disputed findings — Codex is' docs/getting-started.md)
  n1=$(grep -cxF -- 'the floor §5 derives, final pass clean — the one early exit is a pass that comes' docs/getting-started.md)
  n2=$(grep -cxF -- 'back with zero findings. Hook messages like `⚠ Codex Gate A below floor (1/3)` count' docs/getting-started.md)
  n3=$(grep -cxF -- 'the calls against the hook'\''s own reminder threshold, not against the floor §5 obliges,' docs/getting-started.md)
  n4=$(grep -cxF -- 'and are not an error. Your job: arbitrate disputed findings — Codex is' docs/getting-started.md)
if [ "$o1" -eq 1 ] && [ "$o2" -eq 1 ] && [ "$o3" -eq 1 ] && [ "$n1" -eq 0 ] && [ "$n2" -eq 0 ] && [ "$n3" -eq 0 ] && [ "$n4" -eq 0 ]; then
  :                                       # not applied — apply it
elif [ "$o1" -eq 0 ] && [ "$o2" -eq 0 ] && [ "$o3" -eq 0 ] && [ "$n1" -eq 1 ] && [ "$n2" -eq 1 ] && [ "$n3" -eq 1 ] && [ "$n4" -eq 1 ]; then
  if [ -n "$(git diff HEAD -- docs/getting-started.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
    # the amend step accepts this task's path already being staged, so an interrupted
    # add-then-amend resumes there rather than dead-ending on a non-empty index
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
three passes minimum, final pass clean — the one early exit is a pass that comes
back with zero findings. Hook messages like `⚠ Codex Gate A below floor (1/3)` are
the counter, not an error. Your job: arbitrate disputed findings — Codex is
```

NEW:

```
the floor §5 derives, final pass clean — the one early exit is a pass that comes
back with zero findings. Hook messages like `⚠ Codex Gate A below floor (1/3)` count
the calls against the hook's own reminder threshold, not against the floor §5 obliges,
and are not an error. Your job: arbitrate disputed findings — Codex is
```

- [ ] **Assert** — every changed line present exactly once, whole; every replaced line gone.

```bash
test "$(grep -cxF -- 'the floor §5 derives, final pass clean — the one early exit is a pass that comes' docs/getting-started.md)" -eq 1 || { echo "NEW LINE MISSING OR DUPLICATED"; exit 1; }
test "$(grep -cxF -- 'back with zero findings. Hook messages like `⚠ Codex Gate A below floor (1/3)` count' docs/getting-started.md)" -eq 1 || { echo "NEW LINE MISSING OR DUPLICATED"; exit 1; }
test "$(grep -cxF -- 'the calls against the hook'\''s own reminder threshold, not against the floor §5 obliges,' docs/getting-started.md)" -eq 1 || { echo "NEW LINE MISSING OR DUPLICATED"; exit 1; }
test "$(grep -cxF -- 'and are not an error. Your job: arbitrate disputed findings — Codex is' docs/getting-started.md)" -eq 1 || { echo "NEW LINE MISSING OR DUPLICATED"; exit 1; }
test "$(grep -cxF -- 'three passes minimum, final pass clean — the one early exit is a pass that comes' docs/getting-started.md)" -eq 0 || { echo "OLD LINE SURVIVES"; exit 1; }
test "$(grep -cxF -- 'back with zero findings. Hook messages like `⚠ Codex Gate A below floor (1/3)` are' docs/getting-started.md)" -eq 0 || { echo "OLD LINE SURVIVES"; exit 1; }
test "$(grep -cxF -- 'the counter, not an error. Your job: arbitrate disputed findings — Codex is' docs/getting-started.md)" -eq 0 || { echo "OLD LINE SURVIVES"; exit 1; }
```

- [ ] **Amend** — identity first, index empty, scoped diff read, then verify it reached `HEAD`.

```bash
git symbolic-ref --short HEAD | grep -qx 'review-loop-economics' || { echo "WRONG BRANCH — stop"; exit 1; }
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
if git log -1 --pretty=%s HEAD^ | grep -q '^WIP:'; then echo "STACKED WIP — stop"; exit 1; fi
staged=$(git diff --cached --name-only) || { echo "git diff --cached FAILED — stop"; exit 1; }
case "$staged" in
  "") : ;;
  "docs/getting-started.md") echo "NOTE: only this task's path is staged — an interrupted amend; continuing" ;;
  *) echo "UNEXPECTED STAGED PATHS: $staged — inspect before staging"; exit 1 ;;
esac
git diff HEAD -- docs/getting-started.md || { echo "git diff FAILED — stop"; exit 1; }
git add docs/getting-started.md || exit 1
git commit --amend -m "WIP: review-loop economics" || exit 1
test "$(git show HEAD:docs/getting-started.md | grep -cxF -- 'the floor §5 derives, final pass clean — the one early exit is a pass that comes')" -eq 1 || { echo "REPLACEMENT NOT IN HEAD"; exit 1; }
test "$(git show HEAD:docs/getting-started.md | grep -cxF -- 'back with zero findings. Hook messages like `⚠ Codex Gate A below floor (1/3)` count')" -eq 1 || { echo "REPLACEMENT NOT IN HEAD"; exit 1; }
test "$(git show HEAD:docs/getting-started.md | grep -cxF -- 'the calls against the hook'\''s own reminder threshold, not against the floor §5 obliges,')" -eq 1 || { echo "REPLACEMENT NOT IN HEAD"; exit 1; }
test "$(git show HEAD:docs/getting-started.md | grep -cxF -- 'and are not an error. Your job: arbitrate disputed findings — Codex is')" -eq 1 || { echo "REPLACEMENT NOT IN HEAD"; exit 1; }
```

**Read that `git diff HEAD` before staging.** It covers the worktree *and* the index, which
`git diff` alone does not — and `git commit --amend` commits the whole index, so a staged change
this task never made would ride along. The empty-index check above is what makes that observable.

---

## Task 4: The plan-loop sentence

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:40:task-by-task plan (each task starts with a failing test); the same 3-pass loop runs
```

- [ ] **Preflight — a state machine over both texts, where every-new-zero is the signal to apply.**

```sh
  o1=$(grep -cxF -- 'task-by-task plan (each task starts with a failing test); the same 3-pass loop runs' docs/getting-started.md)
  n1=$(grep -cxF -- 'task-by-task plan (each task starts with a failing test); the same loop runs at the derived floor' docs/getting-started.md)
if [ "$o1" -eq 1 ] && [ "$n1" -eq 0 ]; then
  :                                       # not applied — apply it
elif [ "$o1" -eq 0 ] && [ "$n1" -eq 1 ]; then
  if [ -n "$(git diff HEAD -- docs/getting-started.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
    # the amend step accepts this task's path already being staged, so an interrupted
    # add-then-amend resumes there rather than dead-ending on a non-empty index
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
task-by-task plan (each task starts with a failing test); the same 3-pass loop runs
```

NEW:

```
task-by-task plan (each task starts with a failing test); the same loop runs at the derived floor
```

- [ ] **Assert** — every changed line present exactly once, whole; every replaced line gone.

```bash
test "$(grep -cxF -- 'task-by-task plan (each task starts with a failing test); the same loop runs at the derived floor' docs/getting-started.md)" -eq 1 || { echo "NEW LINE MISSING OR DUPLICATED"; exit 1; }
test "$(grep -cxF -- 'task-by-task plan (each task starts with a failing test); the same 3-pass loop runs' docs/getting-started.md)" -eq 0 || { echo "OLD LINE SURVIVES"; exit 1; }
```

- [ ] **Amend** — identity first, index empty, scoped diff read, then verify it reached `HEAD`.

```bash
git symbolic-ref --short HEAD | grep -qx 'review-loop-economics' || { echo "WRONG BRANCH — stop"; exit 1; }
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
if git log -1 --pretty=%s HEAD^ | grep -q '^WIP:'; then echo "STACKED WIP — stop"; exit 1; fi
staged=$(git diff --cached --name-only) || { echo "git diff --cached FAILED — stop"; exit 1; }
case "$staged" in
  "") : ;;
  "docs/getting-started.md") echo "NOTE: only this task's path is staged — an interrupted amend; continuing" ;;
  *) echo "UNEXPECTED STAGED PATHS: $staged — inspect before staging"; exit 1 ;;
esac
git diff HEAD -- docs/getting-started.md || { echo "git diff FAILED — stop"; exit 1; }
git add docs/getting-started.md || exit 1
git commit --amend -m "WIP: review-loop economics" || exit 1
test "$(git show HEAD:docs/getting-started.md | grep -cxF -- 'task-by-task plan (each task starts with a failing test); the same loop runs at the derived floor')" -eq 1 || { echo "REPLACEMENT NOT IN HEAD"; exit 1; }
```

**Read that `git diff HEAD` before staging.** It covers the worktree *and* the index, which
`git diff` alone does not — and `git commit --amend` commits the whole index, so a staged change
this task never made would ride along. The empty-index check above is what makes that observable.

---

## Task 5: The below-floor hook message

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:44:progress claims backed by test runs. If the Gate-A floor wasn't met, the hook says
```

> The hook reports against its **own threshold**, not against what the cycle owes. At a derived
> floor of 1 it announces a shortfall the cycle does not have — the named residual of this change,
> and the same claim Task 3's example carries.

- [ ] **Preflight — a state machine over both texts, where every-new-zero is the signal to apply.**

```sh
  o1=$(grep -cxF -- 'progress claims backed by test runs. If the Gate-A floor wasn'\''t met, the hook says' docs/getting-started.md)
  n1=$(grep -cxF -- 'progress claims backed by test runs. If the hook'\''s own threshold wasn'\''t met, it says' docs/getting-started.md)
if [ "$o1" -eq 1 ] && [ "$n1" -eq 0 ]; then
  :                                       # not applied — apply it
elif [ "$o1" -eq 0 ] && [ "$n1" -eq 1 ]; then
  if [ -n "$(git diff HEAD -- docs/getting-started.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
    # the amend step accepts this task's path already being staged, so an interrupted
    # add-then-amend resumes there rather than dead-ending on a non-empty index
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
progress claims backed by test runs. If the Gate-A floor wasn't met, the hook says
```

NEW:

```
progress claims backed by test runs. If the hook's own threshold wasn't met, it says
```

- [ ] **Assert** — every changed line present exactly once, whole; every replaced line gone.

```bash
test "$(grep -cxF -- 'progress claims backed by test runs. If the hook'\''s own threshold wasn'\''t met, it says' docs/getting-started.md)" -eq 1 || { echo "NEW LINE MISSING OR DUPLICATED"; exit 1; }
test "$(grep -cxF -- 'progress claims backed by test runs. If the Gate-A floor wasn'\''t met, the hook says' docs/getting-started.md)" -eq 0 || { echo "OLD LINE SURVIVES"; exit 1; }
```

- [ ] **Amend** — identity first, index empty, scoped diff read, then verify it reached `HEAD`.

```bash
git symbolic-ref --short HEAD | grep -qx 'review-loop-economics' || { echo "WRONG BRANCH — stop"; exit 1; }
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
if git log -1 --pretty=%s HEAD^ | grep -q '^WIP:'; then echo "STACKED WIP — stop"; exit 1; fi
staged=$(git diff --cached --name-only) || { echo "git diff --cached FAILED — stop"; exit 1; }
case "$staged" in
  "") : ;;
  "docs/getting-started.md") echo "NOTE: only this task's path is staged — an interrupted amend; continuing" ;;
  *) echo "UNEXPECTED STAGED PATHS: $staged — inspect before staging"; exit 1 ;;
esac
git diff HEAD -- docs/getting-started.md || { echo "git diff FAILED — stop"; exit 1; }
git add docs/getting-started.md || exit 1
git commit --amend -m "WIP: review-loop economics" || exit 1
test "$(git show HEAD:docs/getting-started.md | grep -cxF -- 'progress claims backed by test runs. If the hook'\''s own threshold wasn'\''t met, it says')" -eq 1 || { echo "REPLACEMENT NOT IN HEAD"; exit 1; }
```

**Read that `git diff HEAD` before staging.** It covers the worktree *and* the index, which
`git diff` alone does not — and `git commit --amend` commits the whole index, so a staged change
this task never made would ride along. The empty-index check above is what makes that observable.

---

## Task 6: The Gate-B loop description

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:53:`mcp__codex__review` the same way: three passes, final clean. Verification is by
```

- [ ] **Preflight — a state machine over both texts, where every-new-zero is the signal to apply.**

```sh
  o1=$(grep -cxF -- '`mcp__codex__review` the same way: three passes, final clean. Verification is by' docs/getting-started.md)
  n1=$(grep -cxF -- '`mcp__codex__review` the same way: the derived floor, final clean. Verification is by' docs/getting-started.md)
if [ "$o1" -eq 1 ] && [ "$n1" -eq 0 ]; then
  :                                       # not applied — apply it
elif [ "$o1" -eq 0 ] && [ "$n1" -eq 1 ]; then
  if [ -n "$(git diff HEAD -- docs/getting-started.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
    # the amend step accepts this task's path already being staged, so an interrupted
    # add-then-amend resumes there rather than dead-ending on a non-empty index
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
`mcp__codex__review` the same way: three passes, final clean. Verification is by
```

NEW:

```
`mcp__codex__review` the same way: the derived floor, final clean. Verification is by
```

- [ ] **Assert** — every changed line present exactly once, whole; every replaced line gone.

```bash
test "$(grep -cxF -- '`mcp__codex__review` the same way: the derived floor, final clean. Verification is by' docs/getting-started.md)" -eq 1 || { echo "NEW LINE MISSING OR DUPLICATED"; exit 1; }
test "$(grep -cxF -- '`mcp__codex__review` the same way: three passes, final clean. Verification is by' docs/getting-started.md)" -eq 0 || { echo "OLD LINE SURVIVES"; exit 1; }
```

- [ ] **Amend** — identity first, index empty, scoped diff read, then verify it reached `HEAD`.

```bash
git symbolic-ref --short HEAD | grep -qx 'review-loop-economics' || { echo "WRONG BRANCH — stop"; exit 1; }
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
if git log -1 --pretty=%s HEAD^ | grep -q '^WIP:'; then echo "STACKED WIP — stop"; exit 1; fi
staged=$(git diff --cached --name-only) || { echo "git diff --cached FAILED — stop"; exit 1; }
case "$staged" in
  "") : ;;
  "docs/getting-started.md") echo "NOTE: only this task's path is staged — an interrupted amend; continuing" ;;
  *) echo "UNEXPECTED STAGED PATHS: $staged — inspect before staging"; exit 1 ;;
esac
git diff HEAD -- docs/getting-started.md || { echo "git diff FAILED — stop"; exit 1; }
git add docs/getting-started.md || exit 1
git commit --amend -m "WIP: review-loop economics" || exit 1
test "$(git show HEAD:docs/getting-started.md | grep -cxF -- '`mcp__codex__review` the same way: the derived floor, final clean. Verification is by')" -eq 1 || { echo "REPLACEMENT NOT IN HEAD"; exit 1; }
```

**Read that `git diff HEAD` before staging.** It covers the worktree *and* the index, which
`git diff` alone does not — and `git commit --amend` commits the whole index, so a staged change
this task never made would ride along. The empty-index check above is what makes that observable.

---

## Task 7: The axes sentence

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:84:is still owed and Gate A's floor is unchanged at every level. The caution bias is
```

> **Three claims share this sentence and only one is false.** That the profile supplies
> eligibility rather than the skip: **kept**. That the battery is still owed: **kept**. That Gate
> A's floor is unchanged at every level: **this change makes it false**, and it is the only clause
> replaced. **Nothing is added** — an earlier draft introduced a clause about baseline questions
> the old sentence never made.

- [ ] **Preflight — a state machine over both texts, where every-new-zero is the signal to apply.**

```sh
  o1=$(grep -cxF -- 'is still owed and Gate A'\''s floor is unchanged at every level. The caution bias is' docs/getting-started.md)
  n1=$(grep -cxF -- 'is still owed; Gate A'\''s floor derives from the profile and the cited set exactly as Gate B'\''s does. The caution bias is' docs/getting-started.md)
if [ "$o1" -eq 1 ] && [ "$n1" -eq 0 ]; then
  :                                       # not applied — apply it
elif [ "$o1" -eq 0 ] && [ "$n1" -eq 1 ]; then
  if [ -n "$(git diff HEAD -- docs/getting-started.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
    # the amend step accepts this task's path already being staged, so an interrupted
    # add-then-amend resumes there rather than dead-ending on a non-empty index
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
is still owed and Gate A's floor is unchanged at every level. The caution bias is
```

NEW:

```
is still owed; Gate A's floor derives from the profile and the cited set exactly as Gate B's does. The caution bias is
```

- [ ] **Assert** — every changed line present exactly once, whole; every replaced line gone.

```bash
test "$(grep -cxF -- 'is still owed; Gate A'\''s floor derives from the profile and the cited set exactly as Gate B'\''s does. The caution bias is' docs/getting-started.md)" -eq 1 || { echo "NEW LINE MISSING OR DUPLICATED"; exit 1; }
test "$(grep -cxF -- 'is still owed and Gate A'\''s floor is unchanged at every level. The caution bias is' docs/getting-started.md)" -eq 0 || { echo "OLD LINE SURVIVES"; exit 1; }
```

- [ ] **Amend** — identity first, index empty, scoped diff read, then verify it reached `HEAD`.

```bash
git symbolic-ref --short HEAD | grep -qx 'review-loop-economics' || { echo "WRONG BRANCH — stop"; exit 1; }
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
if git log -1 --pretty=%s HEAD^ | grep -q '^WIP:'; then echo "STACKED WIP — stop"; exit 1; fi
staged=$(git diff --cached --name-only) || { echo "git diff --cached FAILED — stop"; exit 1; }
case "$staged" in
  "") : ;;
  "docs/getting-started.md") echo "NOTE: only this task's path is staged — an interrupted amend; continuing" ;;
  *) echo "UNEXPECTED STAGED PATHS: $staged — inspect before staging"; exit 1 ;;
esac
git diff HEAD -- docs/getting-started.md || { echo "git diff FAILED — stop"; exit 1; }
git add docs/getting-started.md || exit 1
git commit --amend -m "WIP: review-loop economics" || exit 1
test "$(git show HEAD:docs/getting-started.md | grep -cxF -- 'is still owed; Gate A'\''s floor derives from the profile and the cited set exactly as Gate B'\''s does. The caution bias is')" -eq 1 || { echo "REPLACEMENT NOT IN HEAD"; exit 1; }
```

**Read that `git diff HEAD` before staging.** It covers the worktree *and* the index, which
`git diff` alone does not — and `git commit --amend` commits the whole index, so a staged change
this task never made would ride along. The empty-index check above is what makes that observable.

---

## Task 8: The second knob mention

**File:** `docs/getting-started.md`

**Site** — pasted `grep -n`:

```
docs/getting-started.md:86:positive integer) moves the 3-pass floor, and `touch .context/codex-gate.off`
```

> The same correction as Task 1, in the second place the docs describe the knob. **Both sites say
> the same wrong thing**, and this repo's own record is that a fix to one has never implied a fix
> to the other.

- [ ] **Preflight — a state machine over both texts, where every-new-zero is the signal to apply.**

```sh
  o1=$(grep -cxF -- 'positive integer) moves the 3-pass floor, and `touch .context/codex-gate.off`' docs/getting-started.md)
  n1=$(grep -cxF -- 'positive integer) moves the hook'\''s reminder threshold, and `touch .context/codex-gate.off`' docs/getting-started.md)
if [ "$o1" -eq 1 ] && [ "$n1" -eq 0 ]; then
  :                                       # not applied — apply it
elif [ "$o1" -eq 0 ] && [ "$n1" -eq 1 ]; then
  if [ -n "$(git diff HEAD -- docs/getting-started.md)" ]; then
    echo "REPLACED BUT NOT YET IN THE WIP — run the amend step only, then skip"; exit 0
    # the amend step accepts this task's path already being staged, so an interrupted
    # add-then-amend resumes there rather than dead-ending on a non-empty index
  fi
  echo "ALREADY APPLIED AND COMMITTED — skip"; exit 0
else
  echo "MIXED OR DUPLICATE STATE — stop, do not retry"; exit 1
fi
```

- [ ] **Replace.** OLD:

```
positive integer) moves the 3-pass floor, and `touch .context/codex-gate.off`
```

NEW:

```
positive integer) moves the hook's reminder threshold, and `touch .context/codex-gate.off`
```

- [ ] **Assert** — every changed line present exactly once, whole; every replaced line gone.

```bash
test "$(grep -cxF -- 'positive integer) moves the hook'\''s reminder threshold, and `touch .context/codex-gate.off`' docs/getting-started.md)" -eq 1 || { echo "NEW LINE MISSING OR DUPLICATED"; exit 1; }
test "$(grep -cxF -- 'positive integer) moves the 3-pass floor, and `touch .context/codex-gate.off`' docs/getting-started.md)" -eq 0 || { echo "OLD LINE SURVIVES"; exit 1; }
```

- [ ] **Amend** — identity first, index empty, scoped diff read, then verify it reached `HEAD`.

```bash
git symbolic-ref --short HEAD | grep -qx 'review-loop-economics' || { echo "WRONG BRANCH — stop"; exit 1; }
git log -1 --pretty=%s | grep -qx 'WIP: review-loop economics' || { echo "HEAD IS NOT THE WIP — stop"; exit 1; }
if git log -1 --pretty=%s HEAD^ | grep -q '^WIP:'; then echo "STACKED WIP — stop"; exit 1; fi
staged=$(git diff --cached --name-only) || { echo "git diff --cached FAILED — stop"; exit 1; }
case "$staged" in
  "") : ;;
  "docs/getting-started.md") echo "NOTE: only this task's path is staged — an interrupted amend; continuing" ;;
  *) echo "UNEXPECTED STAGED PATHS: $staged — inspect before staging"; exit 1 ;;
esac
git diff HEAD -- docs/getting-started.md || { echo "git diff FAILED — stop"; exit 1; }
git add docs/getting-started.md || exit 1
git commit --amend -m "WIP: review-loop economics" || exit 1
test "$(git show HEAD:docs/getting-started.md | grep -cxF -- 'positive integer) moves the hook'\''s reminder threshold, and `touch .context/codex-gate.off`')" -eq 1 || { echo "REPLACEMENT NOT IN HEAD"; exit 1; }
```

**Read that `git diff HEAD` before staging.** It covers the worktree *and* the index, which
`git diff` alone does not — and `git commit --amend` commits the whole index, so a staged change
this task never made would ride along. The empty-index check above is what makes that observable.

---

## Task 9: Confirm the claim has no tenth site

**Runs last.** This re-runs the mechanical part of the discovery search against the finished
files. **It is a bounded check, not a completeness proof** — see the boundary stated under the
first command, and the plan's own count of sites that only review found.

- [ ] **No numeric floor claim survives, except the one C2 owns.**

```bash
if grep -nEi '3-pass|three passes|3 passes|3-passes-per-gate|[0-9]/3' README.md docs/getting-started.md \
   | grep -vF 'Codex Gate B satisfied (3/3 cycle'; then
  echo "A NUMERIC FLOOR CLAIM SURVIVES — read the hits printed above"; exit 1
fi
```

> **The one expected hit is filtered, not tolerated.** The satisfied-message example at
> `docs/getting-started.md:58` prints `3/3 cycle` and belongs to **C2**; C1 runs first, so that
> line is still there when this check runs. Filtering it by exact text is what lets the check
> reach its passing state while C2 is still owed — an unfiltered version could never pass in the
> stated order, which pass 2 caught.
>
> **This sweep covers the numeric spellings only.** Tasks 2, 5 and 7 correct sentences that state
> the claim with no number — *"when a gate isn't satisfied"*, *"If the Gate-A floor wasn't met"*,
> *"Gate A's floor is unchanged at every level"* — and those are covered by their own tasks'
> old-line-gone asserts, not by this grep. Said here because a sweep that looks complete and is
> not is worse than one whose boundary is written down.

- [ ] **The knob's non-binding property holds at both sites.**

```bash
test "$(grep -cF -- "moves the hook's reminder threshold" README.md)" -eq 1 || { echo "README KNOB LINE WRONG"; exit 1; }
test "$(grep -cF -- "moves the hook's reminder threshold" docs/getting-started.md)" -eq 1 || { echo "GETTING-STARTED KNOB LINE WRONG"; exit 1; }
if grep -nF -e "moves the 3-pass floor" -e "moves the 3-passes-per-gate floor" README.md docs/getting-started.md; then
  echo "A KNOB-BINDS-THE-FLOOR CLAIM SURVIVES"; exit 1
fi
```

> **Fixed strings, not a general pattern, and deliberately.** A regex broad enough to catch any
> re-binding of the floor was written first and **errored on this machine's `grep`** —
> *"exceeds complexity limits"*. A command that cannot run reports nothing and reads as a pass,
> which is worse than a narrow check. These three catch the two phrasings that existed and confirm
> the replacement landed in both files; a *newly invented* way of saying the knob moves the floor
> is caught by a reader, not by this.
>
> **The two knob rows are deliberately not identical** — `README.md` names the source, the
> getting-started line does not. The check is on the property, not on sameness.

- [ ] **If either check produced a fix**, amend as the tasks above do and re-run both. A clean
  Task 9 stages nothing and amends nothing — the only task here that does not.

---

## Self-Review

**Scope.** Nine sentences in eight replacements, two files, one claim. Every anchor verified
against the current tree; neither file is touched by Plan A or Plan B, so no simulation was needed
and none is claimed.

**Every replacement is line-complete, and every check is whole-line equality.** Pass 1 caught
substring sentinels that could pass after a clause was dropped; pass 2 caught the two remaining
mid-line replacements with the same hole. Tasks 2 and 3 were restructured — the intro's three
lines and the Gate-A paragraph's four — so that no replacement lands mid-line anywhere in the
plan and `grep -cxF` covers all of them.

**Task 3 merges two sentences the first sweep had split.** They sit in one paragraph and carry one
claim, and splitting them is what let a substring check look sufficient.

**Two sites came from review, not from the original sweep**: the `1/3` counter example (pass 1)
and the intro's *"when a gate isn't satisfied"* (pass 2). Both were found by reading for the
claim, both are now owned, and the fact that a claim-grep missed them twice is recorded in the
plan rather than smoothed over.

**The derivation rule is quoted, not summarised.** Both earlier revisions summarised it and both
summaries were wrong — first by making the source a single story, then by omitting the
above-level-0 arm and two of the three stop conditions.

**Rollback is a task, not a sentence.** Task 0 records the SHA and establishes the clean-tree
precondition that makes `--hard` safe; the plan says what to do when that precondition fails.

**Two rows in the scope table have no owner**, and that is stated as a gap in the split rather
than solved here. They block C3's close, not this plan. Absorbing them would rebuild Plan C.

**Known limit.** Gate A reviews this plan, not the edits. What the edits do is Gate B's — C3's.
