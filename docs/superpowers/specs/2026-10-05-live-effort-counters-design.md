# Live effort counters (2c part 4a) — design

**Story:** `docs/superpowers/stories/2026-10-05-live-effort-counters-story.md` — read the profile from its header at every gate call.

## §0 Scope

**What it is.** A new read-only report, `scripts/live-effort.py`, that shows the effort of review
cycles that have not closed. That includes gate calls whose result has not arrived (pending), and it recomputes from the
sources on every run. Repo-local, like the other 2c reports; it ships nothing in the plugin. The
reasons, all from the story:
- it does no threshold warning, has no status line and sends no notification;
- it reports no money cost;
- it changes no gate rule, pass rule, hook or store (`AC-5`).

**Why a separate script.** `scripts/run-analytics.py` (part 1) collects completed calls into a store
and is the one writer of that store. The live report reads the same sources, writes nothing and
leaves the store alone, so running it any number of times, mid-cycle, cannot change what part 1
records. It reuses part 1's measurement functions (§3) rather than re-implementing them. That
reuse is what makes the reconciliation in `AC-4` hold by construction, not by luck.

**Records of the split.** The telemetry story
(`docs/superpowers/stories/2026-10-02-telemetry-and-review-loop-usefulness-story.md` §6) and
`todos.md` get a dated note: part 4 is split into 4a (this) and 4b (the INCOMPLETE rule, later, on
calibrated data), by Daniel's decision of 2026-10-05.

## §1 Sources, and what each makes attributable before a result exists

Shown by reading this machine's files on 2026-10-05, not assumed:

| Source | Available before the call's result | Not available until the result |
|---|---|---|
| Claude Code transcript (`~/.claude/projects/**/*.jsonl`) | the `tool_use` entry for `mcp__codex__exec` / `mcp__codex__review`: its id, start timestamp and complete input (instruction, `additionalContext`, `workingDirectory`, `reviewType`) | the `tool_result`: end time, envelope, session ids, and the reply lines that name the written slots |
| Codex session log (`~/.codex/sessions/**/rollout-*.jsonl`) | a file per Codex session, with `session_meta` (session id, start, `cwd`) and running `token_count` events | the link from a call to its session ids, which only the result's envelope carries |

**What follows for a call with no result yet (a *pending* call):**
- **Its existence, start time and request are known.** The sources show that no result has been
  observed. They do not show that the call is still executing, since a cancelled call or a crashed
  session leaves the same trace. So the report calls it **pending**, never "running", and its time
  is **time since invocation**, not an execution duration.
- **Its tokens are unknown.** A Codex log matched by directory and start time is not evidence of
  ownership: an unrelated Codex session in the same directory, or the next gate call's session if
  this call returns between two reads, fits the same pattern. A call-to-session link exists only in
  the result. Pending calls therefore show tokens as unknown, with the reason
  `not attributable before the result`, and no live log matching is done.
- **Membership in this clone:** the call's `workingDirectory` must exist and belong to this
  repository's common git directory. This is part 1's rule (`common_dir`), unchanged.
- **Its cycle: none until its result arrives.** A nonce in the request text is not evidence of
  ownership. A request may cite another cycle's findings files as input, and a consultation that is
  not a gate pass may name one. Only the result's reply lines name the slots a call wrote, which is
  part 1's attribution. So a pending call is shown among the unattributed calls, with its start and
  time since invocation, and joins its cycle on the first run after its result exists.
- **The cycle's story:** none while the cycle is open. Part 1 attributes stories only from a closed cycle's
  provenance line, and a request mentioning a story path is not a citation; the gate rules forbid
  deriving the cited set by grep. Open-cycle effort is shown per cycle. That is the story's
  "where the attribution rules allow" (`AC-1`).

## §2 What the report shows

**Populations.** Every call in this clone falls into exactly one of these:
- **Open cycles:** completed calls whose nonce, from the result's reply lines, part 1's `classify`
  returns as `open`. That means no closing provenance line was found in the history searched
  (`git log --all`). It covers cycles still running, cycles abandoned without closing, and cycles
  whose closing commit is not in this clone's history; the report says so.
  Classes `confirmed`, `no story` and `conflicting` are closed or contested, so the report excludes
  them and counts them in one line (cycles and calls), so nothing disappears silently.
- **Unattributed recent calls:** calls started within the last 24 hours that have no cycle. That
  covers every pending call, completed calls with no slot or no nonce (a timeout, a failure, a
  malformed reply), and calls with no result after six hours. They are shown
  aggregated by state (completed, failed, pending, no result after 6 h), with the same totals as a
  cycle. **24 hours** is the report's look-back window for effort with no cycle, stated in the
  header; older unattributed calls are part 1's business.

**Header** (`AC-2`, `AC-3`, `AC-6`):
- `report produced <UTC time>`.
- `newest observed value <UTC time>`: the latest start or end time among the calls this report
  shows (open cycles, recent unattributed and pending calls), or `none observed` when there is
  none. Calls in excluded cycles do not count, and Codex log times are not used at all, since a log
  can be shared with an excluded call; so neither can make old open-cycle data look fresh (updated
  after implementation, PR #43 review).
- Source coverage, in part 1's form: for each source root, whether it was found, and the skipped
  sources by cause (unreadable file, malformed line, wrong shape), taken from the scan's
  `problems` counts. A missing root is shown as `not found`, so "no calls" and "sources
  unavailable" read differently.
- *A gate call is not a review pass; this report counts calls and does not count or validate
  passes.*
- The look-back window and the excluded-cycles line.
- The history searched (`git log --all`), and whether the clone is shallow, in part 1's form.

**Per open cycle:**
- the nonce;
- `calls`, all completed (pending calls are listed unattributed until they return, §1);
- `cycle elapsed`: wall-clock from the earliest call start to `report produced`;
- `summed call duration`: completed calls' durations as part 1 measures them;
- tokens per field (`tokens_in`, `tokens_cached`, `tokens_out`, `tokens_reasoning`), as part 1
  measures them.

**Pending calls**, in the unattributed section, each show their start and their
`pending since invocation` time, named as such. Their tokens are shown unknown.

The three times differ when calls run in parallel, and the report names each one (`AC-2`).

**Totals with unknowns (`AC-3`).** These use part 1's form: the known partial sum and the number of
unknown contributions, `X (? n of m)`. When nothing is known the form is `? (? m of m)`. A total is
never printed as complete while a part is unknown, and an unknown is never read as zero.

**Clock skew.**
- A source timestamp later than `report produced` is not used for the freshness value, and the
  header counts such timestamps.
- An elapsed or pending time that would be negative is shown as unknown, with the reason
  `clock skew`; it is never clamped to zero.

**Provisional values (`AC-4`).** Every run recomputes everything from the current sources. Nothing
is stored, so when a pending call completes, the next run measures it as part 1 does. Its pending
line is then gone, and nothing is counted twice.

**Limits (`AC-6`).** These are written for this report, not copied from part 1, because part 1's
list describes a store this report does not keep:
- calls from removed worktrees, other clones and other machines are not seen;
- transcripts deleted by Claude Code's cleanup are not seen;
- calls outside Claude Code, and tool names mapped in `.context/codex-gate.tools`, are not read;
- tokens of a shared (resumed) Codex session stay unknown, as in part 1;
- a pending call may already have stopped, so "pending" is an observation, not proof that it
  is running;
- a pending call's tokens and cycle are unknown until its result links it to its sessions and
  slots;
- token sums cover only the Codex session files found on this run; a sub-agent log that is
  missing cannot be detected as missing, so a sum can be short with no unknown counted;
- the orchestrating Claude session's own tokens are not measured per gate call;
- an `open` cycle may be abandoned, or closed in history this clone does not have;
- cost in money is not reported;
- open-cycle effort is not attributed to a story.

## §3 Reuse of part 1, and reconciliation (`AC-4`)

`live-effort.py` loads `run-analytics.py` the way the other reports load their neighbours
(`importlib`, `sys.dont_write_bytecode`). It calls:
- `scan_transcripts`, `scan_codex`, `common_dir` and the slot grammar;
- `build_record` and `measure_tokens` for completed calls;
- `cycles_from_history` and `classify` for the cycle state;
- `total` for the `X (? n of m)` form.

It never calls `take_lock`, `load_store` or `write_store`.

**The reconciliation claim, exactly:**
- For completed calls that **both** reports measure **fresh** from the same state of the sources,
  the shared measures are equal per cycle: calls, `duration_s` and the four token fields.
- In practice, that is part 1 run against an empty store and the live report run right after it,
  on the same sources. They are produced by the same functions on the same inputs.

**Expected differences, each with its cause, stated in the report's documentation:**
1. **Part 1's store is immutable; this report recomputes.** A call part 1 stored while its Codex
   logs were missing stays unknown in the store, but appears measured here once the logs exist.
   A call part 1 measured before a later resume keeps its tokens in the store, and is `shared`
   (unknown) here.
2. **Sources deleted after part 1 stored a call.** The store keeps it; this report cannot see it.
3. **Population.** This report covers open cycles and recent unattributed calls only. Part 1
   covers every class and all stored history.
4. **No result after six hours.** Part 1 stores such a call as unfinished, with no slots. This report
   shows it in the unattributed section as `no result after 6 h`, if it started within the
   look-back window.

## §4 Command

`python3 -B scripts/live-effort.py` from any worktree of the repository. No options. Re-run it to
refresh; `-B` keeps the interpreter from writing bytecode, as for the other reports. It needs
git 2.36 or later and Python 3.8 or later, like part 1. A failure exits non-zero with a one-line
cause. Because it writes nothing, it does not take part 1's lock.

## §5 Tests and evidence

`scripts/live-effort.test.sh` follows `scripts/run-analytics.test.sh`: a fixture `HOME` with Claude
Code transcripts and Codex logs, a fixture repository with fixed commit dates, expected text.

Cases:
- **Pending call:** one nonce in its request; it is listed unattributed, shows
  `pending since invocation`, and its tokens are unknown with the reason
  `not attributable before the result`. That holds even when a Codex
  log in the same directory, started after it, exists, so the deleted log-matching cannot come
  back unnoticed.
- **Completion:** the same call after its result is added. Its values equal part 1's for that
  call, the pending line is gone, and nothing is counted twice.
- **Request nonces are not attribution:** a pending consultation whose request names one existing
  findings slot as input stays unattributed, and its cycle's call count does not move.
- **Pending to failed:** a call whose result is a failure with no slot moves to the unattributed
  completed or failed group with its duration; it does not disappear.
- **Pending to expired:** a call with no result after six hours appears as `no result after 6 h`.
- **Another clone:** a call whose working directory belongs to another clone is not shown, and the
  limits say so.
- **Unknown in totals:** a completed call whose log has no `token_count` gives `X (? 1 of 2)`.
- **Closed and conflicting cycles:** they are excluded from the blocks and counted in the
  excluded line.
- **Freshness and skew:** with fixed timestamps, both header times are printed as given. A future
  start gives a `clock skew` unknown and is counted, not used as the newest value.
- **Sources:** a missing `~/.codex/sessions` root shows `not found`; an unreadable transcript and
  a malformed line are counted under skipped sources. With no sources at all, the newest value is
  `none observed`.
- **Reconciliation:** run part 1 against an empty store, then the live report, on the same fixture
  after completion. Per cycle, the calls, duration and token fields are equal.
- **Read-only:** the fixture tree's checksums are unchanged after the run, and no
  `.context/telemetry/` write happens.

**Counterfactual for battery+check.** The cases fail without the script. The real check is a
mutation: re-enabling a directory-and-time log match for pending calls must fail the pending-call
case, attributing pending calls by request nonce must fail the consultation case, and removing the
population rule for unattributed calls must fail "pending to failed".

**Battery.** `AGENTS.md`'s quality row gains the new suite and shellcheck line, and the
architecture tree and Commands prose name the new script. CI runs the battery, so its steps add
the suite too.

## §6 What it does not do

- No threshold, warning, alert, stop or notification.
- No status line, menu bar or dashboard integration.
- No plugin shipping.
- No money cost.
- No change to `.claude/review-gates.md`, the hook, `run-analytics.py`'s behaviour or its store.
- No story attribution for open cycles.
- No cross-machine view.

Part 4b, the minimum-cost INCOMPLETE rule, is separate and later.

## §7 Story criteria

| Criterion | Where |
|---|---|
| AC-1 effort so far, including a pending call; only attributable values | §1 (a pending call: shown, time since invocation, cycle and tokens unattributed until its result), §2 populations and per-cycle block |
| AC-2 three named times; a call is not a pass | §2 header sentence and per-cycle fields |
| AC-3 two timestamps; partial sums | §2 header, totals form, clock skew |
| AC-4 reconciliation; provisional values replaced | §3, §2 provisional values, §5 reconciliation case |
| AC-5 no rule change, no threshold, no money | §0, §6 |
| AC-6 limits stated | §2 header source coverage and limits |
