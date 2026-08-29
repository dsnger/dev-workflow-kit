# Plan A — the rules edits (floor predicate + severity semantics)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development
> (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship parts 1 and 2 of the review-loop-economics change into both prompt copies — the
pass floor becomes a function of the cited story's profile, and finding severity is decided by
whether something in the system takes a different decision.

**Architecture:** Two mirrored prose edits, site by site: `CLAUDE.md` §5 and the inline template in
`/workflow-init`. **No code. Nothing under `plugins/dev-workflow/hooks/` is touched and no hook
state file is written.**

**Tech Stack:** Markdown prompts; POSIX shell for every check; `git` for the records.

**Spec:** `docs/superpowers/specs/2026-08-28-review-loop-economics-design.md` (revision 36, Gate A
closed clean at pass 34). **Read it alongside this plan.** Plan A implements §2, §2.1, §2.2, §2.4,
§3 and the part of §10 that covers the rules it ships.

**Story:** `docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md`

> **Read the profile from that header and from nowhere else.** This plan deliberately does not
> copy the risk value, the security value or the validation mode into itself. §5 makes the story
> header the single writable copy: a copy here would go stale the moment the profile moved, and a
> stale floor is this change's own central failure mode.

---

## Why this is one of three plans

The single 748-line plan this replaces opened **31 Blocker/Major at Gate-A pass 1** (`5c00f8c`;
findings at `.context/codex-reviews/gate-a-plan-rle-pass-1.md`). Twelve of those findings were one
shape — the plan gestured at settled spec content instead of shipping it — and the artifact was
already too long while still needing to grow. The split is A → B → C, sequenced, each its own
Gate-A cycle:

| Plan | Ships | Spec sections |
|---|---|---|
| **A — this one** | the floor predicate and the severity test, site by site in both copies | §2, §2.1, §2.2, §2.4, §3, §10 (partial) |
| **B** | the provenance line, the per-pass curve, the cycle nonce, slot naming | §2.3, §4, §5, §6 |
| **C** | rollout: the falsified user-facing sentences, packaging, the evidence pack | §7, §8 |

**B may not open before A's loop closes.** Only two interventions ever moved a finding curve in
this cycle — splitting an artifact and slimming one — so this is the move with evidence behind it,
not a preference. It costs three separate 3-pass floors under the story's `high` profile. That is
the story's own floor rule applying to the work that writes it, and it is recorded as such rather
than worked around.

### Where pass 1's findings went — every one, to exactly one plan

Stated so nothing falls between three documents the way the passage list fell between two.

| Finding | Owner | Note |
|---|---|---|
| B1 conditions artifact circular | **A** | dissolved: the accounting is a *section of this plan*, reviewed by this plan's Gate-A passes |
| B2 passage set unsound | **A** | dissolved the way B2 asked: the set is **derived from the planned edits**, not imported from revision 15 |
| B3 pass-report paragraph unedited | **A** | Task 4 |
| B4 floor replacement range undelimited | **A** | Task 2 gives exact old and new text and dispositions `counted by the hook` |
| B5 gate-off list read as complete | **A** | Task 2 Step 4 ships §10's "routes known today, not a complete list" framing |
| B6 §2.4 mid-cycle missing | **A** | Task 5 |
| B7 §10 activation missing | **A** | Task 6, for the two parts A ships; **B extends it** to the three record duties |
| B8 `7/7` false in sequence | **A** | every check below states its value *for its point in the sequence* |
| B9-B13 records/nonce/slots under-shipped | **B** | |
| B14-B16 commit topology | **A**, restated in B and C | resolved once, below; each plan repeats the resolution |
| B17 `N/N cycle` in getting-started | **C** | |
| B18 re-review without amending | **A**, restated in B and C | Task 8 |
| B19 evidence produced after close | **C** | |
| B20 literal `<body: ...>` placeholder | **A**, restated in B and C | Task 8 builds the body before amending |
| B21 rewriting closed commit bodies | **C** | |
| M1 one row for two copies | **A** | the accounting has a row **per copy** |
| M2 plan copies the profile values | **A** | header above carries the path only |
| M3 ellipses in replacement text | **A** | every replacement is complete text |
| M4 false `where the 3 come from` rationale | **A** | Task 3 |
| M5 "the floor is unchanged" | **A** | Task 3 |
| M6 nonce diagnostics | **B** | |
| M7 parity result schema | **A** | Task 7 pins the tables |
| M8 future-nonce checkpoint | **C** | |
| M9 interruption / rerun safety | **A**, restated in B and C | every edit task has a preflight |
| M10 `main` currency | **C** | |
| MINOR 11 CHANGELOG content | **C** | |
| NIT 12 `(identical)` in a pasted block | **A** | no editorial token appears inside any pasted block below |

---

## Global Constraints

Verbatim from the spec. Every task's requirements implicitly include these.

- **Prompt-only.** No file under `plugins/dev-workflow/hooks/` changes; no hook state file is
  written, in particular not `.context/codex-gate.floor`.
- **The §5 heading must keep matching `^#{1,6}[[:space:]]+([0-9]+\.)?[[:space:]]*Cross-Model Review`.**
  `codex-gate.sh:94` greps `CLAUDE.md` for it to build every reminder's citation.
- **Every rule lands in BOTH copies**, except where a difference is deliberate and stated.
- **§5's other closure rules are never restated, only referred to.** Three spec revisions were
  spent on this: each summary of the triviality skip dropped a different condition.
- **Anchors are pasted `grep -n` output.** No editorial token ever appears inside a pasted block —
  writing `(identical)` in place of a second grep line cost the predecessor its blanket claim.

### The commit protocol — read this before Task 1

**All ordinary commits happen BEFORE the WIP opens. Then one WIP commit, then the review loop,
then the close.** Nothing commits ordinarily while the cycle is open.

> **The `--no-edit` trap — this is why the protocol looks verbose.**
> `plugins/dev-workflow/hooks/codex-gate.sh:763` is
> `is_wip_commit() { printf '%s' "$1" | grep -Eiq -- "-m[[:space:]]*['\"]?[[:space:]]*wip"; }`
> It matches **the Bash command string**, not git state and not the commit message. So
> `git commit --amend --no-edit` carries no `-m`, is **not** recognized as a WIP commit, and at
> `:886` `is_commit "$cmd" && ! is_wip_commit "$cmd"` is true — **the cycle resets and your passes
> are discarded.** Every cycle-internal amend below therefore restates `-m "WIP: ..."` in full.
> Never `--no-edit` inside the cycle.
>
> That the shipped rules do not warn about this is a real defect, routed to the backlog. **Do not
> fix the hook here** — this plan is prompt-only by its own constraint above.

The topology, in order:

1. **Task 1** commits the conditions accounting — ordinary commit, Gate B N/A, **cycle not yet
   open**.
2. **Task 2 opens the cycle**: `git commit -m "WIP: <subject>"`.
3. **Tasks 3-7 amend it**, each restating `-m "WIP: <subject>"`. Same subject every time.
4. **Task 8** runs the review loop against that commit (`baseSha` = its parent), re-amending after
   every fix, and closes with `git commit --amend -m "<real message>"` — the first message without
   `WIP:`, which the hook correctly reads as the cycle closing.

**Task 7's parity and conformance results are folded into the WIP commit, not committed
separately.** A separate docs commit after the WIP opens would reset the cycle regardless of which
paths it staged.

---

## File Structure

| File | Responsibility | Gate B |
|---|---|---|
| this plan, § "Old-conditions accounting" | what the existing prose required, per copy, dispositioned | N/A — reviewed by this plan's Gate-A cycle |
| `CLAUDE.md` §5 | the live rules | full (in the cycle) |
| `plugins/dev-workflow/commands/workflow-init.md` §5 | the scaffolded mirror | full (in the cycle) |
| `docs/superpowers/specs/…-plan-a-conditions.md` | the accounting, extracted for the record | N/A — ordinary commit, Task 1, before the cycle opens |

---

## Old-conditions accounting

**Derived from the edits this plan actually makes**, against §5 as it stands at HEAD — not
imported from an earlier spec revision. That was finding B2: an imported list can be stale,
overinclusive and incomplete at once, and the exact-once grep that guarded it proved only that the
lead-ins existed.

**One row per passage per copy.** Where the two copies' text is byte-identical for a passage the
rows are identical and say so; a condition unique to one mirror cannot hide behind a shared row
(finding M1).

Anchors, pasted from `grep -n` — `CLAUDE.md` then `plugins/dev-workflow/commands/workflow-init.md`:

```
CLAUDE.md:72:**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
CLAUDE.md:77:final pass must be clean — if pass 3 still finds Blocker/Major, keep going until
CLAUDE.md:79:below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is
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
plugins/dev-workflow/commands/workflow-init.md:330:**From pass 4 onward every pass report carries three lines.** The carrier is **your own
plugins/dev-workflow/commands/workflow-init.md:421:act on the partial list, don't count it toward the 3-pass floor, and don't read "no
plugins/dev-workflow/commands/workflow-init.md:485:- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).** Run on the
plugins/dev-workflow/commands/workflow-init.md:519:  invalidates the prior pass, which is where the 3 come from.
plugins/dev-workflow/commands/workflow-init.md:582:Lenses are **different questions, not more passes.** The 3-pass floor, the Blocker/Major
plugins/dev-workflow/commands/workflow-init.md:659:**Changing a profile:** the pass **proposes the complete resulting header** — both axes,
plugins/dev-workflow/commands/workflow-init.md:674:- **Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw →
```

**Ten passages, each in two copies — twenty rows.** Both copies are byte-identical at every one of
these ten passages; Task 1 Step 2 proves that mechanically rather than asserting it, and the rows
below are written once with that proof standing in for the second copy. **If that proof fails for
any passage, that passage gets two separate rows and the difference is dispositioned.**

| # | Passage | What the existing prose requires | Disposition |
|---|---|---|---|
| 1 | floor paragraph (72 / 272) | a. a hard floor of 3 passes per run · b. Blocker/Major only · c. the count is the hook's · d. a satisfied count is not a clean review · e. Gate A is instruction-backed · f. the hook resets at `writing-plans` · g. a TodoWrite per pass · h. fix Blocker/Major after each · i. Codex is advisory · j. validate before applying · k. dismissed finding → one-line why | a. **replaced** by the derived predicate (Task 2) · c. **moved** — the hook still counts, but as its reminder threshold, not the obligation (Task 2 Step 3) · b, d-k **kept verbatim** |
| 2 | `if pass 3 still` (77 / 277) | the final pass must be clean; if the pass at 3 still finds Blocker/Major, keep going until clean or clearly stuck, then STOP and surface | **kept**, with `pass 3` → `the pass at the floor` (Task 3) |
| 3 | `below 3` (79 / 279) | the only early exit below the floor is a zero-finding pass; don't pad | **kept**, with `below 3` → `below the floor` (Task 3) |
| 4 | pass-report paragraph (133 / 330) | a. from pass 4 onward, three lines · b. the carrier is your own status report · c. never the Codex reply · d. never the findings file · e. the trend line · f. the cluster line · g. the require↔withdraw line | a. **kept and extended** — the three lines still start at pass 4; §2.2's three fields are owed by **every** pass (Task 4) · b-g **kept verbatim** |
| 5 | incomplete-pass (236 / 421) | an incomplete pass is not a review: don't act on the partial list, don't count it toward the floor, don't read "no Blocker/Major visible" as clean | **kept**, with `the 3-pass floor` → `the floor` (Task 3) |
| 6 | Gate A loop (300 / 485) | Gate A is two runs, each its own 3-pass loop; one broad prompt; re-run each pass over the revised artifact | **kept**, with `3-pass loop` → `loop at the derived floor` (Task 3) |
| 7 | `where the 3 come from` (335 / 519) | re-review after every fix, because a fix changes the diff and the hook invalidates the prior pass | **kept**, but its **rationale is corrected** — the number no longer comes from invalidation (Task 3, finding M4) |
| 8 | Lenses (403 / 582) | lenses are different questions, not more passes; the floor, the Blocker/Major filter, the file-first protocol and the clean-final-pass rule are unchanged | **kept**, reworded so "unchanged" no longer claims the floor is fixed (Task 3, finding M5) |
| 9 | `Changing a profile:` (480 / 659) | a. the pass proposes the complete resulting header · b. the human confirms, both directions · c. an agent never moves it alone · d. correct the header, append one log line · e. any axis change voids every prior override · f. `+abuse-path` follows current security · g. passes under the lower profile keep counting · h. only the final clean pass must run under the current profile · i. fold mid-cycle edits into the WIP by amend | **all nine kept verbatim**; §2.4's mid-cycle rules are **appended** after them, not merged into them (Task 5) |
| 10 | Severity (495 / 674) | Blocker = wrong/unsafe/breaks invariant · Major = design flaw → rework · both must resolve · Minor and Nit → collect, never iterate | **all four kept verbatim**; the reachability test is **appended** as the procedure that sets a ceiling on them (Task 6) |

**Nothing in §5 outside these ten passages is edited by Plan A.** Task 7 Step 3 proves that by diff.

---

## Task 1: The accounting, committed before the cycle opens

**Files:** Create `docs/superpowers/specs/2026-08-29-review-loop-economics-plan-a-conditions.md`

- [ ] **Step 1: Preflight — is this already done?**

```bash
test -e docs/superpowers/specs/2026-08-29-review-loop-economics-plan-a-conditions.md \
  && echo "EXISTS — read it and skip to Step 4" || echo "ABSENT — proceed"
```

Every edit task below opens with a preflight, because a plan abandoned halfway must be resumable
without duplicating an append (finding M9).

- [ ] **Step 2: Prove the two copies are byte-identical at all ten passages**

The accounting above writes one row per passage on the strength of this. Run it before trusting it:

```bash
C=CLAUDE.md; T=plugins/dev-workflow/commands/workflow-init.md
for pair in 72:272 77:277 79:279 133:330 236:421 300:485 335:519 403:582 480:659 495:674; do
  a=${pair%:*}; b=${pair#*:}
  if [ "$(sed -n "${a}p" "$C")" = "$(sed -n "${b}p" "$T")" ]; then
    printf 'IDENTICAL %s/%s\n' "$a" "$b"
  else
    printf 'DIFFERS   %s/%s <<<%s>>> <<<%s>>>\n' "$a" "$b" \
      "$(sed -n "${a}p" "$C")" "$(sed -n "${b}p" "$T")"
  fi
done
```

**Expected at this point in the sequence: ten `IDENTICAL` lines, no `DIFFERS`.** Any `DIFFERS` line
means that passage needs two rows in the accounting and a stated disposition for the difference —
fix the accounting before proceeding, do not proceed with a shared row.

- [ ] **Step 3: Extract the accounting to the conditions file**

Copy this plan's § "Old-conditions accounting" verbatim into that file, with a one-paragraph header
naming this plan as its source and Plan A's Gate-A cycle as its review.

- [ ] **Step 4: Commit — ordinary commit, Gate B N/A, cycle not yet open**

```bash
git add docs/superpowers/specs/2026-08-29-review-loop-economics-plan-a-conditions.md
git diff --cached --name-only   # MUST list exactly that one path
git commit -m "docs(spec): old-conditions accounting for the Plan A rules edits"
```

**This is the last ordinary commit until the cycle closes.** Everything after Task 2 amends.

---

## Task 2: Open the cycle, and replace the floor

**Files:** `CLAUDE.md:72`, `plugins/dev-workflow/commands/workflow-init.md:272`

**Interfaces:**
- Produces: the phrase `max(risk, security)` inside the floor paragraph, which Task 3's sites and
  Task 6's severity text both refer back to.

- [ ] **Step 1: Preflight**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"
  sed -n '/Both gates are a LOOP with a HARD FLOOR/,/^$/p' "$f" | grep -c 'max(risk, security)'
done
```

**Expected at this point in the sequence: `0` and `0`** — this is the failing check. `1` and `1`
means Task 2 already ran; verify against Step 3's text and skip to Step 5.

**The `sed` scoping is load-bearing.** An unscoped `grep -c 'max(risk, security)'` returns **1** for
both files even before any edit, because the Profiles section already contains the phrase. The
check would pass before the edit and prove nothing.

- [ ] **Step 2: Read the exact text being replaced**

```bash
sed -n '72,80p' CLAUDE.md
sed -n '272,280p' plugins/dev-workflow/commands/workflow-init.md
```

The old text, in both copies (finding B4 — the replaced range is delimited, not left to judgement):

```
**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
only), counted by the hook.** The hook counts passes but can't read findings or
tell the spec run from the plan run (it resets at `writing-plans`), so Gate A —
the spec run especially — is instruction-backed: a satisfied count is not a clean
review. Open a TodoWrite "Codex pass N" per pass; fix Blocker/Major after each. Your
final pass must be clean — if pass 3 still finds Blocker/Major, keep going until
clean or clearly stuck → then STOP and surface to the user. The only early exit
below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is
advisory — validate before applying; dismissed finding → one-line why.
```

**Lines 77 and 79 of that block are Task 3's sites 2 and 3.** Task 2 replaces only the first two
sentences — through `counted by the hook.` and the sentence that explains it — and leaves the rest
of the paragraph on disk untouched. Task 3 then edits lines 77 and 79 in place.

- [ ] **Step 3: The replacement — complete text, no ellipsis**

Replace exactly these two sentences:

```
**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
only), counted by the hook.** The hook counts passes but can't read findings or
tell the spec run from the plan run (it resets at `writing-plans`), so Gate A —
the spec run especially — is instruction-backed: a satisfied count is not a clean
review.
```

with:

```markdown
**Both gates are a LOOP with a HARD FLOOR: a minimum number of passes per run (Blocker/Major
only), derived from the cited story's profile.** `max(risk, security) == 0` gives a floor of
**1**; every resolvable profile above that, and an artifact citing **no** story, gives **3**. Two
levels, not three — `high` takes its rigor from lens sets and evidence mode, not from extra
passes. **A cited story whose profile is present but unresolvable stops and surfaces** under §5's
existing rule; it does not fall through to 3, because reading it as 3 would turn a stop condition
into a silent default. **Across a cited set the floor is 1 if and only if the set is non-empty and
every member is profiled, resolvable and at level 0** — all four conditions, since "every cited
story" is vacuously true of an empty set; no story cited, or any cited story unprofiled, gives 3.
**One derived value governs all three cycles** — the Gate-A spec loop, the Gate-A plan loop and the
Gate-B cycle. Not because they are one cycle (§5 is explicit that they are three) but because they
derive from the same cited-story set.

**The derived floor is the pass count a cycle owes, and the hook's ratio is a reminder threshold
that controls nothing.** The hook still counts passes, and it still can't read findings or tell the
spec run from the plan run (it resets at `writing-plans`), so Gate A — the spec run especially — is
instruction-backed: **a satisfied count is not a clean review, and a below-threshold reminder is
noted in the pass report and disregarded** where the cycle's own closure rules are satisfied. **This
replaces the pass-count number and nothing else.** Every other rule §5 states about how a cycle
closes stands as written, and none of them is restated here — a summary is where their conditions
would get dropped. **Nothing here writes `.context/codex-gate.floor`**: the knob stays the user's,
never written, never removed, never read for this derivation.
```

- [ ] **Step 4: Add the residual and the gate-off disclosure**

Immediately after the block above, in both copies. Finding B5: the list is explicitly **not**
exhaustive, and it carries every route §10 names.

```markdown
**Named residual:** the hook's messages state its own threshold as an obligation, so at a floor of
1 they report a shortfall the cycle does not owe. Hook text is out of scope here by decision; what
makes that tolerable is the precedence rule above plus the hook exiting 0 on every branch, not the
reminder being harmless.

**The gate-off surface — routes known today, not a complete list**, since an enumeration read as
complete guarantees the routes it omits. **One route is created here**: a stated floor the cited
set does not license, which could not exist before there was a derived floor to state. **Pre-existing
and unchanged**: omitting a higher-risk cited story; minting or editing a profile to level 0;
presenting an incomplete cited set; falsifying evidence entries; silencing reminders; or not
running a pass and reporting that it ran. **A user-set floor is not the lever** — it moves what the
hook says, not what the cycle owes. **None of this is a guard**: the floor is produced by the agent
and nothing checks it against the cited profiles.
```

- [ ] **Step 5: Re-run Step 1's check**

**Expected now: `1` and `1`.**

- [ ] **Step 6: Verify the paragraph's tail survived**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"
  tr '\n' ' ' < "$f" | tr -s ' ' | grep -c "don't manufacture findings to pad"
done
```

**Expected: `1` and `1`** — same as before the edit. This catches a replacement that swallowed its
neighbours.

- [ ] **Step 7: OPEN THE CYCLE**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit -m "WIP: review-loop economics Plan A — floor predicate and severity test"
```

**That subject is reused verbatim by every amend in Tasks 3-7.**

---

## Task 3: The seven floor-wording sites, per copy

**Interfaces:** consumes Task 2's predicate; produces nothing.

- [ ] **Step 1: Preflight — the sequence-correct count**

```bash
grep -cE "min 3 passes|below 3|3-pass|where the 3 come from|if pass 3 still" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Expected at this point in the sequence: `6` and `6` — not 7.** Seven is the count in an
untouched tree; Task 2 has already removed the `min 3 passes` match at line 72/272. Recording 7
here was finding B8: a true measurement of today's tree is not the check's value mid-plan.

After this task both must be **0**.

- [ ] **Step 2: The `pass 1` site the regex does not match**

```bash
grep -n 'carrying a Minor keeps' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Expected: `CLAUDE.md:126` and `workflow-init.md:322`.** This site contains no digit `3` and the
Step 1 regex never matched it — so Step 1 reaching 0 does **not** cover it. It is asserted
separately at Step 5.

- [ ] **Step 3: Apply six replacements per copy**

Complete text, no ellipses (finding M3). **CLAUDE.md line : template line.**

**77 : 277** — old:
```
final pass must be clean — if pass 3 still finds Blocker/Major, keep going until
```
new:
```
final pass must be clean — if the pass at the floor still finds Blocker/Major, keep going until
```

**79 : 279** — old:
```
below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is
```
new:
```
below the floor is a pass with **zero** findings; don't manufacture findings to pad. Codex is
```

**236 : 421** — old:
```
act on the partial list, don't count it toward the 3-pass floor, and don't read "no
```
new:
```
act on the partial list, don't count it toward the floor, and don't read "no
```

**300 : 485** — old:
```
- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).** Run on the
```
new:
```
- **Gate A — Spec, then plan (TWO runs, each its own loop at the derived floor).** Run on the
```

**335 : 519** — old:
```
  invalidates the prior pass, which is where the 3 come from.
```
new:
```
  invalidates the prior pass — which is why a fix costs another pass, though the floor itself
  comes from the profile.
```

> Finding M4: `which is where the 3 come from` was a **causal claim that the new design makes
> false**. The lower bound now comes from the story profile; invalidation only explains why a fix
> requires another review. Rewording it to "where the floor's lower bound comes from" would have
> preserved the false claim in new words — the exact failure `AGENTS.md` records as this repo's
> most persistent defect.

**403 : 582** — old:
```
Lenses are **different questions, not more passes.** The 3-pass floor, the Blocker/Major
```
new:
```
Lenses are **different questions, not more passes** — they change what a pass asks, never how many
passes a cycle owes, which the profile alone decides. The floor, the Blocker/Major
```

> Finding M5: the old sentence continues "… is unchanged." Leaving `The floor … is unchanged` in
> the very change that makes the floor profile-dependent tells readers the opposite of what
> shipped. The rewrite says what is actually unchanged — that lenses add no passes — and lets the
> tail's list of unchanged rules stand.

- [ ] **Step 4: Re-run Step 1's check**

**Expected now: `0` and `0`.**

- [ ] **Step 5: The `pass 1` site, asserted separately**

Old, in both copies (it continues onto the next line — match the fragment, not a reconstructed
sentence):
```
the only exception, exactly as above; a Blocker/Major-free pass 1 carrying a Minor keeps
```
new:
```
the only exception, exactly as above; a Blocker/Major-free pass **below the floor** carrying a Minor keeps
```

```bash
grep -c 'a Blocker/Major-free pass \*\*below the floor\*\* carrying a Minor keeps' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -c 'Blocker/Major-free pass 1 carrying a Minor' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Expected: `1` and `1` for the first; `0` and `0` for the second.**

> This is the sentence that inverts at a floor of 1. Before the edit it tells a floor-1 cycle that
> a clean pass 1 keeps looping, which is wrong — pass 1 *is* the floor there.

- [ ] **Step 6: Confirm the historical citation was NOT touched**

```bash
grep -c "PR #23's Gate-B pass 3 returned all four findings" \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Expected: `1` and `1`.** It cites an actual pass, not a rule; changing it would falsify a record.

- [ ] **Step 7: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics Plan A — floor predicate and severity test"
```

**Never `--no-edit`.** See the commit protocol above: the hook greps this command string for
`-m ... wip`, and an amend without `-m` resets the cycle.

---

## Task 4: The pass report (§2.2)

**Files:** `CLAUDE.md:133`, `plugins/dev-workflow/commands/workflow-init.md:330`

Finding B3: the old plan added every-pass fields to the floor paragraph while leaving the
pass-report paragraph prescribing only the pass-4 three lines, so the shipped prompt would have
described the report shape in two places that disagreed.

- [ ] **Step 1: Preflight**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"; tr '\n' ' ' < "$f" | tr -s ' ' | grep -c 'the cited stories they were read from'
done
```

**Expected at this point in the sequence: `0` and `0`.**

- [ ] **Step 2: Read the paragraph being extended**

```bash
sed -n '133,140p' CLAUDE.md
sed -n '330,337p' plugins/dev-workflow/commands/workflow-init.md
```

- [ ] **Step 3: Insert §2.2's fields immediately BEFORE that paragraph**

Anchor, pasted from `grep -n`:
```
CLAUDE.md:133:**From pass 4 onward every pass report carries three lines.** The carrier is **your own
plugins/dev-workflow/commands/workflow-init.md:330:**From pass 4 onward every pass report carries three lines.** The carrier is **your own
```

Insert before it, in both copies:

```markdown
**Every pass report states three things about the floor**, from pass 1 onward: the **derived
floor**, the **risk and security values read**, and the **cited stories they were read from**. A
report giving the number alone leaves a reader unable to check the derivation while passes are
still being spent — which is the only time checking it is cheap. This is owed by every pass; the
three lines below are owed from pass 4 and are a different obligation.
```

**The existing paragraph is not modified** — its seven requirements (a-g in accounting row 4) all
stand verbatim, and the inserted text says explicitly that the two obligations are distinct so no
reader merges them.

- [ ] **Step 4: Re-run Step 1's check, and confirm the old paragraph is intact**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"; tr '\n' ' ' < "$f" | tr -s ' ' | grep -c 'the cited stories they were read from'
done
grep -c 'From pass 4 onward every pass report carries three lines' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -c 'require↔withdraw pair' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Expected: `1`/`1`, then `1`/`1`, then `1`/`1`.**

- [ ] **Step 5: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics Plan A — floor predicate and severity test"
```

---

## Task 5: A profile or cited set that moves mid-cycle (§2.4)

**Files:** `CLAUDE.md:480`, `plugins/dev-workflow/commands/workflow-init.md:659`

Finding B6. §2.4 composes three existing rules and adds no new one, but none of the composition is
currently written down, so a mid-cycle profile or set edit can silently reuse an old clean pass.

- [ ] **Step 1: Preflight**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"; tr '\n' ' ' < "$f" | tr -s ' ' | grep -c 'Any profile change costs at least one further pass'
done
```

**Expected at this point in the sequence: `0` and `0`.**

- [ ] **Step 2: Read the nine conditions being preserved**

```bash
sed -n '480,493p' CLAUDE.md
```

All nine are accounting row 9 (a-i). **They are kept verbatim.** §2.4's rules are **appended after
them**, never merged into them — merging is how a rewrite drops a condition, which `AGENTS.md`
names as this repo's tenth-recorded instance.

- [ ] **Step 3: Append after the `Changing a profile:` paragraph, both copies**

```markdown
**While a gate is running, the floor derives from the *current* profile at each pass.** Passes
already run keep counting; closing requires the floor **as currently derived**. These are
pass-count rules, so they apply while §5 says a gate is running and are silent otherwise — what §5
says about *when* a gate runs is §5's, unchanged and deliberately not summarised here.

**Any profile change costs at least one further pass**, in either direction and **whether or not
the floor number moves**, because the final clean pass must run under the current profile — so no
already-banked pass can be it. That further pass must itself be clean and every other closure duty
must be satisfied; it is one more pass, not a licence to close on the next one. **What a lowering
drops is whatever the changed values drop, not a fixed pair**: a mode-only override changes the
evidence obligations while leaving the axis-derived lens sets alone, and security `high` →
`standard` keeps the security lens set while changing what evidence is owed. **Every derived
obligation is recomputed from the current profile.**

**The cited set is re-read at each pass, and the final clean pass runs against the current set —
whenever its membership changes, not only when the floor number moves.** Adding a high-risk story
to a set already at floor 3 leaves the number alone while adding that story's lens set, its
evidence obligations and its review scope; a pass run before it joined did not cover them.
**Removing a story** recomputes obligations from the current set and so does remove *that story's*
lenses and evidence duty — but it **never discharges an accepted in-set Blocker or Major**: the
acceptance put that finding in the fix set, not the citation.
```

- [ ] **Step 4: Re-run Step 1's check, and confirm all nine survived**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"; tr '\n' ' ' < "$f" | tr -s ' ' | grep -c 'Any profile change costs at least one further pass'
done
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"
  tr '\n' ' ' < "$f" | tr -s ' ' | grep -o 'proposes the complete resulting header\|human confirms it\|never moves it alone\|append one profile-log line\|voids every prior override\|follows the current security value\|keep counting\|final clean pass\|fold the edit into the active' | wc -l
done
```

**Expected: `1`/`1` for the first; the second must report the same number for both copies and that
number must not fall below its pre-edit value — capture that value in Step 1 before editing.**

- [ ] **Step 5: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics Plan A — floor predicate and severity test"
```

---

## Task 6: Severity semantics (§3), and activation (§10, partial)

**Files:** `CLAUDE.md:495`, `plugins/dev-workflow/commands/workflow-init.md:674`

- [ ] **Step 1: Preflight**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"; tr '\n' ' ' < "$f" | tr -s ' ' | grep -c 'what in the system consumes this text'
done
```

**Expected at this point in the sequence: `0` and `0`.**

- [ ] **Step 2: Append the test after the four definitions, both copies**

Anchor, pasted from `grep -n`:
```
CLAUDE.md:495:- **Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw →
plugins/dev-workflow/commands/workflow-init.md:674:- **Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw →
```

The four definitions stay verbatim. Append:

```markdown
  **Deciding severity — one procedure. The subject list is illustration, not a second rule.**
  Name **what in the system consumes this text** — whatever *acts* on it — and the decision that
  act takes differently if the text is wrong. **Both are required. If you cannot name both**, the
  finding is **Minor or below**: collect, never iterate.

  The exclusions are contract, not commentary. **The reader must consume the text in the system's
  *operation*, not in reviewing it** — the review pass raising the finding is not an in-system
  reader of the text it reviews; without this the test demotes nothing. **Gates remain legitimate
  readers** of rule text they will later apply. **A human reader never satisfies the test** — §5's
  prose exemption already prices that cost as non-gating. **The list of reader kinds is
  illustrative, not closed**, because this ships into projects whose readers we have never seen.
  **The test sets a ceiling, not a floor, and never chooses between Blocker and Major** — the four
  definitions above still decide that. **The instrument carve-out is symmetric**: an instrument
  finding keeps its severity whenever it shows the instrument changes what a gate concludes about
  product behaviour — a false green, and equally a false red or a check blocking a valid change.
  **Rationale prose is Minor only when no rule's application depends on it**, not categorically:
  `docs/prompt-standards.md` requires rules to carry their why, so rationale a reader must consult
  to apply a rule passes the test. **This removes arbitrariness, not judgement.** Coverage-first is
  unchanged — the reviewer reports every finding with severity and confidence; the filter is ours.

  This is the **finding-level analog of the path-level prose exemption**: one principle at two
  granularities — text that *describes* the product versus text that *is* the product.
```

- [ ] **Step 3: Append the activation block after Task 2's gate-off disclosure, both copies**

Finding B7. **Plan A ships the two parts Plan A ships. Plan B extends this list** to the
provenance-line, curve and nonce duties — §10 says extending is safe and replacing is not, so Plan
B appends to this list rather than rewriting it.

```markdown
**When these rules bind.** From the commit that ships them, and **a cycle already running finishes
under the rules it started with**. **Where a cycle's starting rules cannot be established it takes
the stricter reading of every part this change touches** — floor 3, and severity classified without
the demotion. Not a re-derivation, which could hand a level-0 cycle a floor of 1 and *skip* passes
on the strength of not knowing when it started. A user knob set above 3 is not lowered by this
fallback. **A revert is itself a shipping commit for the old rules**, and the activation rule wins
wherever the start is determinable; the fallback covers only where it is not.

**Downstream has no shipping commit.** Adoption binds from the `/workflow-init` run that *actually
writes* the text — which may write nothing, be declined, or be merged in part — so **these rules
bind only over the text a project's `CLAUDE.md` actually contains**, and a partial adoption can
persist undetected. A project taking the floor rule without the severity test gets a floor whose
`docs-only` question the severity test is what settles. What prompt text can do is done; what it
cannot is said.
```

- [ ] **Step 4: Re-run the checks**

```bash
for f in CLAUDE.md plugins/dev-workflow/commands/workflow-init.md; do
  printf '%s: ' "$f"; tr '\n' ' ' < "$f" | tr -s ' ' | grep -c 'what in the system consumes this text'
done
grep -c 'a cycle already running finishes' CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
grep -cF '**Severity:** Blocker (wrong/unsafe/breaks invariant)' \
  CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
```

**Expected: `1`/`1`, `1`/`1`, `1`/`1`.**

- [ ] **Step 5: Amend the WIP commit**

```bash
git add CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git commit --amend -m "WIP: review-loop economics Plan A — floor predicate and severity test"
```

---

## Task 7: Parity and the twelve-item conformance pass

No new rules. This is the verification invariant 11 requires. Finding M7: the results have a
defined schema, so an executor cannot discharge them with an unauditable paragraph.

- [ ] **Step 1: The parity table — one row per changed rule**

Columns: *rule* · *`CLAUDE.md` text* · *template text* · **status** from the closed set
`IDENTICAL` | `DELIBERATE-DIFFERENCE` | `DEFECT` · *reason, required for the latter two*.
One row for each rule added or changed by Tasks 2-6.

```bash
C=CLAUDE.md; T=plugins/dev-workflow/commands/workflow-init.md
for p in 'derived from the cited story'"'"'s profile' 'reminder threshold' 'Named residual' \
         'routes known today' 'states three things about the floor' \
         'Any profile change costs at least one further pass' \
         'what in the system consumes this text' 'a cycle already running finishes'; do
  a=$(grep -cF "$p" "$C"); b=$(grep -cF "$p" "$T")
  [ "$a" = "$b" ] && printf 'PARITY %s : %s\n' "$a" "$p" || printf 'MISMATCH %s/%s : %s\n' "$a" "$b" "$p"
done
```

**Expected: eight `PARITY 1` lines, no `MISMATCH`.**

A whole-section diff proves nothing here — the two copies already diverge on roughly 192 lines
overall for reasons predating this change. Walk the named rules.

- [ ] **Step 2: The twelve-item table — one status row per item per artifact**

Artifacts: the **resulting scaffolded template**, and
`plugins/dev-workflow/commands/workflow-init.md` as the outer command prompt. Columns: *item* ·
*artifact* · **status** from `PASS` | `N/A` | `FAIL` · *reason, required for `N/A` and `FAIL`*.
**Item 7 is read against the whole resulting artifact**, not the diff.

**Root `CLAUDE.md` is outside invariant 11's list and is not part of this pass.**

> **Item 1 for the scaffolded template is `N/A`, and Plan C ships the note that says why** — the
> file the template writes is model-agnostic by design, so a `Target model:` line inside it would
> be false in every repo it lands in. Plan A records the `N/A` here; Plan C writes the reader-facing
> note outside the fence, where it cannot scaffold and cannot become a second `Target model:`
> declaration.

- [ ] **Step 3: Prove no passage outside the ten was touched**

```bash
git diff --stat HEAD~1 -- CLAUDE.md plugins/dev-workflow/commands/workflow-init.md
git diff HEAD~1 -- CLAUDE.md | grep -c '^[+-][^+-]'
```

Read the diff and confirm every hunk falls inside one of the ten accounted passages. **A hunk
outside them is a finding**, not something to wave through.

- [ ] **Step 4: Invariant checks still pass**

```bash
grep -c '^Target model:' plugins/dev-workflow/commands/workflow-init.md
sh scripts/check-invariants.sh && echo INVARIANTS-OK
```

**Expected: `1`, then `INVARIANTS-OK`.** The count must be 1 — `scripts/check-invariants.sh` fails
on any other, and a naive item-1 fix that adds a second declaration is exactly how that breaks.

- [ ] **Step 5: Fold the results into the WIP commit**

Write both tables into the conditions file from Task 1, then:

```bash
git add docs/superpowers/specs/2026-08-29-review-loop-economics-plan-a-conditions.md
git commit --amend -m "WIP: review-loop economics Plan A — floor predicate and severity test"
```

**Not a separate commit.** An ordinary commit here — even one staging only a `docs/**.md` path —
resets the cycle and strands the WIP, because the hook's reset is keyed on the commit, not on the
staged paths.

---

## Task 8: Gate B, and closing the cycle

- [ ] **Step 1: The battery**

The whole `AGENTS.md` § Commands chain, exit 0, assertion counts recorded.

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
sh scripts/check-version-bump.test.sh && sh scripts/check-version-bump.sh main && \
claude plugin validate . --strict && echo BATTERY-GREEN
```

- [ ] **Step 2: The differential check — both revisions read**

The mode is `battery+check+verification`; **read it from the story header, not from here.** This
step is the check that fails without the change, and it is differential by construction: a check
consulting only the post-change text cannot fail.

One question, answered against **both** revisions:

> *At a derived floor of 1, does a Blocker/Major-free pass 1 carrying a Minor close, or keep
> looping?*

```bash
git show HEAD~1:CLAUDE.md | grep -n 'carrying a Minor keeps'   # pre-change
grep -n 'carrying a Minor keeps' CLAUDE.md                     # post-change
```

- **Pre-change** says `pass 1 ... keeps looping` — **wrong at floor 1**, where pass 1 is the floor.
- **Post-change** says `pass **below the floor** ... keeps looping` — correct.

Ask the same of `below 3` versus `below the floor`. **Record which revision produced which
answer.** The observation that would exist if the claim were false is a pre-change revision that
already answers correctly — and it does not.

- [ ] **Step 3: The named risk-path verification**

Recompute the floor this cycle owes from the cited story's profile header, and confirm the pass
reports state it with the axes and the source story. **The observation that would exist if the
claim were false is a pass report whose floor the cited profile does not license.**

Then confirm no floor file appeared:

```bash
test -e .context/codex-gate.floor && echo "PRESENT — was it present at start?" || echo "ABSENT"
```

**This detects a persisting write and cannot detect a transient one** — stated, not glossed.

- [ ] **Step 4: The review loop**

`mcp__codex__review` against the WIP commit, `baseSha` = its parent. Findings to
`.context/codex-reviews/gate-b-<spec|quality>-plana-pass-<p>.md`; **delete both branch targets and
confirm them gone before each call.**

Floor: derived from the story profile — read the header. Carry into every call: the story path,
and the current evidence entry quoted verbatim.

**After every accepted fix:**

```bash
git add -u
git commit --amend -m "WIP: review-loop economics Plan A — floor predicate and severity test"
```

**then** re-review that new commit against the same base. Finding B18: `mcp__codex__review` reads
the committed range, so a re-review run over uncommitted fixes inspects the old snapshot and can
return a clean pass on content that is not what closes.

- [ ] **Step 5: Build the closing body, then close**

Finding B20: no placeholder reaches the amend. Build the body as a file first, read it back, and
only then amend.

```bash
cat > /tmp/plan-a-close.txt <<'EOF'
feat(gates): derive the pass floor from the story profile; decide severity by consequence

<one paragraph: what parts 1 and 2 change, in both copies>

Evidence (docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md):
  battery: <the recorded result>
  check: the floor-1 Minor sentence, read against both revisions — pre-change says pass 1
    keeps looping, which is wrong at floor 1; post-change says below the floor.
  verification: <the named risk-path verification and its observation>
EOF
cat /tmp/plan-a-close.txt   # read it back — no angle-bracket placeholder may survive
grep -c '<' /tmp/plan-a-close.txt
```

**Expected: `0`.** A non-zero count means a placeholder is still in the body — fix it before
amending.

```bash
git commit --amend -F /tmp/plan-a-close.txt
```

**This is the first message without `WIP:`**, and the hook reads it as the cycle closing.

> Plan A's closing body carries the evidence entry. **The provenance line and the per-pass curve
> are Plan B's forms and are not owed by this commit** — they do not exist yet. Plan C's closing
> body carries them for the branch.

---

## Self-Review

**Spec coverage.** §2 predicate, unanimity, unresolvable-stop, one-value-three-cycles → Task 2
Step 3. §2.1 precedence, knob, residual → Task 2 Steps 3-4. §2.2 pass report → Task 4. §2.4
mid-cycle → Task 5. §3 severity → Task 6 Step 2. §10 activation, revert, downstream adoption,
gate-off surface → Task 2 Step 4 and Task 6 Step 3, **partial by design**: the three record duties
in §10's strict-fallback list are Plan B's to append. §2.3, §4, §5, §6 → Plan B. §7, §8 → Plan C.

**Placeholders.** None. Every anchor is pasted `grep -n` output with no editorial token inside any
pasted block; every replacement is complete text with no ellipsis; every check states its expected
value **for its point in the sequence**; the one templated artifact — the closing commit body — is
built as a file and asserted placeholder-free before it is used.

**Type consistency.** `max(risk, security)`, "derived floor", "reminder threshold", "cited set" and
"level 0" are used identically in Tasks 2, 3, 4, 5 and 8, and match the spec's spellings.

**Gate-B classification, per path.** Task 1 stages one `docs/superpowers/**.md` path → **N/A**,
ordinary commit, cycle not yet open. Tasks 2-7 stage prompts → **one full Gate-B cycle**, opened at
Task 2 Step 7 and closed at Task 8 Step 5, with every intermediate commit an amend restating
`-m "WIP: ..."`. No ordinary commit occurs between those two points.

**Known limit.** The replacement wordings are proposals, not transcriptions — the spec pins the
rules, not the sentences — and this plan's Gate A is what reviews them. Where a wording restates a
spec rule the spec pinned as *required properties*, it is quoted rather than paraphrased.
