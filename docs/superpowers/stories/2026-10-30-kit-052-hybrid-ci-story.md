# Kit 0.52 hybrid CI — Story

**Date:** 2026-10-30 · **Size:** story · **Checkpoints:** none
**Risk:** high · **Security:** standard · **Validation:** battery+check+verification

## 1. Problem statement

The kit's CI has two paths, GitHub Actions and `scripts/local-ci.sh` (0.47), but nothing shows which one a
project is on, and the docs read as if local were the default since the October Actions budget ran out.
Daniel, 2026-10-30: the Actions budget is about 180 € a month; "Actions optional; the monthly budget may be
used up; locally as fallback and/or if decided up front; hosted is faster, so don't drop it." Switching today
is a bare `gh workflow disable|enable` with no record, no hint when a run was blocked by billing, and no
reminder when a new month renews the budget. Actions runs the whole battery even for a docs-only change,
while `local-ci.sh` has had a light lane since 0.50. On the shared Mac, sfx-factory serialises heavy work with
a machine-wide lock that `local-ci.sh` ignores, so a 35-minute kit battery and a factory test run can overload
the machine together (`todos.md`, "A machine-wide lock for heavy runs").

Sources: `.context/sparring/20261030-0955-kit-052-hybrid-ci-prompt.md` (the brief, which governs) and
`.context/sparring/20261030-0940-hybrid-ci-prompt.md` (Daniel's order), both in the main checkout; the lock
protocol in sfx-factory `harness/kit.py` (`heavy_lock`, `heavy_open`, `heavy_ticket`, `heavy`), read only.

## 2. Desired outcome

Hosted Actions is the default and local the fallback or an up-front choice, and one command shows and flips
the state with a record. A billing-blocked run is recognised and names the switch command; a new month
reminds the user to switch back; nothing flips without the user. The Actions job takes the same light lane as
`local-ci.sh` for docs- and release-only changes. A full local battery waits for the machine-wide heavy lock
when one is in use on the machine.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** A switch command (`scripts/`, shipped to projects as an inline `/workflow-init` template kept
  byte-identical by a check) shows the state, hosted (workflow enabled) or local (workflow disabled), and flips
  it to the named state only after the user answers yes to a question; no answer or any other answer flips
  nothing. Each flip appends one line (date, from, to, reason) to a log whose location the spec records; the
  command checks the log is writable before it asks, and a write that still fails after the flip is reported
  and leaves the flip standing.
- [ ] **AC-2** The switch command changes only the workflow's enabled state, with the user's own `gh`; never a
  ruleset, branch protection, billing or a spending limit.
- [ ] **AC-3** Given a failed run, the command detects a billing / spending-limit block from its jobs' check-run
  annotations, prints what is blocked, the exact switch command and what else the switch needs (a check run
  Actions already created on a commit stays and must pass, so the local run goes on a head pushed after the
  switch; a required check restricted to one source is the human's to lift), and flips nothing; a run that
  failed in its tests is not reported as blocked.
- [ ] **AC-4** When the month changed since the last switch log line and that line switched to local, the switch
  command (when GitHub also reads local) and `local-ci.sh` (from the log alone, a recorded state) print one
  line: the budget is renewed, with the command to switch back to hosted. Silent otherwise; nothing flips.
- [ ] **AC-5** The Actions `quality` job decides its lane with `local-ci.sh`'s own lane logic and, for a docs- or
  release-only change, runs only the light row's checks; the job keeps its name, no `paths-ignore`, no second
  required check.
- [ ] **AC-6** `local-ci.sh`'s full battery takes an exclusive lock on the machine-wide heavy lock file
  (`$SFX_HEAVY_LOCK`, else `~/.cache/sfx-factory/heavy.lock`) when that variable is set or the default file's
  directory exists, waits while another holder has it, and releases it on every exit including a kill; with
  neither, it takes no lock. A catchable signal stops the battery before the lock is released. It never
  creates, deletes or rewrites the factory's queue files.
- [ ] **AC-7** The docs say hosted is the default and local the fallback or an up-front choice (README,
  `docs/reference.md` "The local path", CHANGELOG), and state whether a kit run joins the factory's FIFO queue.
- [ ] **AC-8** Tests cover: the switch shows, asks, flips (stubbed `gh`), logs, and refuses without an answer;
  budget detection on a stubbed blocked run and no hit on an ordinary test failure; the reminder prints after a
  month change and is silent otherwise; `local-ci.sh` waits while another process holds the lock, then runs,
  and releases on exit and on a kill; a docs-only change takes the light lane on both paths (the Actions lane
  step run locally).
- [ ] **AC-9** Released as the next free minor (0.52.0 unless taken) with CHANGELOG, README and docs updated; the
  `todos.md` row "A machine-wide lock for heavy runs" is closed.

## 4. Affected AGENTS.md invariants
- `## Key invariants` › Packaging — "5. **Every version pinned exactly.**" (ci.yml edits)
- `## Key invariants` › Prompts and scaffolding — "8. **`/workflow-init`'s templates stay inline** in the command body."
- `## Key invariants` › Prompts and scaffolding — "9. **`/workflow-init` never overwrites silently.**"
- `## Key invariants` › Prompts and scaffolding — "11. **Prompt changes pass `docs/prompt-standards.md`**"
- `## Key invariants` › Packaging — "12. **A plugin change requires a version bump.**"
- `### Boundaries (binding)` — 4b (`scripts/local-ci.{sh,test.sh}`: "never ... changes ... a workflow's state") and 5 (shipped templates kept by checks)
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"
- `## Don'ts` — "**Never splice data into shell source a prompt tells the agent to run without bounding it.**"

## 5. Open questions
- None. The version is decided at the PR: 0.52.0 if kit 0.51 merged first, else ask the orchestrator.

## 6. Suggested size
story — one feature (hybrid CI). The switch, the billing check and the reminder share one script and one log;
the Actions lane reuses `local-ci.sh`; the lock sits in `local-ci.sh`. Split into small PRs was considered: each
part edits `local-ci.sh` or its template, so one PR avoids four rebases of the same byte-identical copy.
