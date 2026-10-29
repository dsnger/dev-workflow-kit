# Kit 0.49: learnings from the 0.48 project refresh — Design

**Story:** `docs/superpowers/stories/2026-10-29-kit-049-learnings-story.md` (risk standard, security standard,
battery+check, checkpoints none). **Date:** 2026-10-29. **Plugin version:** 0.49.0.
**Gate A:** runs — risk standard; security standard; evidence battery+check (`strict`: security not `none`).

## 1. Intent
Six small learnings from refreshing six projects to 0.48 (story §1). Each change is the smallest that makes its
criterion true; nothing else in the touched files changes.

## 2. Version record and stale-copy notice (AC-1, AC-2)
- **Record.** New `/workflow-init` template `### 2.23` writes `.claude/dev-workflow-version`: one line, the kit
  version, written inline in the template (`0.49.0`). Invariant 9 applies as to any file: missing → write;
  identical → unchanged; different → show old and new and ask (the run is the refresh, so the recommendation is
  to write). It is written after every other target, and the report says that the record names the kit version of
  the last run, not that every file was accepted.
- **Notice.** `hooks/hooks.json`'s `SessionStart` entry widens from `compact` to `startup|resume|clear|compact`
  (every session-start source), same command. In the hook's `SessionStart` branch, before `compact_lines`, a new
  `version_line` runs on any source. It stays silent
  when the opt-out marker exists (as every output does); not adopted already exits earlier (`is_adopted`). It reads
  the plugin version from `"$(dirname "$0")/../.claude-plugin/plugin.json"` (the hook's own plugin, never this
  repository's layout; Boundary 7) with `sed`, no `jq` (invariant 4); an unreadable or non-`x.y.z` plugin version
  → silent. The project record is read from the repository root; it counts only as one line matching
  `^[0-9]+\.[0-9]+\.[0-9]+$`, so no file content reaches the model's context. It prints one plain line when the
  record is missing, unreadable/malformed, or differs. The record names only the kit version of the last
  `/workflow-init` run, so the line claims no more: `dev-workflow: the last /workflow-init run here recorded kit
  <R | no version (no record) | an unreadable record>; the installed plugin is <P>.` followed by the action, which
  depends on direction (each part compared as a number, `awk`): record older, missing or unreadable → `Tell the
  user; /dev-workflow:workflow-init refreshes the project files.`; record newer → `The installed plugin is older
  than this project's files: tell the user to update the plugin before running /dev-workflow:workflow-init.`
  Equal → nothing. Exit status stays 0 on every path (invariant 1). The compaction comment that says SessionStart
  is registered for `compact` only is corrected; `compact_lines` keeps its own `source` check, so a startup event
  never announces a compaction.
- **This repository** gets `.claude/dev-workflow-version` = `0.49.0` too, so its own sessions are told when the
  installed plugin lags the checkout.
- **Check 4n** in `scripts/check-invariants.sh`: the version in the fenced `### 2.23` template, this repository's
  `.claude/dev-workflow-version` and `plugins/dev-workflow/.claude-plugin/plugin.json` are equal; a mismatch fails
  with the three values. Cases in `check-invariants.test.sh`: equal passes; each one differing fails.
- **Hook suite** (`codex-gate.test.sh`, under `sh` and `dash`): adopted + equal → no line; missing → line;
  malformed record (`0.49.0; rm -rf` or two lines) → the "unreadable record" line, with no record text echoed;
  record older → refresh line naming both; record newer →
  update-the-plugin line; not adopted → nothing; opt-out marker → nothing; hook copied where no `plugin.json`
  sits beside it → nothing; startup, resume and clear sources → no compaction
  line; `hooks.json` matcher holds all four sources (read by the suite); exit 0 in every case.

## 3. No CI run is not a red check (AC-3)
- **Rule text**, this repository's `CLAUDE.md` and the 2.1 template's "Waiting on external work": before waiting
  on a CI run for a PR, read which status checks the target branch requires, each with its source restriction —
  classic protection (`gh api -H "X-GitHub-Api-Version: 2026-03-10" repos/<owner>/<repo>/branches/<base> --jq
  '.protection.required_status_checks.checks[]? | "\(.context) \(.app_id)"'`) and every rule from the rulesets
  that apply to it, all pages (`gh api --paginate -H "X-GitHub-Api-Version: 2026-03-10"
  'repos/<owner>/<repo>/rules/branches/<base>?per_page=100' --jq '.[] | select(.type == "required_status_checks")
  | .parameters.required_status_checks[] | "\(.context) \(.integration_id)"'`), `<base>` checked against
  `^[A-Za-z0-9._/-]+$` first. A non-null source id means only that app's status counts. **None required** (both calls succeed, both empty): a run that never appears
  is no failed check; the quality command on the final head is the green, and the PR body records `run id: none`,
  the reason (for example "Actions budget used up" or "Actions off"), the SHA, the exit status and the duration.
  **One required** that no run or local reporter will produce: stop and report (the check, why nothing produces
  it, and that a ruleset change or the local path is the human's call). **Unreadable** (a call or any page fails):
  treat as required. The existing 5-minute / limit rule is unchanged for a run that is expected.
- **`process-pr-review`** Step 1, Step 3 item 6 (text and report example), Step 4's merge condition and **Done**
  point at that rule: with no required check, the PR-body record stands in for "the required check is green on
  the final head". Item 6's two exceptions (an untouched-test timeout; a docs-only rerun of some stages) lean on
  a green required check for the rest; with none required they do not apply, and the full quality command on the
  final head is the record.
- Verified 2026-10-29 on this repository: the branches call returns `contexts: []` for main (ruleset only), the
  rules call returns `{"context":"quality"}` with no `integration_id`, and a branch with no rules returns `[]`.
  API source: Context7 `/websites/github_en_rest` ("Get rules for a branch": paginated, `per_page` default 30, max
  100; `required_status_checks[].integration_id` "the optional integration ID that this status check must
  originate from"), REST API version 2026-03-10, the version `scripts/local-ci.sh` already sends.

## 4. Local path ships to projects (AC-4, AC-5)
- **Generalize `scripts/local-ci.sh`** (kept the kit's runner, so its 0.47 suite covers the shipped text):
  precondition 4 applies only when `.github/workflows/ci.yml` at that commit pins a shellcheck version: missing file
  or no pin → no shellcheck check and no `shellcheck <v>` part in the description; more than one distinct pin →
  refuse as today. The header's kit-only references (spec path, suite path) become "from the dev-workflow kit
  (`/workflow-init` 2.22); suite: the kit's `scripts/local-ci.test.sh`". Everything else stays.
  New suite cases: no `ci.yml` → runs, description `battery green: local run, claude <v>`; `ci.yml` without a pin
  → same. The existing "no pin → refuse" case changes to this behaviour; "two pins → refuse" stays.
- **Template `### 2.22`** in `workflow-init.md`: the script, fenced, byte-identical to `scripts/local-ci.sh`
  (invariant 8). Asked, default **yes** when the project's default branch requires a check named `quality`
  with no source restriction (§3's two calls), else **no**; invariant 9 applies. When that check is restricted to
  one source (a non-null `integration_id` or `app_id`), say that a status posted by `gh` cannot satisfy it and that
  lifting the restriction is the human's decision, before any switch; keep the 0.47 warning that a same-name
  Actions check run already on a commit must pass too, so the switch comes before the push. Text beside it: the quality row in `AGENTS.md § Commands`
  must be one backticked command, and in a fresh worktree it must install what it needs (for example a frozen
  lockfile install first), as CI does; the switch (`gh workflow disable <workflow>` before pushing the commit run
  locally, then `sh scripts/local-ci.sh <sha>` per head) and that any ruleset or protection change is the human's.
  It never changes a ruleset, a protection or a workflow's state.
- **Check 4m**: the fenced `### 2.22` text equals `scripts/local-ci.sh` byte for byte (as 4l does for 2.21).
  Cases: identical passes; one byte changed fails; template missing fails.
- **Docs:** `docs/reference.md` "The local path" (projects: 2.22, dependencies, the human's ruleset change),
  `docs/setup.md` (a short optional step), `README.md` row, AGENTS.md Boundaries 4b/5 and the check list, 
  `docs/ARCHITECTURE.md`, `docs/TECH-STACK.md` shellcheck row.

## 5. Greptile text (AC-6, AC-9)
Source: greptile.com docs `code-review/greptile-json-reference` (read 2026-10-29): `autoReview` default `["open"]`,
values `open`, `push`, `rebase`, "`[]` means never", and `skipReview: "AUTOMATIC"` "is `[]`, which skips
auto-reviews but allows manual triggers"; `trigger-code-review`: a comment `@greptileai` starts a review.
- 2.5 question: three answers — **no** (default, Ignore, off), **on request** (`autoReview: []`; a review only
  when someone comments `@greptileai`; routed under Process opportunistically as `once per PR`), **label**
  (today's path). The reason line says per-push review is a configuration (`autoReview` with `push`/`rebase`,
  or the legacy `triggerOnUpdates: true`), not Greptile's default, and that it cost one account over 700 USD.
- Same wording in the 2.5 template row, `docs/setup.md` step 9, `docs/reference.md` § PR review bots, README row,
  `docs/getting-started.md` PR bot step. This repository's bot file: Greptile stays off; its turn-on note names
  both paths.
- `todos.md` row "Greptile reviews every push" closed with this change.

## 6. §5 pointer classification (AC-7)
Rule 2's pointer form becomes: the template pointer with **either or both** of two paragraphs absent — the one
beginning `**Before you conclude that file is missing,**` and the one beginning `**Before the session's first
Gate A or Gate B call,**` — each with its adjacent blank line; Rule 2 shows the missing paragraphs as the
difference and recommends adding them. Covers kit 0.24–0.25 (neither), 0.26–0.43 (no probe), 0.44 on (both).
Verified: the pointer text outside those two paragraphs is unchanged from 0.24.0 (`9e12fba^`) to HEAD (`git show`
of each, diffed). The "older pointer" (0.16–0.23) rule is unchanged.

## 7. No active bots (AC-8, AC-9)
- `process-pr-review` Step 2: when no bot is on for this PR, or none on for it reviewed, write one line
  `PR bots: none ran on <sha>` (plus each `<bot>: no review on <sha>` for a bot that is on), wait for nothing, and
  go on. Step 3 item 1's existing empty-claim route still runs (answer any thread that needs it, item 6, then
  Step 4); only bot triage is skipped. Gate B was the review.
- This repository's `docs/pr-review-bots.md`: CodeRabbit row `no` (removed by Daniel 2026-10-29), routing under
  Ignore; its history stays as record; "Wait for" and "Process opportunistically" read *none*. The two passages
  that call the count the arbiter "for any bot" are scoped to CodeRabbit, as the query paragraph is; that
  `todos.md` row is closed.

## 8. Version and docs (AC-10)
0.49.0 in `plugin.json`, the 2.23 template, `.claude/dev-workflow-version`; CHANGELOG entry; README.

## 9. Decisions
- D1: one hook line at session start, not a check at commit time: the commit path is the gate's, and a session
  start is when a refresh can still be planned.
- D2: unreadable plugin version → silent: the notice is advisory, and a guess would name a wrong version.
- D3: the record is a file of its own under `.claude/`, not a line in `CLAUDE.md`, so a project's own edits of
  `CLAUDE.md` never touch it and the hook reads one line.
- D4: the kit keeps one `local-ci.sh`, generalized, rather than a separate project copy: the shipped text is the
  tested text, and check 4m keeps them equal.
- D5: the description keeps the `claude <v>` part in projects too: it names the CLI that ran the battery, and
  removing it changes the 0.47 contract for no gain.
- D6: an unreadable branch-rule answer counts as a required check (stop), the safe direction.
- D8: the hook's matcher widens to every session-start source rather than `startup` alone (Gate A pass 1):
  a resumed session after a plugin update is a session start too.
- D9: the story's §4 cited the manifest rule as invariant 7; it is invariant 6, and the layout rule is Boundary 7.
  Corrected in the story as a citation fix; no criterion changes.
- D7: item 6 of the candidates (Ponytail skipped once) gets nothing built; part 2 of the Greptile order still
  waits on sfx-factory #106/#107.

## 10. Sources and impact boundary
Read: the order and candidates files, `.claude/review-gates.md`, `CLAUDE.md`, `AGENTS.md`,
`process-pr-review.md`, `workflow-init.md` (2.1, 2.5, 2.10, 2.12, 2.21, Step 3–4), `scripts/local-ci.sh`,
`docs/reference.md` (PR review bots, the local path), `docs/setup.md` step 9, this repository's
`docs/pr-review-bots.md`, `todos.md` 0.48 rows, the hook's adoption check and SessionStart branch, canvas
`docs/handovers/kit-048-init.md`. GitHub REST: branches and rules endpoints, tried live on this repository.
Greptile: its own docs (above); not a library API, no Context7 entry. Not touched: the gate rules file, Gate B's
fingerprint, the hook's commit path.
