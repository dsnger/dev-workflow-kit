# Kit local CI: run the quality battery on the Mac and report it to GitHub — Story

**Date:** 2026-10-28 · **Size:** story · **Checkpoints:** none
**Risk:** standard · **Security:** standard · **Validation:** battery+check

## 1. Problem statement
The GitHub Actions budget of the account is used up (Daniel, 2026-10-28 09:18 and 09:20). The `quality` job in
`.github/workflows/ci.yml` is the only producer of the status check `quality` that the ruleset `protect-main.`
(id 19168350) requires on `main`, and the ruleset accepts that check from GitHub Actions only (`integration_id`
15368). Without Actions no pull request can merge, and every push to a pull request or to `main` still queues a run
that costs budget. Daniel decided (D63, "lokal prüfen und an GitHub melden"): run the battery locally and report its
result to GitHub. No self-hosted runner, because the repository is public (a fork's pull request could run code on the
Mac) and the job uses Linux containers. Whether Actions on this public repository are blocked right now is not
verified; the last ten runs were green, the latest on 2026-10-27 12:10.

## 2. Desired outcome
A maintainer runs one command on the Mac against a committed state of the repository. It runs the quality command
from `AGENTS.md § Commands`, and GitHub shows the result as a `quality` commit status on that exact commit, so that,
once the ruleset accepts the check from this source, a pull request merges on a locally produced green and the merge
commit on `main` carries the same status. The Actions workflow stays in the repository and can be started by hand or
switched back on, but costs nothing by default. The repository's own instructions (CLAUDE.md §4, the gate rules,
`AGENTS.md`, README, docs) describe this path and read correctly for a check that a local run reports, with every
earlier condition accounted for.

## 3. Acceptance criteria
_IDs are permanent once the story is committed: never renumber or reuse one; a new criterion takes the next number unused here and on the branch it merges into, and a collision stops for a human; a removed one stays, struck through and dated; a narrowed one keeps its ID with a dated note; cite as `<story path> AC-<n>`; full rules: dev-workflow:intake, "Acceptance-criterion IDs"._
- [ ] **AC-1** The battery runs on committed content only. A script under `scripts/` runs the quality command from `AGENTS.md § Commands` on one named commit (HEAD by default). With uncommitted changes present (tracked or staged modifications, or untracked files git does not ignore) it either refuses and posts nothing, or runs on a clean checkout of that commit in a temporary worktree it removes afterwards. It exits 0 only when the battery passed and the status was posted; a red battery exits with the battery's own status.
- [ ] **AC-2** After a run, the commit carries a commit status with context `quality`, state `success` when the battery exited 0 and `failure` otherwise, posted with `gh api repos/<owner>/<repo>/statuses/<sha>`, where owner and repo come from the `origin` remote's GitHub URL. Its description is short, names the result, and carries no secret, token, environment value or path under the home directory. `gh api repos/<owner>/<repo>/commits/<sha>/status` shows it.
- [ ] **AC-3** A failed post is never silent and never wrong: when `gh` is missing, not authenticated, or the post fails, the output says so and the exit status is non-zero and distinct from a red battery; the script never posts a status for a commit other than the one the battery ran on, and never posts `success` for a run it did not observe passing.
- [ ] **AC-4** The run refuses to start, and posts nothing, when the local `shellcheck` version differs from the version `ci.yml` pins (0.11.0 today). The docs state the remaining differences to the CI job: local binaries instead of the pinned image and the npm-installed `claude` CLI, and macOS tools instead of ubuntu-24.04's (`/bin/sh`, awk).
- [ ] **AC-5** The script is POSIX `sh`, passes `shellcheck --shell=sh`, and has a regression suite with `gh` and the battery stubbed, so the suite runs no real battery and reaches no network. The script's lint and its suite are part of the quality command in `AGENTS.md § Commands`.
- [ ] **AC-6** `ci.yml` keeps the `quality` job with its steps unchanged, but no push or pull request starts it; it runs only when started by hand (`workflow_dispatch`). The docs say how to start it by hand and how to switch the automatic triggers back on.
- [ ] **AC-7** The docs describe the local path: `AGENTS.md § Commands` has a row for the script that was run and observed; `AGENTS.md § Boundaries` states what the script writes; README § Contributing, `docs/ARCHITECTURE.md` (tree, components), `docs/TECH-STACK.md` and `docs/reference.md § Contributing` say what runs where now; `todos.md` has a row per follow-up, including the `/workflow-init` templates of other projects where relevant.
- [ ] **AC-8** CLAUDE.md §4 "Waiting on external work" and the gate rules read correctly for a locally reported check: a check this session posts itself is not an external run to wait on, and the rules' battery-evidence and red-check sentences hold for both a CI-produced and a locally posted required check. Each earlier condition of a changed passage is listed as kept, moved or dropped (AGENTS.md Don'ts). Both gate-rule copies stay byte-identical (check 4j) and within 10,000 bytes (check 4i).
- [ ] **AC-9** The plan lists the ruleset change as an action outside the repository for Daniel, with the exact `gh api` call that makes the required check `quality` accept a status from any source, and nothing in the repository changes the ruleset. The pull request body records whether GitHub Actions still started a run for this pull request, with the run id or its absence.
- [ ] **AC-10** If any path under `plugins/` changes (for example the gate-rules template that check 4j keeps identical), the plugin version is bumped with a CHANGELOG entry (invariant 12); otherwise the version stays. The quality battery is green on the final head, and after the squash-merge the merge commit on `main` carries a green `quality` status posted by the script.

## 4. Affected AGENTS.md invariants
- `## Architecture` › `### Boundaries (binding)` — "4a. `scripts/worktree-cleanup.{sh,test.sh}` (reads; in both modes creates and removes its lock directory under the git common dir; …)" — each script's writes are listed here; the new script needs an item (a commit status on GitHub, a temporary worktree).
- `## Architecture` › `### Boundaries (binding)` — "5. the hook ships in the plugin, the checkers and the reports do not"
- `## Key invariants` › `### Hook` — "4. **POSIX `sh`, and `jq` is optional.** No bash-isms; … CI invokes it with `sh`. Enforced mechanically by the lint command below (`shellcheck --shell=sh`), not by review alone."
- `## Key invariants` › `### Packaging` — "5. **Every version pinned exactly.** No floating `npx -y <pkg>`, `@latest`, or major-only action ref (`actions/checkout@v4`), anywhere — CI, `.mcp.json`, docs, and the inline templates" and "`scripts/check-invariants.sh` checks `uses:` refs, runners, `npx -y` and YAML `node-version:`"
- `## Key invariants` › `### Packaging` — "12. **A plugin change requires a version bump.**"
- `## Key invariants` › `### Prompts and scaffolding` — "11. **Prompt changes pass `docs/prompt-standards.md`** — all 12 checklist items, for any skill, command, agent definition, hook message, or scaffolded template."
- `## Don'ts` — "**Never document a command that wasn't run.** An unverified command in § Commands silently breaks `harden-finding`, `process-pr-review` and the quality gate"
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually compares.**"
- `## Don'ts` — "**Never replace a decision procedure without accounting for its old conditions.**"
- `## Don'ts` — "**Never rename or delete a doc section without grepping for references first.** … The same applies to adding files: the layout tree in `docs/ARCHITECTURE.md` is part of the surface that drifts."
- `## Don'ts` — "**Never splice data into shell source a prompt tells the agent to run without bounding it.**" — the quality command is shell text wherever the script takes it from.
- `## Commands` — "| quality (the whole battery — what CI runs) |", "**Prerequisites and pinning.** The quality command needs `shellcheck` (0.11.0 locally; CI runs the pinned image `koalaman/shellcheck:v0.11.0`), the `claude` CLI (CI pins `@anthropic-ai/claude-code@2.1.207`), and **`dash`**", "**`check-version-bump.sh main` has a precondition** … CI passes the PR's own base ref instead of `main`. It is in the quality row because that row claims to be what CI runs." and "CI runs the parts as separate steps for readable failures; the chained form above is the single command a human runs."
- `## Commands` — "**Check 4i caps the gate rules at 10,000 bytes**" and "**Check 4j** fails when those two texts are not byte-identical"

## 5. Open questions
- Are Actions on this public repository blocked right now? GitHub's billing docs, as recalled and not verified here, do not bill standard-runner minutes in public repositories, so the used-up budget may concern private repositories only. The first push of this pull request shows it (AC-9); the local path is built either way (orchestrator, 2026-10-28 09:19).
- Does the posted status carry a `target_url`? A local run has no public log to link.
- What may the status description name besides the result (the shellcheck version, the user, the host)? "No secrets" is settled; the rest is open.

## 6. Suggested size
story — one script with its suite, one trigger change in `ci.yml`, one pass over the instructions and docs; one spec → plan → PR.
