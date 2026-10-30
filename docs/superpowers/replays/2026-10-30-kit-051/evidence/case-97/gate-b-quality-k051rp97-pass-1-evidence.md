# Gate B quality evidence — k051rp97 pass 1

Reviewed a56ef4455c3c3381e5fdb05fd2e3c3afb25b82ca..8f0cd823339df40977b512bd188d5ff12bf71a24. HEAD equals the requested head. Read the cited design (including its embedded plan), AGENTS.md, the gate rules, prompt standards, implementation, tests, changed prompts and documentation. No separate story is cited; the design explicitly says there is none. This is the quality branch, not a complete AC mapping or a full-battery attestation.

Initial hypotheses: cleanup might turn failed inspection into permission to delete; removal might outrun its path/session/branch checks; new prompt rules might drop existing conditions or disagree with their documentation. The implementation claim was checked against these areas. The configured-status issue below is a conservative refusal, not demonstrated data loss.

Discovery used head-tree git grep and git show. No graph index could be established as matching this head within the repository-only read restriction. The recorded human refresh command is `codebase-memory-mcp cli index_repository --repo-path <checkout root>` (todos.md, Tooling revalidation). No indexing or external service calls were made.

## Tests and reproduction

All executable tests below ran through `.agents/skills/gate-b-review/scripts/run-tests.sh` with the full head SHA, a disposable tracked-file checkout, and 90- or 120-second limits. Later runs used a private temporary parent to avoid the shared temporary-directory problem seen on the first attempt.

TESTS: sh scripts/worktree-cleanup.test.sh (first wrapper attempt) | exit 1 | 49s; cleanup emitted Directory not empty errors and tail reported the wrapper output file missing; no suite results were available. This is unusable harness evidence, not an observed assertion failure in the reviewed suite. Retried in an isolated temporary parent.
TESTS: sh scripts/worktree-cleanup.test.sh (isolated temporary parent) | exit 0 | 71s; all 56 assertions passed; wrapper reported no checkout change.
TESTS: sh scripts/check-invariants.sh | exit 0 | 5s; invariant checks: ok; wrapper reported no checkout change.
TESTS: sh -c configured-status probes using scripts/worktree-cleanup.test.sh lines 1–81 as fixture helpers | exit 0 | 6s; with status.showUntrackedFiles=no, both an untracked file and ignored data survived --remove; rows showed dirty=no and ignored=unknown.
TESTS: sh -c clean-worktree configured-status probe using the same fixture helpers | exit 0 | 3s; clean merged worktree showed ignored=unknown; direct ignored-status call exited 128 with Unsupported combination of ignored and untracked-files arguments; adding --untracked-files=all exited 0.
TESTS: full battery, dash variant, shellcheck, paid prompt eval and real gh/lsof integration | not run; review used the targeted suite and invariant checker plus source inspection. No battery evidence for this head was supplied.

The two ad hoc probes reused the existing suite's actual Git fixtures and stubbed only its existing gh/lsof/cp boundary tools. Inside the disposable copy they evaluated the helper prefix, reset SCRIPT to `$PWD/scripts/worktree-cleanup.sh`, called `fixture; add_wt w1 b1; merge_ff b1`, then set `git -C "$work/r" config status.showUntrackedFiles no`. The first probe created untracked.txt and, in a separate fresh fixture, ignored .worktrees/data, then called `run --remove` and checked preservation. The second left the worktree clean, called `run`, and compared `git status --porcelain --ignored=matching` with the same command plus `--untracked-files=all`. These probes printed observations rather than claiming an assertion-based pass for the defect.

`git diff --check` on the requested range exited 0. A process-list diagnostic was denied by the sandbox; it provided no evidence and was not needed for the review.

## Callers and dependents

CALLERS: scripts/worktree-cleanup.sh — scripts/worktree-cleanup.test.sh:6,71,72,229 invokes it; .github/workflows/ci.yml:101,103,136 wires lint/tests; AGENTS.md:39,248,250,255,270 records its boundary and commands; README.md:72, docs/reference.md:716, docs/ARCHITECTURE.md:44,85 and todos.md:1068 describe invocation and scope. Read these against the implementation.
CALLERS: usage — scripts/worktree-cleanup.sh:64,65,66,70,71,75; malformed arguments exit 2 before repository mutation; suite covers unknown flags, discard without removal and relative roots.
CALLERS: snapshot — scripts/worktree-cleanup.sh:184,259; initial and per-worktree fresh snapshots; missing, failing and empty lsof output become unknown; suite covers all three and a newly appearing session.
CALLERS: session_of — scripts/worktree-cleanup.sh:199,267; raw physical paths are checked against lsof output with a conservative guard for escaped names; suite covers descendants, sibling prefixes, non-ASCII and backslash paths.
CALLERS: merged_of — scripts/worktree-cleanup.sh:200,228; shared classifier for worktree and branch rows; ancestor, matching PR head, failed gh, nonmatching head and result-cap paths read and tested.
CALLERS: dirty_of — scripts/worktree-cleanup.sh:198,269; report and removal recheck both inherit status configuration; finding 1 covers both callers.
CALLERS: ignored_of — scripts/worktree-cleanup.sh:198,271; report and recheck both reject unknown; finding 1 covers both callers. Copy-before-recheck preserves the archive on a later skip.
CALLERS: inside_root — scripts/worktree-cleanup.sh:202; canonical physical root plus slash comparison; suite covers outside roots, explicit parent, equality and symlink escape.
CALLERS: checked_out — scripts/worktree-cleanup.sh:223; initial worktree list excludes checked-out branches from standalone rows; delete_branch repeats the checkout check before deletion.
CALLERS: age_of — scripts/worktree-cleanup.sh:216,230; informational only, not a removal condition.
CALLERS: ahead_of — scripts/worktree-cleanup.sh:216,230; informational only, not a removal condition.
CALLERS: delete_branch — scripts/worktree-cleanup.sh:277,279; worktree and standalone-branch paths use an expected-tip update-ref delete; suite verifies moved-tip failure and checked-out/default branch exclusions.
CALLERS: remove/discard/extra_roots/repo options — scripts/worktree-cleanup.sh:58–76 initializes/parses; roots at 100–106, eligibility at 202–212, removal at 234 and recheck at 272 consume them; usage text and reference usage match.
CALLERS: wl/main/main_phys/common/lock — scripts/worktree-cleanup.sh:78–98 establishes repository identity and the run lock; row parser at 171, checked_out at 178 and mutations at 239–279 consume this state. Bare repositories are rejected and the main entry is excluded from worktree rows.
CALLERS: def/defname/url/slug/gh_ok — scripts/worktree-cleanup.sh:108–119 resolves the default ref and explicit GitHub repository; merged_of, report header and standalone default-branch exclusion consume it. No fetch or remote deletion is performed.
CALLERS: roots/phys — scripts/worktree-cleanup.sh:100–106,194,202; physical descendant checks match the documented boundary and its tested symlink case.
CALLERS: tmp/rm-wts/rm-brs — scripts/worktree-cleanup.sh:94–98,192,218,221,231,245,278–279; removal is fed only by removable report rows; trap removes temporary state and the lock.
CALLERS: base/dest/i/ok archive state — scripts/worktree-cleanup.sh:247–256; exclusive mkdir reservation, bounded suffix retries and cp errors keep the worktree; archive collision and failed-copy/next-row continuation cases exercise this path.
CALLERS: s2/now_entry/why/failed — scripts/worktree-cleanup.sh:236–280; recheck skips changed rows, errors accumulate exit 1, and branch deletion follows only successful worktree removal. Remaining writer/session windows are explicitly documented as requiring quiescence.
CALLERS: CLEANUP_SH — scripts/worktree-cleanup.test.sh:8,42,71,72,229; every script launch and the restricted PATH use the selected interpreter.
CALLERS: STUB_DIR and gh/lsof/cp stubs — scripts/worktree-cleanup.test.sh:18–45,104–123,145–160,185–218; deterministic external failures and inter-call changes are injected while Git remains real.
CALLERS: fixture — scripts/worktree-cleanup.test.sh:84–232; each scenario resets repositories and stub state.
CALLERS: add_wt — scripts/worktree-cleanup.test.sh:84–219; builds real branch/worktree commits used by positive and negative scenarios.
CALLERS: merge_ff — scripts/worktree-cleanup.test.sh:84–219; advances the local default ref for ancestry fixtures.
CALLERS: tip — scripts/worktree-cleanup.test.sh:105,112,116,197; supplies PR head identities and verifies retained moved refs.
CALLERS: run — scripts/worktree-cleanup.test.sh:87–232; captures output and exit status for assertions.
CALLERS: run_bare — scripts/worktree-cleanup.test.sh:121,155; tests missing optional executables using the restricted PATH.
CALLERS: has — scripts/worktree-cleanup.test.sh:133,189,192,198,208,216,225,230; verifies diagnostic text alongside state or exit assertions.
CALLERS: rc_is — scripts/worktree-cleanup.test.sh:91,93,135,198,216,225–230; verifies action failures and usage/lock outcomes.
CALLERS: row — scripts/worktree-cleanup.test.sh:88–203; inspects report classifiers and keep/removable verdicts.
CALLERS: wt_exists — scripts/worktree-cleanup.test.sh:93,135,140,148,189,192,197,204,208,216; checks preservation/removal independently of report text.
CALLERS: br_exists — scripts/worktree-cleanup.test.sh:93,178–182,189,192,204,208,216; checks branch preservation/removal independently of report text.
CALLERS: pass/fail/pass_n/fail_n — scripts/worktree-cleanup.test.sh:9–11,78,88–238; assertions feed the final nonzero status on failure; cp failure is actually injected rather than skipped for root.
CALLERS: CLAUDE.md Plan bullet — CLAUDE.md:86 and workflow-init.md:525 mirror the added timeout/helper-cleanup/independent-stage requirements; docs/coding-workflow.md:116 explains them and CHANGELOG.md:32 describes adoption. Previous parenthetical conditions remain present.
CALLERS: CLAUDE.md section 5 preflight — CLAUDE.md:124 and workflow-init.md:563 give matching success, missing-access and undetermined routes; docs/reference.md:460–471 and hooks/codex-gate.sh:453 retain the empty-error probe/retry recovery. Walked OK/exit-0, nonzero, usage limit, authentication, missing binary, empty reply and timeout outcomes in prose; did not launch Codex.
CALLERS: workflow-init.md section 2.21 skip-prefix question — workflow-init.md:1834–1848, README.md:43, docs/reference.md:168 and todos.md:1063; historical-only restriction is consistent and existing character validation, trailing slash, relative-path restriction and rejection behavior remain intact. The embedded checker is unchanged; check 4l passed.
CALLERS: plugin.json version — plugins/dev-workflow/.claude-plugin/plugin.json:4 changes 0.43.0 to 0.44.0; CHANGELOG.md:25 and todos.md:1063 describe that release/adoption. Read the full manifest: metadata only, consistent with AGENTS.md, MANIFEST.md and docs/ARCHITECTURE.md convention-loading statements.
CALLERS: CHANGELOG.md 0.43.0 backtick limitation — CHANGELOG.md:60, scripts/check-doc-links.sh:25–27 and todos.md:2140; the wording correction matches the existing checker header and closes the named documentation todo.
CALLERS: design sections 2–7 and historical gate records — implementation, tests and documentation listed above are their dependents; earlier review records were treated as historical claims, not fresh battery evidence.

## Prompt standards and assessment

Read the changed prompt text against all twelve items: (1) retained model declaration and the existing explained model-agnostic CLAUDE template exception; (2) explicit probe success and long-run deliverables; (3) access stop versus undetermined continuation; (4) existing structured template/output context and concrete skip-prefix examples; (5) section structure preserved; (6) reasons provided; (7) repo/template/recovery rules compared; (8) short additions, with downstream self-contained duplication required by invariant 8; (9) historical-folder exclusion has an explicit reason; (10) diagnostic outcomes distinguished; (11) rules do not introduce a claim of mechanical enforcement; (12) no new excessive emphasis. No network was used to revalidate external prompting or API documentation; the design's recorded source evidence was read as supplied evidence.

Strengths: destructive actions are opt-in; real Git fixtures verify preservation and deletion; archive errors stop the affected row while allowing the next one to proceed; branch deletion checks the old OID atomically; optional-tool uncertainty and unsupported session-path encodings keep worktrees. The version bump, inline-template boundary and documentation updates are coherent, and invariant checks pass.

Issues: no BLOCKER or MAJOR found. One MINOR: normalize untracked-file settings in both status inspections and add configuration regression cases. Suppressed diagnostic output currently makes this ordinary configuration problem look like unexplained missing evidence.

Assessment: ready from this quality review with a minor fix recommended. This is not a claim that required CI or the complete quality battery passed; those remain unverified for this head in the supplied evidence.
