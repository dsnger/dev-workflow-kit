# Plan A — the rules edits (floor predicate + severity semantics)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship parts 1 and 2 of the review-loop-economics change into both prompt copies — the
pass floor becomes a function of the cited story's profile, and finding severity is decided by
whether something in the system takes a different decision.

**Architecture:** Two mirrored prose edits, block by block: `CLAUDE.md` §5 and the inline template
in `/workflow-init`. **No code.** No file under `plugins/dev-workflow/hooks/` changes.

**Tech Stack:** Markdown prompts; POSIX shell for every check; `git` for the records.

**Spec:** `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md` (revision 36).
Plan A implements §2, §2.1, §2.2, §2.4, §3, and §10 in part.

**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`

> **Read the profile from that header at execution time. This plan states no risk value, no
> security value, no validation mode and no pass count derived from any of them** — not even to
> illustrate a mistake, since quoting a stale-able value to explain why values go stale
> reintroduces it.

---

## Every check below is a pasted observation, not a prediction

**This is the rule that produced revision 3.** Revision 2 stated what its checks *would* print.
Fourteen Blocker/Major followed, five of them broken checks: a phrase containing `**emphasis**`
matched as plain text; a phrase split across a line break matched as one string; a `grep -cF`
pattern beginning `- ` parsed by grep as an option (exit 2); an `awk` range whose end anchor
existed on no line, running to EOF.

Every expected value in this revision was produced by **executing** the check against a simulated
post-edit tree, at its point in the sequence, and pasting what came back. The simulation applies
all sixteen edits to copies of both files, snapshots after each task, and runs each check against
the snapshot that task would actually see.

**The replacement texts below are byte-identical to the ones the simulation applied** — this
document is generated from the same source the simulation executed, so the two cannot drift.

Result of that run, verbatim:

```
T1 preflight (untouched tree)   old=1 new=0        both copies
T1 verify   (after T1)          predicate=1 residual=1 gateoff=1 tail=1   both copies
T2 preflight(after T1)          6                  both copies
T2 minor-site(after T1)         1                  both copies
T2 verify   (after T2)          regex=0  new=1  old=0  PR#23=1            both copies
T3 preflight(after T2)          0                  both copies
T3 verify   (after T3)          marker=1  old-para=1  tells=1             both copies
T4 baseline (after T3)          9                  both copies
T4 verify   (after T4)          9                  both copies  (identical to baseline)
T5 verify   (after T5)          severity=1 activation=1 extensible=1 defs=1  both copies
T6 parity   (after T5)          PARITY-COMPLETE 13/13, 0 problems
```

---

## Why this is one of three plans

| Plan | Ships | Spec sections |
|---|---|---|
| **A — this one** | the floor predicate and the severity test | §2, §2.1, §2.2, §2.4, §3, §10 (partial) |
| **B** | the provenance line, the per-pass curve, the cycle nonce, slot naming | §2.3, §4, §5, §6 |
| **C** | rollout: falsified sentences, packaging, the evidence pack, the review loop | §7, §8 |

**Three Gate-A cycles, ONE Gate-B cycle.** Each plan is reviewed as its own artifact; the three
ship **one diff**, reviewed once after Plan C. Giving Plan A its own cycle produced two Blockers
that were pure infrastructure paradox — the battery could not go green because the manifest bump is
Plan C's, and the findings slots needed a grammar Plan B ships.

**Execution order A → B → C. Plan B may not open before Plan A's Gate-A loop closes.**

### Findings inherited by Plan C — named, because they were relocated, not repaired

Plan A revision 1 carried a Gate-B section that no longer exists here. Four pass-1 findings lived
in it, and a finding whose section moved is **relocated, not fixed** (finding plana-M6). **Plan C
must inherit these explicitly:**

| Finding | What it requires of Plan C |
|---|---|
| pass-1 M8 | single-branch Gate-B recovery: delete only the failed branch, never both |
| pass-1 M9 | record the floor knob's existence **and bytes** before the cycle, compare after |
| pass-1 M10 | never `git add -u`; stage an explicitly inspected path set |
| pass-1 MINOR 12 | build the closing body with `mktemp`, not a fixed `/tmp` path |
| pass-2 B6 | evidence revalidated after every fix and again before the closing amend |

---

## Global Constraints

- **This Gate-B cycle runs under the rules in force at its start — the OLD ones.** The new
  severity semantics, floor rule and record forms bind only **after** the closing commit ships
  them. This is spec §10's activation rule applied to the change's own review: a reviewer applying
  the new Minor-or-below ceiling to the change that introduces it would under-iterate on exactly
  the diff needing most iteration. **Carry this sentence in the `additionalContext` of every
  Gate-B call.**
- **Prompt-only.** No file under `plugins/dev-workflow/hooks/` changes, and the floor knob
  `.context/codex-gate.floor` is never written, never removed, never read for the derivation.
  **This is not a claim that nothing under `.context/` is written**: the Gate-B calls and commit
  events in this work write pass counters, fingerprints and disclosure markers there as always.
  Only the floor knob is untouched.
- **The §5 heading must keep matching `^#{1,6}[[:space:]]+([0-9]+\.)?[[:space:]]*Cross-Model Review`.**
  `codex-gate.sh:94` greps `CLAUDE.md` for it to build every reminder's citation.
- **Every rule lands in BOTH copies.** Where the two copies already differ, the difference is
  pre-existing, is named in the accounting, and is **left exactly as it is**.
- **§5's other closure rules are never restated, only referred to.**
- **Address by content, never by line number.** Line numbers appear only as pasted provenance.
- **Check patterns obey four rules**, each learned from a broken check: no `**` inside a match
  pattern; no pattern spanning a line break; any pattern beginning `-` passed with `-e` or after
  `--`; any range bounded by a condition that exists, never by an end anchor assumed to exist.

### The commit protocol

**One WIP commit, opened here, amended by Plans B and C, reviewed once after C, closed once.**

> **The `--no-edit` trap.** `plugins/dev-workflow/hooks/codex-gate.sh:763` is
> `is_wip_commit() { printf '%s' "$1" | grep -Eiq -- "-m[[:space:]]*['\"]?[[:space:]]*wip"; }`
> It matches **the Bash command string**, not git state. `git commit --amend --no-edit` carries no
> `-m`, is not recognized, and at `:886` the hook **resets, discarding the cycle's passes.** Every
> amend restates `-m "WIP: ..."`. **Never `--no-edit` inside the cycle.** (Backlog: `todos.md`.)

**The base SHA is recorded before Task 1 and is the reference for every diff and every Gate-B
call** — never `HEAD~1` (finding plana-B6). Without it, a resumed Task 1 or an accidental second
WIP stacks commits while still reporting the cycle open, and a review based on the tip's parent
silently omits the earlier WIP: part of the combined diff escapes the only Gate-B review.

```bash
git rev-parse HEAD > .context/plan-a-base-sha
cat .context/plan-a-base-sha
```

**At every plan handoff, the tip must be the sole WIP child of that base:**

```bash
base=$(cat .context/plan-a-base-sha)
n=$(git rev-list --count "$base"..HEAD)
[ "$n" = 1 ] || { echo "STACKED: $n commits above base — collapse with git reset --soft $base, then one WIP commit"; exit 1; }
git log -1 --pretty=%s | grep -q '^WIP: review-loop economics' || { echo "TIP IS NOT THE WIP"; exit 1; }
echo "CYCLE OK — single WIP on $base"
```

1. **No ordinary commit from Task 1 onward** until the combined cycle closes in Plan C.
2. **Task 1 opens the cycle**: `git commit -m "WIP: review-loop economics"`.
3. **Tasks 2-6 amend it**, each restating that exact message.
4. **Plans B and C amend the same commit.** Plan C adds the bump, runs the single Gate-B loop with
   `baseSha` = the recorded base, and closes with `git commit --amend -m "<real message>"`.

---

## Old-conditions accounting

**Derived from the edits this plan makes**, against §5 at HEAD. **Eleven passages.**

**Two passages diverge between the copies and get a row each.** Both divergences were found by
`diff` over the passage's **full extent**, after a 13-line comparison window on the Gate-A passage
produced a false IDENTICAL — a check that ended before the divergence (finding plana-M2).

```
CLAUDE.md:72:**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
CLAUDE.md:77:final pass must be clean — if pass 3 still finds Blocker/Major, keep going until
CLAUDE.md:79:below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is
CLAUDE.md:126:the only exception, exactly as above; a Blocker/Major-free pass 1 carrying a Minor keeps
CLAUDE.md:133:**From pass 4 onward every pass report carries three lines.** The carrier is **your own
CLAUDE.md:236:act on the partial list, don't count it toward the 3-pass floor, and don't read "no
CLAUDE.md:300:- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).** Run on the
CLAUDE.md:335:  invalidates the prior pass, which is where the 3 come from.
CLAUDE.md:403:Lenses are **different questions, not more passes.** The 3-pass floor, the Blocker/Major
CLAUDE.md:480:**Changing a profile:** the pass **proposes the complete resulting header** — both axes,
CLAUDE.md:495:- **Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw →
```

```
plugins/dev-workflow/commands/workflow-init.md:272:**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
plugins/dev-workflow/commands/workflow-init.md:277:final pass must be clean — if pass 3 still finds Blocker/Major, keep going until
plugins/dev-workflow/commands/workflow-init.md:279:below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is
plugins/dev-workflow/commands/workflow-init.md:322:the only exception, exactly as above; a Blocker/Major-free pass 1 carrying a Minor keeps
plugins/dev-workflow/commands/workflow-init.md:330:**From pass 4 onward every pass report carries three lines.** The carrier is **your own
plugins/dev-workflow/commands/workflow-init.md:421:act on the partial list, don't count it toward the 3-pass floor, and don't read "no
plugins/dev-workflow/commands/workflow-init.md:485:- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).** Run on the
plugins/dev-workflow/commands/workflow-init.md:519:  invalidates the prior pass, which is where the 3 come from.
plugins/dev-workflow/commands/workflow-init.md:582:Lenses are **different questions, not more passes.** The 3-pass floor, the Blocker/Major
plugins/dev-workflow/commands/workflow-init.md:659:**Changing a profile:** the pass **proposes the complete resulting header** — both axes,
plugins/dev-workflow/commands/workflow-init.md:674:- **Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw →
```

| # | Passage | Copy | What the existing prose requires | Disposition |
|---|---|---|---|---|
| 1 | floor paragraph | both | a. a hard floor of 3 passes per run · b. Blocker/Major only · c. the count is the hook's · **d. the hook cannot read findings** · **e. the hook cannot tell the spec run from the plan run** · f. it resets at `writing-plans` · g. therefore Gate A is instruction-backed · h. a satisfied count is not a clean review · i. a TodoWrite per pass · j. fix Blocker/Major after each · k. Codex is advisory · l. validate before applying · m. dismissed finding → one-line why | a. **replaced** by the derived predicate · c. **moved** — the hook still counts, as its reminder threshold, not the obligation · **d, e, f, g, h kept verbatim in the second paragraph** (revision 2's row folded d and e away, finding plana-M3) · b, i-m **kept verbatim** |
| 2 | `if pass 3 still` | both | the final pass must be clean; if the pass at 3 still finds Blocker/Major, keep going until clean or clearly stuck, then STOP and surface | **kept**, `pass 3` → `the pass at the floor` |
| 3 | `below 3` | both | the only early exit below the floor is a zero-finding pass; don't pad | **kept**, `below 3` → `below the floor` |
| 4 | pass-1 Minor sentence | both | below the floor nothing closes; a zero-finding pass is the only exception; a Blocker/Major-free pass 1 carrying a Minor keeps looping | **kept**, `pass 1` → `pass below the floor`. **The sentence that inverts at floor 1**, where pass 1 *is* the floor |
| 5a | pass-report paragraph | `CLAUDE.md` | a. from pass 4 onward, three lines · b. carrier is your own status report · c. never the Codex reply · d. never the findings file · e. trend · f. cluster · g. require↔withdraw · h. the five tells · i. any-two makes stop-and-surface **mandatory** · j. "clearly stuck" is not a precondition · **k. "you report the tells" — second person** | **untouched.** Task 3 inserts a new paragraph *before* it and modifies nothing in it, so a-k all stand |
| 5b | pass-report paragraph | template | a-j as above · **k′. "report the tells" — imperative, no addressee** · plus different wrapping | **untouched**, same reason. **The divergence is pre-existing and is left alone** |
| 6 | incomplete-pass | both | an incomplete pass is not a review: don't act on the partial list, don't count it toward the floor, don't read "no Blocker/Major visible" as clean | **kept**, `the 3-pass floor` → `the floor` |
| 7a | Gate A loop | `CLAUDE.md` | a. two runs, each its own 3-pass loop · b. one broad prompt, re-run each pass · c. don't narrow per-dimension · d. the required opening phrase · e. coverage floor not a cage · f. every finding with severity and confidence · g. **the citation `` (`docs/prompt-standards.md`, "coverage first, filter later") ``** · h. one line per finding · i. literal `NO FINDINGS` · j. settle mechanically before each read pass | **a kept**, `3-pass loop` → `loop at the derived floor`; **b-j untouched, g included** |
| 7b | Gate A loop | template | a-f, h-j as above · **g′. the citation is ABSENT** — the template says "findings silently." and stops · plus different wrapping | same edit to `a`; **the missing citation is pre-existing and is left alone.** Revision 2 called this passage byte-identical on the strength of a 13-line window; over its full 30/29-line extent it is not |
| 8 | `where the 3 come from` | both | re-review after every fix, because a fix changes the diff and the hook invalidates the prior pass | **kept, rationale replaced** — see Task 2 (e) |
| 9 | Lenses | both | lenses are different questions, not more passes; the floor, the Blocker/Major filter, the file-first protocol and the clean-final-pass rule are unchanged | **kept**, reworded so "unchanged" no longer claims the floor is fixed |
| 10 | `Changing a profile:` | both | a. proposes the complete resulting header · b. human confirms, both directions · c. an agent never moves it alone · d. correct the header, append one log line · e. any axis change voids every prior override · f. `+abuse-path` follows current security · g. passes under the lower profile keep counting · h. only the final clean pass must run under the current profile · i. fold mid-cycle edits into the WIP by amend | **all nine kept verbatim**; §2.4's rules are **appended after them**, never merged in. Task 4's check measures all nine, scoped to the original paragraph, before and after |
| 11 | Severity | both | Blocker = wrong/unsafe/breaks invariant · Major = design flaw → rework · both must resolve · Minor and Nit → collect, never iterate | **all four kept verbatim**; the reachability test is **appended** as the procedure that sets a ceiling on them |

**Nothing in §5 outside these eleven passages is edited.** Task 6 Step 3 proves it by reading both
diffs against this inventory.

---

## Task 1: Record the base, open the cycle, replace the floor

- [ ] **Step 1: Record the immutable base SHA**

```bash
mkdir -p .context && git rev-parse HEAD > .context/plan-a-base-sha
cat .context/plan-a-base-sha
```

This file is the reference for every later diff and every Gate-B call. It is under `.context/`,
which is gitignored, so it never enters the reviewed diff.

- [ ] **Step 2: Preflight — a closed state matrix over four independent markers**

Revision 2 collapsed this to one marker pair, so an interruption between the floor replacement and
the residual/gate-off insert, or between the two mirrors, read as complete (finding plana-B2).

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%-46s old=%s pred=%s res=%s gate=%s\n' "$f" \
    "$(grep -cF 'HARD FLOOR: min 3 passes per run' "$f")" \
    "$(grep -cF "derived from the cited story's profile" "$f")" \
    "$(grep -cF 'Named residual' "$f")" \
    "$(grep -cF 'routes known today, not a complete list' "$f")"
done
```

| old pred res gate | state | action |
|---|---|---|
| `1 0 0 0` | not started | proceed to Step 3 |
| `0 1 0 0` | Step 3 done, Step 4 not | **do Step 4 only** |
| `0 1 1 0` | Step 4 half-applied | insert the gate-off block only |
| `0 1 1 1` | complete | verify against Step 5, skip to Step 6 |
| `1 1 * *` | duplicate insert | a rerun appended without removing — delete the inserted blocks, restart |
| any `pred` or `res` or `gate` > 1 | duplicate | same |
| `0 0 0 0` | damaged | **STOP** — restore with `git show $(cat .context/plan-a-base-sha):<file>` |

**Cross-copy asymmetry is its own state.** If the two rows differ, execution stopped between the
files: bring the lagging copy to the leading copy's state before proceeding. **Never proceed with
the mirrors disagreeing.**

- [ ] **Step 3: Replace the floor sentences**

The text on disk ends **mid-line** — ` Open a TodoWrite "Codex pass N" per pass;` continues the
same line after `review.` Match exactly this and no more (finding plana-B1); what follows stays:

```
**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
only), counted by the hook.** The hook counts passes but can't read findings or
tell the spec run from the plan run (it resets at `writing-plans`), so Gate A —
the spec run especially — is instruction-backed: a satisfied count is not a clean
review.
```

Replace with:

```
**Both gates are a LOOP with a HARD FLOOR: a minimum number of passes per run
(Blocker/Major only), derived from the cited story's profile.**
The derivation is max(risk, security): a value of 0 gives a floor of 1; every
resolvable profile above that, and an artifact citing no story, gives 3. Two levels,
not three — `high` takes its rigor from lens sets and evidence mode, not from extra
passes. A cited story whose profile is present but unresolvable stops and surfaces
under the existing rule; it does not fall through to 3, because reading it as 3 would
turn a stop condition into a silent default. Across a cited set the floor is 1 if and
only if the set is non-empty and every member is profiled, resolvable and at level 0
— all four conditions, since "every cited story" is vacuously true of an empty set;
no story cited, or any cited story unprofiled, gives 3. One derived value governs all
three cycles: the Gate-A spec loop, the Gate-A plan loop and the Gate-B cycle. Not
because they are one cycle — they are three — but because they derive from the same
cited-story set.

**The derived floor is the pass count a cycle owes, and the hook's ratio is a reminder
threshold that controls nothing.** The hook still counts passes, and it still can't read
findings or tell the spec run from the plan run (it resets at `writing-plans`), so
Gate A — the spec run especially — is instruction-backed: a satisfied count is not a
clean review, and a below-threshold reminder is noted in the pass report and disregarded
where the cycle's own closure rules are satisfied. This replaces the pass-count number
and nothing else. Every other rule stated here about how a cycle closes stands as
written, and none of them is restated — a summary is where their conditions would get
dropped. Nothing here writes the floor knob: it stays the user's, never written, never
removed, never read for this derivation.
```

- [ ] **Step 4: Add the residual and the gate-off disclosure**

Match the floor paragraph's final line **including its trailing newline**, and re-emit it followed
by the two new blocks:

```
advisory — validate before applying; dismissed finding → one-line why.
```

Replace with:

```
advisory — validate before applying; dismissed finding → one-line why.

**Named residual:** the hook's messages state its own threshold as an obligation, so at a
floor of 1 they report a shortfall the cycle does not owe. Hook text is out of scope here
by decision; what makes that tolerable is the precedence rule above plus the hook exiting
0 on every branch, not the reminder being harmless.

**The gate-off surface — routes known today, not a complete list**, since an enumeration
read as complete guarantees the routes it omits. One route is created here: a stated floor
the cited set does not license, which could not exist before there was a derived floor to
state. Pre-existing and unchanged: omitting a higher-risk cited story; minting or editing a
profile to level 0; presenting an incomplete cited set; falsifying evidence entries;
silencing reminders; or not running a pass and reporting that it ran. A user-set floor is
not the lever — it moves what the hook says, not what the cycle owes.
None of this is a guard: the floor is produced by the agent and nothing checks it against
the cited profiles.
```

- [ ] **Step 5: Verify — observed values, both copies**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%-46s predicate=%s residual=%s gateoff=%s tail=%s\n' "$f" \
    "$(awk '/HARD FLOOR/,/never read for this derivation/' "$f" | grep -c 'max(risk, security)')" \
    "$(grep -cF 'Named residual' "$f")" \
    "$(grep -cF 'routes known today, not a complete list' "$f")" \
    "$(grep -cF "don't manufacture findings to pad" "$f")"
done
```

**Observed in the simulation: `predicate=1 residual=1 gateoff=1 tail=1` for both copies.**

The `awk` scoping on `predicate` is load-bearing: unscoped, `grep -c 'max(risk, security)'` returns
1 **before any edit**, because the Profiles section already contains the phrase — the check would
pass before the edit and prove nothing. `tail=1` holds before and after, catching a replacement
that swallowed its neighbours.

- [ ] **Step 6: OPEN THE CYCLE**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git status --porcelain   # nothing else may be dirty
git diff --cached --name-only   # exactly these two paths
git commit -m "WIP: review-loop economics"
base=$(cat .context/plan-a-base-sha); git rev-list --count "$base"..HEAD   # must be 1
```

**The `git status` line is not decoration** (finding plana-M8): `git add` stages the complete
files, so a pre-existing unrelated edit inside either one would be folded into the reviewed diff
and closed under this story. If anything else is dirty, stop and resolve it first.

---

## Task 2: The floor-wording sites

- [ ] **Step 1: Preflight — the sequence-correct count**

```bash
grep -cE "min 3 passes|below 3|3-pass|where the 3 come from|if pass 3 still" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Observed after Task 1: `6` and `6` — not 7.** Seven is the count in an untouched tree; Task 1 has
already removed the `min 3 passes` match. `0`/`0` means this task ran.

- [ ] **Step 2: The site this regex does not cover**

```bash
grep -cF 'carrying a Minor keeps' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Observed after Task 1: `1` and `1`.** Accounting passage 4 contains no digit `3`, so Step 1's
regex never matched it — **Step 1 reaching 0 does not cover it.** Step 4 asserts it separately.

- [ ] **Step 3: Six replacements per copy**

**a.** OLD:

```
final pass must be clean — if pass 3 still finds Blocker/Major, keep going until
```

NEW:

```
final pass must be clean — if the pass at the floor still finds Blocker/Major, keep going until
```

**b.** OLD:

```
below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is
```

NEW:

```
below the floor is a pass with **zero** findings; don't manufacture findings to pad. Codex is
```

**c.** OLD:

```
act on the partial list, don't count it toward the 3-pass floor, and don't read "no
```

NEW:

```
act on the partial list, don't count it toward the floor, and don't read "no
```

**d.** OLD:

```
- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).** Run on the
```

NEW:

```
- **Gate A — Spec, then plan (TWO runs, each its own loop at the derived floor).** Run on the
```

**e.** OLD:

```
  @AGENTS.md. Re-review after every fix — a fix changes the diff and the hook
  invalidates the prior pass, which is where the 3 come from.
```

NEW:

```
  @AGENTS.md. Re-review after every fix — a fix changes the artifact, so the prior
  review no longer covers it. The hook merely notices, at commit time.
```

> **Three findings, one sentence — and this is the third attempt at it.** The original,
> `which is where the 3 come from`, was a causal claim the new design makes false: the lower bound
> now comes from the profile. Revision 1 replaced it with *the hook invalidates the prior pass —
> which is why a fix costs another pass*, making the advisory hook the **cause** of the obligation.
> Revision 2 replaced only the second line, leaving `a fix changes the diff and the hook` in front
> of it, so the shipped sentence read **"the hook no longer covers the artifact"** — the hook still
> the subject. `AGENTS.md` records this exact pattern taking four Gate-B rounds because each
> correction searched for the previous **phrase** rather than the **claim**.
>
> **Both lines are replaced**, and the claim being eliminated is named: *the hook causes the
> re-review obligation.* The test the replacement passes — **delete the hook and the sentence is
> still true**: a fix changes the artifact, so the prior review no longer covers it. What the hook
> does is notice, at commit time.

**f.** OLD:

```
Lenses are **different questions, not more passes.** The 3-pass floor, the Blocker/Major
```

NEW:

```
Lenses are **different questions, not more passes** — they change what a pass asks,
never how many passes a cycle owes, which the profile and the cited set decide together.
The floor, the Blocker/Major
```

> Two findings here too. The original tail reads "… is unchanged", which in the very change that makes the floor profile-dependent tells readers the opposite of what shipped. Revision 2 wrote "which the profile alone decides" — **also wrong**, because cited-set emptiness, membership, unprofiled members and unresolvable members all bear on the result. "The profile and the cited set decide together" is what Task 1's predicate actually says.


- [ ] **Step 4: The pass-1 Minor sentence**

```
the only exception, exactly as above; a Blocker/Major-free pass 1 carrying a Minor keeps
```

Replace with:

```
the only exception, exactly as above; a Blocker/Major-free pass below the floor
carrying a Minor keeps
```

- [ ] **Step 5: Verify — observed values**

```bash
grep -cE "min 3 passes|below 3|3-pass|where the 3 come from|if pass 3 still" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF 'a Blocker/Major-free pass below the floor' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF 'Blocker/Major-free pass 1 carrying a Minor' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF "PR #23's Gate-B pass 3 returned all four findings" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Observed after Task 2: `0`/`0`, then `1`/`1`, then `0`/`0`, then `1`/`1`.** The last must stay
`1`: it cites an actual pass, not a rule, and changing it would falsify a record.

- [ ] **Step 6: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
base=$(cat .context/plan-a-base-sha); git rev-list --count "$base"..HEAD   # must still be 1
```

---

## Task 3: The pass report (§2.2)

- [ ] **Step 1: Preflight**

```bash
grep -cF 'the cited stories they were read' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Observed after Task 2: `0` and `0`.** The pattern deliberately stops before `from`, which begins
a new line in the inserted text — a pattern spanning a line break matches nothing.

- [ ] **Step 2: Insert before the pass-report paragraph**

Match the paragraph's opening line and re-emit it after the new text. **Nothing in the existing
paragraph is modified** — including the `you report the tells` / `report the tells` divergence
between the copies, which is pre-existing and stays (accounting rows 5a/5b). Do not harmonize it.

```
**From pass 4 onward every pass report carries three lines.**
```

Replace with:

```
**Every pass report states three things about the floor**, from pass 1 onward: the
derived floor, the risk and security values read, and the cited stories they were read
from. A report giving the number alone leaves a reader unable to check the derivation
while passes are still being spent — which is the only time checking it is cheap. Where
no story is cited, or a cited story is unprofiled, the report says so in place of axis
values; a multi-story set names each story and its values. This is owed by every pass;
the three lines below are owed from pass 4 and are a different obligation.

**From pass 4 onward every pass report carries three lines.**
```

- [ ] **Step 3: Verify — observed values**

```bash
grep -cF 'the cited stories they were read' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF 'From pass 4 onward every pass report carries three lines' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF 'require↔withdraw pair' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
printf 'C:%s T:%s\n' "$(grep -cF -- '— you report' CLAUDE.md)" \
                     "$(grep -cF -- '— report the' plugins/dev-workflow/commands/workflow-init.md)"
```

**Observed after Task 3: `1`/`1`, `1`/`1`, `1`/`1`, then `C:1 T:1`.** The last asserts the
pre-existing divergence is still exactly as it was — note `--` before a pattern starting with `—`
is unnecessary but `-- ` is used consistently for patterns whose first character could be read as
an option.

- [ ] **Step 4: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 4: A profile or cited set that moves mid-cycle (§2.4)

- [ ] **Step 1: Preflight, and capture the nine-condition baseline**

```bash
grep -cF 'Any profile change costs at least one further pass' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md

for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf 'BASELINE %-46s ' "$f"
  awk '/\*\*Changing a profile:\*\*/,/discard the accumulated passes\./' "$f" \
    | grep -oF -e 'proposes the complete resulting header' -e 'human confirms it' \
      -e 'never moves it alone' -e 'one profile-log line' -e 'voids every prior override' \
      -e 'follows the current security value' -e 'keep counting' -e 'final clean pass' \
      -e 'fold the edit into the active' | wc -l | tr -d ' '
done
```

**Observed after Task 3: `0`/`0`, then `BASELINE 9` for both copies.** Nine markers for the nine
conditions of accounting row 10. Two things make this measure what it claims: the `awk` range ends
at `discard the accumulated passes.`, **the original paragraph's last line**, so the appended text
is outside it; and `grep -oF -e ...` passes each phrase as a separate fixed string, so
`one profile-log line` matches although the source wraps `append` onto the previous line.

- [ ] **Step 2: Append after the `Changing a profile:` paragraph**

Its nine conditions are kept verbatim. §2.4's rules are **appended after them**, never merged in.

```
discard the accumulated passes.

**What this does not do:**
```

Replace with:

```
discard the accumulated passes.

**While a gate is running, the floor derives from the current profile at each pass.**
Passes already run keep counting; closing requires the floor as currently derived. These
are pass-count rules, so they apply while a gate is running and are silent otherwise —
what governs when a gate runs is unchanged and deliberately not summarised here.

**Any profile change costs at least one further pass**, in either direction and whether or
not the floor number moves, because the final clean pass must run under the current
profile — so no already-banked pass can be it. That further pass must itself be clean and
every other closure duty must be satisfied; it is one more pass, not a licence to close on
the next one. What a lowering drops is whatever the changed values drop, not a fixed pair:
a mode-only override changes the evidence obligations while leaving the axis-derived lens
sets alone, and security `high` → `standard` keeps the security lens set while changing
what evidence is owed. Every derived obligation is recomputed from the current profile.

**The cited set is re-read at each pass, and the final clean pass runs against the current
set** — whenever its membership changes, not only when the floor number moves. Adding a
high-risk story to a set already at floor 3 leaves the number alone while adding that
story's lens set, its evidence obligations and its review scope; a pass run before it
joined did not cover them. Removing a story recomputes obligations from the current set
and so does remove that story's lenses and evidence duty — but it never discharges an
accepted in-set Blocker or Major: the acceptance put that finding in the fix set, not the
citation.

**What this does not do:**
```

- [ ] **Step 3: Verify against the captured baseline**

Re-run **the identical command from Step 1**, changing only the label. The `awk` range still ends
at the original paragraph's last line, so it measures the original paragraph alone.

**Observed after Task 4: `1`/`1` for the new marker, and `9` for both copies — identical to the
baseline.** Any difference is a dropped condition, not a formatting artefact.

- [ ] **Step 4: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 5: Severity semantics (§3), and activation (§10, partial)

- [ ] **Step 1: Preflight**

```bash
grep -cF 'what in the system consumes this text' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF 'a cycle already running' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Observed after Task 4: `0`/`0` and `0`/`0`.**

- [ ] **Step 2: Append the severity test to the Severity bullet**

The four definitions stay verbatim.

```
  rework) → both must resolve. Minor · Nit → collect, never iterate.
```

Replace with:

```
  rework) → both must resolve. Minor · Nit → collect, never iterate.

  **Deciding severity — one procedure. The subject list is illustration, not a second
  rule.** Name what in the system consumes this text — whatever *acts* on it — and the
  decision that act takes differently if the text is wrong. Both are required. If you
  cannot name both, the finding is Minor or below: collect, never iterate.

  The exclusions are contract, not commentary. The reader must consume the text in the
  system's *operation*, not in reviewing it — the review pass raising the finding is not
  an in-system reader of the text it reviews; without this the test demotes nothing.
  Gates remain legitimate readers of rule text they will later apply. A human reader never
  satisfies the test — the prose exemption already prices that cost as non-gating. The
  list of reader kinds is illustrative, not closed, because this ships into projects whose
  readers we have never seen. The test sets a ceiling, not a floor, and never chooses
  between Blocker and Major — the four definitions above still decide that. The instrument
  carve-out is symmetric: an instrument finding keeps its severity whenever it shows the
  instrument changes what a gate concludes about product behaviour — a false green, and
  equally a false red or a check blocking a valid change. Rationale prose is Minor only
  when no rule's application depends on it, not categorically: `docs/prompt-standards.md`
  requires rules to carry their why, so rationale a reader must consult to apply a rule
  passes the test. This removes arbitrariness, not judgement. Coverage-first is unchanged
  — the reviewer reports every finding with severity and confidence; the filter is ours.

  This is the finding-level analog of the path-level prose exemption: one principle at two
  granularities — text that *describes* the product versus text that *is* the product.
```

- [ ] **Step 3: Append the activation block after the gate-off disclosure**

**Plan B extends this list rather than rewriting it** — §10 says extending is safe and replacing is
not. `at minimum` and `each further rule this change ships adds its own strict reading to this
list` are what make that possible.

```
None of this is a guard: the floor is produced by the agent and nothing checks it against
the cited profiles.
```

Replace with:

```
None of this is a guard: the floor is produced by the agent and nothing checks it against
the cited profiles.

**When these rules bind.** From the commit that ships them, and a cycle already running
finishes under the rules it started with. Where a cycle's starting rules cannot be
established it takes the stricter reading of every part this change touches — at minimum
floor 3, and severity classified without the demotion; each further rule this change ships
adds its own strict reading to this list. Not a re-derivation, which could hand a level-0
cycle a floor of 1 and skip passes on the strength of not knowing when it started. A user
knob set above 3 is not lowered by this fallback. A revert is itself a shipping commit for
the old rules, and the activation rule wins wherever the start is determinable; the
fallback covers only where it is not.

**Downstream has no shipping commit.** Adoption binds from the `/workflow-init` run that
actually writes the text — which may write nothing, be declined, or be merged in part —
so these rules bind only over the text a project's `CLAUDE.md` actually contains, and a
partial adoption can persist undetected. A project taking the floor rule without the
severity test gets a floor whose docs-only question the severity test is what settles.
What prompt text can do is done; what it cannot is said.
```

- [ ] **Step 4: Verify — observed values**

```bash
grep -cF 'what in the system consumes this text' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF 'a cycle already running' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF 'adds its own strict reading' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF -- '- **Severity:** Blocker (wrong/unsafe/breaks invariant)' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Observed after Task 5: `1`/`1` four times.** Two of these patterns were broken in revision 2:
`adds its own strict reading to this list` spanned a line break, and the Severity pattern begins
`- `, which grep parses as an option and exits 2 — hence `--` before it.

- [ ] **Step 5: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 6: Parity, conformance, and the diff proof

- [ ] **Step 1: Preflight**

This task appends two result tables to **this plan document**. If a table with the marker
`PARITY RESULTS — Plan A` or `CONFORMANCE RESULTS — Plan A` already exists, this task ran: verify
its row count rather than appending again.

```bash
grep -c 'PARITY RESULTS — Plan A\|CONFORMANCE RESULTS — Plan A' \
  docs/superpowers/plans/2026-08-29-review-loop-economics-plan-a-rules.md
```

**Expected `0` before this task, `2` after.**

- [ ] **Step 2: Parity — compare the shipped text, not counts**

One anchor per block, extraction bounded by a condition that **exists** (blank line or the next
`- **` bullet) rather than by an end anchor assumed to exist. Revision 2's two-anchor ranges
produced 10 of 13 rows because three end anchors occurred on no line (finding plana-B5).

```bash
C=CLAUDE.md; T=plugins/dev-workflow/commands/workflow-init.md
tmp=$(mktemp -d) || exit 1
i=0; ok=0; bad=0
while IFS= read -r start; do
  [ -z "$start" ] && continue
  i=$((i+1))
  for pair in "C:$C" "T:$T"; do
    tag=${pair%%:*}; f=${pair#*:}
    awk -v s="$start" '
      index($0,s) && !f {f=1; print; next}
      f && ($0=="" || $0 ~ /^- \*\*/) {exit}
      f {print}' "$f" > "$tmp/$tag.$i"
  done
  cs=$(wc -l < "$tmp/C.$i"); ts=$(wc -l < "$tmp/T.$i")
  if [ "$cs" -eq 0 ] || [ "$ts" -eq 0 ]; then
    printf 'EMPTY   %2s  %s\n' "$i" "$start"; bad=$((bad+1))
  elif diff -q "$tmp/C.$i" "$tmp/T.$i" >/dev/null; then
    printf 'PARITY  %2s  %2s lines  %s\n' "$i" "$cs" "$start"; ok=$((ok+1))
  else
    printf 'DIFFERS %2s  %s\n' "$i" "$start"; bad=$((bad+1)); diff "$tmp/C.$i" "$tmp/T.$i"
  fi
done <<'ANCHORS'
**Both gates are a LOOP with a HARD FLOOR: a minimum number of passes per run
**The derived floor is the pass count a cycle owes
**Named residual:**
**The gate-off surface
**When these rules bind.**
**Downstream has no shipping commit.**
**Every pass report states three things about the floor**
**While a gate is running, the floor derives from the current profile
**Any profile change costs at least one further pass**
**The cited set is re-read at each pass
**Deciding severity
The exclusions are contract, not commentary.
This is the finding-level analog
ANCHORS
rm -rf "$tmp"
[ "$i" = 13 ] && [ "$ok" = 13 ] && echo "PARITY-COMPLETE 13/13" \
  || { echo "PARITY-INCOMPLETE ranges=$i parity=$ok problems=$bad"; exit 1; }
```

**Observed on the simulated post-edit tree:**

```
PARITY   1        14 lines  **Both gates are a LOOP with a HARD FLOOR: a minimum number of passes per run
PARITY   2        14 lines  **The derived floor is the pass count a cycle owes
PARITY   3         4 lines  **Named residual:**
PARITY   4         9 lines  **The gate-off surface
PARITY   5         9 lines  **When these rules bind.**
PARITY   6         6 lines  **Downstream has no shipping commit.**
PARITY   7         7 lines  **Every pass report states three things about the floor**
PARITY   8         4 lines  **While a gate is running, the floor derives from the current profile
PARITY   9         8 lines  **Any profile change costs at least one further pass**
PARITY  10         8 lines  **The cited set is re-read at each pass
PARITY  11         4 lines  **Deciding severity
PARITY  12        15 lines  The exclusions are contract, not commentary.
PARITY  13         2 lines  This is the finding-level analog
PARITY-COMPLETE 13/13
```

**The line counts are part of the expectation.** An `EMPTY` cannot be masked, and a block that
suddenly grows means the extractor ran past its intended end — which is exactly what happened
before the `^- \*\*` bound was added: range 13 captured 24 lines of the Mechanics list.

Record the result as a table headed **`PARITY RESULTS — Plan A`**: *n* · *anchor* · *lines* ·
**status** from `PARITY` | `DIFFERS` | `EMPTY` · *reason, required for the latter two*. **Thirteen
rows.** **A `DIFFERS` or `EMPTY` row stops the task** — it is a parity defect, not a note.

- [ ] **Step 3: The diff proof — both files, every hunk, against the recorded base**

```bash
base=$(cat .context/plan-a-base-sha)
git diff "$base" -- CLAUDE.md
git diff "$base" -- plugins/dev-workflow/commands/workflow-init.md
git diff "$base" --stat -- CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Read **both** diffs in full and confirm every hunk falls inside one of the eleven accounted
passages. **A hunk outside them is a finding.**

No expected line count is stated, deliberately: the correct check is a human reading two diffs
against an eleven-row inventory, and a number invites substituting the number for the read. This is
one of exactly two places in this plan without a numeric expectation; the other is Step 1's
judgement about already-appended tables.

- [ ] **Step 4: The twelve-item conformance pass**

Artifacts: the **resulting scaffolded template**, and `plugins/dev-workflow/commands/workflow-init.md`
as the outer command prompt. One row per item per artifact: *item* · *artifact* · **status** from
`PASS` | `N/A` | `FAIL` · *reason, required for `N/A` and `FAIL`*. **Twenty-four rows**, headed
**`CONFORMANCE RESULTS — Plan A`**. **Item 7 is read against the whole resulting artifact.**
**A `FAIL` row stops the task.**

**Root `CLAUDE.md` is outside invariant 11's list and is not part of this pass.**

> **Item 1 for the scaffolded template is `N/A`; Plan C ships the note that says why** — the file
> the template writes is model-agnostic by design, so a `Target model:` line inside it would be
> false in every repo it lands in.

- [ ] **Step 5: Invariant checks**

```bash
grep -c '^Target model:' plugins/dev-workflow/commands/workflow-init.md
sh scripts/check-invariants.sh && echo INVARIANTS-OK
```

**Expected: `1`, then `INVARIANTS-OK`.** The count must be 1 — `scripts/check-invariants.sh` fails
on any other, and a naive item-1 fix that adds a second declaration is exactly how that breaks.

- [ ] **Step 6: Fold the results into the WIP commit**

```bash
git status --porcelain   # only the plan document may be dirty
git add docs/superpowers/plans/2026-08-29-review-loop-economics-plan-a-rules.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 7: The battery, and the hand-off to Plan B

Plan A runs no Gate-B cycle. The single cycle covering all three plans opens here and is reviewed
and closed by Plan C.

- [ ] **Step 1: The battery, minus one step, for a stated reason**

```bash
shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && \
shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && \
shellcheck --shell=sh scripts/check-invariants.sh && \
shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && \
shellcheck --shell=sh scripts/check-version-bump.sh && \
shellcheck --shell=sh scripts/check-version-bump.test.sh && \
HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh && \
HOOK_SH=dash dash plugins/dev-workflow/hooks/codex-gate.test.sh && \
sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh && \
sh scripts/check-version-bump.test.sh && \
claude plugin validate . --strict && echo "BATTERY-GREEN (version-bump deferred)"
```

> **`sh scripts/check-version-bump.sh main` is deliberately absent, and only that one step.** Plan
> A changes a path under `plugins/dev-workflow/` while the manifest bump is Plan C's, so the
> checker **would correctly fail here**. It is deferred to the combined close, where the bump
> exists. `AGENTS.md` already states this checker's precondition: it compares *commits*, and run
> mid-work it reports clean and uselessly.
>
> **This is a deferral of one step with a named reason, not licence to skip the rest.** Every other
> command must pass before Plan B opens. `scripts/check-version-bump.test.sh` — the suite — still
> runs, because it does not depend on the working tree's bump state.

- [ ] **Step 2: Confirm the cycle is intact before handing off**

```bash
base=$(cat .context/plan-a-base-sha)
n=$(git rev-list --count "$base"..HEAD)
[ "$n" = 1 ] || { echo "STACKED: $n commits above base — collapse with git reset --soft $base, then one WIP commit"; exit 1; }
git log -1 --pretty=%s | grep -q '^WIP: review-loop economics' || { echo "TIP IS NOT THE WIP"; exit 1; }
git status --porcelain
echo "CYCLE OK — single WIP on $base"
```

**Expected: `CYCLE OK`, a clean worktree, and `n` exactly 1.** The count check is what catches a
stacked WIP that a subject-only check would pass while part of the diff escapes review.

- [ ] **Step 3: Hand off**

Plan B opens against this WIP commit, amends it with the same message, and uses
`.context/plan-a-base-sha` as its base. Plan A's Gate-A loop must have closed clean first.

---

## Self-Review

**Spec coverage.** §2 → Task 1 Step 3. §2.1 → Task 1 Steps 3-4. §2.2 → Task 3. §2.4 → Task 4. §3 →
Task 5 Step 2. §10 activation, revert, downstream adoption, gate-off surface → Task 1 Step 4 and
Task 5 Step 3, **partial by design and written to be extended**. §2.3, §4, §5, §6 → Plan B. §7, §8
→ Plan C, with the five relocated findings named above.

**Placeholders.** None.

**Every expected value is an observation.** Each was produced by executing the check against a
simulated post-edit tree at its point in the sequence. **Exactly two steps state no numeric
expectation**, both deliberately and both named in place: Task 6 Step 3 (a human reading two diffs)
and Task 6 Step 1 (a judgement about already-appended tables).

**Type consistency.** `max(risk, security)`, "derived floor", "reminder threshold", "cited set" and
"level 0" are used identically throughout and match the spec's spellings.

**Gate-B classification.** Plan A opens the single cycle at Task 1 Step 6 and runs no review. Every
later commit is an amend restating `-m "WIP: review-loop economics"`. Plan C closes.

**Rerun and interruption.** Task 1 carries a closed state matrix over four independent markers;
Tasks 2-5 carry preflights whose observed values distinguish not-started from complete; Task 6
Step 1 checks for its own output markers. **Cross-copy asymmetry is a named state with a named
action** in Task 1, and the parity check in Task 6 is what catches it if it survives that far.

**Known limit.** The replacement wordings are proposals, not transcriptions — the spec pins the
rules, not the sentences — and this plan's Gate A is what reviews them.
