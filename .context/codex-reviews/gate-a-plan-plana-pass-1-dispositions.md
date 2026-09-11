# Gate A — Plan A cycle — pass 1 dispositions

Advisory human note. Not a findings file; participates in no pass validation.

## Result

Artifact 3b94dbf. VALID pass: terminator exact, 21 finding lines, 0 non-finding lines.
**7 BLOCKER · 10 MAJOR · 4 MINOR = 17 Blocker/Major.**

Routed contract: each plan opens <= 12 B/M; **above ~15 routes back before pass 2**.
17 is above it. **Routed, not iterated.**

## The split worked, directionally

| | single plan (5c00f8c) | Plan A (3b94dbf) |
|---|---|---|
| findings | 33 | 21 |
| Blocker+Major | 31 | 17 |
| **Blockers** | **21** | **7** |

Blockers fell by two thirds. That is the same signal the spec cycle gave when it was
split and when it was slimmed, and it is the third time those two interventions are the
only ones that moved a curve. Scope is smaller here, so this is not like-for-like — but
the Blocker share fell from 64% of B+M to 41%, which scope alone does not explain.

## Two Blockers are consequences of the split itself

These are the routing question. Neither existed before the split and neither is a
drafting error.

- **B4 — Plan A cannot produce a green battery.** Tasks 2-7 change
  `plugins/dev-workflow/commands/workflow-init.md`; the manifest bump is Plan C's.
  `scripts/check-version-bump.sh main` therefore fails at Plan A's WIP HEAD, so the
  battery cannot go green, so the story's `battery+check+verification` evidence cannot
  be produced, so Plan A cannot close its own Gate-B cycle.
- **B5 — Plan A's findings slots are illegal under the rules in force.** Three plans
  running three Gate-B cycles need a per-cycle discriminator; I wrote
  `gate-b-<spec|quality>-plana-pass-<p>.md`. The infix slot grammar is **Plan B's
  deliverable**. Under §5 as it stands today that path is an INCOMPLETE pass, so every
  Plan-A Gate-B pass would be unusable.

Both say the same thing: **splitting the Gate-B cycle creates a bootstrap problem that
splitting the Gate-A cycles does not.** Each plan's own cycle needs infrastructure a
later plan ships.

## The other five Blockers are mine

- **B1** — I copied the profile values into the plan (`high`, three 3-pass floors,
  `battery+check+verification`) in the same document that says it never copies them.
  Predecessor finding M2, unfixed, one paragraph after promising the fix.
- **B2** — the accounting has ten passages; Task 3 Step 5 edits an eleventh
  (`pass 1 carrying a Minor`, 126/322). Task 7 Step 3 would then reject the plan's own
  required edit as an out-of-inventory hunk.
- **B3 — the sequence defect one level deeper.** I fixed the expected *values* for their
  point in the sequence and left the *line numbers* at their untouched-tree positions.
  Task 2 inserts two large blocks at 72-80, so by Task 3 the `carrying a Minor` line is
  no longer at 126/322 and Task 4's `sed -n '133,140p'` and Task 5's `sed -n '480,493p'`
  read unrelated text. Same class as last round's B8, caught at the value level and
  missed at the address level.
- **B6** — evidence not revalidated after each accepted fix nor before the closing amend,
  which §5 requires explicitly.
- **B7** — Plan A's own Gate-B cycle opens **before** the commit that ships the new
  severity rule, so by the activation rule Plan A ships, that cycle must finish under the
  **old** severity semantics. Nothing in the plan says so. Left as written, the cycle
  reviewing this change could apply the new Minor-or-below ceiling to itself and
  under-iterate on exactly the change that introduces it.

## Findings verified independently before routing

- **M1 — half confirmed, half refuted, and the confirmed half is a real defect.** My
  identity proof compares single anchor lines and concludes whole passages match.
  Checked properly with `diff`: the **pass-report passage genuinely differs** between the
  copies — line wrapping, and one substantive difference (`you report the tells` in
  `CLAUDE.md`, `report the tells` in the template). So that passage needs two accounting
  rows, not one. M1's further claim that the **Gate-A passage differs in content is
  wrong**: it is identical across all thirteen lines, as is the floor paragraph.
- **M6 — confirmed, and it is the pattern `AGENTS.md` warns about happening live.** I
  replaced a false causal claim (`which is where the 3 come from`) with another one: my
  replacement makes the hook's advisory fingerprint the *cause* of the re-review
  obligation. The actual reason a fix costs another pass is that the prior review no
  longer covers the changed artifact; the hook only compares a fingerprint at
  commit/review events. Each correction introducing a subtler version of the same claim
  is the four-round failure the Don'ts section records, reproduced in one round.
- **M13 — confirmed.** The global constraint `no hook state file is written` is
  unqualified and false as written: Gate-B calls and commit events write pass counters,
  fingerprints and disclosure markers under `.context/`. Only
  `.context/codex-gate.floor` is deliberately untouched.

## Disposition

All 17 Blocker/Major carried open to the routing decision. No fixes applied: B4 and B5
change what the plans *are*, and repairing the other fifteen against a topology that may
not survive would be work spent twice.

The four Minor are collected, not iterated: Task 7 Step 3's incomplete proof, the fixed
`/tmp` path, the unqualified hook-state claim, and the Self-Review's blanket
sequence-expected-value claim being false in two places.
