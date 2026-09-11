# Gate A — spec — pass 4 dispositions (salvage cycle)

20 findings (4 BLOCKER, 14 MAJOR, 2 MINOR). **None dismissed. 9 applied; 11 held pending one
decision from Daniel.**

## Trajectory

| Pass | Findings | Blockers |
|---|---|---|
| 1 | 15 | 3 |
| 2 | 25 | 2 |
| 3 | 23 | 5 |
| 4 | **20** | **4** |

Findings declining since pass 2; blockers flat. **The composition is the signal:** eleven of
this pass's twenty — including blocker 2 — are downstream of a single element, rider (b)'s
requirement that a dispositions file record the enum drift.

## Applied (9)

**B1 — the scope was too narrow a "narrow".** §2.1 excluded duties from `CLAUDE.md` §5 and
`AGENTS.md`, and offered "an absent supplementary PR-bot review" as an unqualified example. But
`docs/pr-review-bots.md` makes a bot review **and** a recorded human decision mandatory whenever
that bot is under **Wait for** — so the example is a mandatory rule in some routing states, and
the form would have been the prescribed record for bypassing it. Verified at line 139.
**Fixed:** applicability is now "something no applicable rule required", the bot example is
qualified to **opportunistically routed** bots, and the shipped paragraph names the Wait-for
branch as explicitly out of reach, along with `AGENTS.md`, project docs, CI, branch policy and
platform rules.

**B3 — `AGENTS.md` does change after all.** Invariant 11 says `scripts/check-invariants.sh`
carries "two narrow checks" and enumerates them; §5.2 makes it three. Third time this class has
bitten in this cycle (the manifest, the withdrawn-checker chain, now the invariant's own count).
**Fixed:** `AGENTS.md` invariant 11 is in §4's table, with its calibration sentence kept verbatim.

**B4 — §4 contained mutually exclusive instructions.** The rewrite replaced the table and the
"no new file" paragraph but left the older "Two new files are added" paragraph standing, so an
implementer could legitimately resurrect the withdrawn checker. My incomplete edit. **Deleted.**

**F5** — the closed-enum assertion is now bounded to the §5 region of each file, requires
exactly one canonical match with no fifth token, and fails closed on read or parse errors.
Unbounded, it could have been satisfied by a line in `workflow-init.md`'s surrounding command
prose, or by one naming four tokens while negating the rule.

**F6** — "the edited regions" is now an enumerated table of five blocks with expected
occurrence counts and a stated extract-and-diff procedure. Left to judgement, two people diff
different regions and both record success.

**F14** — post-merge restoration said "verbatim" while changing a line inside the block, which
its own identity rules classify as a hard conflict. Now: reproduce the block byte-identically,
`Ref:` included, with restoration context in prose outside it.

**F15** — `ref:` / `Ref:` casing, unified. **F19** — the story's "two prompt edits and a
paragraph" understated the surface; withdrawn. **F20** — the tier-2 story called a Major a
Blocker.

## Held (11) — all downstream of one decision

**B2, F7, F8, F9, F10, F11, F12, F13, F16, F17, F18.**

Rider (b) began as: state the severity enum as a closed set; let the reader normalize an
unrecognized token to `MAJOR`; **record the drift in that pass's dispositions file**. The last
clause is what has grown. It now needs, and pass 4 finds defects in, all of:

- a token-identity rule with a whitespace edge case that currently contradicts its own example
  (F8), and a six-field parse `CLAUDE.md` §5 never actually defines (F7);
- a **bijection** check, because the audit only verifies cited lines resolve, not that every
  drifted line is cited — so one of four `IMPORTANT` findings can be recorded and the other
  three silently omitted (F9);
- a freshness rule, a two-artifact audit, a discount path, and a logical-pass / attempt /
  credited-count identity model to survive single-branch recovery (F11, F12, F13);
- **edits to four shipped hook reminder strings and their test assertions** (B2), which
  currently instruct a retry to *delete* the slot rider (b) now says to *preserve* — the
  standing falsification lens working exactly as intended;
- a `docs/hardening-log.md` append-only supersession row, because a ledger row states
  categorically that dispositions never participate in pass validation (F16);
- more §2.3 rows and a rollback account covering all of it (F17, F18).

**The alternative is to drop the record requirement.** Normalize an unrecognized token to
`MAJOR`, and stop. The drift stays permanently visible **in the findings file itself**, which
carries the original token on the finding line — that artifact is retained by §5 already, and it
is better evidence than a companion that can be deleted. Every held finding evaporates: no
identity model, no audit, no bijection, no hook-message edits, no ledger supersession, and
§5's "companions never validate a pass" is left **untouched** rather than narrowed.

What is lost: the record made the normalization deliberate rather than silent, and let a reader
see at a glance that a pass had drifted. Against that, the findings file shows the same thing to
anyone who opens it.

**Not taken unilaterally.** Daniel named riders (b) and (c) as the salvage; this narrows what
(b) ships. The discriminating check — closed enum + normalization, §5.2's assertion — survives
either way, so the `+check` obligation is unaffected.

## Status

Not clean; 4 passes taken. Held findings are unapplied and recorded. Blocked on the rider
question.
