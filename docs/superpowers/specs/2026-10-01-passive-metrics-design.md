# Passive metrics over the ledger and git — design

**Story:** `docs/superpowers/stories/2026-08-04-passive-metrics-over-the-ledger-story.md` — read the profile from its header at every gate call.

Dark-factory vision step **2b** (`docs/superpowers/specs/2026-08-30-dark-factory-vision.md` §7). This spec
covers only what that story asks for. It stays read-only. It does not widen into step 2c's telemetry,
which the vision assigns to a separate story.

**Design rule for this spec: report what the records say, compute as little as possible.** The script
counts and lists. It does not compute shares, ratios or verdicts, because every derived figure brings
its own edge cases (missing values, zero denominators), and the story only asks that the data become
readable and checkable.

## §1 What is added or edited

| Path | Change |
|---|---|
| `scripts/ledger-metrics.sh` | **New.** POSIX `sh` + `awk` + `git`. Reads, prints a report on stdout, writes nothing. |
| `scripts/ledger-metrics.test.sh` | **New.** Its regression suite, built on throwaway fixture repositories. |
| `AGENTS.md` | § Commands: the quality and lint rows gain shellcheck runs for **both** new files; the quality row (not the lint row) also gains a run of the suite. Layout tree: both files. **Boundaries** paragraph: the list of executable artifacts gains this script and its test. |
| `.github/workflows/ci.yml` | The shellcheck step gains both new files, and the checker-suite step gains the suite. Any step name or comment that enumerates the checkers is updated too. |
| `README.md` | The Contributing paragraph that counts the executables and checker suites is updated, and one line says how to run the report. |

**Before editing, grep for every other place that enumerates the executables or checker suites**
(AGENTS.md Don't: "the layout tree above is part of the surface that drifts"). The plan carries the
exact grep.

**Not shipped.** The script lives under `scripts/`, like `check-invariants.sh`. The plugin does not
contain it, so invariants 11 and 12 do not bind, and the plugin version does not change (Daniel,
2026-10-01). Shipping it to consumer projects is a later, separate decision.

## §2 Interface

```
sh scripts/ledger-metrics.sh [<ref>]
```

- **The ref is resolved once.** The script runs `git rev-parse --verify <ref>^{commit}` (default
  `HEAD`) once at start and uses only the resulting 40-character SHA afterwards. The ledger is read as
  `git show <sha>:docs/hardening-log.md`, and the commit bodies as `git log <sha>`. Every commit
  reachable from that SHA is read, not just the first-parent chain, because an ordinary merge can carry
  cycle records on its merged side. The working tree is never read. So uncommitted ledger edits are not
  counted, and the report header says so.
- **Shallow clones.** If `git rev-parse --is-shallow-repository` prints `true`, the report header says
  that history is truncated. Every "none found" statement in the cycle and checkpoint sections then
  carries `(history truncated: absence not established)`.
- **Locale.** The script sets `LC_ALL=C` so sorting and output do not depend on the environment.
- **Output** goes to stdout only. Exit `0` when the report is complete. Exit `1` with a one-line
  `ledger-metrics: <cause>` on stderr when a source cannot be read. Each cause has its own message: not
  a git repository, the ref does not resolve to a commit, the ledger is absent at that commit, the
  ledger path is not a regular file there (checked with `git ls-tree`: mode `100644` or `100755`, type
  `blob` — a directory or symlink is rejected), the ledger cannot be read, or `git log` fails. Malformed input lines are **not** an exit: they are counted and listed (§3, §4).
- **The script writes nothing** — no file, no git ref, no config. The suite checks the parts of this a
  test can observe (§6). The rest is held by reading the script, and §6 says which part is which.
- **What the script does not control.** It runs ordinary read-only git commands. Git itself can still
  write when the caller's environment or repository tells it to — for example trace variables such as
  `GIT_TRACE` pointing at a file, or a partial clone fetching a missing object. The script does not
  override the caller's git configuration, and the report header says so in one line. This is a stated
  limit, not a guard.

## §3 Ledger section — recurrence and rung holding

**What a row is: exactly the `harden-finding` match.** A line is a row for fingerprint `F` if it matches
the skill's recurrence grep, `^\| *[0-9-]{10} *\| *F *\|`. The script uses that same pattern, so its
count for `F` equals the count the skill's grep gives. This answers the story's second open question:
there is one definition, not two. Cells are split on **unescaped** `|`. A matching row with a cell count
other than seven is **still counted**, as the grep counts it, and is also listed as `irregular` with
its line number. Irregular-width rows are **excluded from rung holding**, and their rung shows as `?` in
the recurrence line, because their rung cell cannot be located reliably.

**Fingerprint spelling.** Taxonomy classes are kebab-case. A fingerprint cell that does not match
`^[a-z0-9]+(-[a-z0-9]+)*$` is listed as `irregular`. No verification command is printed for it, because
its text would be pasted into a shell command.

`Superseded rows` entries are list lines, not rows, so they never match. The ledger header says this
itself: a superseded row "keeps matching the column-2 grep, and keeps counting".

**Recurrence.** One line per fingerprint, sorted by count (descending), then by name:

```
<count>  <fingerprint>  lines <n>,<n>,…  rungs <r1> > <r2> > …
```

`lines` are ledger line numbers at the SHA, ascending. `rungs` are the rung cells in file order. After
the list comes the exact command a reader can run to check any one count:

```
git show <sha>:docs/hardening-log.md | grep -cE '^\| *[0-9-]{10} *\| *<fingerprint> *\|'
```

**Rung holding.** It counts only rung cells that are one of the values the ledger uses: `1 prose`,
`2 lint`, `3 type`, `4 test`, `P std` and `pending` (the ledger on `main` uses five of these on
2026-10-01; `3 type` is the ladder's remaining rung). Any other rung value — empty, a typo, `0` — is
listed as `irregular rung` with its line number and is not counted. One line per counted rung value,
sorted by name. `pending` rows are listed separately as
`pending <n>` and are not counted as landed, because the `harden-finding` skill treats a `pending`
row as "no hardening landed yet".

```
<rung>  landed <n>  followed-by-same-fingerprint <m>  last-of-fingerprint <n-m>
```

**What this line means, printed beneath it.** "Followed" means a later row with the same fingerprint
exists in the file — nothing more. It does not mean this rung failed: a later row can record a different
sub-shape, an out-of-scope guard, or a prerequisite being resolved. And "last" does not mean it held: a
recurrence nobody hardened leaves no row. Judging whether a guard held means reading the rows.

**Empty states.** If the ledger has no rows, the section says `no rows`.

## §4 Git section — review cycles

**Inputs are the pinned commit-body forms** from CLAUDE.md §5 Mechanics: the provenance line, the
per-pass curve, and the skip record (`<CYCLE-FIELD>; <CYCLE>: skipped (see skip reason)`).

**Candidate lines.** A body line is a candidate if it matches `^cycle [^ ;]*;` — the word `cycle`, one
token, then a semicolon — or starts with `cycle none (pre-rule);`. This catches malformed records whose
nonce or spacing after the semicolon is wrong. It does not catch prose that starts with the word
"cycle" (seen on `main`: "cycle closed on the zero-finding exit …"), because there the second word is
not followed by a semicolon. A candidate that fails the full grammar is listed as
**unparsed**, with its commit, and excluded.

**Deduplication.** A record with a real nonce is keyed by its exact text. Text that appears in several
commits is counted once, and every commit carrying it is listed. `cycle none (pre-rule)` records are
**not** deduplicated, because identical text in two commits may be two different legacy cycles: each
occurrence is listed with its commit and flagged `may duplicate another pre-rule record`.

**Ordering, everywhere in this section** — records, cycle lines, unparsed lines and conflict groups:
by the **earliest** committer date (`%ct`) among the commits carrying the record (for a group, among all
its records), then that commit's SHA, then the line text.

**Grouping.** Records with the same real nonce are grouped. A group joins cleanly only if it has at most
one provenance line and at most one curve or skip record. A group with two different provenance lines,
two different curves, a curve and a skip record, or two different skip records is reported as a
**conflict** with all its records, and it is not listed as a cycle. Copying errors and nonce collisions both look like this. CLAUDE.md says the nonce is
collision-resistant, not collision-proof, so grouping by nonce is a strong default and not a guarantee,
and the report says so. `cycle none (pre-rule)` records are never grouped, because that field
identifies nothing.

**Per cycle, one line,** sorted by first commit date, then nonce:

```
<cycle-field>  <kind>  passes <spec>  floor <N|->  set <story-set|->  findings <values>  blockers <values>  majors <values>
```

- The `values` are **the recorded series, verbatim**, including `?`. No sums and no shares.
- After each series: `(? <n>)`, the number of `?` values in it, so excluded values are counted per
  series as story criterion 5 requires.
- `-` means the record has no provenance line. A provenance line with no curve and no skip record is
  printed with `no curve`.
- A skip record is printed as `skipped`, followed by its reason: CLAUDE.md §5 says the reason is the text
  immediately following the marker in the same commit body. The script takes the lines after the marker
  up to the next blank line, joined with spaces. If the next non-empty line is itself a candidate, or
  there is nothing after the marker, it prints `no reason found`. A skip record is keyed by marker
  **and** reason, so two copies with different reasons are two records and form a conflict.

**Empty states.** `no cycle records`, `no unparsed lines` and `no conflicts` are printed when they apply.

## §5 The review-loop comparison (story criterion 5)

The story asks whether profiled cycles under the new rules show a different severity mix than the
`fic2` baseline. **The script prints the two side by side and leaves the comparison to the reader.**
It computes no shares, so it cannot invent one from a missing or zero value.

**Profiled cycles:** joined cycles with a curve whose provenance set contains at least one `(level N)`
entry. They are listed again here with their series and `(? <n>)` counts, as in §4. If there are none,
the section says `no profiled cycles with a curve`.

**The `fic2` baseline**, a constant in the script because its source commit `3cdd075` is not reachable
from `main` (checked 2026-10-01). Passes 1–5 come from the cycle-shape table in
`docs/field-reports/2026-08-26-fic2-cycle-evidence.md`; findings and blockers for passes 6–7 come from
the story's §1. The output names both sources:

- findings `14,24,12,3,6,6,2` `(? 0)`
- blockers `3,4,0,0,0,0,0` `(? 0)`
- majors `5,13,6,2,5,?,?` `(? 2)` — passes 6 and 7 have no recorded Major count.

**Printed with every report, always, not only when a comparison is possible:**

1. The curves are author-written and unchecked. Nothing compares them against the validated pass
   files, so they are self-reported and not measurement.
2. The cycles reviewed different artifacts, so a difference is evidence about the population as much
   as about the rule.
3. No demotion figure is derivable. That would need one finding classified under both rules, and
   nothing records that.

**First checkpoint.** The story names "the first post-merge cycle whose cited set licenses floor 1".
CLAUDE.md §5 licenses floor 1 only when the set is non-empty and every member is profiled at level 0.
The script does not decide whether the checkpoint was reached. It lists the evidence, in the ordering
above:

- every provenance line whose set licenses floor 1, with its recorded floor and commit
- every provenance line that records `floor 1`, with whether its set licenses it

Either list may be empty, and then says `none`. On 2026-10-01 both are empty on `main`: all 19
provenance lines say floor 3, and no set is all level 0. The reader decides which entry, if any, is the
story's "first post-merge" one.

## §6 Testing — the `battery+check` evidence

`scripts/ledger-metrics.test.sh` builds throwaway repositories under a `mktemp -d` directory. It commits
a fixture ledger and fixture commit bodies, then compares the script's output **line for line** against
expected text written in the test. Fixtures cover:

- **Ledger:** two fingerprints with different counts; an escaped `\|` inside a finding; a supersession
  list line (not counted); a row with too few cells (counted and listed as irregular); a fingerprint
  with an uppercase letter (irregular, no command printed); a `pending` row; a row that is followed and
  one that is last of its fingerprint; an empty ledger (`no rows`).
- **Cycles:** a provenance line and a curve with the same nonce (joined); a curve with no provenance
  (`-`); a provenance line with no curve (`no curve`); a skip record; a `none (pre-rule)` pair (not
  grouped); the same curve in two commits (once, both commits listed); two different curves under one
  nonce, a curve and a skip record under one nonce, and two skip records with different reasons (each a
  conflict, not listed as a cycle); a record only on the merged side of a merge commit (found); a prose line
  starting with "cycle " (not a candidate); a candidate with a 7-character nonce (unparsed).
- **Grammar variants:** a quoted story path containing an escaped `\"`; a quoted model; discontiguous
  pass ranges (`1-3,5`); per-pass models with `+`; a `?` in one series (printed verbatim, counted in
  `(? n)`). Malformed variants listed as unparsed: a repeated story path; a count list longer than the
  pass list; a per-pass model list missing a pass; a candidate with no space after the semicolon.
- **Skip records:** a skip record followed by a two-line reason (both lines printed); one with nothing
  after it; one directly followed by another cycle record (both `no reason found`).
- **Rungs:** an empty rung cell and a rung `0` (each `irregular rung`, not counted).
- **Comparison and checkpoint:** the baseline lines exactly; the three caveats; a joined cycle with a
  level-1 set and a curve (appears in the comparison); `no profiled cycles with a curve`; a level-0 set recorded with floor 3 (appears in the first list); a `floor 1` line with an
  `(unprofiled)` entry (appears in the second list, not licensed); both lists empty.
- **Inputs:** a working-tree edit to the ledger that is not committed (no change in output); each
  exit-1 cause, matched by its message, including the ledger path committed as a directory and as a
  symlink; a shallow clone (header says history is truncated).

**What the no-write check covers, and what it does not.** Before and after each run, the suite records
a listing of the whole fixture directory, `.git` included, with each file's mode and a checksum of its
contents. The two must be identical. That catches a write that leaves a file's content, mode or presence
different afterwards. It does not catch a rewrite with the same bytes, a change that is undone before the
run ends, a file created and deleted during the run, or a write elsewhere on the machine. For the
script's own commands those are held by reading it: it contains no file redirection other than to
`/dev/null`, and no git command that writes. That reading is a review check, not a test, and is labelled
as one. Writes git makes because of the caller's environment are outside both (§2).

**The counterfactual — the observation against the prior state.** Before this change there is no
script, so nothing can produce the recurrence report. The suite's first case runs
`sh scripts/ledger-metrics.sh` in a fixture where the script path does not exist and checks that it
fails with "No such file". That is the prior state, observed. It is also why the check is weak on its
own: a missing-file error shows the tool is new, not that it counts right.

**The negative control** shows the count assertion can fail. The suite runs its fingerprint-count case
against a temp copy of the script where `sed` changes the count by one. That run must **exit 0 from the
script** and fail **on the count assertion**, by its name. A broken copy that fails some other way, or
passes, makes the suite fail itself. Only then does it run the real script.

## §7 What it cannot answer, printed in every report

- **Unlogged recurrences.** The ledger only knows recurrences someone hardened.
- **Whether a guard held.** Row succession is not guard failure, and a missing later row is not
  success (§3).
- **Cycles with no record at all.** Before 0.11.0 the curve was a habit, not a rule. A cycle whose
  author wrote neither a provenance line nor a curve is invisible; a malformed record shows up as
  unparsed. Provenance-only and skipped cycles are visible, as §4 describes.
- **Findings files.** The script does not read `.context/`. In this repository the findings files are
  tracked under `.context/codex-reviews/`; in other projects they may be gitignored. Either way, the
  report counts only what commit bodies say.
- **Whether a curve is true.** See §5, point 1.
- **Cost and duration.** That is step 2c's telemetry, out of scope here.

## §8 Out of scope

Writing anything back, any new state file, instrumentation, a plugin command, step 2c's telemetry, the
dashboard, computed shares or verdicts, and changing a ledger or commit-body format.
