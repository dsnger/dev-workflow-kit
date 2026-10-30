CLI: codex-cli 0.162.1
HEAD: 8f0cd823339df40977b512bd188d5ff12bf71a24
MODEL: unknown
EXIT: 0
# Gate B risk evidence — k051rp97 pass 2 attempt 1

Reviewed a56ef4455c3c3381e5fdb05fd2e3c3afb25b82ca..8f0cd823339df40977b512bd188d5ff12bf71a24 using git diff, git show and head-qualified git grep. HEAD equals the requested head; source and index diffs were empty when checked. This is a risk-only pass. The design is docs/superpowers/specs/2026-10-24-kit-044-field-cases-design.md, which explicitly names no separate story. The call supplied no battery evidence and no whatWasImplemented summary.

Initial hypotheses, before reading historical review claims: failed inspection could authorize deletion; archive/recheck ordering could lose data; unusual paths or repository configuration could escape the intended deletion boundary. Read AGENTS.md, CLAUDE.md, the gate rules, prompt standards, the complete new script and suite, the design, and the changed prompts/docs/CI wiring. Checked prior committed Gate A/B dispositions and the local k051rp97 pass-1 artifacts as prior claims, not fresh test evidence. No earlier risk-slot finding or disposition was supplied.

Discovery: queried graph project metadata but did not establish an index matching this reviewed head. Used direct git searches for the shell scripts and non-code artifacts. Human refresh recorded at todos.md:1394: codebase-memory-mcp cli index_repository --repo-path <checkout root>. No index was refreshed.

## Tests and scope

Every executable test/probe ran through .agents/skills/gate-b-review/scripts/run-tests.sh with the full reviewed head and a 90–150 second bound. Probe fixture helpers were the head's scripts/worktree-cleanup.test.sh lines 1–81, evaluated only in the runner's disposable tracked-file checkout, with SCRIPT reset to its actual path. No source files in the reviewed repository were edited.

TESTS: sh scripts/worktree-cleanup.test.sh (first runner attempt, 120-second bound) | wrapper exit 1 | 37s; tail reported the temporary out file missing, so no assertion output was available. This is unusable runner evidence, not an observed suite assertion failure.
TESTS: sh scripts/worktree-cleanup.test.sh (private TMPDIR parent, 150-second bound) | command exit 0, wrapper exit 4 | 45s; all 56 assertions passed, then runner reported checkout changed. Finding 1 is required by the skill. Another probe and read-only tool activity overlapped this run; the orchestrator's live events.jsonl under .context/codex-reviews is included in the runner fingerprint and was observed to contain these tool events. No tracked source/index diff was observed. The runner supplies no per-path delta, so attribution to the suite is not established.
TESTS: sh -c symbolic-ref and configured-status probes using the existing suite helpers (private TMPDIR parent, 90-second bound) | exit 0 | 5s; both alias cases removed the target ref and git show-ref --verify exited 128; status.showUntrackedFiles=no produced dirty=no, ignored=unknown and kept the clean worktree.
TESTS: sh -c Git-failure and archive-staleness probes using the existing suite helpers (private TMPDIR parent, 90-second bound) | exit 0 | 6s; injected for-each-ref failure returned cleanup exit 0; injected final worktree-list failure still deleted m1 and returned 0; a .context note changed after copying was lost when removal succeeded, with only the original text archived.
TESTS: git diff --check a56ef4455c3c3381e5fdb05fd2e3c3afb25b82ca..8f0cd823339df40977b512bd188d5ff12bf71a24 | exit 0 | read-only whitespace check.
TESTS: sh -c session-comparison and ignored-filter failure probes using the existing suite helpers (private TMPDIR parent, 90-second bound) | exit 0 | 5s; awk exit 2 on session comparison yielded session=no despite a matching lsof cwd record and allowed removal; sed exit 2 on ignored-path extraction yielded ignored=0 and deleted ignored .worktrees/data without --discard-ignored. Both cleanup runs exited 0. These are siblings of finding 3's unchecked evidence-processing failures.
TESTS: full battery, dash variant, real gh/lsof integration, paid prompt eval and Codex access probe | not run; targeted risk review only, no external service execution needed.

The probe exit 0 means the observation script completed, not that its demonstrated unsafe behavior passed an assertion. The suite's 56 assertions passed but its wrapper exit 4 remains a separate blocker. The prior spec/quality pass findings for unchecked Git errors and configured status remain reproducible; their files supplied no dispositions to apply. The committed older k044gbr2 lsof-escaping repair is present: unsupported path bytes return unknown at both report and recheck.

## Risk analysis and callers

CALLERS: scripts/worktree-cleanup.sh — scripts/worktree-cleanup.test.sh:6,71,72,229; .github/workflows/ci.yml:101,103,136; AGENTS.md:39,248,250,255,270; README.md:72; docs/reference.md:716; docs/ARCHITECTURE.md:44,85; plugins/dev-workflow/CHANGELOG.md:43; todos.md:1068. These callers depend on conservative classification and deletion limited to reported rows.
CALLERS: usage — script:64-76; malformed options, relative roots, missing arguments and discard without removal stop before taking the lock.
CALLERS: snapshot — script:184,259; command absence/nonzero/no absolute cwd records become unknown, and both callers refuse worktree removal. The initial snapshot and fresh per-row snapshot were traced separately.
CALLERS: session_of — script:199,267; guarded path encoding, exact match and descendant match; an awk execution/read error is not distinguished from no match (reproduced; finding 3). Session recheck occurs before several Git inspections, so the documented adjacent-call limit is not a precise bound for that check either.
CALLERS: merged_of — script:200,228; initial worktree and standalone-branch rows share the ancestry/PR result. Missing default/gh, gh nonzero, empty output, tip mismatch and result cap were traced; explicit host/repository/base options avoid environment repository overrides.
CALLERS: dirty_of — script:198,269; both inherit configured status behavior and reject unknown; finding 5 covers the configuration failure.
CALLERS: ignored_of — script:198,271; report listing at 217 and discard predicates at 211,272 consume its count; .context is deliberately excluded, making it unavailable as an archive-freshness check. A failed sed filter becomes zero ignored paths (reproduced; finding 3).
CALLERS: inside_root — script:202; root parser at 64-68 and physical roots at 100-104 feed strict descendant matching; outside/equal-root/symlink-descendant cases covered by the suite. Tab/newline paths are explicitly unsupported.
CALLERS: checked_out — script:223,227; initial snapshot excludes exact branch names only; it does not resolve symbolic local refs.
CALLERS: age_of — script:216,230; log failure falls back to now, informational only, never permission to delete.
CALLERS: ahead_of — script:216,230; rev-list failure prints unknown, informational only, never permission to delete.
CALLERS: delete_branch — script:277,279; called after worktree removal and for standalone branch rows; checkout-inspection failure and symbolic-ref dereferencing are distinct causes (findings 2 and 3). Expected OID blocks ordinary moved-ref deletion, but does not bind deletion to the alias name.
CALLERS: remove/discard/extra_roots/repo — script:58-76,100-104,211,234,272; flags and paths feed both report and removal. No destructive action before the remove gate except lock/temp allocation.
CALLERS: wl/main/main_phys/common/lock/tmp — script:78-98,169-178,191-279; initial list failure/bare/missing main/common lookup abort; mkdir serializes cleanup runs. Traps handle ordinary exit/HUP/INT/TERM; SIGKILL can leave the documented stale lock, never silently stolen.
CALLERS: tab/roots/r/phys/p/h/b/d/l — script:64-68,100-104,170-219,245-279; serialization feeds candidates and rechecks. Main entry omitted, locked/detached/submodule cases kept; worktree remove remains unforced.
CALLERS: def/defname/c/url/slug/gh_ok — script:106-119,139-149,185-187,226; stale local default is explicitly trusted; standalone default exclusion compares names and is defeated by alias dereference.
CALLERS: now/ct/anc/out/m/s/snap/merged/dirty/ign/sess/verdict — classifier functions and rows at 181-231; only ancestor/pr, clean, permitted ignored count and no session can queue a worktree.
CALLERS: tmp/wts, tmp/co, tmp/brs, tmp/rm-wts, tmp/rm-brs — script:177,191,218,221-231,245,279; candidate lists feed actions. for-each-ref's status is unchecked; ordinary Git status output failures conservatively produce unknown.
CALLERS: base/dest/i/ok/msg/failed/ref — script:224-280; atomic archive mkdir, suffix collisions, parent creation, copy error, Git removal error and expected-OID error paths read. Failed copy keeps that worktree and later rows continue. Interruption during archive preserves the original and may leave a partial uniquely named archive.
CALLERS: s2/now_entry/why — script:258-274; same branch/tip, session, status and ignored rechecks can skip a row after archiving; they never compare current .context contents with the archive, as finding 4 demonstrates.
CALLERS: scripts/worktree-cleanup.test.sh / SCRIPT / CLEANUP_SH — CI:103,136 and AGENTS quality/lint rows invoke the suite; suite:6,8,42,71,72,229 routes every script invocation through the selected shell.
CALLERS: STUB_DIR/real_cp and gh/lsof/cp stubs — suite:17-45,104-123,145-160,185-218; supply deterministic external evidence and errors. Tests do not cover symbolic local refs, failed final branch inspection or post-copy .context writes.
CALLERS: fixture — suite:84-232; resets repositories and markers for each scenario.
CALLERS: add_wt — suite:84-219; creates actual branch commits and linked worktrees.
CALLERS: merge_ff — suite:84-219; advances main and origin/main to provide positive ancestry evidence.
CALLERS: tip — suite:105,113,117,197; PR matching and moved-ref assertions.
CALLERS: run — suite:87-232; captures cleanup output/status for every ordinary fixture.
CALLERS: run_bare — suite:121,155; verifies absence of optional gh/lsof.
CALLERS: has — suite:133,189,192,198,208,216,225,230; diagnostic assertions paired with state/exit checks.
CALLERS: rc_is — suite:91,93,135,198,216,225-230; positive, failure, lock and usage statuses.
CALLERS: row/line — suite:88-203; checks report state/verdict, and fails when no matching row exists.
CALLERS: wt_exists — suite:93,135,140,148,189,192,197,204,208,216; checks actual preservation/removal.
CALLERS: br_exists — suite:93,178-182,189,192,204,208,216; checks actual refs; its default protection tests cover ordinary refs only.
CALLERS: pass/fail/pass_n/fail_n — suite:9-11,78,88-238; aggregate assertions into a nonzero suite result.
CALLERS: work/before/after/n/p/line and stub output/rc/call files — suite:12-81,84-233; temporary fixtures, state comparisons and inter-call mutations feed the assertions; no production callers.
CALLERS: CLAUDE.md Plan bullet / workflow-init section 2.1 Plan bullet — CLAUDE.md:86, workflow-init.md:525, docs/coding-workflow.md:116-124 and CHANGELOG.md:32; all previous plan conditions retained, new timeout/cleanup/independent-failure obligations are prose requirements. No command or enforcement overclaim added there.
CALLERS: CLAUDE.md section 5 preflight / workflow-init section 2.1 preflight — CLAUDE.md:124-131, workflow-init.md:563-570, docs/reference.md:460-471, hooks/codex-gate.sh:453, CHANGELOG.md:36. Walked exit-0 OK, nonzero OK, usage/auth failure, absent command, empty reply and timeout: explicit success, missing-access stop, or undetermined continuation; hook retry remains bounded. No probe launched.
CALLERS: workflow-init section 2.21 skip-prefix question — workflow-init.md:1834-1848, README.md:43, docs/reference.md:168-172, CHANGELOG.md:40 and todos.md:1063. Mixed historical/current folders are not skipped wholesale; existing shell-value validation and refusal remain. No changed checker implementation.
CALLERS: plugin.json version — plugin.json:4, CHANGELOG.md:25, design:12,258, docs/reference.md:170,470, todos.md:1063; changed 0.43.0 to 0.44.0. Read full metadata-only manifest; no component registration change.
CALLERS: CHANGELOG 0.43.0 limit correction — CHANGELOG.md:60, scripts/check-doc-links.sh header and todos.md:2140; only wording narrows to a closed one-line code span and retains unmatched-backtick handling.
CALLERS: design sections 2-7 and new historical gate records — script, suite and docs cited above depend on the design. Head grep found no current code caller of the k044ga7q/k044gbr2 review filenames/nonces. Records describe prior dispositions, not fresh battery evidence.
CALLERS: README cleanup row, reference Reports addition, architecture inventory, AGENTS Boundary 4a/command rows, CI cleanup steps and todos adoption/backlog rows — callers/readers are manual operators, orchestrators and CI; these are the maintained statements falsified by wrong-target deletion, failed inspections and the understated archive window.

The risk checklist included empty snapshots and PR output, malformed paths/options, failed Git/tool/copy/mkdir calls, interrupted archive/removal, stale locks, two cleanup runs, branch movement, session appearance, archive writers, aliases, ignored-data configuration and documented unsupported inputs. This is not an exhaustive proof over arbitrary failures of every system executable. Existing prompt standards were read for failure-state and contradictory-rule risks; no new prompt-only risk finding was established.

## Reproducible observation scripts

Each block was supplied as the sh -c argument to the required runner, using a unique /private/tmp parent for TMPDIR. The scripts print observations; exit statuses described above are not safety assertions.

```sh
eval "$(sed -n '1,81p' scripts/worktree-cleanup.test.sh)"
SCRIPT="$PWD/scripts/worktree-cleanup.sh"
fixture
git -C "$work/r" symbolic-ref refs/heads/alias refs/heads/main
run --remove
printf '\nALIAS TO CHECKED-OUT MAIN\n'
cat "$work/out"
git -C "$work/r" show-ref --verify refs/heads/main
printf 'main-ref-exit=%s\n' "$?"
fixture
git -C "$work/r" symbolic-ref refs/heads/alias refs/remotes/origin/main
run --remove
printf '\nALIAS TO REMOTE-TRACKING REF\n'
cat "$work/out"
git -C "$work/r" show-ref --verify refs/remotes/origin/main
printf 'remote-ref-exit=%s\n' "$?"
fixture
add_wt w1 b1
merge_ff b1
mkdir -p "$work/r/.claude/worktrees/w1/.context"
echo note > "$work/r/.claude/worktrees/w1/.context/handover.md"
git -C "$work/r" config status.showUntrackedFiles no
run --remove
printf '\nCONFIGURED STATUS\n'
cat "$work/out"
exit 0
```

```sh
eval "$(sed -n '1,81p' scripts/worktree-cleanup.test.sh)"
SCRIPT="$PWD/scripts/worktree-cleanup.sh"
real_git=$(command -v git)
export REAL_GIT="$real_git"
cat > "$work/stub/git" <<'STUB'
#!/bin/sh
case "$*" in
  *"for-each-ref"*) [ -f "$STUB_DIR/fail-enumeration" ] && { echo "injected enumeration failure" >&2; exit 1; } ;;
  *"worktree list --porcelain"*)
    if [ -f "$STUB_DIR/fail-final-list" ]; then
      n=$(cat "$STUB_DIR/list-count" 2>/dev/null || echo 0)
      n=$((n + 1)); echo "$n" > "$STUB_DIR/list-count"
      [ "$n" -gt 1 ] && { echo "injected worktree-list failure" >&2; exit 1; }
    fi ;;
esac
exec "$REAL_GIT" "$@"
STUB
chmod +x "$work/stub/git"
fixture
git -C "$work/r" branch m1
touch "$work/fail-enumeration"
run --remove
printf '\nFAILED ENUMERATION\n'
cat "$work/out"
cat "$work/rc"
rm "$work/fail-enumeration"
fixture
git -C "$work/r" branch m1
touch "$work/fail-final-list"
run --remove
printf '\nFAILED FINAL CHECK\n'
cat "$work/out"
cat "$work/rc"
git -C "$work/r" show-ref --verify refs/heads/m1
printf 'm1-ref-exit=%s\n' "$?"
rm "$work/fail-final-list" "$work/stub/git"
fixture
add_wt w1 b1
merge_ff b1
mkdir -p "$work/r/.claude/worktrees/w1/.context"
echo original > "$work/r/.claude/worktrees/w1/.context/note"
printf 'echo late > "$STUB_DIR/r/.claude/worktrees/w1/.context/note"\n' > "$work/lsof.on2"
run --remove
printf '\nWRITE AFTER ARCHIVE BEFORE RECHECK\n'
cat "$work/out"
cat "$work/r/.context/archive-worktree-w1/note"
wt_exists w1
printf 'worktree-exists-exit=%s\n' "$?"
exit 0
```

## Additional evidence-processing failure probe

```sh
eval "$(sed -n '1,81p' scripts/worktree-cleanup.test.sh)"
SCRIPT="$PWD/scripts/worktree-cleanup.sh"
fixture
add_wt w1 b1
merge_ff b1
printf 'p1\nfcwd\nn%s\n' "$work/r/.claude/worktrees/w1" > "$work/lsof.out"
real_awk=$(command -v awk)
export REAL_AWK="$real_awk"
cat > "$work/stub/awk" <<'STUB'
#!/bin/sh
[ -n "${P:-}" ] && exit 2
exec "$REAL_AWK" "$@"
STUB
chmod +x "$work/stub/awk"
run --remove
printf '\nSESSION COMPARISON FAILURE\n'
cat "$work/out"
cat "$work/rc"
wt_exists w1
printf 'worktree-exists-exit=%s\n' "$?"
rm "$work/stub/awk"
fixture
add_wt w1 b1
merge_ff b1
mkdir -p "$work/r/.claude/worktrees/w1/.worktrees"
echo precious > "$work/r/.claude/worktrees/w1/.worktrees/data"
real_sed=$(command -v sed)
export REAL_SED="$real_sed"
cat > "$work/stub/sed" <<'STUB'
#!/bin/sh
case "$*" in *"s/^!! //p"*) exit 2 ;; esac
exec "$REAL_SED" "$@"
STUB
chmod +x "$work/stub/sed"
run --remove
printf '\nIGNORED FILTER FAILURE\n'
cat "$work/out"
cat "$work/rc"
wt_exists w1
printf 'worktree-exists-exit=%s\n' "$?"
exit 0
```
