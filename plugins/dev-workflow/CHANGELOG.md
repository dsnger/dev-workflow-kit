# Changelog — dev-workflow

Every version the plugin manifest has carried, newest first. Entries are written from
`git log` over `plugins/`, not from memory.

An entry covers the plugin-touching commits after the previous version's introducing
commit, up to and including the commit that introduced this one. There are no dates:
the manifest records versions, not release dates, and inventing them would be fiction.

**Bumping is checked**, as of 0.4.1: `scripts/check-version-bump.sh` fails a pull
request that changes a path inside an existing `plugins/<name>/` directory without
changing that plugin's manifest version. Before that it was a convention, and it was
missed twice.

It is a check, not a guarantee, and the difference is written down rather than glossed:
it verifies a bump is *present*, not that it is correct, and it says nothing about an
entire plugin directory being deleted, a file sitting directly under `plugins/`, a
plugin directory being renamed or repointed, or a commit pushed straight to main. A
newly added plugin needs no bump — there is no earlier version to differ from — but it
is not unchecked: a missing manifest, or one whose `version` cannot be read
unambiguously, still fails. Deleting only a plugin's *manifest* while the directory
keeps shipping fails too.
AGENTS.md invariant 12 carries the complete list.

## 0.10.0

- §5's gate loop gained two rules it was missing, both mirrored into `workflow-init`'s scaffolded
  template. Their provenance differs and the difference is worth stating: the **absorb-vs-stop**
  rule was minted in field use by the kit's heaviest consumer and is carried over largely as that
  consumer wrote it, while the **stuck criterion** was constructed during this intake from a small
  number of field observations — after the consumer's own stricter record retracted the first
  reading of them — so it is derived from field measurement rather than field-proven as a rule. **What a loop
  absorbs** is a question of **scope, not of action**: a finding correcting the correction just
  made **and staying inside the assigned fix set** is inside the loop's scope — one that leaves that
  set stops the loop like any other out-of-scope finding, even when it opens no new question, since
  absorbing it would grow the assigned work unagreed — and an in-scope finding is then acted on by
  its severity exactly as before —
  Blocker/Major resolve, Minor/Nit collect and never iterate — so ancestry grants no finding a
  repair round it would not otherwise get; a finding opening a new structural or contract question
  stops the loop whatever its set membership, and where a finding is both, novelty overrides
  ancestry. Size is not the test. **What "clearly stuck" means:** §5 has always sent a non-converging loop to
  the user and never said how to recognize one. It now requires **three conditions together**, any
  one missing meaning keep going — a plateau visible **across passes** rather than one pass's count;
  an **affirmative** stated judgement that coverage is sufficient, with a known materially
  unreviewed area forbidding the exit outright; and Blocker/Major findings that **keep regenerating
  across genuine repair attempts**, each round's fix producing the next. That third condition is
  what separates a plateau from a finish, and **a clean completion takes precedence over the exit**:
  a Blocker/Major-free pass **at or above the floor** has satisfied the clean-final-pass rule, so
  collect the Minors and close rather than report non-convergence on a converged loop. What the
  exit produces is a report that the loop will not converge, never a clearance. Below the floor
  nothing closes, and a zero-finding pass remains the sole exception.
- **A reporting duty ships with the stuck criterion.** From pass 4 onward every pass report carries
  three lines — the trend in findings and Blocker counts across passes, where this pass's findings
  cluster (product behaviour, the test instrument, or prose about either), and any require↔withdraw
  pair against earlier passes. Those lines expose five tells, and **any two present makes
  stop-and-surface mandatory rather than discretionary**, with the stuck reading explicitly not a
  precondition — a loop can be worth stopping long before it plateaus. The rationale is recorded in
  §5 as the maintainer's, not as a measurement of this repo: in another consumer all five signals
  were measurable by day two of a week-long loop, and the cost was never detection but the absence
  of a duty to say so.
- **Surfacing does not close the cycle**, and both copies say so, because the exit would otherwise
  compete with the rule that every Blocker and Major resolves: you surface with the finding still
  open, no pass is credited clean, and the loop resumes on what the user decides. The clean-completion
  precedence is likewise bounded by the floor — a Blocker/Major-free pass closes only at or above it,
  and a zero-finding pass remains the sole below-floor exit.
- **Neither curve measures coverage**, and that is why the coverage condition is affirmative rather
  than merely stated: a low Blocker count can sit beside an entirely unreviewed subsystem, and an
  earlier draft of this rule let a reader disclose insufficient coverage and stop anyway. Six passes
  is where the field observed a plateau — it is that one observation, not a timer that authorizes
  stopping.
- Neither rule loosens the gate, and the shipped text says so where a reader would otherwise
  assume it: a scope stop is **not** an exit — the floor, the Blocker/Major filter and the
  clean-final-pass rule all still stand, and the loop resumes on the revised artifact. Without
  that sentence "stops the loop" reads as a sanctioned below-floor close, which is the gate-off
  path the rule is not for.
- The template copy is downstream-neutral rather than verbatim: it carries both rules and the
  measurement that motivates the second, and drops the consumer's name and this repo's own
  provenance, which do not travel into a scaffolded project. The measurement is quoted as one
  observation on one artifact, and the guidance is stated as guidance — where a long artifact's
  plateau starts is unmeasured, so no threshold is claimed.

## 0.9.1

- §5's human-exception form and its `workflow-init` template no longer claim the empty
  record-only commit "does not reopen any gate". The normative half was right — an empty diff
  raises no review obligation — but the sentence also promised silence from the gate hook,
  which it does not deliver: such a commit can still draw a Gate-B reminder. Both copies now
  say so **without restating the hook's decision logic** — and without pointing at it either,
  since the scaffolded copy must stand on its own in a project that does not have the hook's
  source. Both pin the exemption to the **empty diff**, confirmable with `git show --stat`,
  rather than to the reminder looking inconvenient. The edited human-exception regions of the
  two copies are byte-identical (the files as wholes are not, and never were).
- **Four Gate-B rounds went into narrowing that replacement sentence** — each correction a
  subtler version of the same overclaim — before `docs/prompt-standards.md`'s own rule
  applied: at the fourth correction, delete the mechanism claim rather than refine it a fifth
  time. That deletion is what shipped, and it is why this entry describes no state machine
  either. The same supersession is noted in the design spec (§2.1, §8) and the implementation
  plan, whose approved quoted blocks are left unedited. Ledger row appended under
  `unverified-enforcement-claim`.
- **Corrects one rule 0.9.0 shipped below**, also from PR #24 (CodeRabbit): that entry says the
  model taking each pass is "read from the configured value at that moment", and it shipped
  that rule into both `docs/coding-workflow.md` and `docs/sparring-briefing.md`. It is wrong —
  `mcp-codex-dev` resolves its model chain once per project root and caches it until the
  server restarts, so an edit landed after a root was loaded leaves the configured value naming
  a model the running server is not using. Both documents now say to record the model the pass
  *ran under* and to probe with `mcp__codex__health` where the two can differ — reading the
  per-tool field (`tools.review.model` for Gate B, `tools.exec.model` for Gate A) with the
  top-level `model` as fallback, since the server resolves a gate's model as
  `tools.<tool>.model ?? model` and `CODEX_DEV_REVIEW_MODEL` lands at `tools.review.model`.
  Both documents are corrected across this 0.9.1 range. The 0.9.0 entry is left as the record of what shipped.

## 0.9.0

- §5 and its `workflow-init` template now state the finding-line **severity vocabulary as a
  closed set** — `BLOCKER | MAJOR | MINOR | NIT` — rather than showing it by example, and
  define what the **reader** does with anything else: split on unescaped pipes, trim the
  format's whitespace, match case-insensitively, and read an unrecognized non-empty token as
  `MAJOR`. An empty or malformed field stays a structural failure and the pass stays
  INCOMPLETE. Motivating incident: a Gate-B pass returned all four findings at `IMPORTANT`,
  and discarding it over the token would have thrown away four real findings.
- `scripts/check-invariants.sh` gains **check 4c**, which asserts that canonical line is
  present exactly once in each of `CLAUDE.md` and the command file — compared for equality,
  case-sensitively — and, in the command file, that it sits inside the `### 2.1` section that
  is actually scaffolded into a user's project. A copy anywhere else in that file ships
  nothing. The `### 2.1` anchor and its `### 2.2` terminator are both validated: a renamed,
  missing or duplicated boundary fails loudly rather than widening the range.
- §5 gains a **human-exception record form** — `Human exception:` / `Not done:` /
  `Accepted because:` — for a decision about work **no applicable rule required**: an optional
  check an environment cannot run, a requested review stood down, a courtesy step. It records
  a decision and authorizes nothing: never a gate, a floor, a pass count, an evidence
  obligation, or any mandatory rule from this file, `AGENTS.md`, a project doc, CI, a branch
  policy or the platform. The record is an unverified assertion and the shipped text says so.
- §5 Mechanics now states the **squash-merge carry** explicitly: every evidence entry and
  every human-exception record in the squash range is copied into the squash body, because
  that commit is the only body the merge carries into `main`'s history.
- `docs/coding-workflow.md` gains a **reviewer model selection** section, and
  `docs/sparring-briefing.md` the matching rule for the upstream advisor. Both describe the
  **mechanism only and name no models**: how to add a gateway provider to the Codex CLI, the
  switch surfaces `mcp-codex-dev` resolves in order (the config the CLI reads, the user-level
  `~/.mcp/mcp-codex-dev/config.json`, the per-repo `.mcp/mcp-codex-dev.config.json`, and the
  `CODEX_DEV_MODEL` / `CODEX_DEV_REVIEW_MODEL` environment overrides — the latter Gate B
  alone), each a one-string edit; why a CLI *profile* does not reach the gate calls (`--model` is
  passed, `--profile` never is); and that the model taking each pass is read from the
  configured value at that moment rather than carried in a document. Availability and pricing
  move faster than documentation, so the gateway's own catalog is the reference. The one
  permanent rule is family-level: no model from the implementer's own family satisfies a gate,
  whatever the vendor, gateway or transport. No §5 change — the invariant names families, not
  vendors.
- **What this release deliberately does not ship:** the mid-flight *gate waiver* this work
  began as. Three design cycles over nine review passes found no safe way to authorize a
  zero-pass gate closure in a prompt-only system — every compensating control landed
  unenforceable or recursive, the outage that would justify a waiver is producible by whoever
  benefits, and the preconditions cannot be established in the case they exist for. That
  finding, and what it does *not* claim, are recorded in
  `docs/superpowers/specs/2026-08-14-reviewer-availability-fallback-design.md` §1.

## 0.8.2

- `workflow-init`: the scaffolded ledger header now carries a supersession convention —
  a row whose narration is later found wrong or made stale is corrected by appending a
  `Superseded rows` entry, never by editing the row. Both standing rules hold unchanged:
  never edit a row, one row per hardening.

## 0.8.1

- **Three sentences added to the §5 gate protocol, and to the template `/workflow-init`
  scaffolds.** The Gate-B standing lens now asks what a diff changes the size, value or position
  of, and to grep for where each is described elsewhere — asked as an open question alone it
  missed three such statements in one cycle while being carried with unusual force. The Profiles
  counterfactual now asks for both halves: name the observation that would exist if the claim
  were false, and confirm the wiring could have produced it. The Gate-A pass procedure now asks
  for a mechanical sweep before each read pass, inspecting quoted commands rather than running
  them, since a command quoted in a spec may be destructive.
- **None of the three is a check.** Nothing runs the grep, tests whether a check could have
  failed, or records that a sweep happened. They sharpen questions a reader asks; the ledger
  rows say so rather than implying otherwise.
- **No skill changed.** The `harden-finding` guard-scope precheck — the change this round set out
  to make — turned out to need decisions about durable records, ledger format and mid-run
  collisions that a rule paragraph cannot carry. It is split to its own story.

## 0.8.0

- **The gate hook reads the result of a gate call before counting it.** Until now it
  counted on tool name alone, so a Codex call that failed, timed out, or was auto-
  backgrounded at 120 s advanced the counter — and for Gate B stored a fingerprint over
  content nobody read, which is a false ✓ in the hook's own recorded state. Observed
  directly: `passCountA` moved 3 → 4 on a call that ran 272 ms and never started a
  review. The pinned `mcp-codex-dev` catches its own errors and returns them as ordinary
  results carrying `success: false`, so Claude Code sees a successful tool call; nothing
  in the hook looked further. Five classes now decide it — `success` and `unrecognized`
  count and store, `failure`, `backgrounded` and `no-result` do neither. An escape-aware
  scan (never `jq`, which would reserialize away the very escape variants the matcher
  reads) locates the first `text` element of `tool_response`; the failure marker must be
  the envelope's **immediately-first** property, so a reordered envelope degrades to
  `unrecognized` rather than to a wrong verdict.
- **Fail-open where locating is uncertain, fail-closed where it is certain.** An
  unambiguous "there is nothing usable here" is `no-result` and does not count. Not being
  able to determine anything — unwalkable structure, a repeated `tool_response` key, a
  payload past the 1 Mi-unit scan bound or the 200-frame depth cap — is `unrecognized`,
  which **counts**, with a once-per-workspace disclosure saying the count was made
  without inspection. Counting an uninterpretable result silently was the alternative,
  and it is the direction invariant 2 names as dangerous.
- **The counter is closer to the truth and is still not evidence.** Classification cannot
  see whether the findings file was written, so §5's rule is unchanged and now stated
  with its reason: discount every incomplete pass regardless of what the counter says.
  `CLAUDE.md`, `README.md` and the `/workflow-init` inline template were corrected where
  they taught the old tool-name-only mechanism.
- **Fixes an invariant-1 violation that shipped.** With a directory at a marker path, the
  old `: > "$file"` form exits **2** under `dash` while exiting 0 under macOS `sh` — so
  the hook could fail non-zero on Linux, which invariant 1 forbids. The existing
  regression test never caught it because it only ever ran under macOS `sh`.
- **The test suite now really runs the hook under both shells.** Every runner used to
  invoke the hook as `sh`/`/bin/sh` regardless of what ran the suite file, so running it
  with `dash` exercised the *harness* under dash and the hook under whatever `/bin/sh` is
  — bash, on macOS. Only a handful of explicit `dash` rows ever reached dash, and this
  release's first draft generalized from them to the whole suite. `HOOK_SH` now selects
  the shell the hook itself runs under, CI runs the suite twice, and the claim is true
  rather than corrected.
- **The common result-scan paths are bounded, and timed regression rows keep them that
  way.** Three quadratics made a large-but-legal result stall the synchronous hook: the
  locator built each string byte-by-byte (and `substr(s,j,1)` is O(len) per call in BWK
  `awk`, so any per-character walk is quadratic by itself); the `backgrounded` test ran
  `${b%%\n*}` on every block, which bash 3.2 evaluates by trying successively longer
  suffixes; and guarding that expansion on the notice's literal prefix still left it
  running in full for a block that starts with the anchor and never completes it. A
  150 KB text block — ordinary for a Gate-B review result, and a seventh of the 1 Mi-unit
  ceiling — took **10.9 s** and now takes **0.46 s**; the anchor-prefixed near miss took
  5.9 s and now takes under a second, at the cost of one stated limit (the notice segment
  must fall within the first 4096 characters, so a ~4070+ character tool name counts
  instead of being discarded).
  **Not fixed, and named rather than left to be found — two paths.** `skipval` still walks
  containers character by character, so a large *valid sibling container before*
  `tool_response` costs 3.2 s at 200 KB and 11.5 s at 400 KB; and the record accumulator
  rebuilds the whole input once per input line, so a newline-rich payload is quadratic in
  line count independently of that (0.35 s at 4k lines, 2.69 s at 16k). Only the 1 Mi-unit
  ceiling stops either, and a payload just under it still costs tens of seconds. The lesson is written into
  the code: a size backstop bounds work only if the per-byte cost is constant, and in
  POSIX shell and `awk` it often is not — and a timed regression row only covers the
  branch its own fixture reaches.
- **`.context/codex-gate.off` is not a rollback**, and the docs no longer imply the
  counters are "accurate" while it is set. It silences messages; classification and state
  tracking keep running, so re-enabling lands on counters with the same semantics as
  gate-on — which is not the same as evidence that a review happened.
- **Mapping a Codex tool now says the one thing that made it fail silently, and the
  parser enforces it.** A mapped name must lie in `mcp__codex__*`, because the hook's
  matcher is `^(Bash|Skill|mcp__codex__.*)$`, so an out-of-namespace name is either never
  delivered at all or — for the two reserved names it does deliver — hijacks a lifecycle
  event. Two remedies that told operators to rename the server *away* from `codex` are
  removed — they produced exactly that unreachable configuration. **And the two reserved
  names that DO fire were a false-✓ hazard:** the mapped cases are tested before the
  native `Bash` and `Skill` cases, so `reviewTool=Bash` made a `git commit` **count** a
  Gate-B pass instead of resetting the cycle, and `execTool=Skill` counted a skill
  invocation as a Gate-A pass — both reachable from a plausible typo. Out-of-namespace
  mappings are now ignored like any other unusable line.
- **New setup step: `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS`** (README), the primary defence
  against auto-backgrounding. Requires Claude Code 2.1.212+, must be set in the
  environment Claude Code is launched from, `0` disables backgrounding and a positive
  value must exceed your longest gate call.

**Four accepted residuals, named rather than left to be discovered.** Each is recorded
because a reader who assumes otherwise will trust the counter further than it earns.

- **C1** — the `backgrounded` class recognizes the harness notice **in the wording it
  currently uses**. On any runtime where auto-backgrounding is still effective and that
  prose has changed, the call is counted again — as `unrecognized`, with the disclosure.
  This is why the environment variable is the defence and the hook is the backstop.
- **C2** — an `unrecognized` call whose disclosure is neither delivered nor persisted is
  counted **silently**, in both directions: emit suppressed (gate off) and emit failed,
  each combined with a failed pending write. Two named oracles pin it rather than repair it.
- **C3** — counter mutation is unserialized and `.context/` is trusted. Pre-existing,
  filed in `todos.md`; no locking is added here.
- **C4** — concurrent check-emit-write on the diagnostic markers can duplicate or lose a
  disclosure, in both directions. Spec §6 accepts this under "delivery is best-effort".
  The sequential tests describe sequential behaviour and must not be read as guaranteeing
  more; a partial fix over one state family would be the inconsistent repair C3 refuses.

**Rolling back to 0.7.1 restores the original defect**, and that is the whole trade: failed,
timed-out and backgrounded calls count as gate passes again, and the `dash` special-builtin
exit returns with them — on Linux an unwritable `.context/` makes 0.7.1's hook exit 2,
violating invariant 1. So roll back if 0.8.0 discards passes it should count, and not for
anything else. What it does **not** undo: the three diagnostic markers already written into
`.context/` stay there, and 0.7.1 ignores them.

## 0.7.1

- **Gate B gains a standing lens: "which existing statements does this diff falsify?"**
  A change makes sentences wrong in files it never touches. The checks that ran in the
  motivating cycle — parity diffs, resyncs, greps of the edited paths — inspect only what
  the change touched, so they never looked at these files; a narrow check could pin one
  stale spelling, but no comprehensive check covers arbitrary semantic drift. The lens is
  prompt text: it asks, and nothing enforces the ask or validates the answer. Asking found
  a shipped command that would have let a one-line fix skip Gate B, plus two docs teaching
  a rule the same change had narrowed. Hardening for a fourth `docs-drift` occurrence.

## 0.7.0

- **`intake` proposes a risk and security-relevance profile per story** and derives a
  **validation mode** from the two (`max(risk, security)` → `battery` / `battery+check` /
  `battery+check+verification`, plus `+abuse-path` at security `high`). All three are
  human-confirmed inside intake's existing single question round — there is no
  "unconfirmed" state — and the story header is their single writable copy. A
  `**Profile log:**` records later changes without restating values.
- **§5 gains a Profiles subsection**: lens sets appended by level — risk `high` → threats,
  abuse, rollback, data loss, idempotency, compatibility, observability; security
  `standard` or `high` → assets, trust boundaries, roles, external systems, abuse paths
  (risk `standard` and `trivial` append nothing) — three defined answers for
  reading a profile, and the author's evidence obligations per mode. Lenses are different
  questions, not more passes: the 3-pass floor, the Blocker/Major filter and the
  file-first findings protocol are unchanged.
- **The Gate-B skip narrows** for a profiled story: it now needs **both** a behaviourally
  trivial change **and** effective level 0, where the profile supplies only the second.
  It removes the review but never the evidence. No new way to skip a gate is added.
- **§5 Mechanics: the cycle-closing amend carries one validated evidence entry per cited
  profiled story** (and none for an unprofiled one), so the final
  commit body is its durable record — an entry written only into the `WIP:` body is
  destroyed by the amend that closes the cycle.
- **Unprofiled stories are unaffected**, including today's judgement-based skip: a story
  with no profile line behaves exactly as it did before this release.
- **`process-pr-review` requires both conditions for a Gate-B skip** — the change is
  behaviourally trivial (judged by effect, never by line count) **and** every cited story
  is eligible — where it previously turned on the fix's size alone. Explicit no-story,
  one-story and several-stories branches.
- **The hook's below-floor reminder stops restating the skip rule** and defers to the
  policy file instead — one string, no new hook behaviour. The hook still only counts
  passes and reads no profile; the edit removes a rule statement that the narrowed skip
  made false, rather than teaching the hook anything about profiles.

## 0.6.0

- **Optional companion files beside a gate findings file.** The §5 protocol knew only
  about the findings file, so dispositions and interrupted-cycle state lived in chat
  history and died with the session. The scaffolded template now describes two advisory
  companions: `<slot>-dispositions.md` (one line per finding: verdict + reason) and a
  cycle-stable resume note — `gate-a-spec-resume.md`, `gate-a-plan-resume.md`,
  `gate-b-resume.md`. Cycle-stable rather than pass-named, because a note keyed to the
  interrupted pass is exactly the file a resuming agent will not look for once the counter
  moves. Both are optional and non-validating: the findings file plus its terminator remain
  the only hard requirement, and nothing enforces the companions. Field practice from
  infinite-portfolio-canvas, which had invented 7 dispositions files and a Gate-A resume
  note per-session before the protocol knew about them.
- **The scaffolded prompt-standards template now covers ad-hoc task briefs.** A brief
  handed to the coding agent for one task is a prompt with the same failure modes, held to
  the checklist in spirit — success criteria, stop conditions, verified claims — while
  nobody reviews a brief against all 12 items, which is why those habits must live in how
  briefs are written. Deferred since 0.5.0 and deliberately **not** a verbatim copy of this
  repo's paragraph: that one links a file `/workflow-init` never scaffolds and asserts this
  repo's own incident count, so the template carries a downstream-neutral variant.

## 0.5.1

- **Gate findings go to a file, not the MCP response.** Long finding lists came back cut
  off on effectively every substantial Gate A pass in the field, and a cut landing
  between findings looks exactly like a short list — so dropped findings read as a clean
  review. Both gate prompts in the `/workflow-init` CLAUDE.md template now have Codex
  write the full list to `.context/codex-reviews/<slot>.md`, end it with
  `END OF FINDINGS (<n> total)`, and reply with one line. The reader accepts a pass only
  when the terminator is present, the count matches, the file holds nothing but finding
  lines, and — for a Gate-B `full` review — both branch files pass.
- **Gate B writes one file per reviewer branch.** `reviewType: full` runs the spec and
  quality reviewers in parallel from a single `additionalContext`. Aimed at one path they
  race, and the second writer leaves a correctly terminated, correctly counted file
  holding half the findings, with every check still passing.
- **Bounded recovery.** An incomplete pass gets one attempt, shared with the existing
  timeout retry rather than added beside it, then STOP — two budgets let a pass alternate
  between them indefinitely. Delete exactly what the re-run rewrites; a resumed Gate-B
  branch must carry its `reviewType` alongside its session id, since the tool defaults to
  `full` and would otherwise run the other reviewer into the wrong slot.
- **What this does not do**, stated in the template rather than implied: nothing checks
  the terminator mechanically — the protocol is instruction-backed by design, and a
  recurrence is the trigger to build the checker. The hook counts on `PostToolUse`, so a
  call that returns and then fails validation still increments the counter you are
  discounting — and so does a *failed* review, because the pinned `mcp-codex-dev` returns
  its own errors and timeouts as ordinary results rather than throwing, which makes the
  tool call itself succeed. Discount every incomplete pass whatever the counter says.
- No hook, script, CI checker or other executable machinery changed. The behaviour of
  both gates *does* change — in this repo the prompts are the product — and that change
  is instruction-backed, living in prompts and templates only.

## 0.5.0

- **Gate-B fingerprint covers the index.** `git commit` commits the index, but both hash
  components described the worktree, so staging a change and then reverting the file on
  disk reported Gate B satisfied on content nobody reviewed. The fingerprint now includes
  a tree id from the effective index (`GIT_INDEX_FILE` when set, else the git-dir index).
- **Staging now invalidates a review.** `git add` of already-reviewed content changes the
  index tree, so the fingerprint changes. The committed bytes are unchanged, making this
  a false invalidation — accepted under the "loose in the firing direction" invariant, and
  the reminder explains that staging alone can cause it. One clean pass clears it.
- **Upgrading invalidates any in-flight review once.** The fingerprint's composition
  changed, so a fingerprint recorded by 0.4.x cannot match one computed by 0.5.0. The
  first Gate-B-applicable commit attempt after upgrading reports "cannot confirm" (a
  `WIP:` commit or a docs-only commit bypasses the comparison); a single review pass
  clears it. This is expected, not a bug.
- **An uncomputable fingerprint now fails closed.** The failure value is a constant that
  never matches — including against itself — replacing a `date`+PID nonce that could
  collide under PID reuse and report satisfied.
- **Reminder text no longer asserts causes it cannot know.** The stale reminder names the
  state ("cannot confirm") rather than claiming the tree changed, and describes the causes
  that can produce it; the satisfied reminder claims fingerprint equality rather than that
  Codex read the bytes. The message-contract tests in `codex-gate.test.sh` section 29 are
  what keep this true: they compare each branch's complete `additionalContext` and
  `systemMessage` against a golden fixture, so any reworded or reversed clause fails the
  suite rather than only the clauses someone thought to enumerate.

## 0.4.1

- **A plugin change now requires a version bump**, checked in CI on every pull request
  (`scripts/check-version-bump.sh` + its suite). This entry exists because the rule was
  broken before it was written: 0.4.0 shipped, and then two commits changed the plugin
  without a bump — see the two items below, released here for the first time.
- `commands/process-pr-review.md`, `commands/workflow-init.md`: the enforcement-claim
  checklist item, and the docs-drift escalation to rung P (`fe5e296`, merged as #5).
- `commands/process-pr-review.md`, `commands/workflow-init.md`: four PRs of observed
  Greptile behaviour recorded, plus an opportunistic bot category (`793e234`).

## 0.4.0

- `agents/finding-triage.md`: new read-only PR-comment checker, convention-loaded, that
  validates one reviewer claim against the code (`b952d95`, #4).
- `commands/process-pr-review.md`: delegates each claim to that agent after its
  instruction-path precheck.
- `skills/harden-finding/SKILL.md`: taxonomy and ladder refinements.
- `commands/workflow-init.md`: scaffolds the mechanized invariant checks; the Codex MCP
  preflight now names the cause it can actually diagnose (`bb672eb`, #2).
- `commands/workflow-init.md`: the scaffolded CI template pins `actions/checkout` and
  `actions/setup-node` to v7.0.0 SHAs (clearing the Node 20 deprecation), sets
  `persist-credentials: false`, and ships verified SHAs in its commented pnpm/node
  example instead of `<sha>` placeholders (`46366a0`, #3).

## 0.3.0

- `hooks/codex-gate.sh` and its suite, `commands/workflow-init.md`: the changes from
  self-initializing this repo with the workflow it ships (`e15d480`, #1) — the plugin's
  own gate applied to the plugin's own repo, which is where several of these findings
  came from.

## 0.2.1

- `.claude-plugin/plugin.json`: dropped the `hooks` key. `hooks/hooks.json` is loaded by
  convention, so declaring it too was a duplicate-hooks error and **the plugin did not
  load at all**. Now invariant 6 (`17b87fd`).

## 0.2.0

- `hooks/codex-gate.sh`: Gate-B validity is derived from working-tree **content**, not
  from events, so a file changed through Bash no longer leaves a stale ✓ standing.
- `hooks/codex-gate.sh`: counts Codex passes from any MCP server, or says why it cannot;
  stays out of projects that never adopted the workflow.
- `commands/workflow-init.md`: checks every prerequisite and reports what is missing;
  tri-state Codex preflight with an honest degraded mode.
- `.claude-plugin/plugin.json`: dropped the redundant `skills` and `commands` keys —
  both load by convention.
- `skills/intake/SKILL.md`: wording fixes.

## 0.1.0

Initial plugin (`a05976a`): the `intake` and `harden-finding` skills, the
`workflow-init` and `process-pr-review` commands, the `codex-gate` hook with its test
suite, and `examples/` as read-only reference material.
