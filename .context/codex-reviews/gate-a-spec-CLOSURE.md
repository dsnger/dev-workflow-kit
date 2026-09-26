# Gate A — spec — CLOSURE RECORD

**Cycle:** a supersession convention for the hardening ledger.
**Spec:** `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
**Story:** `docs/superpowers/stories/2026-08-04-hardening-ledger-supersession-story.md`
**Branch:** `ledger-supersession`. **Closed 2026-08-11 on pass 23.**

**Gate A (spec) is CLOSED.** `superpowers:writing-plans` is open. Passes 1–22 applied; **pass 23's
four findings are held-not-fixed and recorded as §8 residuals** — Daniel took the stop decision
before pass 23 ran, so repairing them would have produced exactly the unreviewed revision the
closing pass existed to end.

Reviewer for passes 4–23: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`.
Passes 1–3's model was never recorded, so a change across the Codex outage cannot be ruled out.
Every pass satisfied the file-first protocol: terminator exact, count matching, no non-finding
body lines. No pass was INCOMPLETE; the recovery budget was never spent.

---

## The two generators

Nineteen of the cycle's twenty-three passes chased consequences of two constructs. Both were
**deleted rather than fixed**, and each deletion is what ended the finding stream around it.

### 1. The landed-row boundary — deleted at pass 7

The story's append-only rule was narrowed at pass 3 to "never edit a **landed** row", to make
lawful what PR #22 had already accepted in practice. That required a definition of *landed*, and
three were designed and deleted in turn: **authorship-by-cycle**, **reachability from
`origin/main`**, and **content presence in the published ledger**. Passes 4 through 7 each found
the *replacement* for the previous definition unsound — three times inside the very sentence
written to fix its predecessor. The last was pass 7's blocker: a stale-but-readable ref returns a
confident *absent* for a row already published, licensing an edit to it.

Each definition also carried its own old-conditions accounting, six-case self-test, concurrency
assumption and residual list, every one of which grew defects of its own.

**Rationale for deletion:** with no amendable class there is no test to get wrong, no set to
enumerate, no verdict that can flip, and nothing to keep in step across two prompt surfaces. The
rule is bound to **rows**, not commits, so the drafting floor answers the "may I fix a typo before
I commit" question without rebuilding the boundary. Cost: **one entry, once** — row D's in-place
amend becomes an entry that was never written. Pass 7 restored the absolute wording; AC 3 holds
literally again. Recorded as **explored-and-deleted** in the story so it is not re-explored.

### 2. Check 1d's second half — deleted at pass 21

Pass 19 found the original 1d unsatisfiable: *"no entry this change appends is inert"* fails on
§2.2's own sanctioned repair, since a mistyped locator is a complete entry the moment it exists,
entries are never removed, and the correction is an append. The replacement added a successor rule
— *no inert added entry stands uncorrected by a later added one*.

That clause then produced four Majors across passes 20 and 21: it is satisfied by any later
non-inert entry including one about an unrelated row; it needed a duplicate-alignment oracle
because union merge can produce identical entry lines; it is **unsatisfiable** for an entry aimed
at a row that never existed, a case §2.2 explicitly admits; and the repair relation it rests on is
authorial intent the ledger does not encode, so 1f could not carry what pass 20 moved into it.

**Rationale for deletion:** 1d now reads only *"the entry §3.1 mandates matches at least one row
dated on or before its own date."* It still passes the sanctioned typo-then-correct case — the
mandated entry **is** the corrected one — and still fails the mistyped-locator case it was written
for. The successor rule, the alignment oracle and 1f's fifth confirmation went with it. Pass 22,
the first pass after the deletion, returned **no mechanism defect, no unhandled path, no invariant
risk** — the only pass in the cycle to do so.

**The lesson both share:** the machinery was built for states this change cannot enter, and each
repair enlarged the surface that generated the next finding.

---

## Severity trend

| Pass | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Findings | 11 | 14 | 16 | 15 | 9 | 10 | 5 | 12 | 8 | 6 | 3 | 4 | 7 | 6 | 6 | 5 | 6 | 7 | 5 | 4 |
| Blocker | – | – | – | 1 | 1 | 2 | – | – | – | 1 | 1* | – | – | – | – | – | – | – | – | – |
| Major | 7 | 11 | 11 | 9 | 6 | 6 | 3 | 7 | 5 | 4 | 1 | 3 | 5 | 1 | 4 | 4 | 6 | 6 | 3 | 2 |

\* pass 14's "Blocker" is the only finding dismissed **as stated** in the whole cycle — its premise
was factually wrong (the `+` *was* escaped); its remedy was applied anyway as portability hardening.

**Reading it.** The count never converged to zero and gives no signal on its own. The **class** did:
mechanism defects and shell disappeared after pass 16; the 20–21 spike was self-inflicted by
generator 2 and vanished when it was deleted; passes 22 and 23 returned claims-about-the-design and
one over-coverage finding. Pass 7's findings were superseded wholesale by the boundary cut. Rider 4
(oracle coverage) came back empty at 17 and 18, produced real gaps at 19–21, and at 22 ran in the
**over**-coverage direction for the first time.

---

## Settled decisions, with the passes that settled them

| Decision | Settled | Passes |
|---|---|---|
| **No amendable class.** Every row protected; a correction is always an append | absolute, restored | 3 narrowed · 4–7 tested three boundaries · **7 restored** |
| **The floor is bound to rows, not commits** — drafting below it | stated in shared prose | 5, 8 |
| **Entries take the same floor, at COMPLETE entry shape** — partial lines are drafting | stated in shared prose, anchor 35 | 20 raised · **21 set the boundary at completeness** |
| **Entries are row-markers; latest-in-file governs** — the correcting-entry path is cut | cut | 10, 12 |
| **Match semantics:** an entry applies to every row it matches; uniqueness withdrawn | settled | 10 (zero-match) · 11 (temporal bound) |
| **Inert entries stand as history** — never removed, repaired by appending | settled | 10 |
| **Bounded backwards in time:** on-or-before the entry's own date; backdating forbidden | settled | 11 |
| **Inseparability is per ROW, not per pair** — no permitted distinguishing fragment | generalised | 17 narrowed · **18 generalised** · 19 example fixed |
| **`harden-finding` is out of the change surface** — the convention narrows nothing | settled | 4 |
| **Both surfaces**, resting on a parity claim check 2 validates | resolved | 4 |
| **§6 carries no shell** — properties, falsifying observations, oracles only | settled | 16 |
| **No standing machine consumer parses an entry**; §6's parser is validation-only | narrowed | **22** |
| **1d asks about the mandated entry only** | narrowed | 19 · 20 · **21 deleted the second half** |
| **Thirty-five anchors** (33 + fragment narrowing + entry floor) | extended | 19, 20 |
| **The story carries eight amendments**, one per prompting pass, each with old-condition accounting | — | 1, 3, 4, 5, 7, 9, 18, 19 |

---

## Held-not-fixed — pass 23's four findings

Recorded in the spec's §8 as a single bullet, and actionable by whoever writes the plan:

1. **MAJOR — 1d's matching oracle does not name row-date equality.** A checker comparing only the
   fingerprint passes every stated fixture and still reports non-inert an entry whose locator
   matches no row. The executable check must validate exact row-date **and** fingerprint equality
   before the eligibility bound, with a wrong-row-date fixture.
2. **MAJOR — two sites still carry the pre-narrowing "prose-only" claim** (§5, and §8's
   discriminator-rejected bullet). The accurate claim is **no standing machine consumer**: the
   syntax *is* a standing convention future authors must honour. §2.2 governs where they disagree.
3. **MINOR — 1d's scope oracle reads as plural** and can be misread as quantifying over every added
   entry, recreating the unsatisfiable property the narrowing removed.
4. **MINOR — the format-example guard is understated as "shape alone".** For this change, location
   guards it too (1d's interval, check 3's rejection outside it) — once. The claim is right about
   *standing* enforcement.

---

## What the plan must carry — standing riders into `superpowers:writing-plans`

- **Per-check labels and oracles.** One label per §6 check; the plan carries the oracles, since §6
  states properties and the plan states how they are met.
- **Fences are written at execution time**, for Gate B against the real diff and for the harness —
  not in the spec. Extract every `sh` fence, run it **standalone under both `sh` and `dash`** in a
  clone so `git show BASE:` resolves; **assert exit status, never printed output** (a fence that
  prints its failure and exits 0 is the defect this catches, and it caught exactly that twice);
  treat any stderr shell error as failure; run against fixtures that can fail — good / inert /
  edited-target-row / truncated-row / pre-change — and counter-check every pattern against the
  pre-edit tree, where it must return 0. **Beware the harness itself:** three harness bugs produced
  false results this cycle (a multi-line pattern under `grep -F` that could never match;
  `echo "$(basename $f) exit=$?"`, where the command substitution resets `$?`; a `sed` delimiter
  colliding with `\|` in a fixture). A harness that reports success is not evidence until it has
  been shown able to fail.
- **Decisions without history.** The plan states what to do, not how the decision was revised.
- **Mechanical sweep before every plan pass** — cited paths, quoted passages byte-for-byte
  including emphasis markers, stated counts, cross-references, fence balance. A read pass spends
  expensive judgement on what a parser settles in seconds, and misses it anyway.
- **Per-fix landing check, two levels.** After applying any finding: one match proving the edit is
  in the file, one proving the superseded text is gone — **and the same for any instruction
  elsewhere that tells an implementer what to do to that file.** A pass-9 blocker hid at exactly
  that second level.
- **The change surface is §4, not the scope paragraph.** §4 is authoritative and larger: version
  bump, changelog, the backlog row and its two parked rows, two stories, `docs/coding-workflow.md`,
  and the plan-snapshot note.

## Where everything lives

- **Committed and pushed** (`5c0dfc6`, `5e295f0`, `c3fc742`): the spec through pass 17, both
  stories, `docs/coding-workflow.md`, the plan snapshot note.
- **Uncommitted at closure:** the spec and the story, carrying passes 18–23. Docs-only, so Gate B
  is N/A by §5's prose exemption — **verify path by path before committing**, not by assumption.
- **On disk only, gitignored:** everything in `.context/codex-reviews/` — 23 pass files, their
  dispositions, the resume note and this record. `.gitignore:13` ignores `.context/*`. **A push
  does not back these up.**
