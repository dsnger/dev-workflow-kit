Review: spec branch, strict mode, cycle k051rp97, pass 1.
Range: a56ef4455c3c3381e5fdb05fd2e3c3afb25b82ca..8f0cd823339df40977b512bd188d5ff12bf71a24. HEAD equals the requested head. Read the full range diff, cited design/plan, head AGENTS.md, CLAUDE.md, review-gates.md and prompt-standards.md. No story or AC-numbered criteria exist; the design explicitly says no story, so the mapping below uses its sections and concrete requirements.
Hypotheses checked: cleanup might delete on incomplete inspection or stale state; template wording might lose existing long-run conditions or misclassify preflight replies; narrower skips might alter the checker or omit dependent documentation; packaging and battery wiring might miss the new deliverable.
Graph: index currency for this SHA could not be established. Used head-tree direct searches per the review skill and CLAUDE.md's currency rule; no completeness claim from a graph. Human refresh recorded in todos.md:1394: codebase-memory-mcp cli index_repository --repo-path <checkout root>. No indexing or external-source access performed.
TESTS: sh scripts/worktree-cleanup.test.sh | exit 1 | 53s | invalidated harness run: concurrent run-tests.sh stale_scan removed its temporary copy; missing out file, no assertion output available. This is runner interference, not evidence of a product test failure.
TESTS: sh scripts/check-invariants.sh | exit 0 | 5s | invariant checks: ok
TESTS: sh scripts/worktree-cleanup.test.sh | exit 0 | 64s | isolated rerun, all 56 assertions passed
All test commands above ran through sh .agents/skills/gate-b-review/scripts/run-tests.sh "$PWD" 8f0cd823339df40977b512bd188d5ff12bf71a24 120 -- <command>. No runner returned exit 4. Did not execute the full battery, real gh, Codex probe or paid prompt eval. Dash coverage was inspected through CLEANUP_SH and all launch sites, not executed here. git diff --check for the requested range exited 0.

Requirement mapping (source lines refer to the reviewed head):
- §2 usage, bare rejection, main/common discovery, lock lifecycle: script 53–99; tests 224–233 cover held lock, invalid flags/root, bare and release. Lock uses mkdir and exit/signal traps. No remote mutation command exists.
- §2 roots and physical containment: script 64–67, 101–107, 162–167, 194–203; tests 163–174 cover outside roots, explicit parent root, equal root and symlink escape. Missing-path keep is implemented at 194–196; dedicated assertion: none.
- §2 default ref and merged predicate: script 109–119, 137–150; tests 84–95 and 104–123 cover ancestry, exact PR tip, host/repo/base overrides, mismatch, result cap and failing/missing gh. Default-ref fallback branches are inspected; dedicated fallback assertions: none.
- §2 dirty/ignored eligibility: script 152–160, 198–217; tests 126–142, 201–208 cover dirty files, ignored entries, explicit discard, submodules, locked/detached and status failures. Ahead and age are implemented at 181–182 and printed at 215–216/230; direct value assertions: none.
- §2 sessions: script 122–135, 184, 199, 259–267; tests 145–160 and 185–189 cover visible cwd, prefix sibling, missing/failing/empty lsof, escaping conservatism and late sessions. Non-ASCII/backslash refusal is a documented conservative limitation from the earlier repair, not an unsafe expansion.
- §2 archive then recheck then unforced removal: script 245–277; tests 84–101, 185–221 cover copied content, suffix, absent main .context, late session/tip/status changes, and deterministic cp failure plus continuation. No automatic test for archive mkdir failure; error path inspected.
- §2 branch-only rows, default-name exclusion, expected-OID deletion: script 221–243, 279; tests 177–198 cover merged/unmerged/default branches and moved-tip refusal. Missing failure checks at 222 and 239 are finding 1; no tests inject those failures. update-ref compares the reported OID, but does not itself establish checkout absence.
- §2 quiescence, remaining windows, limitations and caller: script 15–46, docs/reference.md:727–739 and README.md:72. Both remaining windows and caller obligations are present. The script does not claim to eliminate them.
- §3 long runs: CLAUDE.md:86 and workflow-init.md:525 retain all prior parenthesis conditions and add stage timeout, helper cleanup on any exit, and recording all independent failures. docs/coding-workflow.md:119–124 supplies the three field cases. Manual scenario review: hung stage gets a bound; orphan helpers get exit cleanup; independent measurement failures are collected in one run. Automated semantic test: none.
- §4 preflight: CLAUDE.md:124–131 and workflow-init.md:563–570 match each other. Exit 0 plus OK => access; OK plus nonzero => other/undetermined; usage/auth reply => missing-access stop with quote/home; absent command, empty output and timeout => undetermined and continue; later empty gate failure follows existing hook recovery. Default home and two-minute bound are explicit. docs/reference.md:470 points to the rule. Automated semantic test: none. Gate rules and hook unchanged.
- §5 skip prefixes: workflow-init.md:1834–1846 retains prefix validation and rationale, narrows to exclusively historical folders, and redirects mixed folders to dated subfolders or none. README.md:43 and docs/reference.md:168–172 agree. scripts/check-doc-links.sh is unchanged and invariant 4l passed.
- §6 docs and §7 packaging/battery: README, reference, architecture, AGENTS, coding-workflow, changelog and todos all changed as specified. CI has both shellcheck calls and the suite; AGENTS quality/lint rows include them. Manifest is metadata-only and version changed 0.43.0 -> 0.44.0. No plugin cleanup-script copy or new dependency installed. Stale CI inventory is finding 2.
- Additional CHANGELOG 0.43.0 wording repair is bounded and tied to the existing todos row whose trigger was the next CHANGELOG edit; not an unexplained feature addition.
- Prompt checklist: (1) workflow-init target remains named; current external prompting-page verification not repeated under no-network restriction; (2) success outcomes explicit; (3) stop/continue outcomes explicit; (4) exact probe and concrete prefix examples; (5) existing structured template retained; (6) new rules have reasons; (7) checked against AGENTS and surrounding CLAUDE rules, no new contradiction found; (8) inline duplication required for scaffold independence; (9) positive actions with the mixed-folder prohibition explained; (10) access versus undetermined diagnostic states separated; (11) no new mechanical gate enforcement claim, unchanged checkers verified; (12) ordinary emphasis. This review does not assert the implementer's PR-body checklist or paid eval ran: neither evidence was provided.

CALLERS: scripts/worktree-cleanup.sh — scripts/worktree-cleanup.test.sh:6,71,72,229; README.md:72; docs/reference.md:716; docs/ARCHITECTURE.md:44,85; AGENTS.md:39,248,250,255,270; todos.md:1068; .github/workflows/ci.yml:101.
CALLERS: scripts/worktree-cleanup.test.sh — .github/workflows/ci.yml:103,136; AGENTS.md quality/lint rows; scripts/worktree-cleanup.sh:48; docs/ARCHITECTURE.md:45,85.
CALLERS: usage — script argument parser at 64–76; tests 226–228.
CALLERS: snapshot — script 184 and 259; session tests 145–160,185–189 exercise both snapshots.
CALLERS: session_of — script 199 and 267; eligibility checks at 211 and 267.
CALLERS: merged_of — script 200 and 228; both worktree and branch verdicts consume ancestor/pr/no/unknown.
CALLERS: dirty_of — script 198 and 269; tests 126–127,201–208.
CALLERS: ignored_of — script 198 and 271; report listing 217 and discard predicates 210/272; tests 128–135,201–208.
CALLERS: inside_root — script 202; roots tests 163–174.
CALLERS: checked_out — script 223, consumed by branch skip at 227.
CALLERS: age_of — script 216 and 230; information-only output.
CALLERS: ahead_of — script 216 and 230; information-only output.
CALLERS: delete_branch — script 277 and 279; both destructive paths share the unchecked enumeration in finding 1.
CALLERS: remove/discard/extra_roots/repo — parser 58–76, root assembly 107, ignored predicates 210/272 and action gate 234; CLI docs and tests above.
CALLERS: wl/main/main_phys/common/lock/tmp — script discovery 78–99, root assembly, row snapshot at 171–178, branch checkout snapshot at 223, Git calls and archive destination; lock tests 224–233.
CALLERS: def/defname/url/slug/gh_ok — script 109–119, merged_of 137–150, header 185–188 and default branch exclusion 226; PR stub assertions 104–123.
CALLERS: roots/tab/p/h/b/d/l/phys/merged/dirty/ign/sess/verdict — row serialization/parser 171–219, branch rows 224–232 and removal records 245–279; fixture row() checks consume printed keys.
CALLERS: now/ct/anc/out/m/s/snap/s2/now_entry/why — classifier helpers, report snapshot, removal checks at 259–274; tests for classifiers and changed-state skips above.
CALLERS: failed/msg/base/dest/i/ok/ref — action handling 236–280 and branch-row enumeration; archive failure, suffix and moved-ref tests.
CALLERS: worktree-cleanup.lock — creation/traps 89–97 and tests 224–233; AGENTS Boundaries 4a and docs/reference.md:721 describe lock writes.
CALLERS: archive-worktree-* — script 247–256, tests 93,99–101,221; AGENTS Boundaries 4a and docs/reference.md:724.
CALLERS: CLEANUP_SH/SCRIPT — test 6–8,42,71–72,229; all script launches use the selector, including bare test.
CALLERS: fixture — test case setup 84–232, resets stub state and repository fixtures.
CALLERS: add_wt — test case setup 84–221; merge_ff — corresponding merged cases; tip — PR fixture OIDs and moved-ref assertions at 105,113,117,197.
CALLERS: run — normal fixture invocations 87–232; run_bare — missing-tool cases 121,155.
CALLERS: row — classification assertions 88–203; has — ignored listing, skip/failure and usage/bare diagnostics; rc_is — report/removal/failure/usage assertions 91–230.
CALLERS: wt_exists — removal/retention assertions 93–217; br_exists — branch-removal/retention assertions 93–217.
CALLERS: pass/fail/pass_n/fail_n — test assertions and final failure exit 235–238; no unconditional root-user success exemption remains.
CALLERS: stub gh/lsof/cp, STUB_DIR/work/real_cp/before/after/line — test setup 12–46 and fixture 48–61, report identity comparison 86–91, row helper 77–78; gh.args, gh.out, gh.rc, lsof.out, lsof.rc, lsof.calls, lsof.on2 and cp.fail drive assertions and deterministic mutations.
CALLERS: CLAUDE.md Plan clause / workflow-init 2.1 Plan clause — docs/coding-workflow.md:116–126, CHANGELOG 0.44.0 long-runs entry, todos.md:1063–1065; old conditions retained.
CALLERS: CLAUDE.md §5 preflight / workflow-init 2.1 §5 preflight — docs/reference.md:462–471, unchanged codex-gate.sh empty-error recovery, CHANGELOG 0.44.0 and todos.md:1063–1065.
CALLERS: workflow-init 2.21 skip question — README.md:43, docs/reference.md:168–172, CHANGELOG 0.44.0 and todos.md:1065–1066; checker template and prefix-safety text remain.
CALLERS: plugin.json version — plugin packaging and scripts/check-version-bump.sh; actual manifest read, only version changed, convention loading unchanged.
CALLERS: docs/ARCHITECTURE.md inventory / AGENTS Boundaries and Commands — CI lint and test steps, docs/reference.md Reports, README cleanup usage; stale inventory found in CI comment 40–43.
CALLERS: cited design/plan path — cleanup script/test headers, CHANGELOG 0.44.0, closing commit and Gate A/B records in this range. Prior records read as history after independent source inspection, not treated as proof that this head passes.
CALLERS: .context/codex-reviews/gate-a-spec-k044ga7q-* and gate-b-*-k044gbr2-* — cycle/disposition records; checked their links to design and repairs. No shipped runtime depends on their contents.
