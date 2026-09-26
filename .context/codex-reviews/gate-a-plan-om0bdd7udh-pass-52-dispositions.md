# Pass 52 dispositions — Gate-A plan cycle `om0bdd7udh`

Advisory companion per CLAUDE.md §5. Not the findings file; not part of pass validation.

**Snapshot.** `HEAD` `5fb3b942f1907f5d6dd25b32d15b497f855e05f8`, branch `loop-rule-consolidation`,
plan worktree blob `15a9b1c2ff4beb3c6dfa6ae21e00550210d4b969` — **identical before and after the
call**. Nothing staged. Tool: `mcp__codex__exec`, session `01a0b0ac-5d48-75d1-86b8-e196edda1f40`.

**Pass VALID.** Terminator `END OF FINDINGS (4 total)` exact; 4 body lines; every line a finding
line; 6 fields each; no blanks; count matches. File
`.context/codex-reviews/gate-a-plan-om0bdd7udh-pass-52.md`, untracked.

**Floor 3**, derived from `docs/superpowers/stories/2026-08-29-loop-rule-consolidation-story.md`
read fresh at this pass: **Risk `high`** (level 2) · **Security `none`** (0) · max 2 ≠ 0 → 3. One
cited story, from the plan's `**Story:**` header, which parses. Profile resolves; the profile log
holds one `adoption` entry, no override and no axis change. Floor long satisfied; what is missing is
a **clean** pass.

**Method change, declared.** Pass 52's instruction was delivered by pointing Codex at
`.context/gate-a-plan-pass-52-instruction.md` (1006 lines) rather than inlining it in the tool
argument. The reason is fidelity: reproducing 100 KB verbatim into a parameter risks silent drift,
while the file on disk is exact. The findings-protocol contract was restated inline so it could not
be missed. **Whether Codex read the file in full is not established** — the reply and the findings
are consistent with having done so, and that is evidence rather than proof.

## Findings

### 1 — BLOCKER, Task 15 step 4b candidate capture. **CONFIRMED.**

Verified in the text. The commit block is plan lines **2954–2967**: it pins `ITREE=$(git
write-tree)`, commits, then checks `test "$(git rev-parse "HEAD^{tree}")" = "$ITREE"` — one live
`HEAD` read. The capture is a **separate** block, plan lines **2987–2993**, whose whole body is
`git rev-parse HEAD > .context/loop-rule-reviewed-head` — a **second, independent** live `HEAD`
resolution. The plan states the binding rule against itself at line **3027**: "each fenced block
below runs in its own shell invocation". So the tree check authenticates one object and the capture
records whatever `HEAD` names at a later invocation, with nothing tying them.

The capture block's own comment reads "Resolve it ONCE; every consumer below reads this file." That
is true of the consumers **below** it and false of the binding **above** it, which is the half the
finding attacks.

**This is regeneration, not discovery in unswept ground.** It is the resolve-once class of passes
47–49, reintroduced by the twenty-second revision's own new capture block — the third time in this
cycle that new machinery has brought back a class the cycle had already swept.

**Payer:** `workflow-init.md`, `codex-gate.sh` and `codex-gate.test.sh` ship inside the plugin
package, so a substituted candidate can put content into shipped files that never received the
pre-candidate checks. Not the executor alone.

**In the assigned fix set.** It corrects the correction the last two revisions made, inside the same
candidate-identity machinery. Absorbable by the loop — **not repaired here**, because this
assignment stops before repairs.

### 2 — BLOCKER, steps 4b–4 and step 6, battery bound to the worktree. **CONFIRMED AS FACT; OPENS A NEW STRUCTURAL QUESTION.**

The fact is not in dispute and the plan **states it itself**, at lines 2977–2985: step 4 runs over
"the **working tree of the current repository**"; it "describes this candidate only because it runs
immediately after this capture with no commit in between"; and "**Nothing enforces that the worktree
stays unmodified in that window** — step 6 checks that `HEAD` has not moved, which catches a commit
and not a dirty tree. Stated as a limit rather than guarded."

So Codex reports a real gap the plan discloses. **Disclosure does not discharge it** — the twentieth
revision settled that in this cycle ("an accepted Blocker is not discharged by disclosing it"), and
the consequence reaches shipped files for the same reason as finding 1.

**But the fix it proposes is a new mechanism**, not a repair of an existing one: run the battery in
a detached disposable checkout of the recorded candidate, or establish and re-check that index and
tracked worktree equal the candidate on both sides of the battery. That is a second checking
apparatus with its own preconditions and its own failure modes. This cycle has declined such
additions before on the "new precondition" ground (pass 44's three escalations, finding 3 of pass
49) **and has also ruled the opposite way** — the twentieth and twenty-first revisions established
that "a different checking mechanism is not by itself a new requirement", which is what put step 4c
into the plan at all. **Both rulings are live and they point opposite ways here.**

**That is a contract question, and §5 sends it to the user rather than letting the loop absorb it.**
Novelty of the question decides, not size. **This is the blocking decision.**

### 3 — MINOR, Task 0 step 3 baseline site coverage. **CONFIRMED IN KIND; THE NAMED SITES UNVERIFIED. COLLECTED.**

Confirmed in kind: step 3's body promises "Diff every **inventoried and changed** site" (line 1220),
but the artifact's schema says "one `site` record per **inventoried** site" (line 1247), the
completeness predicate says "**every inventoried site** has a `site` record" (line 686), and the
step's own heading is "the **inventoried** ranges" (line 1218). The words "and changed" have no
carrier anywhere — three statements of the rule say "inventoried" and one says more. That is the
same shape as the already-collected "locator steps stating a result for both copies while naming
one".

**Not verified:** that §G and §F item 18's work-loop line are in fact outside the nine anchor pairs
in the `SITES` heredoc. Establishing that needs the design's §4 destination-block set cross-read
against those anchors, which this pass did not do.

**Minor → collect, never iterate** (§5 Mechanics). Recorded, not repaired.

### 4 — NIT, step 4b commit subject. **CONFIRMED BY DIRECT READ. COLLECTED.**

Verified independently before reading the finding. The block's comment at plan line ~2957 reads
`# Where a repair was made, the message is: "WIP: prompt-standards repair + plan records"`, and the
only command in the block is `git commit -m "WIP: plan records"` — unconditional. The prose promises
a distinction the block cannot make.

**Nit → collect, never iterate.** Recorded, not repaired.

## Mechanical prechecks, run on this blob before the call

New observations this session, not a restatement of earlier reports. They used a different extractor
from the plan's own reported baseline and **are not comparable to it**.

- **60 fenced blocks, all balanced, none unclosed** — extractor matches indented fences, since one
  blind to them already produced a wrong count in this cycle. 57 carry `bash`, 1 `python`, 2 none.
- **`sh -n` fails on 8 extracted blocks, `dash -n` on 9.** Every one is in an intended class: five
  are `<…>` operator placeholders (`base<TAB><…>`, `NONCE=<…>`, `git add … <the repaired files, if
  any>`, the record-shape schema), four are `diff <(…)` process substitution inside `bash`-marked
  fences, which `dash` cannot parse by design. **No new syntax regression.**
- **Every repo path the plan cites resolves.** The only non-resolving strings are bare basenames used
  as shorthand in prose, two fixture filenames from the version-bump reproduction table, and
  run-time state files.
- `.context/loop-rule-baseline-diff` is written `.tmp` and atomically `mv`-ed to `.txt` — one file,
  not an inconsistency.

## Loop health at pass 52

Findings 42–52: **3, 5, 9, 2, 1, 2, 3, 6, 4, 6, 4**. Blockers: **2, 2, 2, 1, 1, 1, 3, 5, 2, 2, 2**.
Majors: **1, 2, 7, 1, 0, 1, 0, 1, 1, 2, 0**.

**Tells present — at least two, so stop-and-surface is mandatory, not discretionary.**

1. Finding count rising — **NOT present**; 6 → 4, falling.
2. Blocker count failing to fall — **PRESENT**; flat at 2 for the third consecutive pass.
3. Instrument cluster — **PRESENT**, and total: all four findings are the plan's own execution
   machinery. **Zero** touch the §5 target text this change installs.
4. Prose cluster — **partially present**, and reported rather than resolved: findings 3 and 4 are
   both prose promising what the command beside it does not do, which is two of four. Whether that
   counts as a cluster in its own right or as a subset of the instrument cluster is a judgement; it
   changes nothing, since 2 and 3 alone already make the stop mandatory.
5. require↔withdraw pair — **NOT present**. Pass 51 asked for the candidate to be captured once and
   persisted; the twenty-second revision did that; pass 52 asks for it to be **bound** to the commit
   just made. A sharpening, not a demand for something an earlier pass removed.

**The "clearly stuck" exit is NOT available.** Of three conjuncts: no plateau of six or more passes —
the Blocker curve over the last six is 1, 3, 5, 2, 2, 2, flat only for three; **no affirmative
coverage judgement is possible** — finding 1 is a defect the twenty-second revision itself created,
which is direct evidence that the new machinery is unswept; regeneration **is** present, which is one
conjunct of three, and one is not the exit.

**Nothing here closes the cycle**, and a clean pass would not close it alone: closure needs the clean
pass **plus** every other duty §5 names.
