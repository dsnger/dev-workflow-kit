# Plan B — the records (provenance line, per-pass curve, cycle nonce, slot naming)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the two pinned commit-body records — the provenance line and the per-pass curve —
together with the cycle nonce that attributes them and the slot naming that keeps two cycles from
overwriting each other.

**Spec:** `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md` (revision 36).
Plan B implements §2.3, §4, §5, and §6's method applied to its own passages, plus the §10
extension Plan A's wording was written to permit.

**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`

> **Read the profile from that header at execution time.** This plan states no risk value, no
> security value, no validation mode and no pass count derived from any of them.

---

## Plan B of three

| Plan | Ships | Spec sections |
|---|---|---|
| A | the floor predicate and the severity test | §2, §2.1, §2.2, §2.4, §3, §10 (partial) |
| **B — this one** | the provenance line, the per-pass curve, the cycle nonce, slot naming | §2.3, §4, §5, §6 |
| C | rollout: falsified sentences, packaging, the evidence pack, the review loop | §7, §8 |

**Three Gate-A cycles, one Gate-B cycle** over the combined A+B+C diff, run and closed by Plan C.
**Plan B may not open before Plan A's Gate-A loop closes** — it did, clean at pass 12.

**Plan B edits the POST-PLAN-A tree.** Every `grep -n` anchor below was taken against the files
as Plan A leaves them, not against the untouched tree, and Task 6 edits a sentence Plan A
creates. Executing Plan B against an un-edited tree will fail at Task 6, correctly.

---

## Global Constraints

- **This Gate-B cycle runs under the rules in force at its start — the OLD ones.** The record
  forms this plan ships bind only **after** the closing commit ships them. **Carry this sentence
  in the `additionalContext` of every Gate-B call.**
- **Prompt-only.** No file under `plugins/dev-workflow/hooks/` changes, and the floor knob
  `.context/codex-gate.floor` is never written, never removed, never read.
- **The §5 heading must keep matching `^#{1,6}[[:space:]]+([0-9]+\.)?[[:space:]]*Cross-Model Review`.**
- **Every edit lands in both copies.** All five passages Plan B touches were verified identical
  across the two copies over their full extent, so no row below is split.
- **The two pinned grammars are copied from the spec verbatim, never paraphrased.** The spec pins
  them because a program parses them; a paraphrase would be a second form, which is the one thing
  a pinned form cannot survive.
- **§5's other closure rules are never restated, only referred to.**
- **Line numbers are provenance, never instructions.**
- **For Tasks 2, 3 and 4 the assert-new check is also the preflight, and the OLD text is not.**
  Each of those tasks re-emits its OLD text verbatim inside its NEW text, so **the OLD still
  matches after the task has run** and tells you nothing about whether it did. Read the assert's
  two counts as a closed state space, and stop on anything that is not one of the first two:

  | counts | state | action |
  |---|---|---|
  | `0` and `0` | not started | apply the replacement to both copies |
  | `1` and `1` | done | skip the task |
  | `1` and `0`, or `0` and `1` | **interrupted between the copies** | **STOP and surface. Do not replace either copy** — applying to both would duplicate the block in the copy that already has it while repairing the other |
  | anything above `1` | **already duplicated** | **STOP and surface.** A previous run inserted twice; the extra copy is removed by hand before the task is retried |
- **The two pinned grammars are inserted from the spec's own text, not retyped.** The escape
  specification inside the provenance grammar (`\"` and `\\`) is itself made of backslashes,
  and a transcription step ate them once — the grammar that pins the escape rules had its own
  escapes collapsed. Copy the block; do not re-key it.

### The commit protocol

**Plan B amends the WIP commit Plan A opened**, with the same message, and uses the base SHA
Task 1 of Plan A printed. Plan C adds the manifest bump, runs the single Gate-B loop, and closes.

> **Never `git commit --amend --no-edit` inside the cycle.**
> `plugins/dev-workflow/hooks/codex-gate.sh:763` recognizes a WIP commit by grepping the **Bash
> command string** for `-m ... wip`; an amend without `-m` is not recognized, and the hook resets,
> discarding the cycle's passes.

---

## Old-conditions accounting

Per spec §6's method, against the post-Plan-A text. **Three passages are rewritten and get rows.**
Three further sites are **insertion points whose existing text is re-emitted unchanged** — they
rewrite nothing, and are listed so a reader can confirm that rather than assume it.

| # | Passage | What the existing prose requires | Disposition |
|---|---|---|---|
| 1 | the findings-slot grammar | a. write the full list to `.context/codex-reviews/<slot>.md` · b. create the directory if needed · c. the path is relative to the reviewed repo root, because Codex resolves writes against its working directory · d. `<slot>` is one of three named forms — four concrete names, since `gate-b-<spec\|quality>-pass-<p>` expands to two | a–c **kept verbatim** · d **kept and extended** (Task 1): the three bare names remain, reserved for the legacy single-cycle case, and a cycle holding a nonce uses the infixed form in every slot more than one cycle could write. A refusal rule is added, which is new and not a change to d |
| 2 | the squash-merge carry | a. copy every evidence entry in the squash range · b. copy every human-exception record · c. into the squash body · d. because the squash commit is the only body the merge carries into `main`'s history, so anything left behind is unreachable | **a–d all kept verbatim**; three members added — the provenance lines, the curves, and a skipped cycle's skip record (Task 5). Extended rather than rewritten, because the successor story adds a decline record to this same sentence later |
| 3 | the activation strict-fallback list *(text Plan A creates; this is the second accounting that passage owes, per §6)* | a. from the shipping commit · b. a running cycle finishes under its starting rules · c. where the start cannot be established, take the stricter reading of every part · d. at minimum floor 3 and severity without the demotion · e. each further rule this change ships adds its own strict reading · f. not a re-derivation · g. a user knob above 3 is not lowered · h. a revert is itself a shipping commit | **a–h all kept verbatim**; the list gains the provenance-line duty, the curve duty and the nonce duties at their strictest (Task 6). This is the append that **e** exists to license |

**Insertion points, rewriting nothing:** the optional-companions block (Task 2 appends after it),
the closing-message paragraph (Task 3 inserts before the squash sentence), and the human-exception
block (Task 4 inserts before it). Each task re-emits the existing text verbatim as part of its
replacement, which is what makes the insert auditable as an insert.

---
## Task 1: The findings-slot grammar gains a per-cycle infix

**Spec:** §5 slot rules

**Site** — pasted `grep -n` **against the post-Plan-A tree**, which is what Plan B edits:

```
CLAUDE.md:292:> `gate-a-spec-pass-<p>`, `gate-a-plan-pass-<p>`, or `gate-b-<spec|quality>-pass-<p>`.
plugins/dev-workflow/commands/workflow-init.md:479:> `gate-a-spec-pass-<p>`, `gate-a-plan-pass-<p>`, or `gate-b-<spec|quality>-pass-<p>`.
```

> **This is the rule the cycle that wrote it paid for.** A bare slot was overwritten during this very change, destroying a previous cycle's findings file — an `ls` and an `rm` in one command, so the evidence that the slot was occupied arrived after it was gone. The bare names stay valid for the legacy single-cycle case; anything more than one cycle could write takes the nonce.

- [ ] **Replace, in both copies.** OLD:

```
> `gate-a-spec-pass-<p>`, `gate-a-plan-pass-<p>`, or `gate-b-<spec|quality>-pass-<p>`.
```

NEW:

```
> `gate-a-spec-pass-<p>`, `gate-a-plan-pass-<p>`, or `gate-b-<spec|quality>-pass-<p>` for a
> cycle with no nonce; a cycle that has one writes `gate-a-spec-<nonce>-pass-<p>`,
> `gate-a-plan-<nonce>-pass-<p>` or `gate-b-<spec|quality>-<nonce>-pass-<p>` instead, and uses
> the nonce in every slot more than one cycle could write. The bare names are reserved for the
> legacy single-cycle case they already serve. **A target owned by another nonce is refused,
> not overwritten, and the refusal names the collision** — this section already stops on a
> target that survives deletion, and this extends that to a target that must not be deleted at
> all. That rule exists because a bare slot was in fact overwritten once, destroying a previous
> cycle's findings file.
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "A target owned by another nonce is refused," \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated tree carrying Plan A's edits — the pattern lies on one line, contains no `**`, and is passed after `--`.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 2: The cycle nonce

**Spec:** §5

**Site** — pasted `grep -n` **against the post-Plan-A tree**, which is what Plan B edits:

```
CLAUDE.md:335:  Whoever runs the cycle writes it when useful, replaces it as the cycle moves, and
plugins/dev-workflow/commands/workflow-init.md:522:  Whoever runs the cycle writes it when useful, replaces it as the cycle moves, and
```

> Inserted after the optional-companions block, whose text is re-emitted unchanged — this task rewrites nothing, it appends. The block is the right neighbour because the working record it describes is itself one of the records the nonce keys.
> 
> The bounded retry policy is this plan's to fix and it is fixed here: **at most three attempts in total** — not three retries after a first try — **then stop and surface, naming which of the three causes occurred.** The spec delegates the number; what it requires is that the causes stay distinguishable, since randomness-unavailable, invalid-value and collision need different fixes.
> 
> **Two residuals are disclosed in the shipped text rather than guarded**, because neither can be closed by prompt rules: the uniqueness check compares against cycles *known to be open*, and two cycles starting simultaneously can each check before either publishes. What makes both unlikely is the width of the draw, not the check.
> 
> **This task inserts; it rewrites nothing.** The companions block is re-emitted verbatim, so its OLD text still matches afterwards — the assert-new check is this task's preflight, not the OLD.

- [ ] **Replace, in both copies.** OLD:

```
  Whoever runs the cycle writes it when useful, replaces it as the cycle moves, and
  deletes it once the cycle closes. Nothing depends on it existing.
```

NEW:

```
  Whoever runs the cycle writes it when useful, replaces it as the cycle moves, and
  deletes it once the cycle closes. Nothing depends on it existing.

**The cycle nonce.** Both shipped records below carry a **cycle field**, because a record that
cannot be attributed to a cycle cannot be told apart from another cycle's when several are read
together. That is a limitation rather than a disqualification — a human reading one cycle's
records knows which cycle they came from; what attribution buys is that a *later* reader
**usually** does not have to. Usually, not always: the guarantee is probabilistic, for the two
reasons stated at the end of this block. This section defines three **kinds** of cycle — the Gate-A spec loop, the Gate-A
plan loop and the Gate-B cycle — and **one cycle field is produced per cycle run, not per
kind**: a change carrying several plans runs a Gate-A plan cycle for each, and each of those is
its own cycle with its own nonce.

Generated once at cycle start, immutable, and collision-resistant operationally: **8 to 16
characters drawn uniformly from `[a-z0-9]`, from a source of randomness** — 8 being where
collision resistance starts and 16 where the field stops being a usable infix. **Never derived
from a name, a timestamp or a commit**, each of which collides exactly where sibling cycles do,
which is the one thing the nonce exists to prevent. The character set keeps it safe as a slot
infix and a path component.

**It appears in every record the cycle writes, and that set is named rather than left open**:
the provenance line, the per-pass curve (including a skip record standing in for one), the
cycle's findings slots, and its advisory working record. **The working record is a cycle record
too**: a cycle holding a nonce names it `gate-a-spec-<nonce>-resume.md`,
`gate-a-plan-<nonce>-resume.md` or `gate-b-<nonce>-resume.md`, and the bare names above stay
reserved for the legacy single-cycle case, exactly as the findings slots do. The nonce is not
required in records this change neither introduces nor keys to a cycle — the evidence entry and
a human-exception record among them.

**A nonce is a candidate for recovery only if** it is keyed to this cycle's kind — Gate-A spec,
Gate-A plan, or Gate B — **and** this cycle's artifact, **and** that cycle is still open.
History normally holds many closed cycles' nonces and they are not candidates; a working record
left by a closed cycle is not one either, which is why that record is **retired at closure**
rather than left to be found later. **Recovery has two sources**, because a Gate-A cycle's
commit does not exist while it runs: the working record during the cycle, and history at its
commit. Recovering a single candidate from **either** keeps identity. **No candidate,
disagreeing sources, or more than one candidate → no identity: start a new cycle**, which costs
passes rather than letting one cycle's records read as another's. **Starting a new cycle does
not close, adopt or retire the cycles those candidates belong to** — they stay open, keep their
own nonces, and are a human's to resolve; the new cycle simply does not claim them.

**A cycle does not start without a nonce that is valid and not equal to any nonce observed on a
known-open cycle at check time** — which is the exact property obtainable here, and is weaker
than uniqueness. Where that fails, make **at most three attempts in total**, then stop and
surface, **naming which of the three causes occurred**; each has its own check and its own fix,
and one token would name a symptom rather than a cause:

- **randomness unavailable** — the source errors or returns nothing. *Fix:* make a source
  available, or run where one is. Retrying does not help and the attempts are spent proving it.
- **an invalid value** — the drawn value is not 8 to 16 characters from `[a-z0-9]`. *Fix:*
  redraw, which is what the remaining attempts are for. If it recurs the generator is wrong, not
  unlucky, and that is what gets reported.
- **a collision with a known-open cycle** — the value equals a nonce on a cycle still open.
  *Fix:* redraw. A second collision at this width means the source is not behaving randomly, and
  the report says so rather than repeating the draw.

**No deterministic fallback.**

**Two residuals, disclosed rather than guarded.** The uniqueness check compares against cycles
*known to be open*, so a nonce can repeat one belonging to a cycle nobody can see; and two
cycles starting at the same moment can each check before either has published, so neither
observes the other. **What makes both unlikely is the width of the draw, not the check** — and
unlikely is the honest word. Neither is a guard.

**A cycle that began before these rules shipped has no nonce and cannot acquire one.** Its
records carry the reserved `cycle none (pre-rule)` field and are, by construction, not
cycle-attributable. That exception is bounded and self-terminating: it reaches only cycles
already running when the rules land, and no later cycle can enter the state.
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "Generated once at cycle start, immutable" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated tree carrying Plan A's edits — the pattern lies on one line, contains no `**`, and is passed after `--`.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 3: The provenance line

**Spec:** §2.3

**Site** — pasted `grep -n` **against the post-Plan-A tree**, which is what Plan B edits:

```
CLAUDE.md:687:  **On squash-merge, copy every evidence entry and every human-exception record in the squash range into the squash body — the squash commit is the only body the merge carries into `main`'s history, so anything left behind is unreachable from it.**
plugins/dev-workflow/commands/workflow-init.md:864:  **On squash-merge, copy every evidence entry and every human-exception record in the squash range into the squash body — the squash commit is the only body the merge carries into `main`'s history, so anything left behind is unreachable from it.**
```

> Inserted before the squash-merge sentence, which is re-emitted unchanged here and then edited by Task 5 — so the OLD still matches after this task, and the assert-new check is its preflight.
> 
> **The grammar is the spec's block, copied — two spaces of indentation added so it stays inside its bullet, and nothing else changed.** Verified by de-indenting the shipped block and comparing it byte-for-byte with spec §2.3. That check earns its keep: an earlier attempt embedded the block through a transcription step that interpreted `\\"` as `"` and `\\\\` as `\\`, silently rewriting the very production that specifies which escapes are legal.

- [ ] **Replace, in both copies.** OLD:

```
  **On squash-merge, copy every evidence entry and every human-exception record in the squash range into the squash body — the squash commit is the only body the merge carries into `main`'s history, so anything left behind is unreachable from it.**
```

NEW:

```
  **Every cycle records one provenance line in its closing commit body** — default floor or
  not, so an absent line is never ambiguous between "the default applied" and "someone forgot".
  **One line per cycle**, so a change running five cycles records five. There is no informal
  variant; anything quoting this form elsewhere quotes an instance of it, because the deferred
  metrics work parses it.

  <CYCLE-FIELD>; floor <N> per <STORY-SET>; hook reminder threshold <KNOB>

  <CYCLE-FIELD> := "cycle " <NONCE> | "cycle none (pre-rule)"
  <NONCE>     := [a-z0-9]{8,16}
  <N>         := [1-9][0-9]*
  <STORY-SET> := "none" | "{" <ENTRY> ("," <ENTRY>)* "}"
                                            each <PATH> appears at most once; a repeated path,
                                            with or without conflicting levels, is malformed
  <ENTRY>     := <PATH> " (level " ("0"|"1"|"2") ")" | <PATH> " (unprofiled)"
  <PATH>      := <bare> | <quoted>
  <bare>      := [A-Za-z0-9._/-]+           contains no delimiter, quote or whitespace
  <quoted>    := a double-quoted string, non-empty, whose only escapes are \" and \\ ;
                                            a path containing a newline or other control
                                            character is NOT representable — the cycle stops
                                            and surfaces rather than emitting one
  <KNOB>      := "absent" | [1-9][0-9]* | "unusable(" <CAUSE> ")"
  <CAUSE>     := "unreadable" | "empty" | "non-numeric" | "out-of-range"

  It carries that cycle's **cycle field** — the nonce for any cycle started after these rules
  ship, `none (pre-rule)` only for one that began before them — the **derived floor**, and **the
  cited set that produced it**, each member with its level as a numeral. One floor and one set,
  not an entry per story, since unanimity makes the floor a property of the set. It
  distinguishes **a cited story with no profile** from **no story cited**. It records the
  **workspace knob whenever the file exists**, including when present but unusable, **naming the
  cause**, because those need different fixes.

  **On squash-merge, copy every evidence entry and every human-exception record in the squash range into the squash body — the squash commit is the only body the merge carries into `main`'s history, so anything left behind is unreachable from it.**
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "floor <N> per <STORY-SET>; hook reminder threshold <KNOB>" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated tree carrying Plan A's edits — the pattern lies on one line, contains no `**`, and is passed after `--`.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 4: The per-pass curve

**Spec:** §4

**Site** — pasted `grep -n` **against the post-Plan-A tree**, which is what Plan B edits:

```
CLAUDE.md:689:  **Recording a human exception.** Where a human decides that something **no applicable rule
plugins/dev-workflow/commands/workflow-init.md:866:  **Recording a human exception.** Where a human decides that something **no applicable rule
```

> Inserted before the human-exception block, which is re-emitted unchanged — so again the OLD still matches afterwards and the assert-new check is the preflight. The grammar is spec §4's block with two spaces of indentation added and nothing else, verified the same way.
> 
> Note what the shipped text says about its own worth, because it is the part most likely to be dropped as hedging: the curve is durable **across** cycles and not **within** one, and it is **author-written and unchecked** — nothing compares it against the validated pass files. Whatever later reads it reads a self-report.

- [ ] **Replace, in both copies.** OLD:

```
  **Recording a human exception.** Where a human decides that something **no applicable rule
  required** was nonetheless worth skipping
```

NEW:

```
  **Every cycle records its own per-pass curve in its own commit body.** Gate B alone would
  leave the dominant cost unrecorded — the loops this rule was built from are Gate-A loops.

  <CYCLE-FIELD>; <CYCLE> (passes <SPEC>, <MODELS>): Findings <COUNTS>. Blockers <COUNTS>. Majors <COUNTS>.

  <CYCLE>    := "Gate-A spec" | "Gate-A plan" | "Gate B"
  <SPEC>     := <RANGE> ("," <RANGE>)*      strictly ascending, non-overlapping
  <RANGE>    := <p> | <p> "-" <p>
  <p>        := [1-9][0-9]*
  <COUNTS>   := <n> ("," <n>)*              exactly as many entries as <SPEC> enumerates
  <n>        := 0 | [1-9][0-9]* | "?"      "?" = the count is unrecoverable for that pass
  <MODELS>   := <model> | <PER-PASS> ("; " <PER-PASS>)*
  <PER-PASS> := "pass " <p> " " <model> ("+" <model>)*
  <model>    := <bare-model> | <quoted-model> | "undetermined"
                                            "undetermined" means the model could not be determined;
                                            a real model so named is written as <quoted-model>
  <bare-model> := [!-~]{1,} minus ; : , ( ) + " and space, and not the
                                            literal "undetermined", which is reserved
                                            printable ASCII only; a control character makes the
                                            identifier unrepresentable, handled below
  <quoted-model> := a non-empty double-quoted string, same two escapes as <quoted>;
                                            a reported identifier containing a control character is
                                            written `undetermined` — and the raw value is NOT
                                            reproduced anywhere in the body, since a commit message
                                            cannot safely carry one (NUL cannot appear at all).
                                            What the body records instead is where the value came
                                            from and which bytes were rejected, described rather
                                            than embedded

  A skipped cycle writes `<CYCLE-FIELD>; <CYCLE>: skipped (see skip reason)` and no counts.
  **`<PER-PASS>` keys must be exactly the passes `<SPEC>` expands to, each once, ascending** — a
  list that omits or repeats a pass is malformed, not partially informative — and **every model
  contributing to a split logical pass is listed**, joined by `+`, since recording one of two is
  the same loss as recording none.

  **Majors are recorded as well as Findings and Blockers**, because the severity rule moves the
  Blocker/Major line rather than the total, so totals and Blockers alone could not show even a
  change in the mix. **Subject categories are deliberately not recorded** — they are a judgement
  per finding rather than a count, and the findings files carry the material.

  **One entry per valid pass**, and since incomplete passes are excluded while still consuming
  pass numbers, the record **states which pass numbers it covers**. A valid zero-finding pass is
  recorded as zero, never omitted. **A count that cannot be recovered is written `?`, never
  guessed and never written as `0`** — a cycle keeps its identity through the nonce rather than
  through its pass files, so a resumed cycle may know a pass happened and not what it found, and
  zero and unknown are different facts. **`?` is per series**: a pass whose Findings are unknown
  may still have usable Blocker and Major counts, and a reader excludes the unknown value from
  the comparisons that read that series while keeping the pass's other series.

  A `full` Gate-B pass, separate `spec`/`quality` calls, and a single-branch recovery are
  **branches of one logical pass** contributing one summed entry — **the curve counts logical
  passes; the hook counts calls**, and where they differ the body says so. **Both branches must
  have reviewed the same tracked reviewed commit**; if it changed between them they are not one
  pass, the completed branch is recorded as incomplete and excluded, and the later branch begins
  a new one. Ending the pass is the conservative direction; merging two revisions would produce
  one entry describing two different artifacts.

  **What the curve is worth, stated rather than implied.** Durable **across** cycles; **not
  within** a running one, since the commit does not exist until the cycle closes. And
  **author-written and unchecked** — nothing compares it against the validated pass files, so
  whatever reads it reads a self-reported curve and must not present it as measurement.

  **Recording a human exception.** Where a human decides that something **no applicable rule
  required** was nonetheless worth skipping
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "Findings <COUNTS>. Blockers <COUNTS>. Majors <COUNTS>." \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated tree carrying Plan A's edits — the pattern lies on one line, contains no `**`, and is passed after `--`.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 5: The squash carry

**Spec:** §4 squash carry

**Site** — pasted `grep -n` **against the post-Plan-A tree**, which is what Plan B edits:

```
CLAUDE.md:687:  **On squash-merge, copy every evidence entry and every human-exception record in the squash range into the squash body — the squash commit is the only body the merge carries into `main`'s history, so anything left behind is unreachable from it.**
plugins/dev-workflow/commands/workflow-init.md:864:  **On squash-merge, copy every evidence entry and every human-exception record in the squash range into the squash body — the squash commit is the only body the merge carries into `main`'s history, so anything left behind is unreachable from it.**
```

> **Extends the list; does not rewrite the sentence.** The successor story adds a decline record to this same passage later, and a rewrite here would drop what that adds — or be dropped by it. Both existing members and the reason clause are preserved verbatim.

- [ ] **Replace, in both copies.** OLD:

```
  **On squash-merge, copy every evidence entry and every human-exception record in the squash range into the squash body — the squash commit is the only body the merge carries into `main`'s history, so anything left behind is unreachable from it.**
```

NEW:

```
  **On squash-merge, copy every evidence entry, every human-exception record, the provenance lines, the curves and any skipped cycle's skip record in the squash range into the squash body — the squash commit is the only body the merge carries into `main`'s history, so anything left behind is unreachable from it.**
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "the provenance lines, the curves and any skipped cycle's skip record" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated tree carrying Plan A's edits — the pattern lies on one line, contains no `**`, and is passed after `--`.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 6: The activation list gains the three record duties

**Spec:** §10

**Site** — pasted `grep -n` **against the post-Plan-A tree**, which is what Plan B edits:

```
CLAUDE.md:152:floor 3, and severity classified without the demotion; each further rule this change ships
plugins/dev-workflow/commands/workflow-init.md:352:floor 3, and severity classified without the demotion; each further rule this change ships
```

> **This is the extension Plan A's wording was built to permit.** Plan A shipped the strict-fallback list with two members and the clause "each further rule this change ships adds its own strict reading to this list" precisely so this task could append rather than rewrite — §10 says extending is safe and replacing is not.
> 
> Plan B is the successor in that sentence's sense **within this change**; the loop-rule consolidation story is a different successor and extends it again later.

- [ ] **Replace, in both copies.** OLD:

```
floor 3, and severity classified without the demotion; each further rule this change ships
adds its own strict reading to this list.
```

NEW:

```
floor 3, severity classified without the demotion, the provenance-line duty owed, the curve
duty owed, and the nonce duties at their strictest — the cycle is treated as post-rule, so it
owes a nonce and every record that carries one, and where it cannot recover one it starts a new
cycle rather than claiming `none (pre-rule)`, that reserved field being unavailable to a cycle
whose start cannot be established. Each further rule this change ships adds its own strict
reading to this list.
```

- [ ] **Assert the new text is present.**

```bash
grep -cF -- "the provenance-line duty owed, the curve" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

Before this task: `0` and `0`. After: `1` and `1`. Verified executable against a simulated tree carrying Plan A's edits — the pattern lies on one line, contains no `**`, and is passed after `--`.

- [ ] **Amend the WIP commit.**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics"
```

---

## Task 7: The battery, and the hand-off to Plan C

Plan B runs no Gate-B cycle. The single cycle covering all three plans is reviewed and closed by
Plan C.

- [ ] **Run the battery, minus one step, for a stated reason**

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

> **`sh scripts/check-version-bump.sh main` is deliberately absent, and only that one step**, for
> the same reason it is absent from Plan A: the manifest bump is Plan C's, so the checker would
> correctly fail here. Every other command must pass before Plan C opens.

- [ ] **Hand off to Plan C**

Plan C amends the same WIP commit, adds the manifest bump and the CHANGELOG entry, corrects the
user-facing sentences the two rule changes falsify, produces the evidence pack, runs the single
Gate-B loop against the recorded base SHA, and closes the cycle. Plan B's Gate-A loop must have
closed first.

---

## Self-Review

**Spec coverage.** §2.3 → Task 3. §4 including the squash carry → Tasks 4 and 5. §5 nonce and
slot rules → Tasks 1 and 2. §6's method → the accounting above. §10 extension → Task 6.

**Placeholders.** None.

**Type consistency.** `<CYCLE-FIELD>`, `<NONCE>`, `<STORY-SET>`, `<KNOB>`, `<COUNTS>`, `<SPEC>`
and `<MODELS>` are used exactly as spec §2.3 and §4 define them, copied rather than restated.

**Known limit, and it is the same boundary Plan A closed on.** Gate A reviews this plan, not the
edits. Each task's single check establishes that its edit landed at its site and nothing more.
What those edits do to the shipped files is Gate B's, reading the real diff.
