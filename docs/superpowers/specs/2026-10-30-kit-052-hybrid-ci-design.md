# Kit 0.52 hybrid CI — Design

**Story:** `docs/superpowers/stories/2026-10-30-kit-052-hybrid-ci-story.md` (level 2) ·
**Profile:** risk high; security standard; evidence battery+check+verification (from the story header) ·
**Gate A:** runs — risk high; security standard; evidence battery+check+verification

## 1. Scope

Four parts in one PR, each with tests: (A) `scripts/ci-switch.sh`, a new script with three modes — show,
flip, check a failed run — and the month reminder; (B) a `--lane` mode in `scripts/local-ci.sh` that
`.github/workflows/ci.yml` calls to take the light lane; (C) the machine-wide heavy lock around
`local-ci.sh`'s full battery; (D) docs and release. Non-goals stay: no self-hosted runner, no GitHub App, no
automatic flip, no scheduler, no ruleset, protection, billing or spending-limit change. The battery starts no
test server or database, so no port handling is built. The project CI template (`/workflow-init`'s
`quality.yml`) is not given the light lane here (§7).

**Library APIs.** GitHub REST API, version 2026-03-10 (the version `local-ci.sh` already sends), looked up in
Context7 `/websites/github_en_rest`: "Get a workflow" (`state`), "Enable a workflow" / "Disable a workflow"
(PUT, 204, workflow file name accepted as `workflow_id`), "List jobs for a workflow run" (`jobs[].conclusion`,
`steps`, `check_run_url`, `name`), "List check run annotations" (`[].message`). `perl` `Fcntl`/`POSIX` are
core modules of the system perl, addressed by name like `dash`; no Context7 entry is needed for them, their
`perldoc` is the source.

## 2. (A) `scripts/ci-switch.sh`

Shipped as `/workflow-init` `### 2.24` (asked, like 2.22, same default rule), kept byte-identical by a new
check 4o in `scripts/check-invariants.sh`, the same shape as 4m. POSIX `sh`, `git`, `gh`; `jq` only through
`gh --jq`.

**Usage.**
- `sh scripts/ci-switch.sh` — show: prints `ci-switch: <owner>/<repo> is hosted|local (<file>: <state>)`, then
  the reminder when it applies. Exit 0.
- `sh scripts/ci-switch.sh hosted|local "<reason>"` — flip. Shows the state; already in the target state:
  prints so, exit 0, no log line. Otherwise it checks that the log can be appended (directory created, file
  opened for append; failure: refuse 64 before asking), prints one question,
  `Switch <owner>/<repo> CI from <from> to <to> (<file>; reason: <reason>)? [y/N] `, and reads one line from
  stdin; `y` or `yes` (any case) goes on, anything else or end of input prints `ci-switch: not switched` and
  exits 1. After a yes it reads the state again; changed meanwhile: `not switched`, exit 1. The reason is
  required (empty: usage error); tabs, CR and LF in it become spaces before it is printed or logged.
- `sh scripts/ci-switch.sh check <run-id>` — billing check (§2.3). `<run-id>` must be digits only.
- Exit codes: 0 done (or block found, in `check`), 1 not switched (or no block found), 64 usage, precondition
  or read failure, 75 the flip request failed and the state read back is not the target (nothing logged).

**Preconditions** (each failure: one line, exit 64): inside a git work tree; `origin` names a github.com
repository (the same pattern as `local-ci.sh` precondition 2; owner and repository come from it only, never
`GH_REPO`/`GH_HOST`); `gh` on PATH and `gh auth status --hostname github.com` succeeds; exactly one of
`.github/workflows/quality.yml` (what `/workflow-init` scaffolds) and `.github/workflows/ci.yml` (this repo)
exists in the work tree — none or both refuse and name them.

### 2.1 State and flip

`GET repos/<o>/<r>/actions/workflows/<file>` with `--jq .state`. `active` is hosted; `disabled_manually` and
`disabled_inactivity` are local, shown raw; any other value, an empty one or a failed read (a deleted or
unknown workflow) is not a state: one line naming it, exit 64. The flip is `PUT …/actions/workflows/<file>/enable`
(to hosted) or `…/disable` (to local). A failed PUT is followed by one more read: target state reached (the
reply was lost) — logged, with `(reply failed, state read back)` appended to the reason, exit 0; otherwise
exit 75, nothing logged. Nothing else is written to GitHub, ever: no ruleset, protection, variable, billing
or spending call exists in the script. Two flips at once from two worktrees are not serialised beyond the
re-read after the yes; a change made outside the script (the web UI, another clone) is not logged at all —
both stated in the docs.

### 2.2 Log and reminder

**Log:** `<main>/.context/ci-switch.log`, untracked, where `<main>` is the first entry of
`git worktree list --porcelain` (the main work tree), so every worktree of one clone shares one log — the
precedent is `worktree-cleanup.sh` writing `<main>/.context/archive-worktree-*`. Chosen over a tracked file
because a flip must not need a commit, and a tracked line would make the next head a non-records change.
After a flip, one line is appended, tab-separated: `<UTC date-time ISO 8601>`, `<from>`, `<to>`, `<file>`,
`<reason>`. Writability is checked before the question (above); an append that still fails after the flip
(disk full) prints `ci-switch: switched, but the log line could not be written: <line>` and exits 0 — the flip
stands and GitHub holds the state (story AC-1).

**Reminder:** the last line of the log whose third field is `hosted` or `local`. When that field is `local`
and its date's `YYYY-MM` differs from `date -u +%Y-%m`, print to stderr one line:
`ci-switch: a new month renews the Actions budget (last recorded switch to local: <YYYY-MM>); back to hosted: sh scripts/ci-switch.sh hosted "budget renewed"`.
`ci-switch.sh` prints it only when the API state is also local. `local-ci.sh` prints it from the log alone (a
recorded state; it reads no workflow state), at start of a posting run in every lane; `--lane` never prints
it. So after a switch to hosted made outside the script, `local-ci.sh` can still remind — the line says
"recorded", and the docs say so. No log or no such line: silent. Calendar months in UTC: a billing cycle that
renews on another day is outside this check, stated in the docs.

### 2.3 Billing check

`GET repos/<o>/<r>/actions/runs/<id>/jobs?per_page=100` (`--paginate`), selecting jobs whose `conclusion`
is `failure` and whose `steps` list is empty — a job GitHub never started. For each, the check run id is the
last path segment of its `check_run_url` (digits only, else a read failure), and `GET
repos/<o>/<r>/check-runs/<check run id>/annotations` gives the messages, matched case-insensitive against
`spending limit|payments have failed`. The sentence GitHub writes, as recorded in sfx-factory
`tests/test-ci-runner.sh` (inference: copied from a real block): "The job was not started because recent
account payments have failed or your spending limit needs to be increased." A job with steps (an ordinary
failure, also one whose test output mentions billing) is never read. On a hit it prints, and exits 0, flipping
nothing:
- `ci-switch: run <id>: job "<name>" was not started: <message>`
- `ci-switch: GitHub Actions is blocked by billing for <o>/<r>; switch to local: sh scripts/ci-switch.sh local "Actions budget used up"`
- `ci-switch: then push a new head and run sh scripts/local-ci.sh on it: a quality check run Actions already created on a commit stays there and must pass too; a required quality check restricted to one source cannot be met by local-ci.sh, and lifting that is yours`

No hit: one line, exit 1. A failed read: exit 64.

## 3. (B) Light lane in Actions

**`local-ci.sh --lane <base> [<commit>]`:** prints `light` or `full` and exits 0. It runs precondition 1,
resolves `<base>` (failure: refuse, 64), reads the `quality-light` row and calls the existing
`release_only light <base> <sha>` — the same function and the same row the local light lane uses, no second
variant. It skips preconditions 2–4 and 6, reads no `quality` row, takes no lock, prints no reminder, creates
no worktree and posts nothing. `--lane` and `--from` together: usage error. No `quality-light` row: `full`.

**`ci.yml`:** a step `id: lane` right after checkout:
`lane=$(sh scripts/local-ci.sh --lane "$BASE" HEAD 2>/dev/null) && [ "$lane" = light ] || lane=full`, then
`echo "lane=$lane" >> "$GITHUB_OUTPUT"` and the lane into the log. `BASE` comes through `env`, never `${{ }}`
in the script: `origin/<base_ref>` on `pull_request` (HEAD is GitHub's merge commit, so base..HEAD is the PR's
change), `github.event.before` on a push (all zeros or unknown: the call fails, so `full`). The lint, hook
tests and suites steps get `if: steps.lane.outputs.lane != 'light'`; the old invariant step splits into the
suites (full only) and `check-invariants.sh` plus `check-doc-links.sh` (always). The version-bump step (PRs)
and `claude plugin validate` stay unconditional. The light lane in Actions therefore runs what AGENTS.md's
`quality-light` row runs. The new `ci-switch.sh` and `ci-switch.test.sh` are added to the lint step and the
suite to the suites step, as to AGENTS.md's quality and lint rows. The job keeps the name `quality`; no
`paths-ignore`; no new job. Any failure in the decision is `full`, the safe direction.

## 4. (C) Heavy lock

Around the battery command of the **full lane only** (the light lane runs no tests and takes seconds; a
2-hour wait for it would cost more than it protects). Lock path: `$SFX_HEAVY_LOCK` when non-empty; else
`$HOME/.cache/sfx-factory/heavy.lock` when `$HOME/.cache/sfx-factory` is a directory; else no lock and nothing
is printed. `SFX_HEAVY_HELD` non-empty (a run inside a holder's step, which already has the lock): no lock, as
the factory's own check does — waiting there would deadlock. `HEAVY_LOCK_WAIT_SECS` (the factory's variable)
must be a positive integer of digits, default 7200; anything else refuses 64 before waiting.

**Trust boundary (the factory's `heavy_open` model, without its repairs):** an anchor the factory also
trusts as given — `$HOME` for the default path, the lock's grandparent for `$SFX_HEAVY_LOCK` — is entered
with `chdir` (followed as the factory follows it; ancestors above the anchor are trusted, as there). Below it
the walk is relative and pinned to inodes: for each directory (default: `.cache`, `sfx-factory`; override:
the lock's directory) `lstat` must show a directory, not a symbolic link, owned by this user, without group or
other write; then `chdir` into it, and `stat('.')` must show the same device and inode as that `lstat`, else
refuse (the entry was swapped between the two). The lock file is then opened relative to that working
directory, `O_RDWR|O_CREAT|O_NOFOLLOW`, mode 0600 when created (the factory creates it too), and `fstat` must
show a regular file of this user without group or other write. Since a process's working directory is held by
inode, a rename of any ancestor after the walk cannot redirect the open — the same guarantee the factory gets
from descriptor-relative opens. The kit never creates or chmods a directory. Anything else: refuse 64 naming
the path, nothing run. The battery child changes back to the worktree before it runs.

**Mechanism:** macOS has no `flock` command; `perl` with `Fcntl` and `POSIX` (core modules of the system perl
on macOS and Ubuntu) holds it. One `perl -e` program, passed the path, the wait and the command as arguments
(never spliced into its source): open and check as above; try `flock(LOCK_EX|LOCK_NB)` once a second; print
`local-ci: waiting for the heavy lock <path> (pid <p> in <dir>)` at once and then once a minute, `<p>` and
`<dir>` from the holder's note (first two lines of the file, `?` when absent); give up at the limit. Once it
holds the lock it writes its own note over the file (`<pid>\n<cwd>\nlocal-ci since <time>\n`, then truncates
— the holder note the factory writes and reads for its wait message), then forks the battery as `sh -c <cmd>`
in a process group of its own, with `SFX_HEAVY_HELD=<its pid>` in the child's environment only, and waits.
The lock descriptor is close-on-exec, so the battery never holds it itself.

**Stop before release:** on HUP, INT or TERM the holder sends TERM to the battery's process group, waits up to
5 s, sends KILL to what is left, reaps the child, and only then exits (128+n), which releases the lock. The
normal end also signals the group (TERM, then KILL after 5 s) before exiting, so nothing the battery left in
the background outlives the lock — the factory's `heavy` does the same. Limit, stated in the docs: a SIGKILL
of the holder itself cannot be caught; the kernel releases the lock at once while the battery group runs on
unlocked until it ends. Ctrl-C in a terminal reaches the holder (same foreground group), which then stops the
battery's own group.

A give-up or a refused lock writes a marker file in the run's temp directory and exits; `local-ci.sh` then
refuses (exit 64, nothing posted) instead of reading a battery status. Lock used but `perl` missing: refuse 64.

**Factory queue:** not joined. The factory keeps a FIFO of tickets in `<lock>.queue/`; `local-ci.sh` never
creates, deletes or touches anything there. Consequence, stated in the docs: when a factory holder releases
the lock, a waiting kit run can take it before a factory step that waited longer. Mutual exclusion holds
either way.

**Signals of `local-ci.sh` itself:** unchanged from 0.47 — its trap runs after the foreground command returns;
a TERM sent to the shell alone therefore waits for the battery, as today.

## 5. (D) Docs and release

README (one line in the table and "Contributing": hosted is the default, local the fallback or an up-front
choice; the switch command), `docs/reference.md` "The local path" rewritten around the two states — keeping
its existing conditions: switch before you push the commit you run locally, a check run Actions already
created stays and must pass, a source-restricted required check is the human's, `gh` statuses can be posted
by anyone with write access, run only on read commits — plus the switch, the billing check, the reminder and
its limits, the lock and its limits, and the Actions light lane; CHANGELOG entry; AGENTS.md: Boundaries 4b
(lock, `--lane`), a new 4c for `ci-switch.sh` (changes only the workflow's enabled state, after a yes; appends
to `<main>/.context/ci-switch.log`), 5 (2.24 / check 4o), the Commands rows (lint and quality add the script
and suite; a `ci-switch` row), the checks paragraph (4o), `perl` among the named system tools;
`docs/ARCHITECTURE.md` tree and scripts inventory; `docs/TECH-STACK.md` if it lists system tools;
`/workflow-init` 2.22 (no change of default rule) and new 2.24 with their report/checklist lines; `todos.md`
row "A machine-wide lock for heavy runs" closed. Version: the next free minor at PR time.

## 6. Tests (AC-8)

`scripts/ci-switch.test.sh` (new, stubbed `gh` as in `local-ci.test.sh`, no network): show hosted and local;
`disabled_inactivity` shown as local; an unknown, empty or failed state read → 64; flip with `y` → one PUT
to the right endpoint and one log line with five fields; `n`, empty input and end of input → no PUT, exit 1,
no line; already in the target state → no PUT, no line; state changed between question and PUT → no PUT;
empty reason → 64; unwritable log → 64 before the question, no PUT; a PUT failure with the state unchanged →
75, no line; a PUT failure whose state reads back as the target → 0 and a line marked `reply failed`; both or
neither workflow file → 64; a log shared from a second worktree; reminder: local state and a log line from an
earlier month → printed, current month → silent, last switch to hosted → silent; check: a never-started job
with the billing annotation → hit with the three lines, exit 0, no PUT; a failed job with steps whose
annotation mentions a spending limit → exit 1 and its annotations never read; a `check_run_url` without a
numeric tail → 64; non-numeric id → 64.

`scripts/local-ci.test.sh` (extended): at the suite's start `SFX_HEAVY_LOCK`, `SFX_HEAVY_HELD` and
`HEAVY_LOCK_WAIT_SECS` are unset and `HOME` points into the test directory; each lock case sets its own
values, so no case touches the real factory lock and an inherited holder marker (the suite runs inside a
locked battery) cannot skip the lock. The proof of that clearing is the suite's own run inside a locked
battery (the final `local-ci.sh` full run sets `SFX_HEAVY_HELD` for it): a leaked marker would skip the
wait the lock cases assert, so they would fail. Lane: `--lane` on docs-only →
`light`, on a code change → `full`, without a light row → `full`, with `--from` → 64; the `ci.yml` lane step's
`run:` text extracted and run in the fixture with `BASE` and a temporary `GITHUB_OUTPUT` → `lane=light` for
docs-only, `lane=full` for code and for a bad base; the steps the light lane skips carry the `if:`, and the
ci-switch files appear in the lint and suites steps. Lock: a background holder keeps the lock for a few
seconds → the run prints the wait line and the battery starts only after the holder let go; after the run
another process takes the lock at once; a TERM to the holder during a battery that starts a background
sleeper → the battery group is gone before the lock can be taken by a second process; the battery sees a
non-empty `SFX_HEAVY_HELD`; no `SFX_HEAVY_LOCK` and no default directory → no lock file appears;
`SFX_HEAVY_HELD` non-empty → no wait, empty → the lock is taken; `HEAVY_LOCK_WAIT_SECS` empty, `abc`, `0` or
`inf` → 64 before waiting; a give-up after `HEAVY_LOCK_WAIT_SECS=1` → 64 and nothing posted; a symlinked lock
directory, a symlinked `.cache` on the default path, a group-writable lock directory or `.cache`, and an
existing group-writable lock file → 64; an override whose lock directory is reached through a symlinked
grandparent still locks the same inode the factory would (the anchor is followed, as there); the light lane takes
no lock; reminder printed and silent as in ci-switch, and never printed by `--lane`. Check 4o:
`check-invariants.test.sh` gets the same cases 4m has.

## 7. Decisions

- One script for show, flip and check (one template, one check) rather than three.
- Log under `<main>/.context/`, untracked (§2.2); writability checked before asking; a post-flip write
  failure is reported, not undone.
- The flip reads its answer from stdin, no `--yes`: a flag would allow the silent flip the brief forbids.
- Concurrent flips: a re-read after the yes, no mutex — two people flipping one repository at the same minute
  is not a realistic case for a per-user Actions budget.
- Billing match restricted to never-started jobs, so a test that prints "spending limit" cannot trigger it.
- Workflow file: `quality.yml` or `ci.yml`, exactly one; no option, until a project needs one.
- Light lane in Actions via `local-ci.sh --lane`, not a copy of its awk program.
- Lock only for the full lane; non-empty `SFX_HEAVY_HELD` honoured and set for the child; FIFO queue not
  joined; the lock directory is checked, never created or repaired.
- `perl` for `flock`, since macOS lacks the command; addressed by name as a system tool like `dash`.
- The `local-ci.sh` reminder reads the log only (a recorded state), so it costs no API call.
- The project `quality.yml` template keeps one lane: it runs the project's own stack, and the light-row
  mapping per stack is not designed here (a `todos.md` row).
- The kit uses the factory's variable names (`SFX_HEAVY_LOCK`, `SFX_HEAVY_HELD`, `HEAVY_LOCK_WAIT_SECS`) because
  sharing the lock means sharing the protocol; shipped text calls the default path optional, never required.
- Gate A closed at pass 3 (one extra pass granted) by the orchestrator, dev-workflow-kit-26, 2026-10-30 10:12,
  under Daniel's standing gate-stop delegation: the pass-3 lock-path finding (a same-user race on a directory
  under `$HOME`) is repaired in §4 after the last pass, unreviewed there. Gate B (strict) checks the anchored
  walk on the implementation, with a test that swaps a checked directory between its check and its entry; the
  lock code stays as small as the factory model allows.
- Scope added after rebasing onto 0.51 (orchestrator, dev-workflow-kit-26, 2026-10-30 15:26): 0.51 put its two
  review-skill suites into the AGENTS.md quality row but not into `ci.yml`, and this unit makes hosted CI the
  default again, so `ci.yml` gains them (with their shellcheck lines) and check 4q fails when the quality row
  and `ci.yml` name different `.sh` paths. The rebase also renumbered this unit's template and check: 0.51 took
  `### 2.24` and check 4o, so the switch ships as `### 2.27`, kept by check 4p (Boundaries 4d); §2, §5 and §6
  still say 2.24/4o.
