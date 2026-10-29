# Kit 0.50: proportional gates — Design

**Story:** `docs/superpowers/stories/2026-10-29-kit-050-proportional-gates-story.md` (risk high, security
standard, battery+check+verification, checkpoints none). **Date:** 2026-10-29. **Plugin version:** 0.50.0.
**Gate A:** runs — risk high; security standard; evidence battery+check+verification (`strict`: risk `high`).

## 1. Intent
Two deterministic classifiers decide how much gate a change gets: the **hook** classifies a commit for Gate B
(release-only joins docs-only as a skip), and **`scripts/local-ci.sh`** classifies a head for the battery
(inherit, light or full). Nothing else changes: the docs-only Gate B list (D86), the required check name, CI.

## 2. The release-only check (AC-1, AC-2)
One definition, implemented as one awk program over a configuration-independent patch:
`git -c core.quotePath=true -c diff.noprefix=false diff --no-color --no-ext-diff --no-textconv --no-renames
--no-relative --ignore-submodules=none --submodule=short --src-prefix=a/ --dst-prefix=b/ -U0`. The hook and
`local-ci.sh` each carry a copy (no shared runtime location: the hook lives in a version-keyed cache,
Boundary 7), and both suites run the same cases (§6). The diff is release-only when it names at least one file
and every file is accepted by one rule:
- **D (docs)**: the path passes the caller's docs test (§3 for the hook, §4 for `local-ci.sh`); the docs test
  runs first and is unchanged for the hook (D86).
- **C (changelog)**: basename starts with `CHANGELOG`; any content change.
- **R (manifest)**: basename `package.json` or `composer.json` at any depth. Compared structurally with `jq`,
  not by lines: the old blob (`git show <base>:<path>`) and the new one both parse, are equal after
  `del(.version)`, and their top-level `.version` values are both tokens and differ. No `jq`, a parse failure,
  or a file added or deleted → not release-only (invariant 4: the fallback is the conservative answer).
- **V (version site)**: basename `VERSION` at any depth, or a path on the **Version sites** line of `AGENTS.md`
  read from the diff's base commit (a commit cannot widen its own definition). Its patch is exactly one hunk
  replacing exactly one line with one line (`-` then `+`), each a **version form**, equal once the token is
  replaced. The set is short and fixed, surrounding blanks allowed: a bare token, or `"version": "<token>"`
  with an optional trailing comma. Anything else (TOML, `__version__`, build metadata) is not recognised and so
  not release-only: full gates (D10).

Token: `[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?`. Across all R and V files the old tokens are one string and the
new tokens another, and they differ. So a dependency or tool pin never matches (R: it is not top-level
`.version`; V: its line has other text), a field added or deleted fails, and a second version line in a site
fails (a second hunk). A site is a file the project vouches for: it lists only files whose version-form lines
are release versions.

**Instruction paths are never release-only (D86).** A path matching the hook's `is_prompt_path` regex
(`CLAUDE.md`, `AGENTS.md`, `.claude/`, `plugins/`, `skills/`, `commands/` at any depth) or under `agents/` or
`hooks/` at any depth fails C, R and V, listed site or not. So this repository's own releases
(`plugins/dev-workflow/…`, `.claude/dev-workflow-version`) always take Gate B; that is the intended price.

Structural entries fail the whole diff: `Binary files` (except, for `local-ci.sh`'s rule D, an image under
`docs/`; the path comes from the `diff --git a/P b/P` line, unambiguous with `--no-renames`), `old mode`/`new
mode`, a quoted path (`"a/…"`), `Subproject commit` lines (a gitlink). With `--no-renames` a move is a deletion
plus an addition, each judged by its path, so a moved changelog or doc is accepted and a moved site or manifest
fails. Empty or failed diff → not release-only (invariant 2).

**Version sites line** (new, optional, `AGENTS.md`): `**Version sites:**` followed by backticked repository
paths, one line. This repository gets none: its version sites are all instruction paths. No line → only
`VERSION` and the R files count.

## 3. Hook: release-only note (AC-1, AC-3)
In `PreToolUse` for a non-WIP `git commit`, the existing docs-only branch stays first and unchanged. A new
branch follows it under the same `names_no_paths` guard, refused when the command has `--amend` (an amend's
payload is relative to the old commit's parent, which the staged diff does not show) or `-a`/`--all` (kept
simple: the staged diff alone is classified). When the staged diff (`--cached` against `HEAD`) is release-only
with the hook's docs-only list as rule D, print
`Release-only commit — release-only: version + changelog, no review. Gate B (mcp__codex__review) may be skipped for it per $policy; record that line in the PR body. Any other change in the commit takes Gate B.`
with the status line `ℹ Codex Gate B N/A (release-only commit)`. Otherwise fall through to today's
fingerprint path. The hook still exits 0; a release commit not recognised gets today's reminder (invariant 2).
The Version sites line is read with `git show HEAD:AGENTS.md`; no `HEAD` (first commit) → not release-only.

## 4. local-ci.sh lanes (AC-4, AC-5, AC-6)
The lane contract is normative in `local-ci.sh`'s header, which ships to projects as `### 2.22`; docs point to
it. New usage: `sh scripts/local-ci.sh [--from <green>] [<commit>]`. After the existing preconditions:
1. **Source.** `--from` is resolved once to a full SHA (`git rev-parse --verify -q <arg>^{commit}`, failure →
   exit 64); that SHA, never the argument, is used for the read, every comparison and the description. It must carry a commit status with context `quality` whose latest state is
   `success`, read once from `gh api repos/<slug>/commits/<sha>/status?per_page=100` (Context7: GitHub REST
   "Get the combined status for a specific reference", API version 2026-03-10 — `statuses` holds the latest
   status per context; paginated, default 30). A failed read, `total_count` above 100, no `quality` entry or
   another state → exit 64, nothing posted. A green Actions check run is not a commit status and is not read.
2. **Inherit, same tree.** `--from` and `git rev-parse <from>^{tree}` equals `<sha>^{tree}` (a squash-merge of
   that head): post `success`, `inherited green from <from12>: same tree`; no command runs.
3. **Inherit, records only.** `--from` and `git diff --name-only --no-renames <from> <sha>` (same flags as §2)
   succeeds, is non-empty, and every path is under `.context/` or is `todos.md`: post `success`,
   `inherited green from <from12>: records only`; no command runs (AC-5). A failed diff → exit 64.
4. **Light.** The lane base is `--from` when given, else `git merge-base <sha> origin/main` (none → full). The
   diff base..sha is release-only (§2) with docs rule D = every path is `*.md` or `*.txt`, or an image
   (`png|jpg|jpeg|gif|svg|webp`) under `docs/`, and none is a prompt path (the hook's `is_prompt_path` regex plus
   `agents/` and `hooks/` at any depth),
   and the commit's `AGENTS.md` has exactly one `| quality-light ` row with one command in backticks: run it
   instead of the quality row; description `light lane green|red: docs/release only, local run, …`.
5. **Full.** Otherwise the quality row, as today.
The status context stays `quality` in every lane; `ci.yml` is untouched (disabled; no `paths-ignore` added). A
project narrows the light lane only by its light row (no row: step 4 is full); the docs list is the kit's.

**This repository's light row:** `sh scripts/check-invariants.sh && sh scripts/check-version-bump.sh
origin/main && sh scripts/check-doc-links.sh source-files/ docs/history/ docs/superpowers/replays/ && claude
plugin validate . --strict` (guards, version record, links, manifest; no suites). No secrets scanner exists
in this battery; none is added.

## 5. Rules, consumers and docs (AC-7, AC-10)
- `.claude/review-gates.md` + byte-identical `### 2.1a`: "only docs-only and release-only commits may skip it",
  and one sentence: release-only is a commit the hook marks with the release-only note; record its line in the
  PR body. Check 4i's cap holds by trimming words elsewhere in the file; no rule dropped.
- **Every green-evidence consumer** accepts a `local-ci.sh` lane result where the full quality command was
  owed, and keeps its retry, failure, source and final-head requirements: CLAUDE.md §4 "One source of green"
  and "Waiting on external work" (and their identical text in the 2.1 template), `process-pr-review.md` Step 3
  item 6 (verification and its report shape), `docs/reference.md` local path. Each names the script's header as
  the contract. The sentence: "`scripts/local-ci.sh`'s light or inherited lane (its header) is that green for
  the commit it posts on."
- `docs/reference.md`: the one line "Gate effort scales with the change: a 1-line docs or release PR costs
  almost nothing." under The review gates; a Release-only paragraph beside the docs-only definition; a Lanes
  paragraph in the local path; the merge-commit advice becomes `--from <final head>`.
- `local-ci.sh` → `### 2.22` byte-identical (check 4m); `/workflow-init` Step 3 offers the Version sites line
  and the `quality-light` row (both optional). README, CHANGELOG 0.50.0, version record (check 4n).

## 6. Tests (AC-8)
Both suites, same fixtures: release-only (VERSION + package.json version + CHANGELOG) → release; version plus one
dependency in package.json → not; docs only → hook docs-only note / local-ci light; docs plus one code file →
not / full; base-only update (`--from` an old green head after a rebase that changed base code) → full. Plus:
nested version added beside the release → not (second hunk); a nested-only `"version"` replacement in
package.json or composer.json beside a VERSION bump with the same numbers, all keys at column zero → not (jq);
no `jq` on PATH → not; site line with a tool pin of the
same numbers → not; a TOML `version = "…"` site line → not (unrecognised form); changelog under
`commands/`, `agents/`, `.claude/` or `plugins/` → not; a listed site under an instruction path → not; `agents/x.md` → not light; a binary PNG under `docs/` → light;
a moved `--from` ref → the resolved SHA is used; a failed records diff → exit 64; gitlink change → not; `diff.noprefix`, a textconv driver and
`diff.ignoreSubmodules=all` configured → same results; `--amend` → no release note; same tree with `--from`
→ inherit, no run; differing gitlink with `diff.ignoreSubmodules=all` → not inherited; records-only → carry
named, no run; `--from` not green / read fails → exit 64; no light row → full; light row red → failure posted.

## 7. Measurement (AC-9)
Fixtures: from this branch's final head `H` (green `quality`), two commits: **docs** (one line changed in a
`docs/*.md` file) and **release** (a root `VERSION` file and a root `package.json` `version` bumped plus a root
CHANGELOG line). **Before**, under 0.49's rules, both take one full battery and the Gate B calls the rules owe;
the battery numbers are today's real measurements of that path (2350 s on `4e2d536`, 2450 s on `3563233`, same
suite), labelled as such, with the rule-owed Gate B calls (docs: 0, the docs-only skip; release: one strict pass
= 2 calls). **After** = `sh scripts/local-ci.sh --from H <fixture>` with `gh` stubbed for the post (labelled),
timed, its lane asserted from the printed line, and the Gate B calls counted from the hook note on each fixture
commit and this session's tool calls. The PR states tree ids, durations, the stub and the counts; the fixtures
are not pushed. (Orchestrator decision 2026-10-29 21:47: no re-measured before-runs; cost is the goal.)

## 8. Decisions
- D1: the hook and local-ci each carry the awk program; test parity, not a byte check, keeps them aligned.
- D2: CHANGELOG changes are path-level (any line), as Daniel's order states; a check of "that version's entry" is
  not deterministic across formats.
- D3: `docs/**` is read as text and images under `docs/`; a script under `docs/` takes the full lane.
- D4: a records-only head carries the verdict with no run (AC-5). Accepted risk: a broken link in a moved
  `.context/*.md` record is caught by the next full run, not this one.
- D5: narrowing is per project by the light row only; a finer path filter is not built.
- D8: the hook's release branch refuses `--amend` and `-a` instead of reconstructing their payload: a
  release commit is a plain `git commit`, and refusing costs a reminder (invariant 2).
- D9: `--from` reads only commit statuses; a green from an Actions check run is not carried (CI is disabled).
- D10: two version forms only (orchestrator steer, 2026-10-29 21:43): an unrecognised form is conservatively
  not release-only; AC-1's "site lines" are read as lines in a recognised form.
- D11: A+B applied after pass 3 without a further Gate A pass, orchestrator decision, conservative direction;
  the checker is reviewed at Gate B (dev-workflow-kit-26, 2026-10-29 21:47). A = instruction paths are never
  release-only; B = manifests compared with `jq` after deleting top-level `.version`, no `jq` → not. Gate B
  looks at B's jq comparison specifically.
- D6: ci.yml is not changed: it is disabled, and a lane split there needs the human's workflow change.
- D7: one PR: both classifiers share §2, the splitting check found no independently reviewable half.

## 9. Sources and impact boundary
Read: Daniel's order and items 7–8 (main checkout `.context/sparring/`), 0.49 handover, `.claude/review-gates.md`,
hook docs-only path (`codex-gate.sh` 1463–1525, 1750–1770), `scripts/local-ci.sh`, `docs/reference.md` gates and
local path, `process-pr-review.md` base-update rule (unchanged). No third-party library API; GitHub REST
`GET /repos/{owner}/{repo}/commits/{ref}/status` (API version 2026-03-10, the one local-ci already sends):
Context7 `/websites/github_en_rest` looked up 2026-10-29 — latest status per context, `per_page` max 100,
default 30. Out: ci.yml, process-pr-review's patch-id carry-over, sfx-factory.
