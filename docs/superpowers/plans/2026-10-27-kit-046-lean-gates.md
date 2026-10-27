# Kit 0.46 lean gates Implementation Plan

> **For agentic workers:** Use superpowers:subagent-driven-development (Tasks 1–2) and inline execution (Tasks 3–7), see Deviations. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Ship dev-workflow 0.46.0 with gate modes `lean`/`strict`/`classic`, verify passes, the Gate A threshold, the cap routing and the duties of story AC-5–AC-9.

**Architecture:** One committed setting, `.claude/codex-gate.mode`, read by the hook (reminder numbers) and by the agent through the gate rules (obligations). Rules text lives in two byte-identical copies (`.claude/review-gates.md`, `/workflow-init` `### 2.1a`) plus CLAUDE.md §4 and its `### 2.1` template.

**Tech Stack:** POSIX `sh` hook and suite, Python 3.8 report scripts, Markdown prompts.

**Spec:** `docs/superpowers/specs/2026-10-27-kit-046-lean-gates-design.md` (story `docs/superpowers/stories/2026-10-26-kit-046-lean-gates-story.md`, risk standard → this plan gets no Gate A).

## Global Constraints

- Hook always exits 0; POSIX `sh`; `jq` optional; shellcheck `--shell=sh` clean (AGENTS.md Hook 1, 2, 4).
- Mode numbers (floor/cap): `lean` A 2/2, B 1/3; `strict` A 2/2, B 1/5; `classic`, no file, unusable file: 3/5 both.
- Gate rules ≤ 10,000 bytes, both copies byte-identical (checks 4i, 4j); `CLAUDE.md` template ≤ 20,000 chars (4e); this repo's CLAUDE.md + AGENTS.md ≤ 150,000 chars (4g).
- Every changed prompt passes the 12 items of `docs/prompt-standards.md`.
- Version 0.46.0 in `plugins/dev-workflow/.claude-plugin/plugin.json`; CHANGELOG entry; README/docs in the same PR.
- No `Co-Authored-By`/`Generated with` lines.

## Review Focus

1. A project upgraded from 0.45 with no mode file: hook reminders must stay at 3/5 (Task 1 test "no mode file").
2. A mode file with a trailing newline, CRLF or surrounding spaces: must read as its word, not as unusable (Task 1 test "whitespace").
3. A mode changed `classic`→`lean` with a Gate B counter already positive: floor stays 3 (Task 1 test "mid-cycle").
4. A positive counter from a 0.45 cycle with no remembered-mode state: treated as `classic` (Task 1 test "legacy counter").
5. The 0.45 cycle-line readers on a `floor 1 per` record next to a historical one (Task 2).

## Sources and impact boundary

Read: the spec and story; `.claude/review-gates.md`; CLAUDE.md §4; `plugins/dev-workflow/hooks/codex-gate.sh` (lines 105–235 settings, 1060–1075 `cap_check`, 1455–1495 `compact_lines`, 1675–1745 commit and plan-execution notes); `workflow-init.md` §§ 2.1, 2.1a, 2.2, 2.10, 2.18; `skills/intake`, `skills/harden-finding`; `scripts/ledger-metrics.py` 340–360, 500–580; `scripts/loop-usefulness.py` 300–335; `docs/hardening-log.md` Columns. No library API is used (no Context7 lookup needed).
Impact: the shipped plugin (hook, two skills, one command), this repo's rules and docs. Not touched: `source-files/`, `examples/`, the other report scripts (`run-analytics`, `live-effort`, `status-view` read transcripts, not pass files on disk — checked by grep).

## Long runs, handover, outside actions

- No run is expected to take 45 minutes. The full battery takes about 20–25 minutes (two hook-suite runs of about 9 minutes each); per the brief, a heavy local run of 15 minutes or more is announced in one line first.
- Handover boundary: the merged PR (one unit).
- Actions outside the repository: none (no account, no paid run, no file under the home directory). `claude plugin update` after the merge is the orchestrator's.

---

### Task 1: Hook reads the mode (subagent)

**Files:** Modify `plugins/dev-workflow/hooks/codex-gate.sh`; test `plugins/dev-workflow/hooks/codex-gate.test.sh`; docs strings in `docs/reference.md` § Hook messages if a message changes.

**Interfaces:** Produces: the hook reads `$repo_root/.claude/codex-gate.mode`; state files `.context/codex-gate.modeA` and `.context/codex-gate.modeB` (remembered mode per gate, cleared wherever `countA_file` / `count_file` are cleared); separate variables `floorA capA floorB capB` replacing the single `floor`/`cap` in every use (`cap_check`, compact line, Gate B commit notes, Gate A plan-execution note). Existing `.context/codex-gate.floor`/`.cap`/`.cap-extra` keep overriding both gates as today.

- [ ] Step 1: tests (fail on 0.45.0 where noted): `mode: no file → Gate B below-floor note at 1/3 and Gate A 3`; `mode: lean → B floor 1 met after one pass, B cap note at 3, A floor 2` (fails on 0.45.0); `mode: strict → B cap 5`; `mode: classic → 3/5`; `mode: unusable word → classic numbers plus a note naming the file`; `mode: whitespace/CRLF around lean → lean`; `mode: classic→lean mid-cycle → B floor stays 3 and a note says the modes differ`; `mode: legacy counter without modeB → classic`; `floor file overrides lean`; `Gate A plan-execution note names the spec threshold (risk high or security not none) and the mode`.
- [ ] Step 2: run `HOOK_SH=sh sh plugins/dev-workflow/hooks/codex-gate.test.sh` → the new cases fail.
- [ ] Step 3: implement. Mode word read with the edge-trim used by `read_int_file`; known words `lean|strict|classic`. Remembered mode written at the first counted pass of a gate when its counter goes 0→1; the effective numbers are the higher floor and the lower cap of remembered and current. Messages: keep the existing note shapes, replace `$floor`/`$cap` by the gate's own value, and add "mode <word>" to the floor/cap notes. Every new message gets a `# Target model:` comment like its neighbours and is listed in `docs/reference.md` § Hook messages.
- [ ] Step 4: run both suites (`HOOK_SH=sh sh …` and `HOOK_SH=dash dash …`) and `shellcheck --shell=sh` on both files → all pass.
- [ ] Step 5: WIP commit.

### Task 2: Cycle-line readers (subagent)

**Files:** Modify `scripts/ledger-metrics.py` (the two evidence labels near lines 568–574); test `scripts/ledger-metrics.test.sh`, `scripts/loop-usefulness.test.sh`.

- [ ] Step 1: tests: a standard-risk `floor 1 per {… (level 1)}` provenance line next to a historical one parses in both scripts; ledger-metrics prints the labels `provenance lines whose set licenses floor 1 (pre-0.46 level rule):` and `provenance lines recording floor 1 (pre-0.46 level rule, or a 0.46 lean/strict mode; the record does not say which):`.
- [ ] Step 2: run both suites → the label case fails.
- [ ] Step 3: change only those two labels.
- [ ] Step 4: both suites pass; WIP commit.

### Task 3: Gate rules (inline)

**Files:** `.claude/review-gates.md`; `plugins/dev-workflow/commands/workflow-init.md` `### 2.1a` fenced copy.

- [ ] Step 1: write the new rules into `.claude/review-gates.md`: modes and their numbers (spec §2 table, as short lines); the one approval definition; the Gate A threshold and `**Gate A:** runs | skipped — <profile>` header line; "Blocking" and the phase table as short lines; verify pass (§3) including the full-pass fallback; cap routing (§4); `classic:` lines keeping O6–O8, O12, O14 verbatim in meaning; Gate B prompt: battery evidence and what not to report (§5); closing act: archive step, resume in both places, learning row = the hardening row. Profile-line sentence per O3.
- [ ] Step 2: copy it byte-identically into `### 2.1a`; run `sh scripts/check-invariants.sh` → 4i (≤ 10,000) and 4j pass. If 4i fails, tighten wording, never drop a spec condition (spec D-11).
- [ ] Step 3: walk spec §6 rows O1–O19 against the new text and note each row's line in the PR body; walk `docs/prompt-standards.md` items 1–12.

### Task 4: CLAUDE.md §4 and the `### 2.1` template (inline)

- [ ] Step 1: in both: run order "spec → Gate A (per mode) → plan"; checkpoint `spec` per the approval definition; "brainstorming's design approval is the spec's approval (`.claude/review-gates.md`)"; stop list gains "the quality command still red after 5 rounds"; a quality-command paragraph (one source of green, 5 rounds, crash/missing/timeout red except the untouched-test timeout rule; not in `classic`); Plan paragraph gains the UI app-run duty (not in `classic`).
- [ ] Step 2: `sh scripts/check-invariants.sh` → 4e and 4g pass.

### Task 5: Command and skills (inline)

- [ ] Step 1: `/workflow-init`: after 2.1a, write `.claude/codex-gate.mode` = `lean` per spec §2 (both surfaces current; present file never overwritten; the present-file-with-stale-surface report); 2.2 scaffold Columns text = spec §5 learning rows; 2.10 adds default-branch protection to the closing checklist; the report lists the mode outcome.
- [ ] Step 2: `skills/intake`: checkpoint list and hand-off use "once approved"; `skills/harden-finding`: step 4 `1 prose` with the reason in `ref`; step 7 row content (symptom and cause in `finding`; change, location and evidence in `ref`).
- [ ] Step 3: `docs/hardening-log.md` Columns paragraph same as the 2.2 scaffold.

### Task 6: Repo settings, docs, version (inline)

- [ ] Step 1: `.claude/codex-gate.mode` = `strict`; `.gitignore` adds `!.context/archive/` with a one-line why.
- [ ] Step 2: README (situation rows), `docs/reference.md` (modes, settings files, hook messages), `docs/coding-workflow.md`, `docs/getting-started.md` (the `1/3` example), `docs/ARCHITECTURE.md` (`floor=3` sentence and layout tree if a file is added), CHANGELOG 0.46.0, version 0.46.0, `todos.md` row for D-8 (726 tracked pass files not moved).
- [ ] Step 3: run the AGENTS.md claim-grep recipes (manifest claims; gate-proof overclaims) on the changed files; fix hits.

### Task 7: Battery, Gate B, PR, merge

- [ ] Step 1: announce, then run the full quality battery (AGENTS.md § Commands) → exit 0; `sh scripts/check-version-bump.sh main` after the WIP commit.
- [ ] Step 2: Ponytail pre-review once on the branch diff.
- [ ] Step 3: Gate B under the installed 0.45 rules (floor 3, cap 5), as the hook enforces them; repair Blockers/Majors; closing commit with cycle lines.
- [ ] Step 4: PR, `/dev-workflow:process-pr-review`, squash-merge with own body, main CI read with a bounded wait (60 minutes from the merge, the run id seen first).

## Deviations

- Tasks 3–6 inline instead of subagent-driven: they share one byte budget and must stay consistent sentence by sentence across five surfaces; a subagent per surface would split that.
- Gate B of this change runs under the installed 0.45 rules (floor 3, cap 5), the stricter of the two and the one the installed hook counts.
