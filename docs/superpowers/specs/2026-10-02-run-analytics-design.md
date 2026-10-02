# Run analytics, trace ID and retention — design

**Story:** `docs/superpowers/stories/2026-10-02-run-analytics-trace-id-and-retention-story.md` — read the profile from its header at every gate call.

Part 1 of the 2c epic (`docs/superpowers/stories/2026-10-02-telemetry-and-review-loop-usefulness-story.md`).
Placement and storage were decided by Daniel on 2026-10-02: a repo-local tool, with data kept per
clone and outside git.

**Design rules.**
- Read what already exists.
- Store only typed numbers and identifiers.
- **Write a record once and never change it;** what was unknown when it was written stays unknown.
- Compute attribution when reporting, never store it.
- Where a value cannot be established, say so instead of guessing.
- No hook, gate or command is changed, and nothing calls the tool; it runs when a person runs it.

**Revisions, 2026-10-02.** Pass 1 found that the account's credit balance does not move inside a gate
session's logs, so the balance is dropped and the story's criteria were amended. Pass 2 found that
updating stored records field by field kept producing new edge cases, so records are now immutable.
Pass 6 tried to measure resumed sessions per time window; pass 7 showed resumed counters can reset,
so calls that share a session now carry no token values at all. Pass 3 found that storing only
"complete" calls broke story criterion 1, so every call is stored once
it has a result or is old enough to be dead, with whatever was known then. After pass 4, Daniel
narrowed the scope on the reviewer's assessment
(`.context/sparring/20261002-132344-telemetry-t1-scope-triage-assessment.md`). **Storing** a call
depends only on showing that it ran in this clone. **Attributing** it to a story depends only on an
unambiguous closing provenance line. Unattributed effort is stored and reported, never dropped.

## §1 What is added or edited

| Path | Change |
|---|---|
| `scripts/run-analytics.py` | **New.** Python 3.8+, standard library. Collects gate-call records, applies retention, prints a report. |
| `scripts/run-analytics.test.sh` | **New.** Its POSIX-sh suite on fixture homes and fixture repositories. |
| `AGENTS.md`, `.github/workflows/ci.yml`, `README.md` | The suite joins the quality row, the lint row, CI and the inventories, the same way `ledger-metrics.test.sh` did in PR #33. |

**Not shipped.** Nothing under `plugins/` changes, so invariant 12 does not bind. Invariant 11 does
not bind either, because neither file is a prompt.

**JSONL rather than SQLite.** The vision's §10 names local SQLite. This spec chooses one JSONL file
instead: the records are few (727 distinct gate calls across every transcript on this machine on
2026-10-02), a JSONL file reads and diffs by hand, and records that never change need no database.
This is a choice made here, not a correction of the vision.

## §2 Sources, measured on 2026-10-02

**Claude Code transcripts.** Every `*.jsonl` file under `~/.claude/projects/`, at any depth (subagent
transcripts are nested, `<session>/subagents/agent-*.jsonl`). Each line is one JSON object; the lines
that matter here carry a `timestamp` (some event types, such as `file-history-snapshot`, do not). A
**Codex call** is an assistant `tool_use` item named `mcp__codex__exec` or `mcp__codex__review`. Its
result is the later `tool_result` item with the same `tool_use_id`. A call that appears in several
transcripts is one call: the first occurrence that has a result supplies its values. The
result's text is a JSON envelope; its shape, counted across all transcripts on this machine:

| Tool | Envelope keys |
|---|---|
| `exec` | `success`, `sessionId`, `status`, `output` (with `summary`) |
| `review`, `reviewType` `spec` or `quality` | `success`, `sessionId`, `review` |
| `review`, `reviewType` `full` | `success`, `sessionId` (may be empty), `specSessionId`, `qualitySessionId`, `review` |

7 of 755 results are not JSON; one call can appear in more than one transcript.

**Codex session logs.** `~/.codex/sessions/YYYY/MM/DD/rollout-*.jsonl`. The first line is
`session_meta`, whose `payload.session_id` is the session ID the envelope names. A review that spawns
sub-agents writes several files with the same `session_id`. Each file holds `token_count` events,
whose `info.total_token_usage` is cumulative, and `turn_context` lines that name the `model`.

**The sources' own retention is not ours.** Claude Code deletes transcripts after `cleanupPeriodDays`
(30 by default). The store keeps the numbers after a transcript is gone.

## §3 Reading a call

**Reply lines.** CLAUDE.md §5's gate prompts end with one reply line per branch:
`<gate> | pass <p> | <n> findings | <path>` or `INCOMPLETE | <cause> | <path>`. The tool takes **every**
line of the result text that matches that grammar. For `exec` the text is `output.summary`; for
`review` it is `review`. The slots are the `.context/codex-reviews/<slot>.md` paths those lines name.
Only reply lines are used, because they name the files this call wrote; the instruction often cites
earlier passes' slots. A slot must match a CLAUDE.md §5 slot name, or it is ignored.

**When a call is stored.** As soon as it has a result, or once its `tool_use` is more than **6 hours**
old without one (then it is treated as interrupted, with `ended` and everything from the result
unknown). A call younger than that with no result may still be running, so it is counted as
*pending* and not stored yet.

**Tokens.** For each Codex file whose `session_id` is one of the call's session IDs, and which exists
when the call is stored, take the file's **last** `total_token_usage`. The call's tokens are the sum
over those files. The record keeps how many files it summed.

The token fields are `null` if any of these holds:
- no file is found;
- a found file fails to parse, or has no `token_count`;
- **the call's session is shared with another call.** A resumed session's counters cover several
  calls and can even reset, so no share of them can be assigned to one call. A session counts as
  shared if any of these holds:
  - the call's own input passes a session ID (`sessionId`, `specSessionId` or `qualitySessionId`) —
    that is a resume;
  - any matched Codex file's `session_meta` timestamp is earlier than the call's `started` — the
    session existed before this call;
  - any matched Codex file has an event timestamp later than the call's `ended` — the session went on
    after this call returned (Codex finishes before the MCP result reaches the transcript, so a later
    event belongs to later work);
  - another call in the transcripts read names the same session ID.

  The first three need no other transcript, so sharing is recognized in both directions — the
  resuming call and the resumed one — even after the other call's transcript was deleted. Such records are counted in the header as *session shared, tokens not
  attributable*. A call that
  was stored before its session was resumed keeps the tokens it was stored with: at that moment the
  counters held only its own usage, and records never change.

**A sum from the files found is not proof that every sub-agent's log survived or finished**; §8
prints that limit. The model list is the sorted distinct `turn_context` models from the same files.

**A slot is what makes a call a gate call.** A Codex call with no slot in its reply lines is stored
too, and the report lists it as *no slot* — a gate that failed or was interrupted, or a call that
was not a gate.

**A record** (immutable, keyed by `tool_use_id`). Every value is type-checked. Only `tool_use_id` and
`started` are required: a call whose `tool_use_id` or `started` fails its check is counted as malformed
and not stored. **Any other value that fails its check is stored as `null` (or an empty list) and
counted in the header; the call itself is kept.**

| Field | Type check |
|---|---|
| `tool_use_id` | `^[A-Za-z0-9_-]{1,64}$` |
| `tool`, `review_type` | `exec`/`review`; `spec`/`quality`/`full`/`null` |
| `started` | ISO-8601 UTC |
| `ended`, `duration_s` | ISO-8601 UTC with `ended ≥ started`, and `ended − started`; both `null` when there is no result |
| `success` | boolean or `null` |
| `session_ids` | each `^[0-9a-f-]{36}$`; may be empty |
| `slots` | each a CLAUDE.md §5 slot name; may be empty |
| `codex_files` | integer, the number of Codex files summed |
| `models` | each `^[A-Za-z0-9._:+-]{1,64}$`; may be empty |
| `tokens_in`, `tokens_cached`, `tokens_out`, `tokens_reasoning` | non-negative integers, or `null` |

**No text is stored** — not the instruction, the reply, file content or any other free text (story
criterion 4). Free text is read only to extract the typed values above.

**Unexpected structure is a counted skip.** A line that is not JSON, or whose JSON does not have the
shape §2 describes (a `tool_use` item with a name and an id, or a `tool_result` with a `tool_use_id`),
is skipped. A field inside a usable item that fails its type check is not a skip: it becomes `null`, as
the record table says. An unreadable or unenumerable file or directory is skipped too
(`os.walk` with an error callback). A missing source root is reported. Each kind is counted, and none
stops the run (story criterion 6).

## §4 Which calls, the store and retention

**One git environment for every git call.** Every git command the tool runs, without exception, runs
with an environment from which every variable that selects a repository is removed: `GIT_DIR`,
`GIT_WORK_TREE`, `GIT_COMMON_DIR`, `GIT_INDEX_FILE`, `GIT_OBJECT_DIRECTORY`,
`GIT_ALTERNATE_OBJECT_DIRECTORIES`, `GIT_CEILING_DIRECTORIES`, `GIT_DISCOVERY_ACROSS_FILESYSTEM` and
`GIT_NAMESPACE`. That covers discovering this clone, `git worktree list`, the membership test and
`git log`. It also runs in an explicit directory: the current directory for this clone, and the
call's directory for the membership test. So an inherited variable cannot point any of them at
another repository.

**This clone's common directory** is `git rev-parse --path-format=absolute --git-common-dir`, run in
the current directory, then passed through `realpath`. The tool needs git 2.36 or later, because
`git worktree list --porcelain -z` arrived in 2.36 (and `--path-format=absolute` in 2.31). It checks
`git --version` first; an older git is exit 1 with `run-analytics: git 2.36 or later is required`. Without the flag, git
prints a relative `.git` from the main checkout.

**Which calls are stored: the ones shown to run in this clone.** A call is stored when its
`workingDirectory` is absolute and exists, and the same command run in that directory yields the same
real path. A nested clone or submodule has its own common directory and fails the test.

Two things are deliberately **not** proof of membership:
- **A nonce in this repository's history.** It shows the cycle was recorded here, not that this clone
  ran the call.
- **A relative or absent `workingDirectory`.**

So calls from a **removed worktree**, or from another clone of the same repository, are outside this
version's coverage; the report prints that limit. To keep a worktree's calls, run the tool before
removing the worktree. Calls that are not stored are counted, never listed.

**Location.** `<main>/.context/telemetry/`, where `<main>` is the first `worktree` entry of
`git worktree list --porcelain -z` (NUL-delimited, so a path needs no unquoting). If that entry is
bare or its directory is missing, the tool exits 1 with `run-analytics: main worktree unavailable`. `.context/` is
gitignored except `codex-gate.on` and `codex-reviews/` (checked 2026-10-02). Files:
- `gate-calls.jsonl` — the store, one record per line;
- `.lock` — the lock.

**One locked section.** The run opens `.lock` with `O_NOFOLLOW | O_NONBLOCK`, checks with `fstat` that it
is a regular file (a FIFO, device or directory is exit 1), and takes an exclusive, non-blocking
`flock`. If another run holds it, the tool exits 1 with `run-analytics: another run holds the lock`.
Everything that touches the directory happens while the lock is held: cleanup of stale temporary
files, loading, adding, retention and the replacing write.

**Directory and file checks.** If `.context`, `.context/telemetry`, the store or the lock is a symlink,
or the store exists but is not a regular file, the tool exits 1 without writing. The directory is
created, or kept, with mode `0700`; the store and the lock with mode `0600`.

**Loading.** Every line must parse and pass §3's checks, and no `tool_use_id` may appear twice. Any
failure leaves the store untouched and exits 1, naming the line. Silently dropping a record would be
data loss; a human can move the file aside.

**Adding.** A storable call whose `tool_use_id` is not in the store is appended. One that is already
there is left alone, because records never change.

**Retention.** A record whose `started` is more than **365 days** before the run is deleted. The
comparison is in UTC, to the second. `--keep-days N` sets another limit; *N* must be an integer from 1
to 36500, otherwise exit 1. Retention runs on every run, since every run collects. The 365-day default
is this spec's decision: it keeps a year of cycles comparable.

**Writing.** `tempfile.mkstemp` in the same directory with the fixed prefix `.gate-calls.tmp.`, then
`os.replace`. Stale files with that prefix are deleted at the start of the locked section.

## §5 Trace ID and attribution

**Trace ID = the story's repository-relative path.** Specs and plans carry it in their `**Story:**`
header, and closing commits carry it in the provenance line. The story needs no new field. Two limits
are printed with the report:
- a renamed or moved story gets a new trace ID;
- a reused path joins two stories under one ID.

**Attribution happens at report time and is never stored.** `scripts/ledger-metrics.py`'s record parser
is loaded by path with `sys.dont_write_bytecode = True`, so no `__pycache__` is written, and runs over
`git log --all`. For each nonce in a record's slots, exactly one class applies, checked in this order:
1. **conflicting** — two or more different provenance lines, or two or more different curve or skip
   records, of any kinds (CLAUDE.md: one nonce names one cycle, and nonces are not collision-proof);
2. **confirmed** — exactly one distinct provenance line (with zero or one curve-or-skip record). Its
   story set is the record's story set, and may be `none` ("cycle without a story");
3. **open** — no provenance line reachable. That is a cycle still running, abandoned, or closed in a
   commit this clone does not have. The report says which history was searched and whether it is
   shallow.

A record with no nonce-bearing slot is **no nonce**. Confirmed is the only class with a story.
**Every other class is unattributed effort**: it is stored and reported with its known and missing
values, and no story is guessed for it. A provenance line records what its author wrote, so
"confirmed" means recorded, not independently proven.

A record whose slots carry different nonces counts once under each nonce. The class counts in the
header are counts of (record, nonce) pairs, plus one per no-nonce record, and the report says so.

## §6 Interface and report

```
python3 scripts/run-analytics.py [--keep-days N]
```

**Exit 0** when the report printed. **Exit 1** with one line `run-analytics: <cause>`, each cause named,
when:
- it is not a git repository, or `git worktree list` or `git log` fails;
- the lock is held;
- the store, the lock or a directory is a symlink, or the store is not a regular file;
- the store is invalid;
- the store cannot be written;
- `--keep-days` is invalid.

Git's stderr is captured and not shown. Every printed value is a §3-typed value, a repository-relative
path, or the tool's own text. The store path is printed relative to the main worktree.

**The report** is built from the **store**, after this run's additions and retention, not from the
sources. Records whose sources have since been deleted therefore stay in every section.
1. **Header.** Records stored, added this run, deleted by retention; pending calls; calls not stored
   (not in this clone); stored values that failed their checks; stored records with no result, with
   no Codex logs, and with unknown tokens; skipped sources by kind; each missing source root; class
   counts.
2. **Attributed effort, per story.** A story's total is the sum over its confirmed cycles. A cycle
   confirmed for several stories appears under each, so those stories' totals overlap; the report
   says so. These totals are attributed effort, not the story's full cost. Per cycle it shows the
   gate calls, the distinct pass numbers among its slots, total duration, and token sums.
3. **Unattributed effort**, in this order: cycles without a story, open, conflicting, no nonce, no slot.
   Each has the same columns as section 2.
4. **What it cannot answer** (§8).

**Sums with unknown values.** Every sum adds only the known values and prints
`<sum> (? <u> of <m>)`, where *u* of the *m* contributing values were unknown. If all *m* are
unknown it prints `? (? <m> of <m>)`. A sum is never printed as a total without its unknown count,
and unknown never counts as 0.

**Empty states.** A section with nothing in it prints `none`. A run whose sources are all missing still
reports what the store holds, lists the missing roots in the header, and exits 0.

**Pass numbers are not verdicts.** "Distinct pass numbers among the slots" counts what the calls wrote.
It says nothing about which passes were valid or counted toward a floor; the report says so.

## §7 Testing — the `battery+check` evidence

`scripts/run-analytics.test.sh` points `HOME` at a temporary fixture home and builds:
- **Transcripts**, one at depth 1 and one nested under `subagents/`, holding:
  - an `exec` gate call with result, slot and Codex logs;
  - a `full` review with two reply lines and two session IDs;
  - a call with no result;
  - a non-JSON result;
  - a call with no slot;
  - a `health` call;
  - a call whose instruction cites an earlier slot while its reply names the current one;
  - a call whose second session has no Codex file;
  - a second call that resumes the first call's session (both calls' tokens `null`, counted as
    session shared); the same resume after the first call's transcript is deleted, and after the
    second call's transcript is deleted (shared both times);
  - a call with no result, older than 6 hours (stored as interrupted), and one younger (pending);
  - the same call in two transcripts;
  - a call in this clone with a fresh nonce (open, stored as unattributed effort);
  - a call with an invalid model value (stored, model `null`, counted in the header);
  - a call from a directory that no longer exists, whose nonce is in the history (not stored);
  - a malformed line, and a line of the wrong shape;
  - a call from an existing directory in an unrelated repository with a fresh nonce.
- **Codex logs**: two files sharing a `session_id`, a file with no `token_count`, a session with two
  models, and a file with an unparseable line.
- **A fixture repository** whose history has: a confirmed cycle, a cycle confirmed with story set
  `none`, two different provenance lines for one nonce, one nonce with a Gate-A curve and a Gate-B
  curve, a provenance set mixing level 0 and level 1, and a curve with no provenance line. It also
  has a linked worktree.

Line for line, the suite asserts the report and the store. In particular it checks:
- each attribution class, and that only confirmed cycles carry a story;
- every header count: pending, no result, no Codex logs, unknown tokens;
- the unrelated repository's call is not stored;
- a second run adds nothing; after a transcript is deleted the record stays unchanged and still
  appears in the report;
- a group with partly and with wholly unknown tokens prints `(? u of m)` and `? (? m of m)`;
- retention deletes a 400-day-old record and keeps a 10-day-old one;
- a held lock, a FIFO at `.lock`, an invalid store line, a duplicate `tool_use_id`, and a symlinked
  store or lock each exit 1 with their own message;
- a run from the linked worktree writes the same store as one from the main worktree;
- an empty fixture home with an empty store yields the zero report with exit 0, and with a filled
  store it still reports the stored records;
- a membership check run with an inherited `GIT_DIR` pointing elsewhere gives the same result;
- the fixture home's files are byte-identical before and after, and the fixture repository's
  `git status`, refs and index are unchanged;
- no `__pycache__` appears.

**No-text check (story criterion 4).** Every free-text field in the fixtures carries the marker
`SECRET-MARKER-7f3a`: instructions, replies, review bodies and file contents. After every run the marker
appears nowhere in the store or the report.

**Counterfactual and negative control.** `git ls-tree` on the base commit shows that no collector exists
there; this observes the missing tool, not the ignored store. A copy of the script that stores a reply
line's raw text must fail the no-text check. A copy that drops the membership test must fail the
unrelated-repository check.

## §8 What it cannot answer, printed in every report

- **Calls whose transcript was deleted** by Claude Code's cleanup before they were collected.
- **Cost in money or credits.** The logs carry no per-call cost, and the account balance does not move
  inside a session's logs.
- **Tokens of calls that share a Codex session** (a resume): they are left unknown rather than
  split.
- **Whether a token sum is complete.** It covers the Codex files present when the call was stored; a
  sub-agent log that was missing or still being written at that moment is not in it.
- **Calls from removed worktrees or other clones** of this repository: membership needs the working
  directory to exist in this clone.
- **Stories of open, abandoned or conflicting cycles:** their effort is reported as unattributed and is
  not guessed onto a story.
- **Values that are unknown when a record is written stay unknown**, because records never change.
- **The orchestrating session's own tokens per gate call.** The transcript records usage per assistant
  message, not per tool call.
- **Calls made outside Claude Code**, for example Codex run directly.
- **Renamed or reused story paths** (§5).

## §9 Out of scope

Review-loop usefulness (part 2), spec-delta (part 3), live counters and any INCOMPLETE rule (part 4),
any hook, shipping in the plugin, and storing any session text.
