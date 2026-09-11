# Gate A — plan — CLOSURE RECORD

**Cycle:** a supersession convention for the hardening ledger.
**Plan:** `docs/superpowers/plans/2026-08-12-hardening-ledger-supersession.md`
**Spec:** `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md` (its own Gate A
closed at pass 23 — `gate-a-spec-CLOSURE.md`).
**Branch:** `ledger-supersession`. **Closed 2026-08-12 on plan pass 7.**

**Gate A (plan) is CLOSED.** `superpowers:executing-plans` is open — sequential, mirror edits in the
same commit. Passes 1–7 applied in full; nothing is held.

Reviewer for all seven passes: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`.
Every pass satisfied the file-first protocol: terminator exact, count matching, no non-finding body
lines. No pass was INCOMPLETE; the recovery budget was never spent.

## Why it closed here

Pass 7 returned **two findings, both Minor, zero Blocker and zero Major**. §5's loop is a
Blocker/Major loop — Minor and Nit are collected, never iterated — so a pass with none is its exit
condition, and both Minors were applied rather than collected because each was a one-line
cross-reference fix.

## Trend

| Pass | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|
| Findings | 18 | 11 | 9 | 8 | 6 | 2 | 2 |
| Blocker | 2 | 1 | 4 | 3 | 1 | – | – |
| Major | 12 | 8 | 2 | 4 | 3 | 2 | – |
| Minor | 4 | 2 | 3 | 1 | 2 | – | 2 |

Monotone in the count from pass 2. The Blocker spike at pass 3 was not a regression: those four had
been latent since pass 1 and surfaced only once the surrounding defects cleared. Both severity
columns reach zero together.

## Two cuts applied before pass 1, by the sweep

- **428 lines of shell** across 31 fences, against spec §6's own "the executable form is written at
  execution time, carried in the plan with one label per check" → cut to labels, properties and
  oracles. Zero lines of shell remain.
- **Check 1's candidates were never bounded** to the label-to-`Columns:` interval, contradicting
  §6's own 1d oracle — which is also §8 held item 4's trace.

## What the passes actually caught

**Two Blockers about the Gate-B mechanics** (pass 1): the consolidation reset to *the parent of the
first WIP* and then reviewed an empty range, with the closing `--amend` set to rewrite `BASE`
itself; and a Gate-B fix was to be "re-reviewed" without being amended into the WIP commit, so
`mcp__codex__review` would have re-read the **stale** committed range and reported a clean pass on
code it never saw.

**Two Blockers where the validation violated the convention it validates** (pass 3): `C1b`'s
counter-check mutated the real 2026-07-20 row and `C3`'s moved the real block and added and removed
a complete entry — operations §2.1 and §2.2 forbid the moment the text exists, committed or not, in
the very file the convention is being added to. Every such mutation now runs on a scratch copy, with
the boundary stated: *prose* mutations are covered by neither rule and stay in place.

**Two staging Blockers** (passes 2 and 4): `git add -A` would have swept the untracked
`docs/research/` tree and the executor's fixtures into a commit or an amend; and `git reset --soft`
cannot be repaired by adding paths, because an explicit `add` does not *unstage* an extra one — so
the equality assertion would have halted execution with no route forward. Now `--mixed`, five named
paths, and an asserted cached set.

**One Blocker per pass, 3 through 5, of one shape: a fix that landed in one site and not in its
mirror.** §8's held-not-fixed intro still said Gate B reviews the checks after §6 had been corrected
to say the opposite; the plan promised the reviewer a paste of the check source that
`additionalContext` did not carry; `BASE` contained the plan while §8 claimed the plan was inside the
reviewed range. Naming that failure mode in the pass-5 and pass-6 prompts is what drove it to zero.

## Settled decisions

| Decision | Settled at |
|---|---|
| **The plan carries labels, properties and oracles; no executable form** | pre-pass sweep |
| **Eight labels** — `C1a`–`C1d`, `C1f`, `C2a`, `C2b`, `C3`; **spec 1e is not implemented**, recorded in §8 | pass 1 |
| **Gate B compares the implementation range only** — neither the plan nor the checks are inside it; both reach the reviewer as context | passes 3–5 |
| **Spec §6 governs, except on the four §8 held-not-fixed items**, where the plan's remedies are authoritative | pass 1 |
| **No counter-check may mutate a row or a complete entry in the real ledger**; prose mutations may stay in place | pass 3 |
| **Never a pathspec broader than the step's file list**, with the staged set asserted before every commit and amend | passes 2, 4 |
| **The evidence entry is one artifact**, composed before the first Gate-B call, carrying the story path inside it | passes 4, 6 |
| **One baseline, one advertised mutation per fixture**; seventeen rows with expected outcomes, PASS rows as well as FAIL | passes 2, 6 |
| **Five labels fail on the untouched tree** — `C1a`, `C1d`, `C2a`, `C2b`, `C3`; `C1b` and `C1c` are protective | pass 1 |

## The four §8 held-not-fixed items, traced

1. **row-date equality** → `C1d`.4 plus the `entry-wrong-rowdate` fixture — executable.
2. **the pre-narrowing "prose-only" claim** → the Global Constraint stating §2.2 governs — wording,
   which is all this one admits.
3. **plural scope** → `C1d`.1 plus `entry-good`'s second inert entry — executable, as of pass 2.
4. **the format-example guard** → `C3` plus Task 5's below-the-table counter-check — executable. Not
   `C1d`.2, which *ignores* a line outside the interval rather than detecting one; that
   mis-attribution was itself a pass-4 finding.

## Spec edits made during the plan cycle

Five, each from a plan-pass finding: §6's "reviewed by Gate B against the real diff" corrected to
*supplied to the reviewer alongside* it; §8's held-not-fixed intro brought into line; a new §8
residual recording that the checks are never fingerprinted and that `battery+check` evidence is
produced by unfingerprinted code; the §8 record that check 1e is not implemented; and the §6 anchor
oracle's false "two begin with `-`" corrected to one.

## Where everything lives

- **Uncommitted at closure:** the spec, the story and this plan. Task 1 of the plan commits all
  three and pins `BASE`.
- **On disk only, gitignored:** `.context/codex-reviews/` — seven plan pass files, their
  dispositions, this record, and the spec cycle's twenty-three. `.gitignore:13` ignores `.context/*`;
  a push does not back these up.
