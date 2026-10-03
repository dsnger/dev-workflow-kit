# Review-loop warning light — design

**Story:** `docs/superpowers/stories/2026-10-02-review-loop-usefulness-assessment-story.md` — read the profile from its header at every gate call.

Vision step 2c, part 2, as narrowed on 2026-10-03: a **warning light**, not a usefulness
assessment. The epic is `docs/superpowers/stories/2026-10-02-telemetry-and-review-loop-usefulness-story.md`;
its criterion 5 (the full usefulness assessment) stays open.

## §1 What it is

`scripts/loop-usefulness.py` is a read-only report. For every review cycle whose records appear in the
history it reads (a cycle that left no record there is invisible to it), it shows the recorded evidence, the cycle's product distance where the changed files
establish it, and one of four states with a one-line explanation and a recommendation:

| State | Meaning |
|---|---|
| **red** | a red threshold is reached: surface to a human before running a similar loop again, and change the review method or stop the approach |
| **amber** | an amber threshold is reached: reassess whether further passes of a similar loop have a concrete expected benefit |
| **no warning** | no threshold is reached in the available data; no action is suggested, and usefulness is unknown |
| **not determinable** | no threshold is reached by what is known, and missing or conflicting data leaves the state open: supply the data or classify by hand before relying on it |

A warning means "reassess review effort", never "waste proven" or "poor review". No state says
a loop was useful, and there is no green. The report informs a human: it changes no gate, hook,
floor, severity rule, pass-validity rule or record format, never closes, continues or reopens a
cycle, and triggers no repair or release. It writes nothing. It is repo-local and not shipped, like
`scripts/ledger-metrics.py` (P8) and `scripts/run-analytics.py` (part 1).

| Path | Change |
|---|---|
| `scripts/loop-usefulness.py` | **New.** Python 3.8+, standard library. |
| `scripts/loop-usefulness.test.sh` | **New.** POSIX-sh suite with fixture repositories. |
| `AGENTS.md`, `.github/workflows/ci.yml`, `README.md` | The suite joins the quality and lint rows and CI; the inventories count the new script. |

Nothing under `plugins/` changes, so invariant 12 does not bind.

## §2 Inputs

1. **Commit-body records.** The ref (default `HEAD`) is first resolved with `git rev-parse --verify
   --end-of-options <ref>^{commit}`; a ref that does not resolve is exit 1. History is then read with
   `git log -z --format=%H%x00%ct%n%B <sha>`; a non-zero exit is exit 1 ("history could not be
   read"), and nothing is reported from partial output.
   Records are parsed by loading `scripts/ledger-metrics.py` through `importlib` with
   `sys.dont_write_bytecode` set, and calling its `CANDIDATE` and `parse_record`. P8 is imported,
   not changed (epic criterion 8). A skip record's identity includes the reason text that follows
   it, as in P8.
2. **The run-analytics store**, `<main worktree>/.context/telemetry/gate-calls.jsonl`, opened
   read-only without a lock (it is replaced by an atomic rename, so a reader sees one whole file).
   A line is used only if it is a JSON object whose `tool_use_id` is a string, `slots` a list of
   strings, `duration_s` a finite non-negative number or `null`, each token field a non-negative
   integer or `null`, and `tokens_unknown` a string or `null`, and whose token fields are all
   integers exactly when `tokens_unknown` is `null`. Any other line is skipped and counted. A
   `tool_use_id` seen on an earlier line makes the later line a skipped line too. An absent or unreadable store makes every effort value unknown, and the header says so.
3. **Changed paths** of one commit per cycle (§4): `git -c log.showSignature=false show --no-show-signature --first-parent --name-only
   --format= -z <sha>`.

No findings file, dispositions file or session text is read (story profile: security none).

Every git call removes repository-selecting variables and `GIT_TRACE*`, sets `GIT_TRACE2*` to `0`,
every `log` and `show` call carries `-c log.showSignature=false` and `--no-show-signature`, so no
signature verifier runs, and history is read with `-c i18n.logOutputEncoding=UTF-8`, as in part 1. Git 2.36 or later is
required. **Partial clones are not supported**: in one, reading history can fetch missing objects,
which would write to the repository. Before reading history the report runs `git config
--get-regexp '^(extensions\.partialclone|remote\..*\.(promisor|partialclonefilter))$'`; any
output is exit 1 with "partial clones are not supported".

## §3 Which cycles, and what each shows

**Record identity follows P8**: identical record text is one record, wherever it appears. Every
nonce found gets a state, except a skipped one, because missing or conflicting records are missing
data and must not drop out of the report:

| Records for the nonce | Listed as | Evidence used |
|---|---|---|
| a skip record, no curve | **skipped**: no loop ran, so no state | — |
| one distinct curve text and one distinct provenance text | **closed** | increases and excess |
| one distinct curve text, and no provenance or several distinct provenance texts | **open or unclosed** | increases only; excess unknown ("no provenance line" or "conflicting provenance lines") |
| no curve, or several distinct curve texts, or a skip beside a curve | **conflicting or incomplete** | none: the state is **not determinable**, with the reason |

`cycle none (pre-rule)` records identify nothing; they are counted in the header and not
assessed. A candidate line that `parse_record` rejects is counted in the header as unparsed.

Each closed or open cycle shows these lines. Every value is shown or marked unknown with its reason;
unknown is never zero.

**Context.** Kind, the commit (short sha and date) chosen by §4 to carry its records, the floor and
the cited story set with levels, exactly as the provenance line records them. Which version of the
workflow rules governed the cycle is not recorded and is shown as unknown.

**Material findings (reported, not confirmed, not deduplicated).** Blocker + Major per pass from the
curve, and their occurrence total. A finding repeated in several passes counts in each. Whether a
finding was true, and how many distinct findings there were, is unknown: no findings file is read.
A `?` in either series makes that pass's value unknown; it is excluded from the total, which
prints as `sum (? u of m)` like part 1.

**Increases.** The number of passes whose Blocker + Major is higher than the previous pass's — the
previous **entry** of the curve, whatever its pass number, since incomplete passes consume numbers
without an entry (a curve for passes 1,3,5 compares 3 with 1 and 5 with 3), and
the number of comparisons that could not be made because a value was unknown. An increase means a
later pass reported more material findings than the one before it. That a repair caused it, and
whether a finding recurred or was reopened, is unknown.

**Stored effort (observed).** From the run-analytics store, matched by nonce in each record's
`slots`; each `tool_use_id` counts once per cycle, however many of its slots name the nonce. Shown:
calls, the pass numbers the stored slots cover against the passes the curve records (for example
`stored for passes 1,2,6 of 1-6`), total duration, the four token sums with their unknown counts
and the store's `tokens_unknown` reasons. With no stored call, every effort value is unknown:
"no stored call; cause not known (possible: older than the store, made outside this clone or from a
worktree removed before collection, still pending, or not yet collected)".
Effort decides no state in this version.

**Coverage (recorded only).** Passes run against the floor; whether the final recorded pass had no
Blocker or Major; whether it reported zero findings. What the reviewer examined is not recorded and
is shown as unknown for every cycle.

## §4 Product distance

Distance is the causal path to product behaviour (vision §4). A file path alone does not establish
an effect, so the report names a distance only where the changed file is itself what runs:

| Distance | When — paths changed by the commit carrying the cycle's provenance line |
|---|---|
| **product** | a convention-loaded plugin component that runs in users' projects: `plugins/*/skills/**`, `plugins/*/commands/**`, `plugins/*/agents/**`, `plugins/*/hooks/hooks.json`, a `plugins/*/hooks/*.sh` that is not `*.test.sh`, or `plugins/*/.claude-plugin/plugin.json` |
| **machinery** | not product, and a file that runs or steers runs in this repository: `scripts/*.sh`, `scripts/*.py`, `.github/workflows/*`, `plugins/*/hooks/*.test.sh`, `CLAUDE.md`, `AGENTS.md`, `.mcp.json` |
| **unknown** | anything else — `docs/**` (specs and plans describe something whose distance the paths do not show), changelogs, fixtures, examples — and a commit that cannot be read |

For an open or unclosed cycle (§3), the commit carrying its curve is used instead. Where the
record text appears in several commits, the newest by commit date is used (ties: the lexically
greatest sha) — for a
squash-merged PR this is normally its squash commit, which carries the whole change. The report prints the distance and
the path that decided it, or "unknown — classify by hand".

**Unknown is never treated as low risk.** A cycle of unknown distance takes the state the more
tolerant **product** thresholds give. Where those give **no warning** but the machinery thresholds
give a warning, the state is **not determinable** instead, with both results shown (for example
`not determinable: amber under machinery thresholds, no warning under product thresholds`). Where
the product thresholds already give a warning, that warning stands and the stronger machinery
result is shown beside it. So not determinable always means that no threshold is reached by what is
known, as §1 defines it.

## §5 The thresholds

Two signals decide a state, because the records hold them for every closed cycle: **excess
passes** (the number of curve entries beyond the floor in the provenance line; a pass number with no
entry was an incomplete pass and does not count) and **increases** (§3). Finding
counts alone never decide a state, so few or zero findings cannot cause a warning (story criterion
5). Effort is shown and decides nothing in this version, because it is unknown for most recorded
cycles.

| Distance | amber when | red when |
|---|---|---|
| product | excess ≥ 4 or increases ≥ 2 | excess ≥ 9 or increases ≥ 4 |
| machinery | excess ≥ 3 or increases ≥ 2 | excess ≥ 6 or increases ≥ 4 |

Machinery reaches each excess-pass warning earlier (vision §4: "lower thresholds mean
earlier reassessment, not lower severity").

**Not determinable from unknown counts.** Where no threshold is reached by known data and at least
one comparison could not be made, the state is **not determinable**. This is deliberately
conservative: it does not try to work out how many increases the unknown values could still
produce, so it can name a cycle not determinable that no value could have warned about, but it never
shows "no warning" over a gap. A threshold already reached by known data stays a warning, whatever
else is unknown. For an open or unclosed cycle (§3), excess is unknown, so its state is a warning
only where its increases reach one, and otherwise not determinable.

The explanation line names the deciding signal, its value and the threshold, for example
`red: 23 increases (red at 4, product)` or `no warning: 0 excess passes, 1 increase (amber at 4 /
2, product); usefulness unknown`.

**Every threshold is provisional.** It changes only with a dated note in this section and in the
report, and with the calibration below recomputed.

## §5a Calibration

Computed 2026-10-03 under the thresholds above. Excess uses each cycle's recorded floor. The
field-report cycles record none. The kit's own `fic2` and `rle` cycles ran under the fixed
"min 3 passes per run" that `CLAUDE.md` carried from `e15d480` (2026-07-18, line 72) until the
derived floor shipped, so they use 3 (INFERRED: the rule is recorded, the floor per cycle is not).
The sfx cycles ran in a consumer project whose `CLAUDE.md` required a fixed three-pass floor (sfx
line 22), and its exact rule combination per pass is unverified (sfx lines 27-30), so their excess
is shown as assumed. The
expected state is what the source's own verdict calls for: a loop its source says should have been
reassessed or stopped expects a warning; a loop its source calls ordinary or cheap expects no red.
The design-time script and its output are kept with the plan.

**Recorded cycles on `main` at 7cbbce4** (26 closed, one skipped Gate B, two pre-rule records; no open, conflicting or incomplete nonce):

| Cycle | Distance | Excess / increases | State | Source verdict | Agrees |
|---|---|---|---|---|---|
| `awsf1ec771` Gate-A spec | product | 62 / 23 | red | none recorded for this cycle; expected red is a design judgement (65 passes) | not checkable |
| `om0bdd7udh` Gate-A plan | product | 53 / 21 | red | none recorded; design judgement (56 passes) | not checkable |
| `d0wzih7gr2` Gate-A plan | product | 11 / 3 | red | none recorded; findings rose 22 → 42 | not checkable |
| `bd2vvqjtbn` Gate-A spec | machinery | 7 / 1 | red | none recorded; Majors 17 → 0 over a long low tail | not checkable |
| `mtf7ua7qze` Gate-A plan | machinery | 3 / 1 | amber | none recorded | not checkable |
| the other 21 | product or machinery | ≤ 3 / ≤ 1 | no warning | none recorded | not checkable |

The distances in this table come from the squash commits' changed paths (§4); a cycle whose squash
changed only `docs/**` would read unknown.

**Field-report cycles** (`docs/field-reports/`). Distance follows §4 from the commit that closed
the change: `fic2` closed at `3cdd075` (fic2 l.159) and the `rle` cycles at `7c0d475`, and both
change `plugins/dev-workflow/commands/*.md`, so they are **product**. The sfx cycles ran in a
consumer project whose commits are not in this history; their distance is taken from the report's
own description (sfx l.51-55, runtime design consequences) and is marked so:

| Cycle | Distance | Excess / increases | State | Source verdict | Agrees |
|---|---|---|---|---|---|
| `fic2` Gate B (fic2 l.201-202; Majors l.138-144, passes 6-7 unknown) | product | 4 / 2, 2 comparisons unknown | amber (reached by known data) | "correct and … disproportionate"; stopped twice by the maintainer (l.116-117, 146-150) | yes |
| `rle` Gate-A spec (rle-spec l.15-17) | product | 31 / 10 | red | three mandatory two-tell stops (l.31-33) | yes |
| `rle` Plan A (rle-plans l.33-35) | product | 9 / 4 | red | "the ordinary one"; closed clean (l.81-83) | partly: a warning fits 12 passes on prompt rules; red is stronger than the source's tone |
| `rle` Plan B (l.42-44) | product | 4 / 3 | amber | "the cheap cycle" (l.85-89) | yes: no red |
| `rle` Plan C (l.52-54) | product | 4 / 3 | amber | "closed as not converged" (l.47-49) | partly: warns, but weaker than the source |
| `rle` Plan C1 (l.64-66) | product | 0 / 1 | no warning | stopped on two tells, not resumed (l.69-71) | **no — limit**: its tells were rising total findings and rising Blocker + Major (l.69-71); the light ignores totals and needs two increases, and the material series 8, 8, 10 has one |
| `rle` Gate B, pre-rule (l.137-139; pass 2 discounted, l.143) | product | 1 / 2 over the four valid passes (2 / 2 over all five) | amber either way | "closed as not converged" (l.130-131) | partly: warns, weaker than the source |
| sfx POI spec (sfx l.41) | product (from the report) | 0 / 0 (floor assumed) | no warning | no verdict on the loop (l.89-93) | not checkable |
| sfx POI plan (sfx l.42) | product (from the report) | 1 / 1 (floor assumed) | no warning | 16 of 30 pass-4 findings attributed to the previous revision (l.44-46) | **no — limit**: repair origin is not read |

**Vision §4 acceptance cases.** All three turn on finding content or coverage, which this report
does not read, so the warning light **cannot distinguish any of them**; each is listed as a limit in
the report:
1. harmless explanatory polish versus a plan command corrupting review evidence — no field report
   supplies a harmless-polish case, and the nearest corrupting evidence is measurement scripts that
   replace product files (sfx l.65-74), not a plan command; either way the counts carry no content;
2. speculative helper optimization versus an observed product bottleneck — no field evidence either
   way (sfx l.49: no cost or duration series);
3. a useful clean verification pass versus a pass of unknown coverage (rle-spec l.68-81 against
   canvas-disp l.251-253) — the report shows coverage as unknown for every cycle.

**Threshold change from this calibration:** red at 3 increases made `rle` Plan B, which its source
calls the cheap cycle, red; red now needs 4 increases. Expected recommendation per case: a warning
state calls for reassessing review effort before a similar loop; no case's state waives a floor,
a tell or a closure condition.

## §6 The report

Plain text on stdout, in this order:

1. **Header.** The ref read and whether history is shallow; cycles closed, open or unclosed,
   skipped, and conflicting or incomplete; pre-rule and unparsed record counts; whether the store was read, and its skipped
   lines; the state counts.
2. **Cycles**, newest first by commit date, one block each, as in §3 and §4, with the state, its
   explanation and its recommendation (§1).
3. **Thresholds**, as in §5, with the calibration date.
4. **What this report cannot answer**: whether any finding was true or distinct; that a repair
   caused an increase, or that a finding recurred; what the reviewer examined; whether a loop was
   worth its effort; cost in money; effort for cycles without stored calls; a cycle's distance
   where the changed files do not establish it; which workflow-rule version governed a cycle; that
   curves are author-written and unchecked; the calibration cases it cannot distinguish (§5a).

Exit 0 on success. Exit 1 with `loop-usefulness: <reason>` on stderr when the ref does not resolve to a
commit, history cannot be read, git is missing or older than 2.36, the repository is a partial
clone, or the parser cannot be loaded.

## §7 Tests

`scripts/loop-usefulness.test.sh` builds fixture repositories whose commit bodies carry cycle
records, and a fixture store, then compares the whole report with expected text. It covers:
- each state for product and machinery, with fixture cycles on both sides of every threshold;
- unknown distance: both thresholds agree; product gives no warning and machinery a warning (not
  determinable); product gives amber and machinery red (amber, with red shown beside it);
- a cycle with zero findings, and one with many first-pass findings and no excess or increase (no
  warning); one with few findings and three increases and no excess (amber), and one with four
  (red);
- `?` counts: excluded from the total; a missing comparison that makes the state not determinable;
  a warning reached by known data that stays a warning despite a `?`;
- skipped, skip-with-curve, curve-only, provenance-only, two provenance texts with one curve, two
  curve texts, a pre-rule record, and an unparsed candidate line;
- a git log that fails after the ref resolved (exit 1, no partial report), and a partial clone (exit 1);
- the same provenance text in two commits (the newer one decides the distance);
- store absent, a malformed line, a line with a wrong field type, a full Gate-B call with two slots
  for one nonce (counted once), a cycle with stored calls for only some passes, and one with none;
- the run writes nothing: a listing of every file in the fixture repository and HOME, ignored files
  included, with sizes and modification times, is unchanged, and so is the store;
- an open (curve-only) cycle with four increases (red) and one with none (not determinable), and a
  cycle with two provenance texts and a four-increase curve (red);
- a negative control: a copy whose state rule ignores increases turns the four-increase fixture
  from red into no warning, and the suite catches it.

## §8 Story criteria

| Criterion | Where |
|---|---|
| 1 recorded evidence, unknown with reason | §3, §6 |
| 2 four states with explanation, no green, no score | §1, §5 |
| 3 thresholds in one place, calibrated, limits listed | §5, §5a |
| 4 distance only where established, unknown not low risk | §4 |
| 5 counts alone cause no warning | §5, §7 |
| 6 what it cannot establish | §6 |
| 7 no gate or record change, no file written | §1, §2, §7 |
