# Sequential single-branch Gate-B calls — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-08-14-sequential-branch-calls-hook-story.md` — read its profile fresh at each pass.

**Spec:** `docs/superpowers/specs/2026-10-09-sequential-branch-calls-hook-design.md` (Gate-A spec cycle `td28n1y4yu`, closed in `bda8eb9`). The spec decides behaviour; this plan decides order, files, tests and the remaining local choices. Where they seem to differ, the spec wins and the difference is a finding.

**Goal:** the hook credits a matched `spec`+`quality` pair as one Gate-B pass, and both rule copies make sequential single-branch calls the default.

**Architecture:** one new state file (`.context/codex-gate.pendingBranch`) consumed by atomic rename; Gate-B counters renamed to `passes`/`freshPasses`; request fields read only from `tool_input` (jq, or a new awk scanner); rule text edited in `.claude/review-gates.md` and `/workflow-init`'s template `### 2.1a`.

**Tech stack:** POSIX `sh` (`sh` and `dash`), `awk`, optional `jq`, `shellcheck` 0.11.0.

## Global constraints

- AGENTS.md invariants 1–4: exit 0 on every path; loose in the firing direction; Gate-B validity stays content-derived (the fingerprint logic is not touched); POSIX `sh`, `jq` optional.
- Invariant 11: every new or changed hook message passes `docs/prompt-standards.md` (12 items), in particular item 10 (diagnostic states name causes, with check and fix) and item 11 (enforcement claims name their mechanism).
- Invariant 12: `plugins/dev-workflow/.claude-plugin/plugin.json` 0.20.0 → 0.21.0, CHANGELOG entry.
- No full `reviewType: full` deprecation and no refusal (spec §2.2).

## Review focus (inputs the spec implies, most likely to bite first)

1. A single-branch payload whose shape differs from the synthetic ones. Task 1's fixture case is **synthetic** — the `full` capture `shape0-success-review.json` with `reviewType` rewritten — so it pins the boundary, not a real single-branch envelope. Task 6's own Gate-B calls are real single-branch payloads, but they run through the **installed 0.20.0** hook. A real payload could be captured with the scoped installed-hook dump `hooks/fixtures/README.md` documents; **this change chooses not to**, to keep the installed plugin untouched while another session uses it. Real-envelope validation of the new reader is therefore **not performed in this change**; the PR and CHANGELOG say so, and the first downstream run on 0.21.0 is where a mismatch would show.
2. An agent passing a short or symbolic `headSha` (`HEAD`, 7-char) — must not credit, must say why. Task 2.
3. A Gate-B cycle already in progress when 0.21.0 lands (old `passCount` present). Task 2.
4. `.context/` not writable while existing counter files are — no credit **where a stale path (legacy counter or pending file) must be retired and cannot be**; a `full` call with nothing to retire still credits through the existing writable files. Task 2.
5. A `full` call issued while a half pair is pending. Task 2.

## Sources and impact boundary

**Read:** CLAUDE.md, AGENTS.md, `.claude/review-gates.md` (full); the story and its change record; the spec; `plugins/dev-workflow/hooks/codex-gate.sh` (header, field readers, `classify`, `note*`, the review PostToolUse branch, Bash reset branch, PreToolUse commit check); the head, runners and section index of `codex-gate.test.sh`; `fixtures/README.md` §§ on the review capture; `docs/prompt-standards.md` checklist headings; the `mcp__codex__review` tool schema; `todos.md` rows "`reviewType: full` races", G3 follow-up order, "From PR #26".

**Impact boundary:** the hook and its suite; `.claude/review-gates.md`; `workflow-init.md` template `### 2.1a` (and the template prose before it, line ~545, which states how the hook counts); `plugin.json`; `CHANGELOG.md`; `todos.md`; a new replay package under `docs/superpowers/replays/`. **Not touched:** Gate A logic, the fingerprint (`tree_hash`), `classify`, `scripts/*` (none reads `passCount` — checked by grep), the `full` race itself.

## Handover boundary

The completed story: PR open, CI green, review bots processed, merge decision presented to Daniel. Write `.context/handover-sequential-branch-calls.md` there and stop. No earlier boundary: the Gate-B cycle must not be split across sessions.

---

### Task 0: Close this plan's Gate-A cycle before any code

The Gate-A plan cycle closes **before Task 1 starts**, by `.claude/review-gates.md`'s Gate-A act: confirm the plan file equals the text sent in the final pass's request; then, since `HEAD` does not carry it, commit it unchanged (`git add` of the plan file alone, then a commit whose message carries this cycle's provenance line and per-pass curve); then confirm `git show HEAD:<plan path>` equals the file. These records travel to `main` by squash carry, like the spec cycle's in `bda8eb9`.

- [ ] Equality check, commit, post-commit check

### Task 1: Read request fields from `tool_input` only

**Files:** modify `plugins/dev-workflow/hooks/codex-gate.sh` (field-reading helpers near `input_field`); test in `codex-gate.test.sh`, new section after the last numbered one.

**Outcome:** a helper that returns, for `reviewType`, `baseSha`, `headSha`, one of three states: a value, **absent**, or **uncertain** (spec §3.2).
- `jq` present: first require that `.tool_input` exists and is an **object** — missing, `null` or non-object is uncertain (for missing or `null` input jq's `has` returns false with exit 0, which would otherwise read as absent and default to `full`; for a string or array it errors). Then `has(key)` decides absent; a present non-string member is uncertain; a non-zero `jq` exit is uncertain.
- `jq` absent: a new awk program walks the payload with string/escape state and depth, finds the **top-level** `tool_input` key, and prints only its **direct** string members up to the matching `}`. No top-level `tool_input`, no matching brace, a key present with a non-string value, or **any direct member key containing a backslash escape** (it might decode to one of the three names) → uncertain. The scanner carries the same size and depth bounds `LOCATE_AWK` documents, and exceeding either is uncertain — a refused classification must not be followed by an unbounded second scan. Reuse `LOCATE_AWK`'s string-consumption approach (backslash parity, `substr` extraction) rather than inventing a second one; whether to share code or copy the routine is a local choice.
- **Every verdict is decided on the decoded value, not on a shell capture of it**: command substitution strips trailing newlines, so `full` plus a newline would read as `full`, and 40 hex characters plus a newline would pass a length check run after capture. On the `jq` path classify inside `jq` and emit only a verdict token: `reviewType` as exactly `spec`, `quality`, `full`, absent, or other; each SHA as usable (`type == "string"`, `length == 40`, characters only `[0-9a-f]`) or not, and a usable SHA's value with it — safe to capture, since it can then hold only hex. On the `jq`-free path compare the raw, still-escaped value: `reviewType` must equal one of the three names exactly and each SHA must be exactly 40 characters of `[0-9a-f]`; a value containing a backslash is never one of these.
- Do **not** change the existing `input_field` (other branches depend on its behaviour).

**Test situations** (each under both normal and `nojq_run`, each asserting exit 0):
- fields present → values read;
- `tool_input` `{}` → all absent (this is what every existing `rev()` call sends, so existing cases keep counting as `full`);
- `headSha` only inside `tool_response` → absent;
- `tool_response` before `tool_input` → values read;
- a sibling key after `tool_input` carrying `headSha` → absent;
- `tool_input` missing, `null`, or a string → uncertain (both paths);
- truncated payload (unclosed `tool_input`) → uncertain **on the `jq`-free path only**: on the `jq` path the hook's existing `field` routing already rejects malformed JSON before the helper runs (exit 0, no output) — pin that unchanged outcome separately rather than claiming helper coverage there;
- the text tool_input, with its quotes backslash-escaped, inside a string value → not taken as the key;
- a direct member whose key is reviewType with one letter written as a JSON unicode escape (backslash, u, four hex digits), value `spec` → uncertain on the `jq`-free path, `spec` on the `jq` path; neither gives `full` credit;
- `headSha` = 40 lowercase hex followed by a JSON-escaped newline → unusable on both paths, no credit, pending unchanged; `reviewType` = `full` or `spec` followed by a JSON-escaped newline → unrecognized on both paths, no credit, pending unchanged;
- a large sibling object before `tool_input` (past the scan bound) under `nojq_run` → uncertain, and the run finishes within the existing performance cases' time limit;
- synthetic: the `full` capture `shape0-success-review.json` with its `reviewType` rewritten to `spec` → `spec` read (labelled synthetic in the case name).

How the helper is exposed to tests is a local choice (the suite drives the hook only through payloads; prefer asserting through Task 2's observable behaviour over adding a test-only entry point).

Tasks 1 and 2 share **one checkpoint**: Task 1's cases observe the reader through the counting branch Task 2 wires, so neither task is green alone.

- [ ] Write the cases (they fail against the current hook)
- [ ] Implement the reader (green comes at the Task 2 checkpoint)

### Task 2: Pairing, renamed counters, retirement, notes

**Files:** modify `codex-gate.sh` (state-file block at the top, review PostToolUse branch, Bash reset branch, PreToolUse commit check, message constants); `codex-gate.test.sh` (`count`/`fresh` variables → new names, `reset_all`/`reset_gate_state` add the pending file and the old names, new section).

**Interfaces:** consumes Task 1's helper. Produces state files `.context/codex-gate.passes`, `.context/codex-gate.freshPasses`, `.context/codex-gate.pendingBranch` (line `<branch> <baseSha> <headSha>`).

**Decisions already made by the spec (do not re-decide):** the five-row table of §3.2; claim = `mv` of the pending file to a per-process name inside `.context/` (e.g. suffixed with `$$`), read only after a successful rename; "no credit over stale state" (§3.1) with "confirmed gone" = path absent after removal; legacy names retired only where classification lets a call through, at the commit check and at every reset; `full`/absent retires a pending file through the same claim before crediting; the commit-time note keyed on existence (§3.4); a non-`WIP` reset removes pending + old + new names.

**Local choices left open:** helper names; message wording, within prompt-standards; where the claim file is removed.

**Test-environment changes this task owns:** `mv` becomes a command the hook needs, so add it to every restricted PATH the suite builds (`nojq` and the others built by `mk_path`) and to the replay's PATH, and add one case proving a claim succeeds inside the restricted PATH before any pairing assertion relies on it. Existing case **39a** (an awk fault still counts and discloses when `jq` is absent) conflicts with the spec's no-credit-on-uncertain rule for Gate B, because the `jq`-free request reader needs awk: update its Gate-B expectation to "no credit, no fingerprint write, uncertain note" when `jq` is absent, keep its expectation where `jq` is present (the request reader then does not need awk), and leave its Gate-A part unchanged.

**Messages** (each a `note` pair, model-facing ctx in the hook's `<state>/<consequence>/<next>/<stop>` form plus a user line; a `Target model:` comment like the existing constants):
- branch recorded, awaiting the other on the same `baseSha`/`headSha`;
- recording could not be confirmed (causes: write failed, unreadable, claimed by a concurrent hook; checks: `.context/` writability, concurrent review calls);
- branch cannot be paired: SHAs unusable (name which, and that both must be 40-char lowercase object names) — and, separately, the request fields could not be read (uncertain);
- unrecognized `reviewType` value;
- credit withheld because a stale path survived removal — **name the path**, and give the cause as undetermined among: unwritable `.context/`, a directory or other non-file at that path, the path recreated by another writer (pass-5 Minor 2);
- commit check: pending-branch state present, not counted, its usability unverified.

**Pass-5 Minor 1:** `note_unverified` is today called before counting and its text says recording "was attempted". Call it only on paths where a credit or a pending record is actually attempted, so a rejected call creates **no new** disclosure and **no new** `unverifiedPending` debt. An earlier debt is still delivered by `flush_notes` as today, with its "Earlier" prefix. Test: starting with no debt, an `unrecognized`-class result with an unusable `headSha` emits no unverified disclosure and leaves no debt file.

**Test situations** (normal and `nojq_run` unless stated; every case asserts exit 0):
- AC-1: three spec→quality pairs → `passes` = 3, commit check prints the satisfied message.
- AC-2: one pair then a lone spec → `passes` = 1 and the commit check carries the pending note; three pairs + lone spec → satisfied message **and** pending note.
- AC-3: `tool_input` `{}` and `reviewType: full` each → +1, as today.
- AC-4: first branch `success: false` (fixture `shape1-fast-fail` retargeted) then both succeed → 1; second branch fails → 0 and pending kept; quality before spec → 1; same branch twice → 0, pending replaced; same `headSha`, **different `baseSha`** → 0 and pending replaced, then a partner on the replacement's base → 1; WIP commit between branches (`jq` only, new `headSha` on the second) → 0; non-`WIP` commit between branches → pending gone; unusable SHAs (`HEAD`, 7-char, uppercase hex) → 0 with the reason; unknown `reviewType` → 0; `full` with a pending half → +1 and pending gone.
- **Preservation oracle for every no-credit path**: seed `passes`, `freshPasses`, a distinct `gateB` fingerprint and a pending record first, and assert the first three unchanged afterwards, and the pending record unchanged wherever §3.2 says "change no pending state" (unusable SHAs, uncertain read, unknown `reviewType`). This applies to the request-rejection cases above and the stale-state cases below; legacy-name retirement is its one permitted side effect.
- Stale state: `.context/codex-gate.passCount` = 3 present at the first new-hook review → ignored (`passes` = 1 after one pair) and removed. Stale-state no-credit cases: `passCount` made a non-empty directory → no credit, note names the path; `.context/` made read-only (`chmod a-w`) with a pending `spec` and a matching `quality` call → no credit (claim fails); the same with a `full` call → no credit (pending cannot be retired), note names the pending path; restore permissions after each; `.context/` read-only with **no** pending file and a lone `spec` call → the pending write fails, could-not-confirm note.
- Exclusive claim, deterministic, one case per interleaving step: the pending file gone before the rename (simulating another process's claim) → no credit; a leftover claim file with a matching record and no pending file → no credit (claim files are never read); a successful claim → the pending path no longer exists afterwards. Counterfactual for the first case: a version reading the pending file without renaming it would credit — state in the case comment which assertion that would fail.
- Concurrency smoke, not proof: two hook processes against one pending record started together, 20 repetitions, `passes` ≤ 1 each time. `bump_count` is a non-atomic read-modify-write, so this smoke cannot tell a single credit from two lost-update credits; the deterministic cases above carry the claim property.
- Existing suite: every pre-existing case passes unchanged apart from the two variable renames, the `mv` PATH additions and case 39a's `jq`-free Gate-B expectation (all three named above).

- [ ] Rename `count`/`fresh` in the suite, add the new cases; run → the new cases fail, the old ones pass on the old hook except the renamed-file reads (expected)
- [ ] Implement; **Tasks 1+2 checkpoint**: `HOOK_SH=sh sh …test.sh` and `HOOK_SH=dash dash …test.sh` green; `shellcheck --shell=sh` clean
- [ ] Prompt-standards pass over every new/changed message (write the 12-item check into the Gate-B request as evidence, not into the hook)

### Task 3: Rule text, both copies, and the falsified-sentence sweep

**Files:** `.claude/review-gates.md`; `plugins/dev-workflow/commands/workflow-init.md` (template `### 2.1a` and the prose at ~545 "The hook counts passes by TOOL NAME …").

**Edits:** exactly spec §3.5's list. Both copies must say the same thing; the template copy keeps its downstream framing.

**Sweep** (spec §3.5 last bullet, plus the Gate-B standing lens): grep `reviewType`, `full`, `in parallel`, `counts calls`, `passCount`, `freshCount`, `one file per branch`, `both branch files` across both copies, `README.md`, `docs/` (excluding `superpowers/` history and `field-reports/`), `plugins/dev-workflow/` and `CHANGELOG.md`; fix every sentence the change falsifies; list the hits and dispositions in the Gate-B request. `scripts/check-invariants.sh` 4c (severity enum present once per copy) and 4e (template size) must stay green.

- [ ] Edit both copies
- [ ] Sweep, fix, record dispositions
- [ ] `sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh` green

### Task 4: Packaging and backlog

**Files:** `plugins/dev-workflow/.claude-plugin/plugin.json` (0.21.0); `plugins/dev-workflow/CHANGELOG.md` (new top entry: behaviour change, renamed state files, the rollback procedure with all six full paths from spec §4, the residuals: `full` race undetected, reset-vs-claim window, counter never reads findings files); `todos.md` (close the "`reviewType: full` races" row naming this story and PR; G3 follow-up order: mark the first item done; story AC-7); `plugins/dev-workflow/hooks/fixtures/README.md` — its line calling `full` "the mode this project's Gate B uses" is corrected (the capture itself stays a `full` capture, as recorded), and a new fixture is documented there if Task 1 adds one.

- [ ] Edits; `sh scripts/check-version-bump.sh main` after the WIP commit

### Task 5: Named verification — pair-counting replay

**Files:** create `docs/superpowers/replays/2026-10-09-pair-counting/` with `replay.sh` (POSIX `sh`) and `README.md` (what it shows, how to run, the observed output).

**Outcome:** spec §5's replay: a throwaway git repo; the hook from this branch and `git show 205efd3:plugins/dev-workflow/hooks/codex-gate.sh`, each from a fresh `.context/`; the same payload sequence; `sh` and `dash`; with `jq` and with a `jq`-free PATH; checkpoints C1 (3 vs 6 and the old ✓), C2 (pending note vs a bare ✓), C3 (WIP between branches, expectations split by `jq`). The script prints one line per checkpoint × hook × shell × jq and exits non-zero if any expectation fails. Observed output pasted into the README and quoted in the evidence entry.

- [ ] Write, run, record

### Task 6: Battery, Gate B, PR

- [ ] Lint and both hook-suite runs; stage everything; `git commit -m 'WIP: sequential-branch-calls'`
- [ ] Then the **full** quality command from AGENTS.md § Commands, so `check-version-bump.sh main` compares the WIP commit against a current `main`
- [ ] Nonce for the Gate-B cycle
- [ ] Gate B **using the new default on itself**: per pass, resolve `baseSha` (merge-base with `main`) and `headSha` to 40-hex once; `mcp__codex__review` with `reviewType: spec`, then `reviewType: quality`, each `additionalContext` naming only its own slot `gate-b-<spec|quality>-<nonce>-pass-<p>`, the story path, the evidence entry verbatim, the risk-high lens set, the standing "which statements does this diff falsify?" lens with the size/value/position list (counter names, a new state file, the version, the default call shape), and the Task-3 sweep dispositions. Delete only the call's own target before it. Floor 3.
- [ ] Repair loop, per pass: validate both branch files; resolve in-set Blocker/Major as Mechanics · Severity says; re-run the affected suites; stage and `git commit --amend --no-edit` onto the active `WIP:` snapshot (HEAD); resolve the **new** `baseSha`/`headSha` and use them for both branches of the next pass. Which branch the pass takes — continue, suspend, or close — is the closure ordering's.
- [ ] Observe the **installed** 0.20.0 hook counting each call (expected: 2 per pass) — record as a live counterfactual note in the PR, not as evidence of the new hook
- [ ] Close: `git commit --amend -F <msg>` with the evidence entry and the Gate-B cycle's provenance line and curve (the Gate-A spec and plan cycles' records are already in their own closing commits, Task 0 and `bda8eb9`, and travel by squash carry)
- [ ] Push, open PR, wait for the bots per `docs/pr-review-bots.md`, `/dev-workflow:process-pr-review`; present the merge decision with the squash-body carry list

**Evidence entry (draft, revalidated before every Gate-B call):**
```
Evidence — docs/superpowers/stories/2026-08-14-sequential-branch-calls-hook-story.md
Check: codex-gate.test.sh AC-1 case (three spec→quality pairs → passes 3); fails on 205efd3 (6).
Verification: pair-counting replay, docs/superpowers/replays/2026-10-09-pair-counting/ — C1/C2/C3 under sh+dash, jq/no-jq; counterfactual from 205efd3 in the same run.
```
