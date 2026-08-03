# Hardening round — the 0.8.0 cycle and PR #21 — Design

**Story:** `docs/superpowers/stories/2026-08-03-hardening-round-0-8-0-and-pr-21-story.md`
— the profile lives in that story's header and is read fresh at every pass. No value from
it is copied here.

**Scope:** findings 1–6 and 8 of the story. Finding 7 (the ledger's missing supersession
convention) is split out; opening its intake is a deliverable of this round (§8).

## 1. What this round is

Seven findings from the 0.8.0 cycle and PR #21, each processed through
`dev-workflow:harden-finding` with one standing precheck: **before proposing any
escalation, read the prior row's stated guard.** Outside that guard → the fitting rung, no
escalation. Inside → the mechanism was meant to catch this and did not, which is a
regression to repair.

The round also lands that precheck in the skill itself, because a rule that only exists as
a human instruction is the defect the parked row names.

## 2. Decision record

| # | Decision | Why | Rejected alternative |
|---|---|---|---|
| D1 | The round **edits `CLAUDE.md` §5** and its shipped mirror | Three findings' homes are in §5. Relocating them to a non-shipping file to honour a scope sentence optimizes the artifact instead of the defect | Land them in `AGENTS.md` Don'ts — repo-local, so the shipped lens could not be strengthened at all and downstream projects inherit nothing |
| D2 | The three parked §5 triggers **fire on a change to the mechanism each row names**, not on adding or sharpening a rule inside §5 | Each row is about a specific mechanism — the file/slot protocol, the template sync contract, the ledger route. None is touched here | A literal touch reading, which fires two triggers whose items each need their own design, inflating the round |
| D3 | The story's "doesn't touch §5 at all post-split" is **corrected inline as an amendment** naming what it replaced | It was a prediction made before the homes were traced. Silently deleting it would be `rewrite-drops-prior-condition` | Honouring the sentence by relocating the edits (see D1) |
| D4 | F2's evidence half, F3, F4 and F6 all fingerprint **`verification-masks-failure`** and resolve at one site | Same failure: a check reports success because of how it was wired. The taxonomy's own rule prefers a reused near-miss over a precise class nobody greps | Minting `single-environment-test-blindness` and `perf-oracle-fixture-gap`, splitting a four-occurrence signal into three that never recur |
| D5 | Each §5 edit is **one clause at the exact existing site** | §5 is the repo's most load-bearing prompt and draws concentrated Gate-A fire. A finding needing a full paragraph is a finding whose home is wrong | Rewriting the surrounding paragraphs, which is how conditions get dropped |
| D6 | `prompt-standards.md` item 11 gains a **sub-clause, not a 13th item** | A new numbered item ripples the count through three files pinned by check 4b — the escalation the 2026-07-27 row refused by name | Item 13 |
| D7 | The skill edit is **all prose**: step 3 gains three branches, step 7 one sentence | No new column, no metadata, no format change. The step-7 sentence is guidance about the existing free-text `ref` | A scope field on the log row, which is the machinery the story exits on |
| D8 | Version **0.9.0** | `#16` (rules added to shipped prompts) took a patch; `#15` (a skill's procedure changed) took a minor. This round does both | 0.8.1, which understates a decision-procedure change |

## 3. The precheck, in `harden-finding`

**Step 3 (Recurrence check).** The bullet reading "latest matching row is a real rung
(1–4/P) → the prior rung didn't hold; propose **one rung stronger**, with reasoning" is
replaced by:

> - latest matching row is a real rung (1–4/P) → **read that row's stated guard before
>   proposing anything.** Rungs guard scopes; a fingerprint match is not a scope match.
>   - **outside** the guard → that mechanism never claimed this shape, so it did not fail:
>     pick the rung that fits this finding, and do not escalate.
>   - **inside** the guard → the mechanism was meant to catch this and did not; that is a
>     regression. Repair or strengthen it, and say what changed and why the old form missed
>     this case.
>   - **no determinable guard** (older rows often state none) → quote the `ref` text you
>     read, say what it leaves undetermined, then pick the fitting rung. Never escalate on
>     the occurrence count alone. The quote is what keeps this branch from becoming the
>     default: "nothing determinable there" is a conclusion reached after reading, and
>     quoting makes that claim checkable.

**Step 7 (Log).** Gains one sentence:

> State in the `ref` what the rung you land actually guards — the exact spelling, path, or
> rule it covers — so the next recurrence can be judged against a scope rather than a count.

**Direction check, for the reviewer.** An earlier draft of this rule had the two branches
inverted, which would have entrenched the bug it was filed against. Outside the guard means
*no escalation*; inside means *regression*. Read them in that direction.

## 4. The four clause edits

Each lands at the site named, mirrored into
`plugins/dev-workflow/commands/workflow-init.md` in the same commit.

### 4.1 §5 Gate B standing lens — finding 1

Site: the `CLAUDE.md` §5 Gate B paragraph opening **"Standing lens, every Gate-B call"**.
Cited by anchor rather than line number throughout this spec, because a moved line citation
is finding 1's own C3.

Appended to the existing lens paragraph:

> **Name the sets this diff changes the size or position of** — a list that gained a
> member, a count, a cited line or path, a version string — and grep for where each is
> described elsewhere. Asked as an open question alone, this lens missed three such
> statements in one cycle while being carried with unusual force; recall does not enumerate
> a set, a search does. The search is still something you run, not something that runs.

**Diagnosis this rests on.** The lens *was* carried on the 0.8.0 cycle, and the plan's
execution notes record it being carried "with unusual force". It still missed C1–C3, and
all three are one shape: the diff changed the membership of a set described elsewhere — a
prerequisite list gained `dash`, a run count went four to five, a cited line moved. The
open question asks for recall; enumerating a set needs a search.

**What this does not do.** It adds no mechanical component. The grep is greppable, and
nothing runs it or validates the answer. A lens that failed under force needs a sharper
question, and this is one; it is not a check, and the ledger row says so.

### 4.2 §5 Profiles counterfactual — findings 2 (evidence half), 3, 4, 6

Site: the `CLAUDE.md` §5 Profiles paragraph containing **"Either route owes the
counterfactual"**.

Appended to the counterfactual paragraph:

> The counterfactual has two halves, and the second is the teeth: **name the observation
> that would exist if the claim were false, and confirm the wiring could have produced that
> observation.** A check that supplies its own input, runs where the defect cannot appear,
> or uses a fixture that never reaches the branch it covers has a falsifying observation in
> principle and no way to produce it — it reports success because of how it was wired, not
> because the thing it checks succeeded.

### 4.3 §5 Gate A pass procedure — finding 5

One sentence, after "Each pass: validate, revise, re-run":

> Before each read pass, run what a machine can check on the artifact's own assertions —
> fenced blocks through a parser, cited paths and line numbers, counts, referenced commands
> — and fix what it reports first, so the read pass spends its attention on what no parser
> decides: on this repo's largest plan a `sh -n` sweep found in seconds defects that eight
> read passes had missed.

### 4.4 `prompt-standards.md` item 11 sub-clause — findings 2 (claim half), 8

> **State the claim's scope, and never let a negative imply the rest is covered.** "It
> bounds the scan, not memory" named one thing the mechanism does not do and left the
> reader to infer it does the others — the bound was a size bound, the work was quadratic,
> and time went unbounded and unnoticed for three drafts. When you name what a mechanism
> does not cover, name the axes you checked, or say you enumerated one and did not check
> the rest.

The checklist stays at 12 items, so check 4b does not ripple.

## 5. The eight ledger rows

Seven findings, eight rows: finding 2 splits, because its two halves are different classes.

| Row | Story finding | Class | Occ | Precheck verdict | Rung |
|---|---|---|---|---|---|
| 1 | F1 — C1–C3, PR #21 | `docs-drift` | 5 | **inside** the 2026-07-27 lens — it was carried and missed all three | `P std` |
| 2 | F2, claim half — C4–C5, PR #21 | `unverified-enforcement-claim` | 5 | **outside** item 11 — a README and a story are not prompt artifacts, which is the scope item 11 claims | `P std` |
| 3 | F8 — "bounds not memory" | `unverified-enforcement-claim` | 6 | **outside**, same guard, same reason | `P std` |
| 4 | F3 — `$EVIDENCE` dry run | `verification-masks-failure` | 2 | **outside** the 2026-07-20 row, whose `ref` states its own scope: "nothing checks new plans for the same shape" | `P std` |
| 5 | F4 — single-shell regression test | `verification-masks-failure` | 3 | **outside**, same row, same reason | `P std` |
| 6 | F6 — timed row, unreached branch | `verification-masks-failure` | 4 | **outside**, same row, same reason | `P std` |
| 7 | F2, evidence half — dash coverage claimed in release evidence | `verification-masks-failure` | 5 | **outside**, same row, same reason | `P std` |
| 8 | F5 — read pass before the sweep | `mechanical-check-skipped-before-review` | new | — | `P std` |

Finding 2 occupies rows 2 and 7: its C4–C5 half is a claim nothing verified, its evidence
half is a check that could not fail. Different classes, different fixes, so different rows.

**Rows 4–7 move `1 prose` → `P std`, and that is not an escalation.** The ladder puts
prompt artifacts on rung P; the counterfactual rule lives in `CLAUDE.md` §5, which §5 itself
classifies as product rather than prose. The rung follows the artifact, not the count. Each
row states this, because a reader comparing rung names alone will read it as a stealth
escalation.

**Each of rows 4–7 answers the clause's two questions for its own case**, so a future grep
lands on worked examples rather than an abstraction.

**Occurrence counts are derived from the ledger, and two differ from the story's estimate.**
The story says `docs-drift` and `unverified-enforcement-claim` are both at "occurrences 6+".
Counting the rows: `docs-drift` reaches 5 here (2026-07-18 twice, 2026-07-25 as `pending`,
2026-07-26 resolving that row rather than recording a new defect, 2026-07-27 as the fourth),
and `unverified-enforcement-claim` reaches 5 and 6. The correction is stated rather than
quietly applied, because an unchecked count is the class this round hardens.

**Row 8 mints one class**, in `docs/hardening-taxonomy.md`:

> - `mechanical-check-skipped-before-review` — an artifact carrying machine-checkable
>   assertions goes to an expensive read pass before anything parses it, so attention is
>   spent on what a tool decides in seconds. Aliases: `sh -n` after the fact, the parser
>   would have caught it, read pass before the sweep, manual review of machine-decidable
>   claims.

Its boundary against `verification-masks-failure`: there, a check ran and could not fail;
here, the cheap check never ran at all.

## 6. Everything else the round ships

- `todos.md` — the three parked §5-trigger rows each gain the D2 half-sentence; the
  scope-blind row records this round as evidence case 3 and is marked done with what shipped.
- `docs/hardening-taxonomy.md` — the row-8 class.
- `plugins/dev-workflow/CHANGELOG.md` and `.claude-plugin/plugin.json` — 0.9.0.
- The story file — the D3 amendment.

## 7. Validation evidence

Mode is read from the story header at each pass. As of this writing it derives
`battery+check`, which owes:

- **battery** — the full quality command from `AGENTS.md § Commands`, green.
- **check, with its counterfactual** — apply §4.2's clause as worded to the four cases in
  rows 4–7. **Each must fail it.** The counterfactual is that each of the four passed
  before: all four shipped, and three of them shipped a defect behind a green check.

## 8. The follow-on intake

Finding 7 gets its own story, produced by `dev-workflow:intake` as a deliverable of this
round, carrying its fired trigger (`docs/hardening-log.md`'s 2026-07-20 row now teaches
pre-0.8.0 counting behaviour as current) and its central design question: whether the
convention must also reach `/workflow-init`'s inline ledger-header template, since a
repo-only fix ships a rule this kit's ledger obeys and every scaffolded one does not.

## 9. Gate-A riders, verbatim in every pass prompt

1. **Direction check.** Confirm the §3 precheck's branches point the direction the parked
   row states: outside the guard → fitting rung, no escalation; inside → regression to
   repair. An earlier draft had them inverted.
2. **Sweep before reading.** Before the read pass, mechanically validate whatever this spec
   asserts that a machine can check — line citations, counts, quoted file contents, grep
   claims — and report what the sweep found separately from what the read found.
3. **Four-case self-test.** Apply §4.2's clause as worded to the four cases in rows 4–7.
   Each must fail it. A clause all four would have passed is miswired.

## 10. What this round does not do

- It adds no mechanical check. Every rung here is `P std`; a reader is the detection.
- It does not claim the strengthened lens catches the class. It sharpens one question and
  names a search; nothing runs the search.
- It does not resolve the ledger's supersession gap — §8 opens that, and until it lands the
  2026-07-20 row still reads as current.
- The precheck depends on rows stating their guard. Older rows do not, which is why §3 has a
  third branch rather than a promise.
