# Gate-Pass Result Classification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stop the gate hook from counting Codex calls that delivered no review, by classifying the tool result before touching any pass state.

**Architecture:** One classifier runs in the `PostToolUse` branch for the two gate tools. A single escape-aware `awk` scan locates the result text block and yields its **escaped** bytes; one shell matcher reads those bytes and returns one of five classes. Three classes write no gate-pass state; two behave exactly as today. Output is buffered so an invocation writes at most one hook JSON document. Diagnostic markers are separate from pass state and always best-effort.

**Tech Stack:** POSIX `sh`, POSIX `awk`, POSIX `sed`. `jq` is used only by `emit` and the existing field readers — **never** by classification.

**Spec:** `docs/superpowers/specs/2026-07-31-failed-codex-call-counts-as-a-pass-design.md`
**Story:** `docs/superpowers/stories/2026-07-30-failed-codex-call-counts-as-a-pass-story.md` — read its header for the live profile at each gate pass; never copy the values here.
**Gate-A closure (spec):** `.context/codex-reviews/gate-a-spec-CLOSURE.md`
**Gate-A closure (this plan) + Gate-B obligations:** `docs/superpowers/plans/2026-08-01-gate-pass-result-classification-execution-notes.md` — **read before executing.** Gate A closed at pass 9 as a pre-authorized judgement exit; 34 open findings are recorded there as Gate-B obligations, and three execution-blocking ones were fixed in this plan at closure.

---

## What this plan specifies, and what it deliberately leaves to execution

**Narrowed at Gate-A pass 6, human-confirmed 2026-08-01.** Passes 4 and 5 pushed literal test-harness shell into this document; pass 6 then found three skeletons still open *and three fresh defects in the shell added to close the previous ones* — including that the plan's own helper code failed this repo's ShellCheck policy. The document was 1732 lines and converging on a verbatim copy of a test suite that Gate A cannot run, lint, or execute.

**So the line is drawn here.** This plan specifies:

- the **contracts** (A1–A7), the **class table**, the **marker state table**, and the accepted **residuals**;
- the **five message pairs**, in full — they are product, they are prompts, and invariant 11 binds them;
- the **behaviour of each task** and its commit boundary;
- for every test, its **label** and its **oracle**: the state it must observe and *what it must fail on*. Coverage stays reviewable without a line of harness shell.

It does **not** specify the harness shell. That is written test-first during execution and reviewed at **Gate B**, as code that runs and lints. Where a pass-6 finding was about harness mechanics, it is dispositioned **"moves to Gate B"** by name at the end of this document — inherited the way this plan inherited spec §11's deferred contracts, not dropped.

**The verified code seeds live beside this plan, not inside it.** `.context/plan-drafts/` holds `locate.awk` and `match.sh` — green at **56/56** under `verify.sh`, under both `sh` and `dash` — plus `harness.sh`, a **seed that has never been run** and says so in its own header. They are evidence and starting points; this plan states what they must satisfy. If that directory is missing (it is git-ignored), the bodies must be reconstructed and re-verified against `verify.sh` before use — the cost of keeping them out of the plan, stated rather than discovered.

**Spec amended earlier in this cycle.** Pass 1 showed the spec's two-locator design was not implementable as written: its in-span check needs byte offsets, which `jq` does not report, so the span had to come from the scan anyway. §3.1 now specifies **one** locator, and the re-encode step, the uniqueness and in-span checks, and §7.3's extraction-parity matrix are **deleted** rather than fenced off. Recorded inline in §3.1 with what it replaced. Human-confirmed.

**What 56/56 does NOT establish.** `sh` and `dash` invoke the same system `awk`, so it is shell coverage, not `awk`-implementation coverage — and `awk` is load-bearing. Only macOS BWK `awk` exists on the development machine; CI's `ubuntu-*` runs `mawk`. Green in both places is the portability evidence. Until CI has run, portability is **unverified**.

---

## Carried obligations — check off or explicitly re-disposition during this plan's Gate A

Nothing here may silently evaporate. Each item names the task that discharges or preserves it.

### A. Implementation contracts deferred from spec §11

- [ ] **A1** — The scanner as a state machine: quote state, backslash parity, value boundaries, the operational meaning of "depth 1". → Task 5
- [ ] **A2** — Recognition of duplicate depth-1 keys and of structures the scan cannot walk. → Task 5
- [ ] **A3** — Accepted raw encodings around every token, including the blank-byte grammar. → Task 5
- [ ] **A4** — Full backgrounding-notice grammar: what the anchor fixes, what it leaves variable, and the near-misses that must NOT match. → Task 5
- [ ] **A5** — Complete marker state table across both disclosure markers and `bgAdvice`. → Task 5
- [ ] **A6** — Composition against every existing emit branch, and events that would otherwise emit nothing. → Task 4 (mechanism) and Task 5 (the disclosure wired into it)
- [ ] **A7** — Separator and encoding rules for composed messages. → Task 4

### B. Shipped-doc scope from the spec's Gate-A pass 8

**Every B edit lands in Task 6, with one stated exception: B2's occurrence inside `codex-gate.sh` is a comment on the function Task 3 rewrites, and is edited there** — separating a comment from the code it describes across four commits is how comments go stale.

- [ ] **B1** — `CLAUDE.md:168` and `commands/workflow-init.md:347` say the hook is *"keyed on tool name, and never sees the file"*. **Only the first clause becomes false.** "Never sees the file" is about the **findings file** and stays true. Three further sites say the same thing in different words — Task 6 Step 1. → Task 6
- [ ] **B2** — "Accurate counters" on opt-out: `README.md:97`, `commands/workflow-init.md:1038`, **and the two suite sites `codex-gate.test.sh:296` and `:306`** → Task 6; `codex-gate.sh:291` → **Task 3**. The suite pair was missing from this list until the pass-8 census caught it: a test whose label asserts the retired claim keeps it true in the one place nobody rereads.
- [ ] **B3** — Mapping instructions: `commands/workflow-init.md:123-124`, `:74` and `:157` (the preflight remedies that rename the server *away* from `codex`), `README.md:98`, and the unknown-tool message in `codex-gate.sh:392`. → Task 6

### C. Accepted residuals — must survive unchanged, not be engineered away

- [ ] **C1** — Spec §4: a reworded backgrounding notice, on any runtime where auto-backgrounding is still effective, is counted again. Preserved by Task 5; named in the CHANGELOG (Task 7).
- [ ] **C2** — Spec §5.2: an `unrecognized` call whose disclosure is neither delivered nor persisted is counted silently. **Both directions** — suppressed emit, and failed emit — each combined with a failed pending write. Preserved by Task 5; asserted by two named oracles.
- [ ] **C3** — Spec §5.1: counter mutation is unserialized and `.context/` is trusted. Pre-existing, filed in `todos.md`. Preserved by Task 5 (no locking is added).
- [ ] **C4** — **Concurrent check-emit-write on the diagnostic markers** duplicates or loses a disclosure, in both directions. Spec §6 accepts this under "delivery is best-effort". Recorded rather than repaired — a partial fix over one state family would be the inconsistent repair §5.1 refuses. The sequential tests must not be read as guaranteeing more. Named in the CHANGELOG (Task 7).

### Watch-item

**If this plan's Gate-A findings concentrate on A5–A7, STOP AND SURFACE rather than elaborating.** The named pressure valve is a *simpler composition semantics* — dropping compose-into-one-emit for a single deferred flush, or accepting a duplicated disclosure instead of tracking pending/shown. That trade changes what the design promises about delivery, so it is decided upstream by the human. It has not fired: A5–A7 drew 6/36, 4/28, ~5/27, ~4/24, 3/17, ~4/35.

**A genuine `NO FINDINGS` exit is expected, and narrowing the scope does not change that.** The smaller artifact is a scope correction, not a judgement exit through the back door. If it still cannot go clean, the stop-and-surface rule fires exactly as before. Two stop-and-surface events have already occurred (passes 3 and 6); a third is the human's decision, not a reason to lower the bar.

---

## Global Constraints

- **The hook always exits 0.** Every path, including a classifier failure, an unwritable marker and a failed emit. Withholding a *count* must never become a non-zero *exit*.
- **Marker writes use `printf '%s' '' > f`, never `: > f`.** `:` is a POSIX **special builtin**: a redirection failure on one makes the shell exit, ignoring the enclosing `{ … } 2>/dev/null || true` and even an `if`. Verified 2026-08-01 — with a directory at the target, the `:` form prints nothing and exits **2** under `dash`, while the `printf` form exits 0. Ubuntu's `/bin/sh` **is** `dash`, and CI runs `ubuntu-24.04`. **This is a live defect in the shipped hook:** `codex-gate.sh:394` uses that form today, so on Linux an unwritable `.context/` makes the hook exit 2 from the unknown-tool branch — invariant 1 violated in released code. Task 4 fixes it. The existing "special-builtin redirection regression" test only ever ran under macOS `sh`, where the form survives, which is why it stood.
- **POSIX `sh` only.** No bash-isms. `shellcheck --shell=sh` is in the battery, and it applies to the suite as much as to the hook.
- **`awk` and `sed` are both required for classification; `jq` is irrelevant to it.** `awk` locates, `sed` runs the blank test. A failure in either is uncertainty, not a verdict: an `awk` status that is neither 0 nor 1, and a nonzero `sed`, both map to `unrecognized` — counted, disclosed, never a guess. `sed`'s status is checked for a specific reason: a failed substitution yields an empty string, which reads as blank and would classify a genuine success envelope as `no-result` — fail-**closed**, the one direction this design refuses for a result it can see.
- **Loose in the firing direction.** On uncertainty, fire. A false ✓ is the dangerous direction.
- **Hook messages are prompts.** `docs/prompt-standards.md`, all 12 items, for every string added or changed. The final strings are in Task 5 — Gate A cannot review a prompt that does not exist.
- **Never `git add -A`.** Stage the exact paths each task names, and **check the index first**: `git diff --cached --name-only` must contain nothing outside that list before committing. A pre-staged unrelated file otherwise enters the WIP commit and then the squash, silently.

### The battery, per commit

- **Before committing** — the full `quality` row of `AGENTS.md` § Commands **minus** `check-version-bump.sh`. That is six `shellcheck` invocations, **four** script runs and `claude plugin validate . --strict` — not three, as an earlier draft said; miscounting is how `check-invariants.test.sh` or `check-version-bump.test.sh` gets dropped while the task still claims the full battery. **This block, verbatim:**

```sh
shellcheck --shell=sh plugins/dev-workflow/hooks/codex-gate.sh && \
shellcheck --shell=sh --exclude=SC2015 plugins/dev-workflow/hooks/codex-gate.test.sh && \
shellcheck --shell=sh scripts/check-invariants.sh && \
shellcheck --shell=sh --exclude=SC2015 scripts/check-invariants.test.sh && \
shellcheck --shell=sh scripts/check-version-bump.sh && \
shellcheck --shell=sh scripts/check-version-bump.test.sh && \
HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh && \
HOOK_SH=dash dash plugins/dev-workflow/hooks/codex-gate.test.sh && \
sh scripts/check-invariants.test.sh && \
sh scripts/check-invariants.sh && \
sh scripts/check-version-bump.test.sh && \
claude plugin validate . --strict
```

  Every later task means **this**, run and green — re-read it against the `AGENTS.md` row before the first commit, since that row is the source of truth and this is a copy.
- **The `dash` run needs `HOOK_SH=dash`, and without it the run is theatre.** Every runner in the suite invokes the HOOK through `$HOOK_SH_BIN`; the variable defaults to `sh`, so `dash codex-gate.test.sh` alone executes the harness under dash and the hook under whatever `/bin/sh` is — bash, on macOS. That is exactly the gap Gate-B pass 1 found in this cycle's own release evidence, after the earlier wording here invited it. The special-builtin defect is shell-dependent and macOS `sh` does not expose it; claiming `dash` coverage without running the HOOK under dash is what let it ship. If `dash` is unavailable, say so and record CI-on-Ubuntu as the only evidence, rather than claiming both.
- **After committing** — `sh scripts/check-version-bump.sh "$BASE"`, with `$BASE` the SHA recorded at Task 1. It compares commits, so the commit must exist first; and passing `main` on this checkout compares HEAD with itself and succeeds trivially, which is not evidence.

## File Structure

| File | Responsibility | Task |
|---|---|---|
| `plugins/dev-workflow/.claude-plugin/plugin.json` | version bump `0.7.1` → `0.8.0` | 1 |
| `plugins/dev-workflow/hooks/fixtures/*.json` + `*.response.json` + `README.md` | sanitized captured payloads | 1 |
| `plugins/dev-workflow/hooks/codex-gate.test.sh` | the suite, written test-first against this plan's oracles | 2, and every task after |
| `plugins/dev-workflow/hooks/codex-gate.sh` | `emit` status, buffered output, locator, classifier, state effects, messages | 3–5 |
| `README.md`, `CLAUDE.md`, `commands/workflow-init.md`, `AGENTS.md`, `docs/architecture.md`, `codex-gate.sh` | the shipped statements this change falsifies, and the layout trees the new directory drifts | 6 |
| `plugins/dev-workflow/CHANGELOG.md` | the entry, written when the behaviour it describes exists | 7 |

**Ordering rationale.** The manifest bump is in the **first** plugin-touching commit: `check-version-bump.sh` compares base against HEAD, so once any plugin file is committed without a bump every later task fails it. The CHANGELOG entry is not there — an intermediate commit carrying a released version whose entry describes absent behaviour is misleading history. Fixtures and helpers land before any behaviour change. `emit`'s status change and the output buffer land before the markers that depend on them. Documentation lands after the behaviour it describes is real.

**Every intermediate commit is `WIP:`-prefixed.** CLAUDE.md §5 is *tests green → Gate B → commit*, and the hook treats any non-`wip` commit as closing a Gate-B cycle: it resets the counters and fires a STOP on the next one. Six plain commits before the single Gate-B cycle would be six plugin changes that each closed a cycle without a review — and on a shared or interrupted branch they are what someone else pulls. Task 7 squashes them into one reviewed snapshot **before** Gate B runs.

---

### Task 0: Execution preconditions

Before any of this runs. Neither is optional, and both exist because the working tree at
Gate-A close is **not** clean.

- [ ] **Commit the approved Gate-A artifacts first, on their own.** The spec amendment (§3.1)
  and this plan are unstaged edits right now. Left that way, they either fall outside every
  WIP snapshot and the whole Gate-B range — the settled amendment invisible to the reviewer
  — or get swept into the squash without appearing in the reviewed diff. Commit them as a
  normal docs commit (`docs/**.md` is prose, so Gate B is N/A per CLAUDE.md §5), **then**
  record `$BASE`.
- [ ] **Then stop on anything unaccounted.** `git status --porcelain` must be empty. A
  stray edit or a pre-staged file otherwise enters the first WIP commit, then the squash,
  and the pre-reset path audit in Task 7 cannot see what it never staged.
- [ ] **Record `$BASE = git rev-parse HEAD` here, after those commits and before Task 1**,
  and write the literal SHA into a durable note — the execution log or the evidence entry
  draft — not a shell variable. Tasks 1 and 7 both need it, in different shells, hours
  apart; a variable that lived in one terminal is how Gate B ends up with the wrong range.
  Validate it with `git merge-base --is-ancestor "$BASE" HEAD` before each use.

### Task 1: Fixtures and the version bump

**Files:** modify `plugins/dev-workflow/.claude-plugin/plugin.json`; create `plugins/dev-workflow/hooks/fixtures/` with seven payloads, their `*.response.json` slices, and `README.md`. Source (untracked, never shipped): `.context/probe-payloads/`.

**Produces:** `$FIXTURES` — `"$(cd "$(dirname "$0")" && pwd)/fixtures"` — used by every later task.

- [ ] **Step 1: Bump the manifest version.** `0.7.1` → **`0.8.0`** — minor, not patch: the hook changes what a gate call does to the counters, which is new behaviour under the same interface. Invariant 12's checker cannot judge that, so it is named here. **No CHANGELOG entry yet** — Task 7.

- [ ] **Step 2: Sanitize the four captures BY HAND.** Not with `jq`: rewriting a payload through `jq` reserializes `tool_response`, erasing exactly the escape and whitespace variants the matcher must read — while a `jq -c '.tool_response'` comparison would still report "identical", because it compares semantics, not bytes.

  **The seven fixtures, source to destination.** Verified against `.context/probe-payloads/` on 2026-08-02; note the one rename, which no earlier draft named and which every later inventory depends on:

  | Source | Destination | Origin |
  |---|---|---|
  | `shape0-success.json` | `shape0-success.json` | capture |
  | `shape1-fast-fail-execution-failed.json` | **`shape1-fast-fail.json`** | capture, **renamed** |
  | `shape2-executor-timeout.json` | `shape2-executor-timeout.json` | capture |
  | `shape3-backgrounding-notice.json` | `shape3-backgrounding-notice.json` | capture |
  | — | `shape0-success-review.json` | Step 4, synthetic-repo capture |
  | copy of `shape0-success.json` | `collision-success-quotes-both.json` | Step 5, synthetic |
  | copy of `shape1-fast-fail.json` | `collision-failure-quotes-true.json` | Step 5, synthetic |

  Each gets a sibling `<name>.response.json` (Step 6), so fourteen files plus the README. Every later label, slice check, replay row and counterfactual uses **these** names.

  Edit **only** these values, changing no byte inside `tool_response`:

  | Field | Replacement | Why |
  |---|---|---|
  | `session_id`, `prompt_id` | `00000000-0000-0000-0000-000000000000` | session identity |
  | `transcript_path` | `/dev/null` | absolute path under `~` |
  | `cwd`, `tool_input.workingDirectory` | `/tmp/fixture-repo` | machine layout; the second carries a private scratchpad path |
  | `tool_use_id` | `toolu_fixture` | session identity |
  | `tool_input.instruction` | `probe: reply with ok` | prompt content across a trust boundary |

  `permission_mode` and `effort` carry no machine or prompt data and stay as captured. The `tool_input` **object is kept**, not emptied: this repo's own gate prompts quote payload text, so a realistic `tool_input` is what makes the decoy tests mean anything.

- [ ] **Step 3: Prove `tool_response` survived byte-exact.** Extract the located block from source and copy with the same locator, and compare. **Requirements on the procedure**, since they are what earlier drafts got wrong: both extractions must be checked for **status 0** before their outputs are compared (two failed extractions produce two equal empty strings and would print `OK`); the step must **exit nonzero** on any mismatch (a bare `echo STOP` exits 0); and `diff`'s status must be accepted at 0 or 1, with only a real error failing it. Run Steps 3 and 7 in **one shell**, with the locator materialized once and cleaned up once — assuming a temp file survives between checklist steps in different shells is how this breaks.

  The locator body is **not** in this plan (see the scoping note). Materialize it from `.context/plan-drafts/locate.awk`, or reconstruct and re-verify it against `verify.sh` first.

  **Then read every `diff` yourself.** Only the Step-2 fields may differ. The automated half proves the located block is byte-identical; the human half catches a field nobody listed. The README states the bound: what is pinned byte-exact is the **located text block**, not every byte of the surrounding array.

- [ ] **Step 4: Capture the review-tool fixture — in an isolated install.** `tool_response` cannot be redacted afterwards, so it must never contain real work: capture against a **disposable synthetic repository** with invented content.

  **Isolation is mandatory, not preferred.** The method in `.context/probe-payloads/INDEX.md` inserts a stdin dump into the *globally installed* cached hook, which serves every project on the machine and would record complete payloads — prompts, absolute paths, review content — from any concurrent work. Use a separate Claude Code profile or a scratch plugin install. **If isolation cannot be established, stop and surface** rather than mutating the shared cache: the fixture is worth less than the exposure.

  Should a human later decide the shared-cache route is acceptable anyway, the procedure needs all of: a guarded backup whose checksum status is checked directly (`cmd | cut` reports `cut`'s status, so a partial checksum reads as verified); **one** cleanup function, idempotent, that restores and verifies before releasing the backup; signal handlers that **exit** after cleanup; no `trap -` before the restore; and deletion of every payload the dump captured for a call other than this one.

  **Then read the whole fixture end to end before staging it.** No real path, code excerpt or finding text. A manual gate — the thing it guards is content, not shape. Same read for the four sanitized captures.

- [ ] **Step 5: Create the two collision fixtures.** Copy `shape0-success.json` and `shape1-fast-fail.json`; edit the `summary` inside the result text so each quotes **both** marker literals. **Synthetic by necessity** — no real call produces them — and the README says so. They pin the failure direction: a success quoting `false` stays `success`, a failure quoting `true` stays `failure`.

- [ ] **Step 6: Write the response slices.** For each fixture, a sibling `<name>.response.json` holding only that fixture's `tool_response` array, byte-identical to the slice inside the payload. Copy by hand; do not re-serialize.

  This is the one representation choice, made here rather than left open: the driver must build payloads **without `jq`**, or a machine with no `jq` fails the driver rather than the hook — and `sed`-extracting a multi-line array at test time is a second parser nobody reviews. The cost is one duplicated slice per fixture, which Step 7 pins.

- [ ] **Step 7: Prove each slice matches its payload**, in the same single shell as Step 3, exiting nonzero on any drift. What it compares is the **located block**, not the whole array: two slices differing only in inter-element whitespace would pass, and the README must not claim more. Its **permanent** form belongs in Task 5, where the locator lives in the hook and the suite can drive it with no untracked reference — a permanent test reading an ignored path is green here and broken in every clone.

- [ ] **Step 8: Write the provenance README.** What was sanitized and how; that `tool_response` is byte-exact and *what that claim covers*; why the review fixture came from a synthetic repo; which fixtures are synthetic; why the slices exist and what pins them; one row per fixture naming the class it exercises.

- [ ] **Step 9: Battery and commit.** Write out the full pre-commit block here (see § The battery), then check the index, stage exactly `plugins/dev-workflow/.claude-plugin/plugin.json` and `plugins/dev-workflow/hooks/fixtures`, commit as `WIP: test(hooks): ship sanitized captured payloads as fixtures (0.8.0)`, and run `sh scripts/check-version-bump.sh "$BASE"` afterwards.

  `$BASE` was recorded in Task 0, **before** this commit — not derived here as `HEAD~1`, which is wrong the moment a fix adds a commit, and not used before it exists, which is what an earlier draft did by calling the version checker with an unset variable.

---

### Task 2: The suite harness

Every helper later tasks rely on, defined before first use so no section aborts under `set -u`. **The shell is written here, test-first, not copied from this plan** — `.context/plan-drafts/harness.sh` is an unrun seed whose header lists the three problems it is known to carry.

**What the harness must provide**, by contract:

| Helper | Contract |
|---|---|
| `payload`, `resp`, `resp_from`, `resp_success`, `unrec` | build payloads and responses with **`printf` and `cat` only** — no `jq`, or the driver becomes the thing under test |
| `payload_from` | retarget a whole captured fixture to another tool name, touching one field and no `tool_response` byte |
| `run`, `rev`, `revout`, `execp`, `codextool`, `codextool_unrec`, `rev_noresult` | capturing and silent runners, **named for which they are** — a silent runner behind a message assertion makes it vacuous |
| `run_closed`, `nojq_run`, `nojq_run_closed` | stdout closed, and the jq-free `PATH`, in both combinations |
| `mk_path` | restricted `PATH` builders. Must pass `shellcheck --shell=sh`: the obvious `mk_path nojq $HOOK_CMDS` form splits an unquoted expansion (SC2086) and a command substitution (SC2046) |
| `reset_all`, `reset_gate_state` | full reset **including the opt-out marker**, and a narrow gate-state-only reset for scenario sequencing |
| `class_of` | one invocation's class from **that invocation's own** effects — counters, markers, and an exact message substring. No cross-test global state |
| `run_scenario` | one hook invocation per branch name, with per-scenario setup and cleanup |
| `field_of`, `golden` | exact field comparison, **consistently** handling the jq-free case in every caller |

**Two contracts the restricted `PATH`s must satisfy, because getting them wrong makes whole sections pass vacuously:**

1. **Every external command the hook runs must be linked**, not just the one being tested. `tree_hash` shells out to `mktemp` and `cp`; without them every jq-free Gate-B scenario computes `unavailable` and takes a different branch, so a matrix claiming to compare `jq` and jq-free would compare two different code paths. **Oracle:** under the jq-free `PATH`, a success fixture records a **usable, self-matching** fingerprint. If it does not, the jq-free rows prove nothing and must not be reported as coverage.
2. **A fault shim must fail only what it targets.** Removing `sed` entirely breaks `field()`'s routing, so the hook never reaches `emit` and an encoder-failure test passes for an unrelated reason. Every shim is verified in both directions — the normal path still works, the targeted path fails — before any assertion depends on it, and a shim that cannot be built prints `skip -` **with its dependent assertions skipped too**, not left to run.

**Then convert the existing suite:** every payload representing *a gate call that should count* carries a real success envelope, including the mapped-tool sections. The only result-less payloads left are inside `rev_noresult`.

**Oracle for this whole task:** the suite passes against the **unchanged** hook. The hook ignores `tool_response` today, so adding it changes nothing — which is what makes this task behaviour-neutral and provable.

Commit: `WIP: test(hooks): drive gate calls with real result envelopes`.

---

### Task 3: `emit` propagates writer status

Spec §6 defines marker-writing as conditional on "a complete hook JSON document was written". `emit` returns 0 unconditionally after its output command.

**Produces:** `emit` returns `0` written · `1` suppressed by the off-switch · `2` write failed. Callers treat **only 0** as "shown".

- [ ] **Step 1: Implement.** Both `jq` and fallback branches return 2 when their writer fails. In the fallback, **both `sed` encoder substitutions must succeed or return 2**: a failed substitution yields an empty field while `printf` still exits 0, so without the check a truncated document reports "written" and burns a one-shot on a message nobody can read.

- [ ] **Step 2: B2's hook-side occurrence, in the same edit.** `codex-gate.sh:291` says state tracking "keeps running so re-enabling is accurate". Replace with: *"State tracking keeps running while off, so re-enabling carries the same counting semantics as if the gate had been on — not a guarantee that every counted call was reviewed."*

**Oracles:**

| Label | Must fail on |
|---|---|
| `hook exits 0 with stdout closed` | any path where a dead stdout propagates a nonzero exit |
| `a failed write does not burn the one-shot` | `emit` returning 0 after a failed write. Asserted through the **unknown-tool note**: a successful review `PostToolUse` emits nothing, so closing stdout on it exercises no writer at all and both outcomes hold before the change |
| `jq-free: failed write does not burn the one-shot` | the same, through the fallback emitter |
| `encoder failure exits 0, prints nothing, burns nothing` | an empty-but-well-formed document being written and treated as success. Needs the **selective** `sed` shim |

Commit: `WIP: fix(hooks): emit reports whether it actually wrote`.

---

### Task 4: One emit per invocation — discharges A7, and A6's mechanism

Spec §6: an invocation owing two messages composes them into one document. Impossible while each branch writes as it decides, so output is **buffered** and written once at the end. **Behaviour-neutral**: the same branches say the same things through a different pipe.

**Produces:** `note ctx msg` (append) and `flush_notes` (write once, then apply one-shot markers). `emit` is called from `flush_notes` and nowhere else.

**A7 — separator and encoding.** `additionalContext` bodies join with `" — "` (space, em dash, space); `systemMessage` bodies with a single space. **No newline anywhere** — the `jq`-free emitter escapes only backslash and quote, and a literal newline would produce an invalid JSON document. A disclosure carried from an earlier event is prefixed `Earlier: ` in **both** fields, so the model-facing and user-facing copies cannot disagree about which call the statement is about.

- [ ] **Step 1: Add the buffer and convert all nine call sites.** Every `emit "…" "…"` becomes `note "…" "…"` with identical strings. The one site that read `emit`'s status — the unknown-tool note — sets a `mark_noted` flag that `flush_notes` applies only on status 0. `flush_notes` runs immediately before the final `exit 0`; both earlier `exit 0`s (not adopted, not a git repo) are before any `note`, so nothing is buffered when they fire.

- [ ] **Step 2: Convert `codex-gate.sh:394` to the `printf` form** as part of moving it — this is the live invariant-1 defect in § Global Constraints.

**Oracles:**

| Label | Must fail on |
|---|---|
| `<branch> emits exactly one document`, for all nine emitting branches | zero output as well as two. **`= 1`, never `-le 1`** — `-le 1` passes a dropped message, which is the failure this assertion exists to catch |
| `a silent event emits nothing` | any output on a reachable non-emitting event |
| the existing suite, unchanged | any behavioural difference from the conversion, including *"suppressed note does not burn its one-time marker"* |
| `exits 0 with a directory at the marker path`, **under `dash`** | the special-builtin exit. macOS `sh` does not expose it |

**`silent` must be an event the hook actually receives.** `hooks.json` registers **two different matchers** — verified 2026-08-02: `PostToolUse` is `^(Bash|Skill|mcp__codex__.*)$` and `PreToolUse` is the unanchored `Bash|Skill`. It is the **PostToolUse** one that matters here, and under it a `PostToolUse` for `Edit` never arrives in production, so a debt-flush test built on it proves nothing about a reachable invocation. Use a **non-commit Bash `PostToolUse`**. Cite the event when citing the matcher: the two are not the same string, and `run_scenario` drives both events.

Commit: `WIP: refactor(hooks): buffer output so one invocation writes one document`.

---

### Task 5: Classify and act — discharges A1–A5, completes A6

**One task and one commit, deliberately.** Splitting locator, classifier, wiring and disclosure produced intermediate commits that could not be green: the classifier is unobservable until it is wired, and the wiring calls the diagnostic interface. Each such commit would ship either a function nothing calls or a call to a missing function.

**A1 — the state machine, stated operationally.** The scan holds the whole payload in one string and walks it with three primitives. `readstr` consumes a JSON string from its opening quote and returns the index of its closing quote, yielding the **raw** bytes between them. **Backslash parity is the whole rule** — a backslash takes the next byte verbatim whatever it is, so `\\` ends parity and the following `"` closes the string, while `\"` does not. It was written as a byte-at-a-time `esc`-flag loop; that loop was quadratic (`substr(s,j,1)` is O(len) per call in BWK `awk`), so it is now **one anchored `match()`** encoding the same parity rule, extracting once with `substr`. Same accepted language, same bytes returned — the mechanism changed, not the contract. `skipws` consumes space, tab, newline and CR. `skipval` consumes one **span**: a quote-aware string; a balanced container span whose closers must match their openers (`[1}` is rejected); or a primitive, only if the token is exactly `true`, `false`, `null` or a JSON number. It does **not** parse a container's members. **"Depth 1" is not a counter** — it is the structural position the walk occupies: the top-level loop reads key/colon/value triples of the payload's single outer object and nothing else, so a `tool_response` inside any string or nested container is never a candidate.

**A2 — recognition, and what carries the safety. `locate_result` is a locator, not a validator**, and this paragraph claims nothing more. Three passes read a stronger promise into the prose than the code keeps; the promise is stated at its true size and pinned by fixtures rather than by wording.

**What makes the walk trustworthy is string-boundary tracking, and nothing else.** `readstr` decides where every JSON string starts and ends, from quote state and backslash parity alone. That one property is why a `tool_response` mentioned *inside* a string — the `tool_input` decoy, a result quoting the key, this repo's own gate prompts — is never mistaken for the key. **Malformation outside a string boundary cannot redirect the walk**: it may be stepped over, but it cannot move where the next string begins.

**Refusals it makes**, each tested: a second depth-1 `tool_response` key; a repeated `type` or `text` member in **any element the scan examines**, not only the one it would select (verified: a duplicate inside a non-text element *preceding* a valid text block also refuses — stricter than the first-text-element rule requires, and it is the behaviour, so the prose states it); a document not starting with `{`; a non-string key, missing colon or unterminated string in the path it walks; a mismatched container delimiter; **a stray comma in the path it walks**; a bare token that is not a JSON literal; garbage after the outer object's `}`; and **nesting deeper than 200**.

**The comma rule is scoped to the walked prefix, and the scope is the whole of it.** The scan **exits as soon as it selects a text block**, so nothing after that element is examined at all — a *trailing comma after the selected element* is not refused, it is never seen. The frozen verifier pins that case as `success`, and the suite asserts it. Stating the rule unqualified described a validator the code is not (P9-4).

**Refusals it does NOT make, frozen as fixtures asserting today's behaviour.** A *walkable* invalid document is walked past and the real block located, status 0 — `[1,]`, `{"a" 1}` and `"\q"` in a sibling value are pinned so this correspondence is checked mechanically instead of argued again. The response array is walked only as far as the selected element. An escaped key spelling is compared as raw bytes and simply does not match.

**Why that is the right size.** The payload's producer is Claude Code, whose serializer emits valid JSON, so a walkable-invalid document is synthetic. And the threat a validator would answer is one **spec §10 already accepts by name**: a mapped third-party tool is trusted for counting, so a hostile server needs no malformed JSON — it can return `{"success": true}`.

**Two bounds, and what each does and does not cover.** The **length ceiling** refuses a payload whose accumulated length would exceed 1 Mi *`awk` length units* — not bytes: POSIX `awk`'s `length()` counts characters and implementations differ on multibyte input, so the cut-off is not identical between BWK `awk` and `mawk`. It bounds the **scan**, not memory: `payload=$(cat)` already holds the whole input and `awk` still ingests it. The **depth cap** refuses nesting past 200, because the closer stack is a string and each push is O(length), making deep nesting quadratic in work an external MCP result could dictate. Neither is a contract; both are backstops, and both route to `unrecognized`.

**Both bounds are SIZE bounds, and a size bound only bounds work if the work is linear in size — which it was not.** Gate B on the implementation measured a 150 KB text block, comfortably under the ceiling, at **10.9 s in one synchronous hook invocation**, and the cost grew quadratically: ×3 size cost ×8.4 time. Two independent quadratics, both fixed here, both now covered by a timed regression row with a stated bound rather than by prose:
- `readstr` accumulated the value byte-by-byte **and** re-derived `length(s)` per iteration; worse, `substr(s,j,1)` is O(len) per call in BWK `awk`, so any per-character walk over the payload is quadratic on its own. It now finds the string with one anchored `match()` and extracts once.
- The `backgrounded` test evaluated `${b%%\n*}` on every block. `%%` removes the **longest** matching suffix, which bash 3.2 — macOS `/bin/sh`, what the hook runs under — evaluates by trying successively longer suffixes; with no `\n` present that is quadratic, and it dominated everything else (5.4 s at 150 KB, 21.6 s at 300 KB). It is guarded by the cheap literal prefix the anchor already requires **and** truncated to a bounded head before it runs — the guard alone was not enough, as the paragraph below records.

A third quadratic sat behind the second and was found by the next Gate-B pass: guarding the expansion on the anchor prefix left it running in full for any block that *does* start with the anchor and then never completes the notice — 5.9 s at 150 KB — and the first timed fixture began with an envelope, so it took the guard's cheap path and never reached the branch. The head is now truncated to a bounded 4096 characters before the expansion runs, which costs one documented limit: a notice whose quoted tool name exceeds ~4070 characters is `unrecognized` rather than `backgrounded`, so it counts.

**What is bounded, and what is NOT — stated this way because three consecutive attempts at this paragraph each claimed more than held.** Bounded now: the ordinary success/failure envelope path (150 KB in 0.46 s), and the anchor-prefixed near miss in both its `\n` placements. **Still quadratic — TWO paths, not one.** (a) `skipval` walks a container character by character, and `substr(s,i,1)` is O(len) per call in BWK `awk`, so a large *valid sibling container before* `tool_response` costs 3.2 s at 200 KB and 11.5 s at 400 KB. (b) The record accumulator `s = s $0 "\n"` rebuilds the whole input once per input line, so a **newline-rich** payload is quadratic in line count independently of (a) — a pretty-printed payload costs 0.35 s at 4k lines, 0.75 s at 8k and 2.69 s at 16k. Naming only (a) was itself a finding at pass 3: the timed rows all use large single-record payloads and never reach (b). Only the 1 Mi-unit ceiling stops that path, which means the ceiling is doing real work rather than serving as a formality — and a payload just under it still costs tens of seconds. So the ceiling does **not** bound the work at roughly two seconds in general; it bounds it at roughly two seconds *on the shapes measured above*.

**The general claim to keep, because it is the one that was missing:** a size backstop says nothing about time unless the per-byte cost is constant, and in POSIX shell and `awk` it frequently is not — `substr(s,i,1)` and `${var%%pat*}` are both O(len) per operation here. **And the procedural lesson, earned three times in one cycle:** a timed row only covers the branch its own fixture reaches, so "the curve is linear" generalized from one measured shape has been wrong every time it was written.

Malformed JSON is **not a class**: per spec §3.3 a payload the hook cannot *route* never reaches here. **Routability itself depends on `jq`, and that predates this change**: with `jq`, `field()` on a malformed document returns empty and the hook exits silently; without it, the `grep` fallback can still read a tool name, so the same payload routes and lands in `unrecognized`. That divergence belongs to `field()` and is left alone — stated because a reader comparing the two environments will otherwise read it as a classifier bug.

**A3 — the accepted encodings, complete.** Whitespace is accepted at exactly **four** points — after the encoded `{`, after the key `\"success\"`, after the `:`, and **after the value token**, where `_token_ends` strips before testing for a delimiter — and at each: literal ASCII space, and the two-byte escapes `\n`, `\t`, `\r`. Nothing else; a Unicode escape is not whitespace here and needs no special handling, because it matches no anchor and the terminal default carries it to `unrecognized`. **Blank** is the same alphabet over the whole block. **The value token must end** at a delimiter — `true` followed by anything other than encoded whitespace, `,` or `}` is `unrecognized`, because `true*` alone accepts `truely`, a false **success**. Whitespace stripping is bounded at 64 units; past it the prefix match fails and the block is `unrecognized`. The blank test is one `sed` pass, so a large blank block costs linear work in `sed` rather than shell iterations.

**A4 — the notice grammar, and what is deliberately outside it.** The anchor is exactly: the block **begins** `MCP tool \"` (escaped quote — the shared representation carries `\"`, and a draft expecting a literal `"` did not match the real capture at all), and the segment `\" is still running after ` occurs **before any `\n` escape**, **within the first 4096 units of the block** — a bound added for performance that narrows this class: a notice whose segment falls past it is `unrecognized` and therefore COUNTS rather than being discarded. ~200x the longest real tool name, tested immediately inside and outside the cutoff, and stated in spec §4. Everything else is variable **by decision**: spec §4 places the quoted tool name, the threshold digits and unit, and the task id outside the anchor so it covers both gate tools, any mapped name and any threshold. Validating a duration format would narrow the anchor to shapes observed once, widening C1 rather than closing it. **Near-misses that must not match**, each tested: the phrase later in the text; a whole notice quoted inside a real envelope's `summary`; a block beginning `MCP tool \"` with no `is still running after`; the segment appearing only after a `\n`.

**A5 — the complete marker table.** Three files: `codex-gate.bgAdvice`, `codex-gate.unverified` (shown), `codex-gate.unverifiedPending` (owed). `bgAdvice` is independent of the other two.

| `unverified` | `pending` | Event | Result |
|---|---|---|---|
| absent | absent | `unrecognized`, flush wrote (0) | write `unverified` |
| absent | absent | `unrecognized`, flush suppressed (1) | write `pending` |
| absent | absent | `unrecognized`, flush failed (2) | write `pending` |
| absent | absent | `unrecognized`, flush wrote, **`unverified` write fails** | write `pending` — the debt survives the marker |
| absent | present | any unsuppressed **routed** event | prepend `Earlier: ` disclosure; on 0 → write `unverified`, delete `pending`; on 1 or 2 → **retain** `pending` |
| absent | present | the current event is **itself `unrecognized`** | one disclosure, **no `Earlier:` prefix**, pending cleared on a successful write |
| absent | present | flush wrote, `unverified` write fails | **retain** `pending` (duplicate beats loss) |
| absent | present | flush wrote, `unverified` written, **`pending` delete fails** | present+present → next row |
| present | present | any routed event | delete `pending` best-effort at flush start; no disclosure |
| present | absent | `unrecognized` again | nothing emitted, nothing written |
| absent | absent | `unrecognized`, flush **suppressed** and `pending` write fails | counted, nothing delivered, nothing recorded — **C2, direction 1** |
| absent | absent | `unrecognized`, flush **failed** and `pending` write fails | counted, nothing delivered, nothing recorded — **C2, direction 2** |
| any | any | any other marker write fails | proceed, exit 0; the debt is retained or retried per the rows above |
| `bgAdvice` absent | — | `backgrounded`, flush wrote | write `bgAdvice` |
| `bgAdvice` absent | — | `backgrounded`, flush suppressed or failed | **not** written — the one-shot stays unspent |
| `bgAdvice` present | — | `backgrounded` | short form; no write |

**The prefix is about whose call the statement describes**, not where the debt came from. `Earlier: ` exists so a carried disclosure cannot read as a statement about the current call; when the current call is *itself* `unrecognized`, the statement **is** about it, so no prefix — one message covers both and pending clears. That is why `note_unverified` setting the flag takes precedence over the pending check.

**C2 is two rows, not a property of marker writes generally.** A failed `bgAdvice` write costs a repeated advice message; a failed shown-write followed by a successful pending write keeps the debt and repeats the disclosure; a failed pending *delete* leaves the coexistence row, cleaned up next flush. None is a silent counted pass. Only **undelivered and unpersisted** produces one — in either of spec §5.2's two directions.

Concurrency is **not** covered by this table and is not meant to be: that is **C4**.

- [ ] **Step 1: Declare the message strings.** Final text, in the hook, above the branches. **Five pairs, ten strings.** All declared unconditionally so `set -u` cannot abort on any path.

  **The field split decides where every sentence goes.** Spec §6: `additionalContext` is read by **Claude via Claude Code**; `systemMessage` by **the operator**. A remedy only a human can perform — restarting Claude Code, editing a config, changing a server timeout, unmapping a tool — belongs in `systemMessage`, because the model receiving `additionalContext` cannot do any of it.

  **Structure (item 5):** each `additionalContext` carries compact tagged sections — `<state>`, `<consequence>`, `<next>`, `<stop>` — rather than a flowing paragraph with inline labels, which is what item 5 asks for and what earlier drafts only approximated. Tags are literal text inside a single-line shell string; **no literal newlines**, per A7. Each `systemMessage` reads *state → operator action* **where there is one** — `FAILURE_MSG` carries state plus the one configuration remedy an operator owns, and nothing more.

  **Item 1** is satisfied inside the delivered text: every `additionalContext` opens `Claude Code gate hook —`. A source comment naming the consumer is not the prompt. The header comment stays for the "checked that model's prompting page" half, which a prefix cannot carry.

```sh
FAILURE_CTX='Claude Code gate hook — <state>this Codex call returned an envelope reporting failure.</state> <consequence>Not counted as a gate pass, no review fingerprint stored, does not count toward the floor.</consequence> <next>Read error.code in the tool result. CODEX_EXECUTION_FAILED is the pinned server generic failure code and does NOT tell you whether the call started, so check the accompanying error message and any session artifacts before assuming nothing ran; a call that did start may have left work behind. CODEX_TIMEOUT means the executor gave up mid-run: re-run the SAME call with the SAME scope. Any other code, or no code at all, is unclassified: every envelope whose first property is success false reaches this state, not only the two codes named here, so re-run once with the same scope and, if it repeats, report the code and message verbatim together with the effective server name and version from claude mcp list — an unfamiliar code is itself evidence about which server answered. Never retry with a narrower instruction or a smaller range, because that would count a pass for less than the artifact or diff the gate requires. Report one line: "gate pass discarded | error-code | started yes/no/unknown". Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume.</next> <stop>One retry per pass is the whole recovery budget under CLAUDE.md section 5. If the retry also fails, stop and surface that line; the operator note carries the configuration remedy.</stop>'
FAILURE_MSG='⚠ Codex call failed — not counted as a gate pass. If the code was CODEX_TIMEOUT, the fix is configuration and only you can apply it: raise the executor timeout for the Codex MCP server, or reduce load outside the review. Do not ask for a smaller review scope — a narrower pass is worth less than a slow one.'

NORESULT_CTX='Claude Code gate hook — <state>this gate call carried no result text the hook could read.</state> <consequence>Not counted as a gate pass, no review fingerprint stored.</consequence> <next>Treat the pass as not run and report it. Two causes produce this shape and the tool name cannot separate them: a hooks-API payload change, or a mapped third-party tool returning empty or non-text content. Report one line: "gate call unreadable | mapped yes/no from .context/codex-gate.tools | claude-code version". Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume.</next> <stop>One retry per pass is the whole recovery budget under CLAUDE.md section 5. A repeat is configuration or contract, not a transient failure, so stop and surface it; the operator note carries both checks.</stop>'
NORESULT_MSG='⚠ Gate call returned no readable result — not counted. Run both checks before concluding. First: does .context/codex-gate.tools map a tool name? Second: what does `claude mcp list` show as the effective server and version — not what .mcp.json says, because scope precedence can make a different entry of the same name effective. These checks narrow the cause; they do not prove it. If a mapping or a third-party server is in play, that tool may be returning empty or non-text content, which it can do legitimately: unmap it, or replace it with a server exposing exec and review. If both checks show the pinned server at its pinned version, a payload-contract change is the remaining explanation — record your Claude Code version and report it.'

BG_LONG_CTX='Claude Code gate hook — <state>this gate call was moved to the background at the auto-background threshold, 120 s by default, so its result never reached the hook.</state> <consequence>The pass was discarded and not counted, and no fingerprint was stored.</consequence> <next>The original call may still be running and can still write its findings file later. Stop it by the task id in the tool result, or wait for it to finish, before deleting that slot or re-running the pass. Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume.</next> <stop>Do not re-run while that task is active: a late writer landing in a slot you already re-ran leaves a correctly terminated file from the wrong run, and no downstream check can detect that. One retry per pass is the whole recovery budget under CLAUDE.md section 5. If the call backgrounds a second time, stop and surface it as a setup problem rather than retrying again.</stop>'
BG_LONG_MSG='⚠ Gate pass discarded (backgrounded) — a setup gap, not a failed review. Set CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS in the environment Claude Code is launched from, then restart Claude Code: it reads the value at process start, so exporting it inside a tool shell leaves the running session unchanged. Use 0 to disable auto-backgrounding, or a positive value that exceeds your longest gate call, since a positive value shorter than the call still backgrounds it. Requires Claude Code 2.1.212 or newer.'

BG_SHORT_CTX='Claude Code gate hook — <state>this gate call was backgrounded and its result never reached the hook.</state> <consequence>The pass was discarded and not counted, and no fingerprint was stored.</consequence> <next>Stop or await the original call by the task id in the tool result before re-running the pass. Before re-running, delete the target findings file for the pass and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume.</next> <stop>Do not re-run while that task is active, so a late writer cannot land in a slot you already re-ran. One retry per pass is the whole recovery budget under CLAUDE.md section 5. If the call backgrounds a second time, stop and surface it rather than retrying again.</stop>'
BG_SHORT_MSG='⚠ Gate pass discarded (backgrounded) — not counted. Set CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS in the environment Claude Code is launched from and restart Claude Code; the full guidance was shown once earlier in this workspace.'

UNVERIFIED_CTX='Claude Code gate hook — <state>this workspace has classified at least one gate call as countable without being able to interpret its result, and attempted to record it.</state> <consequence>The counter is a mechanical tally, not a count of completed reviews: it can include calls that failed or reviewed nothing, so it can overstate them.</consequence> <next>Judge every pass on its findings artifact and discount any incomplete or unverified call, whatever the counter says.</next> <stop>Normally said once per workspace. It repeats only when its marker cannot be persisted or two hook runs race, so treat a repeat as a marker problem rather than as new information.</stop>'
UNVERIFIED_MSG='ℹ A gate call was classified as countable without inspection, and recording it was attempted. Causes with a check and a fix: a pinned-server envelope whose key order or formatting changed — compare the version in .mcp.json with the server actually serving the tools (`claude mcp list`), and pinning it back fixes it; a reworded backgrounding notice — set CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS in the environment Claude Code is launched from and restart Claude Code, using 0 to disable auto-backgrounding or a positive value exceeding your longest gate call, needing Claude Code 2.1.212 or newer; a broken awk or sed, which classification requires — check them functionally rather than by version flag, since --version is not POSIX and BSD sed exits nonzero for it on a healthy macOS: `printf "x\\n" | awk "{print}"` must print x and `printf "x\\n" | sed s/x/y/` must print y, each exiting 0. Causes with no user-side fix: a mapped third-party tool whose envelope this hook cannot read — .context/codex-gate.tools names it, and unmapping it removes the gate rather than fixing the envelope; a payload the scan refused as oversized or ambiguous — these two are **not distinguishable from the outside**, since both produce this same message and the same state, so measure the payload size against the 1 Mi-unit ceiling to rule the first in or out and treat the rest as unresolved; and a defect in this hook parser — same situation. For either, keep the payload **locally and access-restricted**: it can contain prompts, absolute paths, review content, session identifiers and unrelated concurrent call data, so strip those before showing it to anyone, and never attach it unsanitized to a report. The list is not exhaustive: unrecognized is the terminal class, so any future unmatched shape lands here too.'
```

  **Every path that permits a retry also requires the §5 cleanup.** `FAILURE_CTX`, `NORESULT_CTX`, `BG_LONG_CTX` and `BG_SHORT_CTX` all direct or allow a re-run, and CLAUDE.md §5 requires deleting every target findings file and **confirming it is gone** before each call — precisely because a died-part-way call leaves a valid-looking file that no terminator can distinguish from a fresh one. Retrying without it recreates a false clean pass through a door the counter fix does not close. Each of those four `<next>` sections therefore ends with: *"Before re-running, delete the pass's target findings file and confirm it is gone — both branch files for a full Gate-B re-run, only the failed branch for a single-branch resume."* The backgrounded pair keeps that **after** its stop-or-await instruction, in that order: deleting a slot while the original call can still write it is the race those messages exist to prevent.

  **Oracle for this step, and it is not optional: pipe the ten assignments through `sh -n`.** They are single-quoted shell strings, so **no ASCII apostrophe may appear anywhere inside them** — POSIX shell cannot escape one within single quotes, and `\'` opens an unterminated quote rather than escaping anything. That defect reached this plan twice (`printf \'x\\n\'`, and a `pass's` in the cleanup sentence) and both would have made the shipped hook unparseable. Write inner examples with double quotes, and phrase possessives around the apostrophe. **Same check after embedding into the hook**: `sh -n`, then `shellcheck --shell=sh`.

  Six wordings are load-bearing and were changed for stated reasons, not style. **`CODEX_EXECUTION_FAILED` does not mean "the call never started"** — the pinned server uses it generically for abort-before-start, abort-after-start and child execution errors, so telling Claude it never started invites overwriting or colliding with artifacts from a call that did. **The timeout remedy is operator-side** and lives in `systemMessage`; the model gets the retry-same-scope rule and nothing it lacks the authority to do. **`NORESULT_MSG` narrows without concluding** — spec §6 says the tool name cannot distinguish the two causes, so provenance evidence must not become a causal claim. **`UNVERIFIED_MSG` keeps the spec's "no user-side fix"** for the unreadable mapped tool: unmapping removes the gate, which is not a fix, and an earlier draft's reclassification contradicted approved spec §6. **Its `awk`/`sed` check is functional**, because `--version` is not POSIX and BSD `sed` exits nonzero for it. **`UNVERIFIED_CTX` says "classified as countable and attempted to record"**, never "was counted" — the counter write is best-effort, and a categorical claim about recorded state is item 11 exactly.

- [ ] **Step 2: Install the locator and matcher** from `.context/plan-drafts/{locate.awk,match.sh}`.

  The `awk` program becomes `LOCATE_AWK`, **a single-quoted shell variable — so it must contain no ASCII apostrophe anywhere, comments included.** Two crept into its comments during this cycle (`caller's`, `machine's`) and were removed; one would terminate the quote and leave the hook unparseable. **Verify mechanically after embedding**: `sh -n` on the hook, then `shellcheck --shell=sh`, then one classification test — a syntax error here is not subtle, but it is also not something a reader reliably spots in a 90-line embedded program. `match.sh` installs as ordinary functions, so its apostrophes are fine; the constraint is the quoting, not the file.

  `locate_result` is the one-line wrapper the classifier calls, and its contract is: feed **`$payload` unchanged** to `LOCATE_AWK` via `awk`, and return `awk`'s status untouched. It must not pre-process the payload, must not consult `jq`, and must not collapse statuses — `0` located, `1` unambiguously nothing there, **anything else** cannot-determine. Collapsing "anything else" to a specific class is how a missing `awk` (127) would become `no-result` instead of the fail-open class.

  Then `strip_ws`, `_token_ends`, `classify_block`, and:

```sh
classify() {
  blk=$(locate_result); rc=$?
  [ "$rc" = 1 ] && { printf 'no-result'; return 0; }
  [ "$rc" = 0 ] || { printf 'unrecognized'; return 0; }
  classify_block "$blk"
}
```

  `[ "$rc" = 0 ] ||` rather than `[ "$rc" = 2 ] &&`: a missing or failing `awk` exits 127, and every status that is not "located" or "nothing there" must reach the fail-open class rather than fall through to a matcher holding an empty string. Two properties belong in comments because a later edit can silently break them: the locator accumulates records and works in `END`, restoring the newline `awk` stripped, because `RS="\0"` is not portably a record separator; and it prints with `printf "%s"`, so no trailing newline is appended — the caller reads it through command substitution, which strips trailing newlines, harmless only because a JSON string cannot contain a raw newline.

- [ ] **Step 3: Wire the classes to state effects.** For each gate tool: `success|unrecognized` fall through to today's behaviour, with `unrecognized` also calling `note_unverified`; every other class calls `note_discarded` and **falls through to `flush_notes`** — no `exit 0` in the discarded branch, or the message just buffered is never written.

- [ ] **Step 4: Implement the diagnostic interface and extend `flush_notes`** per the A5 table. `note_unverified` sets a flag and nothing else: the *decision* is there, the *delivery and state* are in the flush, because only the flush knows whether anything was written.

**Oracles for Task 5.** Each row is a test label and the thing it must fail on. Where a row says "both emitters", it runs twice — once through the normal runners, once through the jq-free pair — and a wrapper that declares the parameters without using them is not coverage.

*Classification — ported from `.context/plan-drafts/verify.sh`.* **Port by label, and account for every one.** The corpus is **53 call sites producing 56 assertions** — one `chk` inside a `for` loop covers the four real captures, so a label count and an assertion count are different numbers and neither substitutes for the other. Enumerate with:

```sh
grep -nE '^[[:space:]]*(chk|p_case) "' .context/plan-drafts/verify.sh | sed 's/".*//'
```

  For each of the 53, record *ported* or *excluded, with which of the two exclusions applies*. A group heading cannot show that `non-object element skipped` or an array-walk boundary quietly stopped being required, which is exactly the decision-procedure-replacement failure `AGENTS.md` names. Every ported row must be a payload the hook **routes**: a complete `hook_event_name` and a gate `tool_name`. A bare `{"tool_response":…}` fragment routes to nothing and would report an unidentified class for every row — a table that looks ported and asserts nothing.

| Group | Must fail on |
|---|---|
| the four real captures | any drift in the shapes this whole change was built from |
| both collision fixtures | a success quoting `false` classifying as failure, or the reverse. The failure direction is where a mistake produces the false ✓ |
| polarity grammar: compact, tab, space-before-colon, CRLF, reordered, glued token, past the 64 bound | a whitespace form silently reclassifying, and `truely` reading as `true` |
| notice anchor + its four near-misses | the anchor matching text that merely contains the phrase, or missing the real capture |
| every `no-result` shape | any of them counting |
| both decoy directions — `tool_input` quoting the key **before**, a result quoting it **after** | a byte-position heuristic returning |
| **block selection**: a non-text first element followed by a real text block, classified from the text block | an `element [0]` implementation, which passes every `no-result` and capture row while violating spec §3.1's settled first-`text`-element rule |
| a duplicate `type`/`text` in a **preceding non-text** element | the stricter any-examined-element refusal regressing while the selected-element duplicate rows stay green |
| duplicate depth-1 key; duplicate `type`/`text` | last-wins classifying an ambiguous payload |
| the three **walkable-but-invalid** rows — **locator-level, exempt by label from the routing rule below** | a future tightening turning the locator into a validator, or a claim about validation widening again. They are malformed *outer* JSON, so with `jq` they never route and with `grep` they do: requiring them to run through the hook would make them vacuous in one environment and untestable in the other. They stay contract tests over the locator, which is the level their claim is about |
| the length ceiling; the depth cap at 201 openers; and ordinary nesting unaffected | either bound disappearing, **or the cap being set so low it refuses real payloads** — the third row is what makes the second safe to tighten |
| Unicode-escaped marker key | a payload malformed for a *different* reason passing as this test. The located text must contain the **six-byte** `\u0022success\u0022` spelling and **no raw quote** around `success`; an earlier version supplied raw quotes, which made the outer payload malformed and reached `unrecognized` from the locator rather than the matcher. Assert the locator **succeeded** before the matcher's verdict |

Two groups stay in the drafts and are **not** ported, stated rather than dropped: deliberately unroutable documents (spec §3.3 excludes them), and documents whose routability depends on `jq` (their behaviour is two different things in two environments, neither the classifier's doing).

*State effects.*

| Label | Must fail on |
|---|---|
| `<class>/<default\|mapped>/<runner> writes no gate-pass state from clean` | an implementation that recomputes and stores the **current** fingerprint over a seeded identical one — byte preservation alone cannot see that. Says **gate-pass** state: a first backgrounded call writes `bgAdvice` by design |
| `<class>/<default\|mapped>/<runner> preserves passCount/freshCount/fingerprint/passCountA` | any discarded class touching earned state, on either gate, under either tool-name source, in **both emitters** |
| `<class> creates no diagnostic marker` / `backgrounded creates its diagnostic marker` | the two state families being conflated |
| `success counts` + `success creates no disclosure marker` | `unrecognized` passing as `success` — their counter and fingerprint effects are identical by design |
| `real review capture is class success with no marker` | a drifted `shape0-success-review` counting through the fail-open terminal class. **Count and fingerprint alone cannot see this** — assert the class |
| `<fixture>: payload and response slice locate identical bytes` — one per fixture, the **permanent** form of Task 1 Step 7 | a fixture edited without its slice. Class-equivalent drift leaves every classification row green while the README's byte-exact claim about the duplicated representation is false. Both locator statuses must be 0 before the bytes are compared |

*Markers, both emitters, one label per A5 row.* Each needs a **surgical** fault, and the two blunt approaches both failed: replacing `.context` with a file removes the adoption marker so the hook exits before classifying, and `chmod 500 .context` breaks the counter writes while stdout still succeeds. What separates operations: a **directory** at a marker path fails `printf > f`; a non-writable `.context` fails `rm` while an **existing** file can still be truncated.

| Label | Must fail on |
|---|---|
| `on: writes shown, owes nothing` · `off: owes pending, no shown` · `failed write: owes pending` | any of the three flush outcomes writing the wrong marker |
| `shown-write failure keeps the debt` | the debt dying with the marker |
| `pending flushes prefixed` · `flush clears pending` | a carried disclosure losing its `Earlier: ` or its cleanup |
| `pending+unrecognized: not prefixed, ctx exact, shown written, pending cleared, still counts` | the precedence between `note_unverified` and the pending check inverting |
| `shown+pending resolves to shown` · `the next event clears the coexistence` | the retry never happening. Needs a **real** pending file: a directory there is not seen as pending at all |
| `shown means silent` | a spent one-shot re-firing |
| `C2/1` and `C2/2`: counted, no output, neither marker, exit 0 | either direction of the accepted residual being quietly closed **or widened** |
| `long advice writes its marker` · `short form names the variable` · `off/failed write does not burn the bg one-shot` · `bgAdvice write failure repeats the long form` | the one-shot burning on a message nobody saw |
| exit 0 with a directory at **each** marker path, under `sh` **and** `dash` | the special-builtin exit |

*Fault tolerance of the two load-bearing tools.* Three shapes each — absent, nonzero exit, partial output then failure — through **both** gate tools.

| Label | Must fail on |
|---|---|
| `<awk fault>: exits 0, review counts, stores a usable fingerprint, discloses; exec counts` | fail-**closed** on pass state while disclosing uncertainty. Input is a real **failure** envelope, the one case where fail-open costs a real count |
| `<sed fault>: exits 0, a success envelope still counts, discloses` | the blank test's empty output reading as blank and turning a genuine success into `no-result` |

*Messages and composition.*

| Label | Must fail on |
|---|---|
| golden on **both fields** for `failure`, `no-result`, `backgrounded` long and short, the disclosure alone, and one composed pair | a negation, a dropped remedy, a reordered composition. Clause greps catch none of those. Expected values are **literal copies** — a golden reading the hook's own variable agrees with any text the hook emits |
| `<scenario>: exactly one document` — for **fourteen**: the nine existing emitting branches from Task 4, plus `failure`, `no-result`, `backgrounded` long, `backgrounded` short, and the disclosure alone | zero output as much as two. Count them explicitly: an omitted branch is the dropped-output failure this oracle exists to catch, and an earlier draft said thirteen while listing fourteen sources |
| `<scenario>: composed ctx/msg exact` | truncation, reordering, duplication or negation of a branch message |
| `<scenario>: pending cleared after a successful flush` | the debt surviving delivery |
| `silent: flushes the debt alone, no separator` | the wrapper failing on the branch that emits nothing of its own |
| one two-message branch through the **jq-free** emitter, both fields exact, then parsed by a real JSON parser | the fallback escaper mangling the longest, most punctuated string it ever handles |

**The composition matrix has one sequencing requirement**, and getting it wrong makes five rows fail for a harness reason: the pending disclosure must still be owed when the **observed** event runs. Scenario setup that itself emits will flush and clear the debt first. Keep the off-switch on through setup and remove it immediately before the observed event.

**Every exact field comparison must handle the jq-free case the same way.** Without `jq` the fallback extractor returns the field's **escaped** bytes, so a decoded expectation fails on any message containing a quote — and every message here contains quotes. One helper, used by every comparison, not just some.

Commit: `WIP: feat(hooks): classify gate results and stop counting the ones that reviewed nothing`.

---

### Task 6: The shipped statements this change falsifies — discharges B1, B2, B3

**Files:** `CLAUDE.md`, `README.md`, `commands/workflow-init.md`, `codex-gate.sh`, **`codex-gate.test.sh`**, `AGENTS.md`, `docs/architecture.md`. The hook because B3 includes the unknown-tool message; the last two because Task 1 added a shipped directory and both carry layout trees.

- [ ] **Step 1: Census.** Three greps, run 2026-08-01. The mechanism claim has **five** sites, not the two the B1 list carried — the extra three phrase it differently, which is why the pattern needs three alternations:

```sh
# `git grep` over TRACKED files, not recursive grep: `.mcp/` holds generated cache copies
# of the hook (AGENTS.md defines it as generated state), and a recursive walk edits or
# counts files nobody ships. An earlier draft said this in prose and left the commands
# recursive — the prose is not the command.
X='source-files/|docs/superpowers/'
git grep -niE 'key(s|ed) on (the )?tool.?name|key on those|counts passes by tool|never (sees|inspects|reads)' -- '*.md' '*.sh' | grep -vE "$X"
git grep -niE 'accurate' -- '*.md' '*.sh' | grep -vE "$X"
git grep -niE 'execTool|reviewTool|codex-gate\.tools' -- '*.md' '*.sh' | grep -vE "$X"
```

| Site | Phrasing | Disposition |
|---|---|---|
| `CLAUDE.md:168` | "keyed on tool name, and never sees the file" | Step 2 |
| `commands/workflow-init.md:347` | same sentence, inline template | Step 2 |
| `commands/workflow-init.md:250` | "The hook counts passes by TOOL NAME" | Step 2 |
| `README.md:59` | "the gates and their pass counters key on those two tool names" | Step 2 |
| `AGENTS.md:70` | "(the gates key on those two tool names)" | **read and decide** — it describes which MCP tools back the gates, which classification does not change |

**The greps decide**, not the list — but read the hits, do not count them. Verified 2026-08-02: grep 1 returns **seven lines for five sites**, because the `CLAUDE.md` and `workflow-init.md` sentences each wrap across two lines (`:168`/`:169`, `:347`/`:348`). A count comparison would report a phantom two-site discrepancy every time.

**Grep 2 has two hits the B2 list does not carry, and they are in the suite:** `codex-gate.test.sh:296` (the section comment *"Full state machine keeps running while off (so re-enable is accurate)"*) and `:306` (the assertion label *"re-enable sees accurate state"*). Both assert the exact overclaim §5.2 retires. Reword both — comment and label — to *"same counting semantics as gate-on, not evidence of review"*, and add `codex-gate.test.sh` to this task's staged paths. Test-suite hits are assertions **about** the strings and change with them; that is a reason to disposition them, not to exclude them.

Exclude generated state explicitly: `.mcp/` holds cache copies of the hook (`AGENTS.md` defines it as generated), and a recursive grep that reaches them sends the census into files nobody ships. `git grep` over tracked files is the simpler guard and is what these commands should use.

- [ ] **Step 2: B1 — correct one clause, keep the other.** *"…keyed on tool name, and never sees the file"* becomes *"…keyed on tool name **and on the result envelope**, and still never sees the file."* **"Never sees the file" stays** — it is about the *findings file*, and discounting an incomplete pass whose findings file is missing remains instruction-backed.

  *"A failed review therefore looks like a successful tool call and increments the counter"* becomes:

> A failed review therefore still looks like a successful *tool call* — but as of 0.8.0 the hook reads the result of gate calls it can route, and withholds the count for three **recognized** shapes: an envelope whose **first** property is `success: false`, the harness backgrounding notice **in the wording it currently uses**, and a result from which no usable text can be obtained. Every other routed gate call counts, including any located text the hook cannot interpret — a reordered envelope, a reworded notice, an unknown third-party shape — which counts **with** a disclosure that is attempted and normally shown once per workspace, but can be lost or repeated when its marker cannot be persisted. So the counter is closer to the truth than it was and is still not evidence: **discount every incomplete pass regardless of what the counter says**, because classification cannot see whether the findings file was written.

  **Six precisions there are load-bearing** and none may be dropped when it is edited: **first property**, not "contains"; **the current wording**, not "a backgrounding notice" (a reworded one is counted — C1); **routed** gate calls, since an unroutable payload touches no state at all; **"located text it cannot interpret" ≠ "no text at all"** — the first is `unrecognized` and counts (decision 2), the second is `no-result` and does not (decision 3), and collapsing them contradicts a settled decision either way; **"no usable text"**, not "absent", since `no-result` also covers null, empty, non-array, non-object, non-text and blank; and the disclosure is **attempted and normally once**, not guaranteed (C2, C4, item 11).

  `commands/workflow-init.md:250` → *"counts passes by tool name and by result envelope"*. `README.md:59` → *"the gates key on those two tool names, and the pass counters additionally skip routed calls whose result the hook reads as failed, backgrounded, or yielding no usable text — a result it can read but not interpret still counts, and normally says so once."*

- [ ] **Step 3: B2 — retire "accurate."** `README.md:97` and `commands/workflow-init.md:1038` take spec §5.2's contract: opt-out preserves the same counting semantics as gate-on, and the counters are never evidence a review happened.

- [ ] **Step 4: B3 — every mapping instruction.** Each states that a mapped name must lie in `mcp__codex__*` and that the remedy is registering the server as `codex`. **`commands/workflow-init.md:74` and `:157` offer renaming the project entry *away* from `codex`** — producing exactly the unreachable configuration decision 1 describes. Remove that remedy unless it also re-registers the effective server as `codex`.

  The unknown-tool message is a shipped prompt, so its replacement is literal. Add the target-model prefix the other four hook prompts carry, then after *"…genuinely has two tools that separate reviewing TEXT from reviewing a DIFF"*, insert:

> **A mapped name must also lie in the `mcp__codex__*` namespace.** This hook is invoked by a `hooks.json` matcher of `^(Bash|Skill|mcp__codex__.*)$`, so a mapping naming a tool outside it is either never delivered — the mapping looks applied and does nothing — or, for the reserved names `Bash` and `Skill` that matcher does deliver, hijacks that lifecycle event. The parser refuses both. (Normative statement: the design's decision 1.)

  And to its `systemMessage`, because registering a server is an operator action:

> A mapped tool name must start with `mcp__codex__`, or it is refused: outside that namespace it is either never delivered to the hook or — for `Bash` and `Skill` — hijacks a lifecycle event. Register the server under the name `codex` to place its tools there.

- [ ] **Step 5: The layout trees.** Add `hooks/fixtures/` to `AGENTS.md` § Architecture and `docs/architecture.md`. Two greps, because the Don'ts require both: `grep -rn 'codex-gate' AGENTS.md docs/architecture.md MANIFEST.md README.md`, and the mandated manifest-claim census `grep -rniE 'declare[sd]?|convention[- ]load' --include='*.md' . | grep -v source-files/`. **Then read `plugins/dev-workflow/.claude-plugin/plugin.json` in this same change** and check every hit against it — three sites once shipped the claim that the manifest declares `hooks` when it declares nothing, and no mechanical check can tell whether a sentence about a manifest is true.

- [ ] **Step 6: README setup for the environment variable** (spec §9, a story acceptance criterion). `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS` with **every settled clause**: requires Claude Code ≥ 2.1.212; set in the environment Claude Code is **launched from**, so a running session must be restarted; `0` disables auto-backgrounding; a positive value must **exceed** the longest expected gate call. And **both** outcomes without it — while the notice keeps its current wording the pass is *discarded*, and if that harness prose changes the call is *counted* with a disclosure. That second outcome is C1, and it is why this setting is the primary defence rather than the anchor; a Setup section promising only "discarded" hides the residual where the operator could still prevent it. **`CLAUDE_CODE_AUTO_BACKGROUND_TIMEOUT_MS` is not documented** — it exists in the 2.1.220 string table but was never exercised, and naming the wrong one of two is this repo's docs-drift class.

- [ ] **Step 7: Golden assertions for the two edited prompts**, and update the unknown-tool golden in **both** places it appears — the branch assertion and the composition matrix — or the composed assertion fails on a change the branch assertion accepted.

- [ ] **Step 8: All 12 prompt-standards items** for every string added or changed in Tasks 5 and 6.

Commit: `WIP: docs: describe result classification where the old mechanism was taught`.

---

### Task 7: Changelog, validation evidence, and Gate B

- [ ] **Step 0: Define the evidence file, before anything reads it.**

```sh
EVIDENCE="$(git rev-parse --show-toplevel)/.context/evidence-0.8.0.md"   # .context/ is ignored
: > "$EVIDENCE"
```

  Steps 2–5 each **append** their result to it: the counterfactual's verbatim `FAIL` lines, the named-verification table, the `awk`-portability statement, and the rollback outcome. Before every commit or amend that embeds it, require it **readable and non-empty**, and re-read it — a fix changes the diff even when the profile sits still.

  This step exists because `$EVIDENCE` was referenced by three commit commands and **assigned nowhere**; the scratch dry run that "passed" had defined the variable itself, so it proved the `git` mechanics and never tested the plan's own. Keep it out of the temp directories Step 2 cleans up.

- [ ] **Step 1: The CHANGELOG entry.** `0.8.0`, newest first. Names the behaviour change **and C1–C4 by name**. It lands here, not in Task 1, so no intermediate commit carries a release note for behaviour that does not exist.

- [ ] **Step 2: The `+check` counterfactual.** Materialize the pre-change hook from `$BASE` beside the **new** suite and fixtures in a temp directory. `git stash` cannot do this — Tasks 3–5 already committed the changed hook.

  **Requirements, each of which an earlier draft got wrong:** the evidence file lives **outside** the temp directory, or the cleanup deletes it before the assertions read it; every guard (`git show`, `cmp`, empty blob) **exits nonzero**, since a bare `echo` continues against a wrong or empty hook; the cleanup is a function with signal handlers that **exit**, and it removes the evidence files too; and **status and completion are checked, not just `grep`** — piping a suite through `grep` hides a crash, a `set -u` abort or a truncated run, so the new suite must exit 0 **and** print its completion marker, and the old one must terminate normally.

  Then assert **exact labels**, not "something failed". The four, named here so the counterfactual is auditable against this plan rather than against whatever the suite happened to produce — only the mechanical runner suffix is filled in at execution:

  1. `failure/default/<runner> preserves passCount`
  2. `timeout/default/<runner> preserves passCount`
  3. `failure/default/<runner> writes no gate-pass state from clean`
  4. `backgrounded/default/<runner> writes no gate-pass state from clean`

  Each must be **present** in the base-hook run's failures and **absent** from the new run's. Those four are chosen because each fails for the change's own reason — the old hook counts a discarded class — rather than for a harness difference. **An observation to record, not an assertion to make**: the matching lines go verbatim into the evidence entry.

- [ ] **Step 3: The named verification** (the story's profile requires it — re-read the header).

  **Two parts, and the second is not optional.** Replaying captured payloads through the changed hook establishes the classification; it does **not** satisfy story criterion 10, which asks for the probe methodology re-run against the changed hook with the variable **absent and set**. An earlier draft substituted pre-change captures and said so, which is a live acceptance criterion silently weakened. Either run the live probe in an isolated profile for both variable states, or **obtain and record a human amendment to the story criterion before Gate B**.

  For the replay part, every row is guarded: fixture-read status, `sed` substitution status, the routed tool name, the **exact class**, an explicit expected value per row, and the exact row count — failing the step on any mismatch. Unguarded, a missing fixture or failed `sed` supplies an empty payload to an always-zero advisory hook and still prints the expected `absent` counter, so most of the evidence can be false while looking correct. The success row uses **`shape0-success-review`**, not `shape0-success`: the latter is an `exec` capture whose entire result was the word `ok`, and calling it "a genuine pass" would claim Gate-B continuity for content no reviewer saw.

- [ ] **Step 4: `awk` portability evidence.** The local battery uses one `awk`; CI's `ubuntu-*` runs `mawk`. **Bind the CI result to the exact reviewed tree** — a run from before the Gate-B fixes does not cover the final amended bytes — and re-run it after any classifier or locator fix. The work is on `main`, so name the branch or PR route used rather than "after pushing", which reads as pushing unreviewed WIP history to `main`. If CI has not run against the final tree, **say so in the evidence entry** rather than citing 56/56 as portability.

- [ ] **Step 5: The rollback, verified.** `.context/codex-gate.off` is **not** a rollback — it suppresses messages while classification and state tracking keep running, so a workspace whose passes are being discarded stays stuck and goes quiet about it.

  The real rollback is the version-keyed cache path invariant 12 exists for. Verify three things, each a hard stop: the prior hook is **present**; it matches the **released bytes**, resolved as the **newest commit whose manifest still contains 0.7.1** — not the commit that *set* it, and not `git log -S`. Verified 2026-08-02 in a scratch repo: `-S` finds commits where the string's count *changed*, so it resolves to the 0.8.0 bump that **removed** 0.7.1 and yields the new hook's bytes — the check would then report a mismatch on a correct cache. "The commit that set it" is wrong too, because a later docs commit can change the hook while the version sits still, and those are the bytes that shipped. Walk `git rev-list HEAD` and take the first commit whose `plugin.json` matches `"version"[[:space:]]*:[[:space:]]*"0\.7\.1"`. A tag would be simpler, and this repo has **none** — `git tag -l` is empty — so creating one is a prerequisite to record, not to assume; and it **behaves** as 0.7.1 did, by counting a failure envelope in a disposable adopted repo. Make the probe's failure branch exit nonzero **and** check the subshell's status outside it — an `echo "STOP"` inside a subshell lets the release continue past a failed check.

  **Side-by-side bytes are not an operable rollback.** Record and verify how an operator actually *activates* 0.7.1 in this environment — the cache path is an implementation detail and `claude plugin marketplace add` has no version syntax — and confirm the active hook's bytes afterwards. If no verified switch path exists, stop the release rather than shipping a rollback story nobody has run.

  > **AMENDED 2026-08-02, human-confirmed by Daniel. The hard stop above is lifted for this release only, and replaced by a documentation requirement.** The drill is *not executed*; rollback is verified by inspection and its unverified part named. What was established: the plugin cache **is** version-keyed (`cache/<marketplace>/<plugin>/<version>/`), `installed_plugins.json` is what selects the active version, 0.7.1 is present, and its hook bytes match the repo at the newest commit whose manifest still carries 0.7.1 — so that resolution method is confirmed empirically rather than assumed. What is **not** established, and is stated in the release evidence rather than implied away: no operator switch path has been executed, because 0.8.0 has never been installed and editing `installed_plugins.json` is undocumented. **Two facts make executing it the wrong trade here:** the drill would mutate a shared plugin environment that every concurrent Claude Code session on this machine runs against (the risk P9-24 named), and 0.7.1 **is already the active version**, so the rollback target is the current state rather than a state anyone must reach. The residual is that recovery *after* activating 0.8.0 is untested. Reinstate the hard stop for any later release that ships with 0.8.0 already active, where that residual is no longer hypothetical.

  **Then put the candidate back, and prove it.** This drill ends with 0.7.1 *active*. Running it before Gate B and not reversing it means every Gate-B pass executes under the old hook — which counts failed calls, so the pass accounting the review depends on is the accounting this change exists to fix. Either run the whole drill in an isolated profile, or reactivate 0.8.0, **byte-verify the active hook**, and reload the session before the first Gate-B call. Verify, do not assume: this is the one step whose failure is invisible until the review is already worthless.

  **State what a rollback costs, not only what it leaves behind.** Reverting to 0.7.1 **restores the original defect**: failed, timed-out and backgrounded calls count as gate passes again. It also restores the `dash` special-builtin exit — on Linux, an unwritable `.context/` makes 0.7.1's hook exit 2, violating invariant 1. So rollback is right for "0.8.0 discards passes it should count", and wrong for anything else; a CHANGELOG that mentions only the leftover markers lets an operator roll back believing it merely removes classification. Also record what it does **not** undo: the three diagnostic markers stay in `.context/`, and 0.7.1 ignores them.

- [ ] **Step 6: Squash into the reviewed snapshot.** Before the battery and before Gate B — the numbering matters, because an earlier draft ran the post-squash battery in a step that came *before* the squash existed.

  **Stage Task 7's own edit first.** Step 1 modified `CHANGELOG.md` and nothing has committed it; `reset --soft` preserves an unstaged edit but the commit that follows will not contain it, so the release note invariant 12 requires would sit outside the reviewed range while the path audit — which reads commits — cannot see it.

```sh
git merge-base --is-ancestor "$BASE" HEAD || { echo "STOP: BASE is not an ancestor"; exit 1; }
git log --oneline "$BASE"..HEAD          # read it: every commit must be one of THIS plan's WIP snapshots
git diff --name-only "$BASE"..HEAD       # read it: every path must be one this plan named
git status --porcelain                   # read it: CHANGELOG.md must appear, and nothing unexpected
git add plugins/dev-workflow/CHANGELOG.md
git reset --soft "$BASE"
git commit -m "WIP: gate-pass result classification (0.8.0)" -m "$(cat "$EVIDENCE")"
git show --stat --format=%B HEAD         # read it: every named path present, evidence body present
```

  **Two `-m` arguments, not `-m` with `-F`** — `git` rejects that combination outright (*"options '-m' and '-F' cannot be used together"*), so the earlier form could not create the snapshot at all. The first `-m` is the subject and carries the `WIP:` prefix `is_wip_commit` looks for; the second is the evidence body.

  The ancestry check and the reads are not ceremony: an unconditional `reset --soft` folds **every** commit since `$BASE` into the snapshot, so a concurrent or unrelated commit gets rewritten into this change, and re-running the step widens the range again.

- [ ] **Step 7: Full battery on the squashed tree**, including `sh scripts/check-version-bump.sh "$BASE"` — now that the commit exists — with that exact command recorded. Passing `main` on this checkout compares HEAD with itself and proves nothing.

- [ ] **Step 8: Gate B.**

  **Squashing happens before the clean pass, never after.** A `reset --soft` moves HEAD, changing `git diff HEAD` and the effective index — two of the three inputs to `tree_hash` (invariant 3) — so squashing after a clean pass invalidates the fingerprint that pass recorded and correctly fires Gate B again, spending the passes rather than preserving them.

  **`baseSha` is `$BASE`, passed literally.** Not a live merge-base: this work is on `main`, where `git merge-base main HEAD` returns HEAD and Gate B would receive an **empty range** and could return clean having seen nothing.

  Minimum three passes, findings to file, clean final pass.

  **Every amend rebuilds subject *and* body, in one command.** A bare `git commit --amend -m "WIP: …"` replaces the whole message and **erases the evidence body**; `--amend --no-edit` preserves it but carries no `-m`, and `is_wip_commit` greps the command for `-m … wip` — verified — so the hook reads it as a real cycle-closing commit and **resets the counters mid-cycle**. Only the two-`-m` form satisfies both:

```sh
# after each fix: inspect, stage ONLY the fix paths, audit, revalidate evidence, then amend.
# A bare `--amend` commits nothing new — the fix stays unstaged, the next reviewer reads the
# old range, and the fingerprint sees a worktree the commit does not contain.
git status --porcelain                    # read it: only the paths the fix touched
git add plugins/dev-workflow/hooks/codex-gate.sh   # <- replace with the exact paths THIS fix touched
git diff --cached --name-only             # read it: nothing outside that set
git commit --amend -m "WIP: gate-pass result classification (0.8.0)" -m "$(cat "$EVIDENCE")"
git status --porcelain                    # read it: MUST be empty before the next review call
# closing, after the clean pass — same shape, real subject:
git commit --amend -m "feat(hooks): classify gate results and stop counting the ones that reviewed nothing" -m "$(cat "$EVIDENCE")"
```

  **The evidence entry is in the body from the first snapshot**, revalidated and rewritten into `$EVIDENCE` after every fix — a fix changes the diff even when the profile sits still. Every Gate-B call carries the story path and that entry quoted verbatim.

  The standing lens applies with unusual force: this change edits `CLAUDE.md` §5 itself, so ask **which existing statements this diff falsifies** — including in files it does not touch.

---

## Findings that move to Gate B

Inherited, not dropped — the way this plan inherited spec §11's deferred contracts. Each is a harness-mechanics defect found at Gate-A pass 6, in shell that no longer lives in this document. Gate B reviews the real implementation and must confirm each:

1. **Expected-message constants** — every `*_EXPECTED` name referenced must be assigned, with the inventory checked against the required set rather than only against names already referenced.
2. **The dual-emitter marker loop** — every row must actually run through both runner pairs; a wrapper that declares parameters and leaves the blocks calling the direct runners is not coverage.
3. **The raw-hook runner in the C2 rows** — a `PATH=…` scalar cannot be expanded as a command prefix; use runner functions that perform the redirection and return the hook's status.
4. **The three `sed` fault shims** and the three `awk` ones must exist, and each must be self-verified in both directions before an assertion depends on it.
5. **The jq-free field comparison** must be routed through one helper used by *every* exact comparison, not only `golden()`.
6. **The skip branches** must skip their dependent assertions, not merely print `skip -` and fall through.

## Self-Review

**Spec coverage:** §3.1 → Task 5 (A1, A2); §3.2–3.3 → Task 5; §4 → Task 5 (A4) and C1; §5.1 → Task 5 Step 3; §5.2 → Task 5 Step 4 (A5); §6 → Tasks 4 and 5; §7.1 → Task 1; §7.2 → Task 2; §7.3 → Task 5's oracle tables; §7.4 → Task 7; §9 → Task 6; §11 → A1–A7 as mapped.

**Placeholders:** the harness shell, deliberately and by scope (see the note at the top and the Gate-B list). Not placeholders: the five message pairs, the class and marker tables, the contracts, every oracle, and Task 7's procedures — those are what Gate A can judge. **The five pairs are no longer verbatim-final, and this document is not their source of truth:** Gate B revised all five `additionalContext` literals and `UNVERIFIED_MSG` — the target-model prefix (P9-28), the background report format (P9-29), the cleanup rationale and its later deletion (P9-30), the `FAILURE_CTX` scope (P9-31), the refusal families (P9-32), the trust boundary (P9-33), the task-id conditional (P9-36) and the repeat causes (P9-37). The shipped strings in `codex-gate.sh`, and their literal goldens in the suite, are authoritative. Task 6's prose *targets* are located by line and grep rather than quoted, because quoting them would create a fourth copy of the sentences this change exists to correct.

**What no reader should infer.** The scan is a locator, not a validator: string-boundary tracking is what makes the walk trustworthy, a walkable-invalid document is walked past (three fixtures pin that), and its two bounds are backstops in `awk` length units and nesting depth, not contracts — neither bounds memory. The marker table describes sequential behaviour only (C4). The `+check` counterfactual shows four named tests depend on the new code, not that the old hook was wrong in every way the new one is right. 56/56 local is shell coverage, not `awk`-implementation coverage. And the oracles state what each test must *fail on*; whether the shell satisfying them is correct is a Gate-B question, which is the point of moving it there.
