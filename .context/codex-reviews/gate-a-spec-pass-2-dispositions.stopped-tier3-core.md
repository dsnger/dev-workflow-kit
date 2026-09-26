# Gate A — spec — pass 2 dispositions (stripped design)

29 findings (14 BLOCKER, 13 MAJOR, 2 MINOR). **None dismissed.** Enum held an eighth time.

## The blocker count rose 4 → 14. Read it before reacting to it.

| Cycle | Blockers by pass |
|---|---|
| Three-tier | 4 → 4 → 6, stopped |
| Two-tier with debt machinery | 7 → 8 → 12, stopped |
| **Stripped** | **4 → 14** |

**Eight of the fourteen are defects in machinery pass 1 asked for and this pass is the first
to see** — the dedicated index (2), its parent binding (3), the authorization digest (4, 6),
the Gate-A continuation rule (7, 8), the merge-strategy scoping (9), the docs-only tree test
(1). The artifact grew 489 → 750 lines; every one of those blockers is in the new 261. This
is the "a fix introduces a subtler version of what it fixed" pattern the pass-2 prompt
explicitly hunted, and it found it. Ordinary, all with named fixes.

**Two are the recursive shape returning from a new direction** — 12 (the "complete pass
ledger" has no authoritative enumeration source) and 13 (dropping a story citation drops the
profile). Both are the same thing the two stopped cycles died of: making the waiver safe
wants protected state, and protecting state wants the gate. **Both are taken fail-closed
instead**, which needs no new state: ambiguity refuses the waiver. That makes tier 3 refuse
more often, which is the safe direction, and it is a real answer rather than a deferral.

**Four are the inventory and the probe** — 19, 20 (the fourth exhaustiveness claim is false
again) and 21 (the probe's positive scenario does not reach the decision point).

So: **not stuck.** No finding says the mechanism cannot exist.

## The watch item fired, and is taken by calibration — not by an override

Findings 21–26 all land on §10's prompt-differential probe: the positive scenario omits the
ordered close (21), it spends the wrong call budget (22), its `OLD` assertion is not entailed
(23), it names no runnable invocation (24), it pins no runner or model against invariant 5
(25), and — the substantive one — **three matching outputs from a probabilistic model
establish that the model emitted those tokens, not that the procedure's semantics require
them** (26).

26 is the same unverified-evidence claim in a new costume, exactly what the resume note
watched for. **It does not force the whole-mode override**, because the fix is calibration
rather than abandonment: pin the runner and model, freeze the prompt bytes, make the parse
deterministic, add a mechanical structural oracle beside the model probe, and **state the
claim as what was observed** — a pinned model's verdicts under frozen inputs — instead of as
what a compliant reader must derive. CLAUDE.md already permits a **named verification** where
no automated test is possible, and requires the counterfactual, which the frozen `OLD` blob
supplies. Calibrated that way it is honest evidence; claimed the old way it was an overclaim.

`battery+check+verification` therefore still stands in full and no override is proposed.
**If pass 3 falsifies the calibration too, that is the point to take a whole-mode override
to Daniel**, and not before.

## Blockers — all accepted

1. **Docs-only test enumerates the whole tree.** A tree is the entire repository, so the rule
   as written refuses every real Gate-A tree. **Fix:** classify the **changed paths** of the
   parent-tree → prospective-tree diff, naming additions, deletions, renames, modes and type
   changes — and name that comparison, per the gate-proof Don't.
2. **The dedicated index is never initialized.** A fresh `GIT_INDEX_FILE` starts **empty**, so
   following §3.5 literally writes a tree that deletes every tracked path not restaged. A
   data-loss path introduced by pass 1's own fix. **Fix:** `git read-tree` the expected parent
   first, then stage, then verify.
3. **Nothing binds the expected parent.** The index is isolated; `HEAD` is not. Another
   process can advance the branch between authorization and commit, and step 7 still passes
   because it compares only trees. **Fix:** expected parent inside the digest, a
   compare-and-swap check that `HEAD` still equals it immediately before commit, and both
   parent and tree verified after.
4. **Read-back checks the tree, never the message.** Everything authorization is said to bind
   — marker, decision, checklist, evidence — lives in the message. **Fix:** read the committed
   message back and compare its normalized record bytes as well as tree and parent.
6. **The authorization loop is circular.** The decision block's timestamp and reason are
   *created by* the answer, yet the digest containing them must be shown *before* it. Filling
   them afterwards changes the authorized bytes; pre-filling them records a predicted
   decision. **Fix:** split a pre-answer **request digest** from a post-answer
   **attestation** — the human returns the request digest plus their decision data, and the
   committed block binds to what was returned.
7. **No A-spec continuation.** Pass 1 defined continuation only for A-plan at
   `executing-plans`; the A-spec reminder at `writing-plans` has none, so a correctly waived
   **spec** still cannot advance — the original stall, unsolved. **Fix:** the symmetric rule.
8. **A-plan continuation never compares the plan it is about to execute.** It validates the
   blob named in the waived commit, not the current one, so a plan edited afterwards clears
   the reminder on an old authorization. Second gate-off path. **Fix:** require blob equality.
9. **Branch-head immutability makes ordinary merge impossible after a Gate-A waiver**, since
   plan and implementation commits necessarily follow it. **Fix:** scope immutability per
   gate — Gate A binds its own commit and artifact; Gate B binds the final head.
10. **`auth-failed` is locally manufacturable.** Withhold or corrupt a credential and the
    request stays canonical while the reviewer "cannot run". **Fix: the source is removed.**
    A local authentication failure is a **configuration error to repair**, never an outage.
12. **The complete pass ledger has no authoritative source.** §5 records no durable pass ids
    as passes occur, `.context/` slots are reusable and collide, and the hook counter is
    explicitly not evidence — so a lost adverse pass is indistinguishable from no pass.
    **Fix, fail-closed and state-free:** the ledger is authoritative only where it is durable
    (pass ids accumulated in the WIP body at Gate B), and **any** ambiguity — a resumed
    session without one, a slot whose provenance cannot be established, a gap in the sequence
    — **refuses the waiver**. `Passes completed: none` may only be written when the absence
    itself is established, never when it is merely observed.
13. **Dropping a story citation drops the profile.** Removing the citation immediately before
    the waiver sheds the high-risk mode, its lenses and its evidence while still satisfying
    the written three-case rule. **Fix:** bind to the **union** of story paths recorded across
    the cycle; an unexplained disappearance is an **unresolvable profile** (stop and surface),
    never `unprofiled`.
19. **The fourth exhaustiveness claim is false again.** Named omissions: Gate A's placement
    before `writing-plans` / `executing-plans`; the sweep's no-side-effects and
    do-not-run-quoted-commands limits; Gate B's explicit `AGENTS.md` check; the
    companion-deletion rule; the zero-finding early exit as a distinct clause; and the rule
    that a changed evidence entry invalidates the clean pass. **Fix:** add them, and stop
    claiming exhaustiveness in the abstract — claim the derivation and name what was checked.
20. **The standing falsification lens is silently dropped at tier 3.** Rows 52 and 53 are
    marked untouched, but a zero-pass Gate-B closure has no reviewer to ask them and the
    checklist does not include them. **Fix:** both narrowed, both questions — including the
    required repository search — added to the checklist.
21. **S1 does not reach the decision point.** It lists preconditions and an authorization but
    omits the ordered close, so a compliant reader should return `REFUSE` on `NEW` and the
    probe fails while the procedure is correct. **Fix:** a fully sequenced transcript, plus
    negative variants for each ordered-close binding.

## Majors and minors — accepted

5 (digest has no algorithm, framing or field order — specify SHA-256 over a length-delimited
serialization and record it), 11 (step 5's probe count per source), 14 (mixed
profiled/unprofiled cycles need per-story status in the marker), 15 (the item-by-item
checklist evaporates into four words and is not carried — needs a bounded record inside the
digest and through both merge strategies), 16 (the free-text
"answered-with-exception" is an unbounded route around the only compensating evidence —
**removed**), 17 (`baseSha..headSha` cannot survive the amend that creates it — target by
expected parent + authorized tree + diff digest), 18 (a revert leaves the invalid marker
discoverable — needs an explicit invalidating incident marker), 22/23/24/25/26 (the probe —
see above), 27 (escaping needs backslash-parity, reverse-order unescaping, list framing and
accept/reject vectors), 28 (`status-page` is unreachable as a recorded `Cause` — **removed**
from the enum; it survives as corroboration only), 29 (the continuation clears the reminder
**whenever** derived for that unchanged plan; "once" overstates a state-free mechanism).

**Net effect on the enum:** 10 and 28 together shrink the source enum from four values to
**two** — `quota-observed` and `attempt-failed`. Both require a canonical call; neither is
manufacturable without disabling the account itself.

## Status

Not clean; floor not met. Pass 3 next. No decision is owed to Daniel yet — the watch item is
taken by calibration, and the stuck test does not fire.
