# Compare: observations against `expected/` (2026-10-10)

Model in every run: `claude-opus-5-5` (`out/*-meta.json`). Claude Code 2.1.296.

## Run 1 — part A blocked by the trust dialog, kept as a record

The first two part-A sessions (`out/a-new-*`, `out/a-old-*`) did not commit. The fixture's
`.claude/settings.json` allow-list was ignored, because the fixture directory had never been
trusted (`out/a-*-stderr.txt`), so `sh -n tool.sh` needed an approval nobody could give. Both
sessions stopped before the closing act, and correctly so: the battery is part of the evidence
entry. Each printed the closing message it would write:

- **new rules:** `cycle r3pl4yfx01; ledger check: fixed 2, hardening owed 1` and one owed line,
  `gate-b-spec-r3pl4yfx01-pass-1:1 — major — docs-drift — README.md — …`. Matches.
- **0.21.0 rules:** no ledger-check line, no owed line. Matches.

Run 2 repeated part A with the same prompt and fixture, adding `--allowedTools` for `git`,
`sh -n`, `ls`, `cat` and `grep`. Part B needed no command beyond `git`, ran once, and is reported
under run 1's flags.

## Part A, new rules (run 2, `out/a-new2-*`)

| Expected | Observed |
|---|---|
| `ledger check: fixed 2, hardening owed 1` | present, exactly |
| the duplicate counted once | `fixed 2` from three repaired lines |
| the owed line names the spec slot's line, class `docs-drift`, severity `major`, target `README.md` | `gate-b-spec-r3pl4yfx01-pass-1:1 — major — docs-drift — README.md — usage line still named the removed --global flag` |
| the typo not owed | absent from the owed lines |
| no `WIP:` commit remains | `out/a-new2-log.txt`: `initial`, then the closing commit |

**Matches.** One deviation, unrelated to the ledger check: the session derived the floor as 3
from an **empty cited set**, because the fixture has no plan whose `Story:` header Gate B would
read, and closed on the zero-finding exit, which needs no floor. The 0.21.0 session read the
floor from the working record instead (1). That is a fixture gap: a Gate-B cycle's cited set
comes from plan headers, and the fixture carries none.

## Part A, 0.21.0 rules (run 2, `out/a-old2-*`)

| Expected | Observed |
|---|---|
| no `ledger check` line | none |
| no `hardening owed` line | none |

**Matches.** The counterfactual's observation exists: the same fixture and prompt under the
old rules produce neither record.

## Part B, new rules, fresh checkout (`out/b-new-*`)

| Expected | Observed |
|---|---|
| `pass-1:1` closed (`rung 2`), not listed as open | listed under "Closed" |
| `quality-pass-1:2` open and blocked, `ref` named | "open, blocked", `pending todos.md#validation-lint-prerequisite` |
| `quality-pass-2:1` open, no outcome | "open, no outcome line" |
| each intake: finding text, source, severity, place | all four for both, source read from the slot |
| the quoted target read whole | `scripts/run — all.sh`, with a note that it is quoted because it contains the separator |
| no question back | none; it also checked for a shallow clone and other branches |

**Matches.** It also remarked that an outcome line in the same commit as its owed line is
irregular, since hardening runs as its own change, and still counts it. That is the rules'
closing condition read as written: the fixture packed both into one squash body, which a real
squash carry does.

## Seen and not part of the claim

- Every committing or drafting session appended a `Co-Authored-By` trailer. That comes from
  the client's defaults, not from the rules under test; this repository forbids it in its own
  commits.

## Run 3 — parts A and B again, on the repaired rules (`out/a-new3-*`, `out/b-new3-*`)

Gate-B pass 1 changed the rule text: the pinned dispositions line gained the duty's scope and
timing, an unknown-pass-status rule was added, and a quoted-target example. Parts A and B were
run again on that text with run 2's flags; the counterfactual was not, its rules being unchanged.
Part A: `fixed 2, hardening owed 1`, the same owed line, no `WIP:` commit left, and the same
empty-cited-set floor reading as run 2. Part B: the same two open obligations, the pending one
blocked, the rung-2 one closed, all four intake fields each, the quoted target whole, and it
checked for a shallow clone and other branches. **Matches.**

## Run 4 — all three parts on the rules as repaired after the PR #56 bot review

The bot review (PR #56) found two fixture faults and one prompt fault, all fixed before this
run: the repaired `tool.sh` accepted any argument, contradicting the fixture's own invariant; the
fixture had no plan citing the story, so a Gate-B cycle's cited set was empty and its floor 3
(runs 2 and 3 noticed and closed through the zero-finding exit); and prompt A told the session
the floor was met, a premise the fixture did not establish. The rules also changed: a declined
finding is `not fixed`. Parts A (both rule texts) and B were run again with run 2's flags
(`out/*4-*`).

- **A, new rules:** `fixed 2, hardening owed 1`, the owed line names the spec slot's line,
  `docs-drift`, `major`, `README.md`; floor 1 read from the plan's `Story:` header; no `WIP:`
  commit left. **Matches.**
- **A, 0.21.0 rules:** no ledger-check line, no owed line; floor 1 likewise. **Matches.**
- **B:** two open obligations, the pending one blocked with its `ref`, the rung-2 one closed;
  each intake complete from git alone; no question back. **Matches.**

## Verdict

Every expectation in `expected/` matched, in both parts and in the counterfactual, on every rule text tested; run 4 is the one whose rules shipped. This is one
sample per part; the limits in `README.md` stand.
