# Gate-B 0.8.0 — triage of the ten open Blocker/Major, into exactly two bins

Cycle-level record. Supersedes the pass-1-only companion; it is cycle-qualified because
the conventional `<slot>-dispositions.md` name is occupied by the 26 Jul cycle.

Rule applied: **fix now everything cheap and in-diff; disposition formally only what has a
named home outside this PR** — a `todos.md` row with a trigger, or a follow-up story. One
line each.

---

## BIN 1 — FIXED IN THIS DIFF (7)

| # | Finding | What was done |
|---|---|---|
| 1 | **P9-12 · unroutable flush + unescaped event** (SPEC-2, QUALITY-4) | **A correctness bug in this diff, not an inheritance.** Reproduced: with a pending disclosure, an event named `Bogus\` emitted `"hookEventName":"Bogus\","` — the backslash escapes the closing quote and Claude Code receives **invalid JSON**. Two new defects combined: `flush_notes` ran unconditionally so an unroutable event reached `emit`, and `$event` was interpolated raw beside two escaped fields. Both fixed; 5-row oracle in both runners, written first, failed first. |
| 2 | **QUALITY-7 · composed order contradicts spec §6** | Spec §6 is explicit — *"disclosure first, then the per-occurrence message"* — and the code appended the disclosure instead, with the golden freezing the inversion. Added `note_front`; goldens updated. The implementation drifted, so the implementation moved. |
| 3 | **QUALITY-1 (residual) · anchor-prefixed near miss** | The pass-1 fix guarded `${b%%\n*}` on the anchor prefix, which left it running in full for a block that *does* start with the anchor — 5.9 s at 150 KB, 23.1 s at 300 KB. Head now bounded to 4096 chars. Two oracle rows (both `\n` placements), written first, failed first. One stated limit: a ~4070+ character tool name counts instead of being discarded. |
| 4 | **P9-2 / P9-4 · plan-contract drift** (SPEC-7, QUALITY-8/9) | Docs-drift class, cost sentences. A2's comma rule is now scoped to the walked prefix, naming the trailing-comma-after-selected-element as never seen rather than refused; A3 now says **four** whitespace sites, naming `_token_ends` as the fourth. |
| 5 | **QUALITY-11 / SPEC-9 · unknown-tool role split** | A prompt fix inside a PR that already reviews prompts. `additionalContext` now carries only model-owned next steps (report it, treat passes as uncounted); install / `.mcp.json` / mapping / namespace all moved to `systemMessage`, per spec §6's field split. Goldens updated. |
| 6 | **SPEC-9 / QUALITY-3 · rollback hard stop** | Recorded as an explicit **amendment to plan Step 5**, not left as commit prose. Names what was established (cache is version-keyed, `installed_plugins.json` selects, 0.7.1 bytes match the resolved commit), what was not (no switch executed after activating 0.8.0), why executing it is the wrong trade here (mutates a shared plugin environment; 0.7.1 is already active), and reinstates the hard stop for any later release shipping with 0.8.0 active. |
| 7 | **P9-6 · escaped `type` value** (SPEC-1, QUALITY-3) | Resolved the way Gate A's own disposition allowed — *state it, add a fixture*. Boundary now stated in spec §3.1 as a known gap in that section's own contract, pinned by a characterization row asserting `no-result`, and carried in `todos.md` with a trigger. Fail-closed, so a real result is discarded rather than miscounted; still a wrong verdict on a legal payload, and the spec says so. |

## BIN 2 — DISPOSITIONED, each with a named home (4)

| # | Finding | Home |
|---|---|---|
| 8 | **QUALITY-2 / SPEC-11 · `skipval` walks containers character-by-character** — 3.2 s at 200 KB, 11.5 s at 400 KB; only the 1 Mi-unit ceiling stops it | `todos.md` → *"Locator: `skipval` walks containers one character at a time"*. Trigger: a slow-hook report, or any change raising the ceiling. Three candidate fixes, all design calls — a patch would be picking one silently. |
| 9 | **SPEC-3 / QUALITY-5 · A5 marker matrix breadth** (single emitter pair, missing cross-family failure combinations, P9-9's named skip) | `todos.md` → *"A5 marker matrix and A6 composition coverage are narrower than the approved plan"*. Trigger: a disclosure/advice bug the current rows miss. Needs a selective `rm` shim. |
| 10 | **SPEC-4 / QUALITY-6 · A6 composition breadth** (not exact-tested against every emitting branch) | Same `todos.md` row as #9 — one row, because the two share a fixture-and-shim build-out. |
| 11 | **QUALITY-12 · `hardening-log.md:26` teaches the old mechanism** | `todos.md` → *"The hardening ledger has no supersession convention"*. The ledger's header forbids editing a row **and** limits rows to one per hardening, so there is no sanctioned in-diff move — that missing convention is the actual defect. Trigger: the next row falsified by a later change; this is the second. |

## Minors — collected, never iterated

SPEC-5, SPEC-6, QUALITY-5, QUALITY-6, QUALITY-7, QUALITY-13 … QUALITY-19. Two are worth a
line because they are honesty items rather than coverage items: QUALITY-18/19 concern the
fixture README's provenance wording (isolation, and "edited by hand … exactly seven field
values and nothing else" sitting beside a description of mechanical replacement). Neither
changes behaviour; both are candidates for the next prose pass.

## Closure rule agreed for this cycle

If pass 3's only Blocker/Major are re-raises of the four dispositions above, the cycle
closes **clean-with-dispositions**, and the closure record names each dismissed finding
with its home. Any *new* Blocker/Major: fix and continue, floor unchanged.

---

# Pass 3 — VALID, and it was not clean: seven NEW Blocker/Major

Both branch files valid (spec 15, quality 15; terminators present, counts matched, no extra
lines, distinct branch-appropriate content). **The reply carried a spurious extra line** —
the quality branch reported `gate-b-spec | pass 3 | 16 findings` alongside its own — which
is the write-race shape §5 warns about. Checked rather than assumed: the two files are not
identical, each holds findings of its own branch's flavour, and the spec file's mtime is the
later of the two. Treated as a mis-report, not a race; the pass stands.

Per the closure rule, the four dispositions were re-raised as expected and cost nothing. But
pass 3 also raised **seven new Blocker/Major**, so the rule's second clause fired: fix and
continue, floor unchanged.

## New in pass 3 — all fixed

| Finding | Verified how | Fix |
|---|---|---|
| **Reserved-name mapping hijack** (QUALITY-1) | Reproduced: `reviewTool=Bash` made a `git commit` **count** a Gate-B pass instead of resetting the cycle; `execTool=Skill` counted a skill invocation as Gate A. Mapped cases precede the native cases, and those are the only two out-of-namespace names the matcher delivers. | Parser now requires `mcp__codex__*`; three rows, including one proving a legitimate in-namespace mapping still counts. **This diff introduced the contract it contradicted**, so it is in-scope, not inherited. |
| **Second quadratic: the record accumulator** (SPEC-1, QUALITY-3) | Reproduced: pretty-printed payloads cost 0.35 s at 4k lines, 0.75 s at 8k, 2.69 s at 16k — independent of `skipval`. | The *finding* was that plan/CHANGELOG/evidence named only `skipval`. Both paths are now named in all four places and the `todos.md` row covers both. Chunked accumulation reduces but does not remove it, and the two paths share a fix only if the scan stops indexing with `substr` — so the deferral is extended, not invented. |
| **4096 bound narrows a normative class** (SPEC-2, QUALITY-2) | The bound was documented in the plan and CHANGELOG but not in **spec §4**, which still said the anchor covers any mapped name at any length. | Stated in spec §4 with its reason and its reinstatement condition, and pinned by two rows: a genuine notice immediately inside the cutoff (→ `backgrounded`) and immediately outside (→ `unrecognized`). |
| **The plan's battery omits `HOOK_SH`** (SPEC-3, QUALITY-4) | True: `AGENTS.md` was updated at pass 2, the plan's own copy was not — so the plan still prescribed the exact run that produced the false dash claim. | Both the fenced battery and the dash bullet now set `HOOK_SH`, with the reason. |
| **A1 still describes `readstr` as an `esc`-flag loop** (SPEC-4, QUALITY-15) | Plan-internal contradiction created by the pass-1 rewrite. | A1 now states the parity rule as the contract and the anchored `match()` as the mechanism, noting the language and returned bytes are unchanged. |
| **The plan calls its ten message strings final literal text** (SPEC-5, QUALITY-5) | Six differ from the shipped strings after P9-28…37. | The plan now says it is **not** their source of truth and names which findings moved them; `codex-gate.sh` and the literal goldens are authoritative. |
| **Evidence reports 437/437** (SPEC-6, QUALITY-6) | True and stale — the suite is now **451/451, 0 failures, 1 named skip**, under both shells. The implementer claim of 449 was also wrong. | Corrected, and the base-hook counterfactual totals are now labelled as a record of that run rather than of the current row set. |

## Dismissed with reason

- **"The suite leaks an untracked repo-root file `0` containing `400000`."** Not reproducible
  and not ours: a clean-status check before and after a full run under **both** shells shows
  no change, and no such file exists. It was created by the reviewer's own ad-hoc probing
  during the pass. Worth recording because a suite that dirties the checkout would move the
  Gate-B fingerprint (invariant 3) — so this was checked rather than waved off.

---

# The bounded sweep (2026-08-03) — three claims, full inventory, one home each

Authorized after pass 6 widened instead of narrowing. The diagnosis was that three *claims*
were restated across many artifacts and each pass reached a copy the last had not. The fix
is inventory-first, all sites together, one normative home with pointers — not another pass.

## Claim 1 — the namespace boundary

**Normative home:** the design's **decision 1** (`…failed-codex-call-counts-as-a-pass-design.md`),
now carrying the sentence *"This paragraph is the single normative statement of the namespace
boundary; every other mention points here rather than restating it."*

| Site | State before the sweep |
|---|---|
| design, decision 1 | correct, but ended in a broken fragment `…), and always could not.` left by the pass-4 edit — **repaired, and made the home** |
| plan, Task 6 Step 4 insertion (×2) | corrected at pass 5 |
| `workflow-init.md` cause-2 remedy | *"the hook never fires on them at all"* — **fixed** |
| `workflow-init.md` preflight sample output | *"where the hook never fires"* — **fixed** |
| `workflow-init.md` inline `CLAUDE.md` template | correct; **gained a pointer** to decision 1 |
| `codex-gate.sh` parser comments (×2) | *"a tool that never fires"* — **fixed** |
| `codex-gate.sh` namespace guard comment | correct (pass 3) |
| unknown-tool `systemMessage` + its golden | correct (pass 4) |
| `README.md`, `CHANGELOG.md` | correct (pass 4) |
| `hooks.json` matcher, suite comments | statements of fact, not the claim |

The claim is precise only when it says **both** halves: outside `mcp__codex__*` a name is
either never delivered, **or** — for the reserved `Bash`/`Skill` the matcher does deliver —
hijacks that lifecycle event. The parser refuses both.

## Claim 2 — the trust boundary for third-party tools

**Normative home:** the design's §3.1 *"Why fail-closed is right here"* paragraph.

| Site | State before the sweep |
|---|---|
| design §3.1 rationale | *"a **mapped** third-party tool may legitimately return…"* — **fixed** |
| design, decision text | same wording — **fixed** |
| design §6 `no-result` diagnosis | mapped-only — **fixed**, now names both routes |
| design §6 `unrecognized` cause list | mapped-only — **fixed** |
| `UNVERIFIED_MSG` in hook **and** its golden | *".context/codex-gate.tools names it, and unmapping it removes the gate"* — **fixed**: the file names it *only if mapped*, and a server registered under the default `codex` name reaches the gates with no mapping |
| `NORESULT_CTX`/`MSG` | corrected at P9-33 |
| story `no-result` criterion | corrected at pass 5 |

The precise form: a third-party tool reaches the gates **either** through a mapping **or**
as a server registered under the default `codex` name, so an absent mapping does not rule
it out — which is exactly what decision 1's own remedy creates.

## Claim 3 — when a pending disclosure is flushed

**Normative home:** the design's §5.2 state-transition table.

| Site | State before the sweep |
|---|---|
| design §5.2 transition table | *"pending \| any unsuppressed hook event"* — **fixed** to *routed* hook event |
| design §5.2 rationale | *"an unrelated later event has nothing to flush"* — **fixed** |
| design §6 composition | *"would collide again on the next event"* — **fixed** |
| plan A5 marker table | *"present \| present \| any event"* — **fixed** |
| `codex-gate.sh` routing gate comment | already correct (the P9-12 fix) |

The P9-12 fix was right; only its restatements lagged. Since that fix, `flush_notes` runs
**only for a routed event** — an unroutable payload preserves the debt for a later routed one.

## Also in this sweep

- **Malformed-routing narrowed** in the design. It said such a payload "cannot route"; that
  holds **with** `jq`, and **without** it the `grep` fallback can read a tool name out of a
  document malformed elsewhere, so the same payload routes and classifies — normally landing
  in `unrecognized`, counted and disclosed. The divergence is `field()`'s and predates this
  change; the plan already said so and the design now does too.
- **The seeded-state TIMEOUT rows are restored**, not re-dispositioned. `timeout` (the
  captured `shape2-executor-timeout` envelope) now runs the same seeded matrix as the other
  discarded classes — 16 rows across both gates, both name sources, both runners. The plan
  required a seeded timeout preservation row; a classification-only row had been substituted
  without a kept/moved/dropped disposition, which is an AGENTS.md Don't.

Suite: **451 → 467** assertions, 0 failures, 1 named skip, under both shells.

---

# CLOSURE — clean-with-dispositions (Gate-B pass 9, 2026-08-03)

**Nine passes. Pass 9 returned ZERO Bucket C — nothing new — on both branches.**

- **Spec branch: 4 findings, all Bucket A.** Dispositions-only, which is the pinned exit.
- **Quality branch: 22 findings — 4 Bucket A, 1 Bucket B, 0 Bucket C.** The Bucket B was a
  one-clause over-generalization in the namespace home ("the plan points here rather than
  restating it") — Task 6 necessarily quotes the literal text it authors for a shipped
  surface. Narrowed after the pass; **docs-only, no behaviour, prompt, or test touched.**
  Recorded rather than glossed: it was not re-reviewed.

Both branches independently reproduced the evidence rather than reading it: **467 passes,
0 failures, 1 named skip under `sh` AND under `dash` separately**, invariants 123/123,
version-bump 36/36 against BASE, strict plugin validation — all from their own checkout.

## The four dismissed findings, each with its home

| # | Finding | Home | Trigger |
|---|---|---|---|
| 1 | **Two quadratic locator paths** — `skipval` walks containers one character at a time (`substr(s,i,1)` is O(len) per call in BWK awk): 3.2 s at 200 KB, 11.5 s at 400 KB. Independently, the record accumulator `s = s $0 "\n"` rebuilds the whole input once per line: 0.35 s at 4k lines, 2.69 s at 16k. Only the 1 Mi-unit ceiling stops either. | `todos.md` → *"Locator: TWO quadratic paths — `skipval`'s container walk and the record accumulator"* | a slow-hook report, or any change that raises the ceiling |
| 2 | **A5 marker-matrix breadth** — runs through one emitter pair, omits mixed disclosure/background-advice write-failure combinations, and carries P9-9's pending-delete row as a *named* skip because one permission governs both operations on `.context/` and a directory at the pending path is not seen as pending. | `todos.md` → *"A5 marker matrix and A6 composition coverage are narrower than the approved plan"* | a disclosure or advice bug the current rows do not catch |
| 3 | **A6 composition breadth** — exact-tested for a carried disclosure with failure, a silent Bash event and one jq-free pair, not against every emitting branch. | same row as #2 — they share a fixture-and-shim build-out | as above |
| 4 | **`docs/hardening-log.md:26` teaches the pre-0.8.0 counting rule.** No sanctioned in-diff move exists: the ledger header forbids editing a row *and* permits one row per hardening. The missing supersession convention is the actual defect. | `todos.md` → *"The hardening ledger has no supersession convention"* | the next row falsified by a later change — this is the second |

## Why each is a disposition rather than a dodge

#1's three candidate fixes (jump-based walk, length-scaled work budget, lower ceiling) are
each design calls with different trade-offs; patching one silently would pick for the reader.
#2 and #3 need a selective `rm` fault shim and per-branch composition goldens — a coverage
build-out, not a correction. #4 cannot be done inside this diff without breaking one of the
ledger's own two rules.

## What the cycle actually produced

Four defects that would have shipped, each found by review and each fixed with an oracle
written first: a **denial of service** (150 KB → 10.9 s, now 0.46 s, three quadratics),
**invalid emitted JSON** (`"hookEventName":"Bogus\","` from an unroutable event plus one
unescaped field), a **false ✓ configuration hijack** (`reviewTool=Bash` made a `git commit`
*count* a Gate-B pass instead of resetting the cycle), and a **spec-order inversion** frozen
by its own golden. Plus five overclaims in the release evidence, each caught and narrowed.

## awk portability — now established, on PR #21

The one gap the commit body names as outstanding is closed by the PR it points at.
CI run 30794079534 (`quality`) **passed in 1m43s** on `ubuntu`, which supplies **mawk**
where the local battery runs BWK awk, and which runs the hook suite twice — `HOOK_SH=sh`
and `HOOK_SH=dash`. So the locator's `match(/^([^"\\]|\\(.|\n))*"/)`, the bounded
`printf '%.4096s'` head and the whole 467-row matrix are now exercised against a second
awk implementation and a second shell. That is shell **and** awk-implementation coverage,
which 467/467 locally was not.

PR: https://github.com/dsnger/dev-workflow-kit/pull/21
