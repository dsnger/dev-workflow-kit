# dev-workflow-kit

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

Ground progress claims: before reporting a step as done, audit the claim against a tool result from this session ("tests green" needs a test run to point to). Report unverified work as unverified — this keeps status reports factual on long runs.

The work loop includes the review gates: **spec ready → Gate A (spec) → plan ready → Gate A (plan) → execute → tests green → Gate B → commit** (see §5).

## 5. Cross-Model Review (Codex) — TWO MANDATORY GATES

Independent second opinion at two gates. Easiest steps to skip, so the discipline is
yours — a non-blocking hook (shipped by the `dev-workflow` plugin) reminds you at
each. Opt out per-workspace with `.context/codex-gate.off` (delete to re-enable); the
gates still apply.

**Both gates are a LOOP with a HARD FLOOR: min 3 passes per run (Blocker/Major
only), counted by the hook.** The hook counts passes but can't read findings or
tell the spec run from the plan run (it resets at `writing-plans`), so Gate A —
the spec run especially — is instruction-backed: a satisfied count is not a clean
review. Open a TodoWrite "Codex pass N" per pass; fix Blocker/Major after each. Your
final pass must be clean — if pass 3 still finds Blocker/Major, keep going until
clean or clearly stuck → then STOP and surface to the user. The only early exit
below 3 is a pass with **zero** findings; don't manufacture findings to pad. Codex is
advisory — validate before applying; dismissed finding → one-line why.

**What a loop absorbs, and what stops it — a question of scope, not of action.** A finding
that corrects the correction you just made **and stays inside the assigned fix set** is
**inside this loop's scope**: keep it here rather than handing it back, then act on it by its
severity exactly as Mechanics already says — Blocker/Major resolve, Minor/Nit collect and
never iterate. Ancestry decides where a finding belongs; it never decides what you do with
it, and it grants no Minor or Nit a repair round it would not otherwise get. **The assigned fix set is fixed before the pass you are answering: it is the
scope the approved story or plan assigns to this cycle, plus repair obligations you already
accepted in earlier passes.** A finding is in-set when repairing it stays inside that scope —
never merely because it arrived in the current pass, which would put every new finding in the
set by definition and leave the boundary deciding nothing. Where membership is genuinely
unclear treat the finding as **outside**, which costs a question and never a silent expansion. **A correction that leaves that set stops the
loop like any other out-of-scope finding**, even when it opens no new question at all —
absorbing it would grow the assigned work without anyone agreeing to that — and it resumes
the moment the user says whether the set now includes it. A finding
that opens a **new structural or contract question** stops the loop and goes to the user —
**size is not the test, novelty of the question is**, so a structural finding that is
genuinely small still stops it, while a long correction still aimed at the last correction
does not — provided that correction, too, stays inside the set, which its ancestry never
supplies on its own. **When a finding is both** — it corrects the last correction *and* opens a new
structural or contract question — **the new question wins and the loop stops**: novelty
overrides correction ancestry, because absorbing on ancestry is exactly how a contract
decision gets made without anyone choosing it. Stopping this way is **not an exit from the gate**: the floor, the
Blocker/Major filter and the clean-final-pass rule all stand, and the loop resumes on the
revised artifact once the question is answered — what the stop prevents is a loop
committing you to a design you never chose, which is a different failure from an
unfinished review. (Field-minted in `infinite-portfolio-canvas` and carried here because
the alternative was observed there: handing back a three-line repair-of-a-repair wastes a
session, and absorbing a contract question spends a decision that was not the loop's to
make.)

**Recognizing "clearly stuck", so that exit is a reading and not a mood.** Read the
**Blocker curve across passes**, not any single pass's total — it is the better of the two
signals, the total says less than it looks like, and one low count is a snapshot rather
than a plateau. **Neither curve measures coverage:** a low Blocker count can sit beside an
entirely unreviewed subsystem. So this exit needs three things **together**, and a missing
one means keep going: a plateau visible across passes (six or more is where the field saw
one); an **affirmative judgement that coverage is sufficient**, stated — a known materially
unreviewed area forbids this exit outright, and disclosing it does not license it; and
**Blocker or Major findings that keep regenerating across genuine repair attempts**, each
round's fix producing the next. That third condition is what makes a plateau rather than a
finish, and it is why **a clean completion takes precedence over this exit**: a
Blocker/Major-free pass **at or above the floor** has satisfied the clean-final-pass rule —
collect the Minors and Nits and close — and reporting "will not converge" on a converged
loop is a false report. **Below the floor nothing closes**, and a zero-finding pass remains
the only exception, exactly as above; a Blocker/Major-free pass 1 carrying a Minor keeps
looping.
**Surfacing does not close the cycle, and that is what makes this reachable.** You surface
*with the finding still open* — the resolve rule is not waived, no pass is credited as
clean, and the loop resumes on whatever the user decides. Reading it as "stop instead of
fixing" would put the exit in competition with the rule that every Blocker and Major
resolves, and then nothing could satisfy both.
**From pass 4 onward every pass report carries three lines.** The carrier is **your own
status report to the user** — never the Codex reply, which stays exactly one line per branch,
and never the findings file, which admits no line that is not a finding or the terminator.
They are cheap because the numbers already exist: (1) the **trend** — findings and Blocker counts across the passes
so far; (2) where this pass's findings **cluster** — product behaviour, the test instrument,
or prose about either; (3) any **require↔withdraw pair** against earlier passes, meaning a
pass demanding what an earlier pass had removed.

Those three lines expose **five tells**: the finding count rising rather than falling; the
Blocker count failing to fall; findings clustering on the **instrument** rather than on
product behaviour; findings clustering on **prose about** either; and a require↔withdraw
pair. **Any two present makes stop-and-surface mandatory, not discretionary** — you report
the tells and hand the decision to the user, and the "clearly stuck" reading above is not a
precondition for it. A loop can be worth stopping long before it plateaus.

Recorded rationale, from the maintainer rather than from a measurement of this repo: in the
Bricks consumer all five signals were measurable by **day two** of a week-long loop, and the
cost was never detection — it was the absence of a duty to say so. That is why this is a
reporting obligation with a mandatory threshold and not another heuristic to weigh.

**The two rules above do not compete**, and neither overrides the other: the absorb rule
decides whether *a finding* is inside this loop's scope, this reading decides whether *the
loop* can still converge. A small correction-of-a-correction that stays inside the assigned fix
set is absorbed and is not by itself evidence of a plateau. The field measurement behind it, quoted at the
precision its own record keeps: nineteen Gate-A passes over successive revisions of one
design spec past 2800 lines (the exact size is not part of that evidence), findings from 43
into a 2–19 range after pass 6 and never zero, Blockers from 11 to 0–1 from pass 7 on — and
the late Blockers were semantic contradictions rather than wording, which is why a low
count is a signal to read and not a clearance. That a round regenerates roughly half the
findings it closes is a **hypothesis** in that record rather than a measurement; one
lineage was established (the last pass's Blocker came from the previous pass's fix). Hence
the sizing guidance: prefer **smaller specs with named interfaces** and let the plan carry
the detail — guidance, not a threshold, because where the plateau starts is unmeasured.

**Findings go to a FILE, not the response — both gates.** In the field, long finding
lists came back cut off on effectively every substantial Gate A pass, and a cut that
lands between findings is indistinguishable from a short list: silently dropped
findings, the dangerous direction. Claude Code both limits MCP tool output (25,000
tokens by default, `MAX_MCP_OUTPUT_TOKENS`) and persists over-threshold results to disk
behind a file reference; which one produced the field loss is not established, and the
protocol is correct either way, because the response stops carrying the findings at all.
Append to the gate prompt:

> Pass the reviewed repo root as `workingDirectory`. Write the FULL findings list to
> `.context/codex-reviews/<slot>.md` (create the directory if needed; the path is
> relative to that root — Codex resolves writes against its working directory, so
> without this a valid file can land in a different checkout). `<slot>` is
> `gate-a-spec-pass-<p>`, `gate-a-plan-pass-<p>`, or `gate-b-<spec|quality>-pass-<p>`.
>
> One finding per line in the format above; escape a literal pipe inside a field as
> `\|`.
> Severity is one of exactly: BLOCKER | MAJOR | MINOR | NIT — no other token.
> Every line before the terminator is exactly one finding line — no blank lines,
> headings, prose or wrapped continuations. End the file with a final line reading
> exactly `END OF FINDINGS (<n> total)`, `<n>` being the number of finding lines. A
> clean pass is the single body line `NO FINDINGS` with `END OF FINDINGS (0 total)`.
>
> Then reply with ONLY one line per branch — `<gate> | pass <p> | <n> findings | <path>`
> — or `INCOMPLETE | <cause> | <path>` if you could not write the file. An unwritten
> file behind a normal-looking reply is the one outcome the reader cannot diagnose.

**Gate B takes one file per branch** because `reviewType: full` runs the spec and
quality reviewers in parallel from one `additionalContext`. Aimed at a single path they
race, and the second writer leaves a correctly terminated, correctly counted file
holding half the findings — with every check still passing.

**Before each call, delete every target file and confirm it is gone.** A call that dies
part-way leaves the prior attempt's valid file behind, and no terminator can tell that
from a fresh one. If a target survives deletion, stop and name the cause — path resolved
against the wrong root, permissions, a *directory* at the target, or a file reappearing
(another writer) each need a different fix, and "delete failed" alone sends you retrying
the delete. Run one pass at a time: the slot name has no invocation-unique component, so
two concurrent calls on one slot race. Passes are sequential by construction, so that is
a stated limitation, not a guarded one.

**Optional companions, from field practice.** Two files may sit beside a findings file.
Both are advisory human notes: neither is ever the findings file, neither participates in
pass validation, and either may be deleted or rebuilt. The findings file plus its
terminator remain the only hard requirement, and a zero-finding pass needs no companion.

- `<slot>-dispositions.md` — one line per finding: verdict + reason. It makes a dismissal
  durable, so "we looked at that and why" outlives the session rather than the chat.
- a **cycle-stable** resume note when a cycle is interrupted — `gate-a-spec-resume.md`,
  `gate-a-plan-resume.md`, `gate-b-resume.md`. Cycle-stable, not pass-named: a note keyed
  to the interrupted pass number is exactly the file a resuming agent will not look for
  once the counter moves or an incomplete pass is discounted. Gate A runs separate spec
  and plan loops, so those are two cycles; Gate B is one cycle with one note even under
  `reviewType: full`, because the per-branch findings files race only since Codex's two
  reviewers write them — the resume note is written by the outer agent, sequentially, and
  splitting it would create two records able to disagree about one shared recovery budget.
  Whoever runs the cycle writes it when useful, replaces it as the cycle moves, and
  deletes it once the cycle closes. Nothing depends on it existing.

(Field practice, infinite-portfolio-canvas: 7 dispositions files and a Gate-A resume note
had been invented per-session there before the protocol knew about them.)

**Accept a pass only when** the file exists and is readable; its last line is exactly
`END OF FINDINGS (<n> total)`; it contains exactly `<n>` finding lines *and nothing
else* (or the single line `NO FINDINGS` when `<n>` is 0 — "n valid lines somewhere in
the file" would accept a truncated file padded with fragments); and, for a `full` Gate-B
pass, both branch files satisfy all of that. Anything else — missing, unreadable or
empty file, wrong path, malformed terminator, count mismatch, extra lines, one branch
file, an `INCOMPLETE` reply — is an **INCOMPLETE pass**, which is not a review: don't
act on the partial list, don't count it toward the 3-pass floor, and don't read "no
Blocker/Major visible" as clean.

**Reader:** the severity field is taken by splitting the line on **unescaped** pipes and
trimming the ASCII whitespace the finding format puts either side of each separator; a field
that is empty or all whitespace is a **structural** failure, so the line is INCOMPLETE and is
never normalized. Otherwise the field is matched **case-insensitively** against the four tokens
first — `Minor`, `minor` and `MINOR` are all `MINOR`, because `CLAUDE.md` Mechanics
legitimately spells them in Title case and a model copying that spelling is doing as it was
told, not drifting. A field that matches no token case-insensitively, and is non-empty, is
read as `MAJOR`. Every **structural** failure stays INCOMPLETE — a malformed
line, a wrong field count, an empty severity field, a bad terminator, a count mismatch. Only
the severity token is tolerated, and only when everything else about the line is right.
(PR #23's Gate-B pass 3 returned all four findings at `IMPORTANT`; discarding that pass over a
token would have thrown away four real findings.)

**Recovery: one attempt per pass**, shared across timeout, an `INCOMPLETE` reply and
failed validation — the Mechanics timeout-retry rule widened, not a second budget beside
it, since two budgets let a pass alternate between them indefinitely. The attempt is a
fresh re-run, deleting exactly what it will rewrite: both branch files for a full
re-run, only the failed branch for a single-branch resume — deleting both and recreating
one makes the both-files check fail by construction, spending the attempt on a path that
cannot succeed. Prefer a resume only when the reply shows the review ran and just the
write failed: pass the `sessionId` from the original tool result back, and for a Gate-B
branch pass its `reviewType` alongside (`spec` with `specSessionId`, `quality` with
`qualitySessionId`) — the tool defaults to `full`, and a resume that omits it can run the
other reviewer and write the wrong slot, which no check detects, because the file is
well-formed and merely from the wrong branch. Whether a resumed session re-executes the
write or just returns its prior summary is not established; if it returns the summary,
that was the attempt. Spent and still incomplete → STOP and surface, naming which check
failed.

**What this does not do.** The hook counts on `PostToolUse`, keyed on tool name **and on
the result envelope**, and still never sees the file. Claude Code fires `PostToolUse`
after a *successful* call and routes a failed one to `PostToolUseFailure`, which the
plugin registers no handler for — but do not infer from that which failures escape
counting: the pinned `mcp-codex-dev` catches its own errors, executor timeouts and aborts
included, and returns them as a normal result carrying `success: false` rather than
throwing or setting `isError` (`dist/tools/codex-review.js`). A failed review therefore
still looks like a successful *tool call* — but as of 0.8.0 the hook reads the result of
gate calls it can route, and withholds the count for three **recognized** shapes: an
envelope whose **first** property is `success: false`, the harness backgrounding notice
**in the wording it currently uses**, and a result from which no usable text can be
obtained. Every other routed gate call counts, including any located text the hook cannot
interpret — a reordered envelope, a reworded notice, an unknown third-party shape — which
counts **with** a disclosure that is attempted and normally shown once per workspace, but
can be lost or repeated when its marker cannot be persisted. So does a call that returns
and then fails validation. The counter is therefore closer to the truth than it was and
is still not evidence: a "satisfied" count can still overstate the passes you actually
hold, and reasoning about which failure took which event path will get it wrong. The rule
that follows is the simple one: **discount every incomplete pass regardless of what the
counter says**, because classification cannot see whether the findings file was written.
Nothing checks the terminator mechanically; this is
instruction-backed by design, and a recurring truncation incident is the trigger to build
the checker, not a reason to build it now. Detection is conditional: it catches an absent
or malformed terminator, a count mismatch and a missing branch file *in the artifact you
actually read*; it does not catch a model that writes a wrong count with a matching
number of lines, nor a stale file if you skip the delete.

**Why `.context/codex-reviews/`:** with the current `tree_hash()`, changes confined to
`.context/` move none of its three fingerprint inputs, so review artifacts cannot
invalidate the review they document. Ignore `/.context/codex-reviews/` specifically —
not all of `.context/`, which would strip the committed `codex-gate.on` adoption marker.

- **Gate A — Spec, then plan (TWO runs, each its own 3-pass loop).** Run on the
  **spec** right after brainstorming (before `writing-plans`), then on the
  **plan** before `executing-plans`/`subagent-driven-development` — catching a
  spec flaw before it's baked into the plan. Tool: `mcp__codex__exec` (raw;
  reviews the TEXT you pass, not the git tree). Use ONE broad prompt, re-run it
  each pass over the revised artifact (don't narrow per-dimension; new findings
  surface because the artifact changes between passes). The prompt MUST open with
  *"Use the superpowers:brainstorming skill to review this spec,"* (say "plan" on
  the plan run), then ask Codex to check it against our settled decisions and
  surface **contradictions/inconsistencies, missing requirements, unhandled
  state/edge/error/empty/concurrent paths, and risks to the Key Invariants
  (@AGENTS.md) — plus anything else** (coverage floor, not a cage). Append the
  intent + artifact text + which invariants it touches. Ask for **every** finding
  with severity and confidence — you filter to Blocker/Major downstream, Codex
  never does, because a model told to report only high severity drops real
  findings silently (`docs/prompt-standards.md`, "coverage first, filter later").
  Ask for one line per finding and a literal `NO FINDINGS` when a pass is clean —
  the explicit clean signal is what lets you exit the loop:

  ```
  MAJOR | high | §3 "Retry policy" | retry count unbounded | a poisoned job loops forever | cap at 5, then dead-letter
  NO FINDINGS
  ```

  Each pass: validate, revise, re-run. Before each read pass, settle mechanically what
  the artifact asserts and a machine can decide without side effects — cited paths,
  quoted passages, stated counts, the syntax of standalone fenced blocks — because a read
  pass spends expensive judgement on what a parser settles in seconds and misses it
  anyway, inspecting quoted commands rather than running them, since a command quoted in
  a spec may be destructive or an intentional failure. (Large/high-risk artifact: optional focused
  per-dimension passes on top.)
- **Gate B — Code.** Tests green, before `git commit`. Tool: `mcp__codex__review`
  (args `instruction`, `whatWasImplemented`, `baseSha`; `reviewType: full` runs
  spec + quality in parallel). Skip ONLY trivial changes. Check against
  @AGENTS.md. Re-review after every fix — a fix changes the diff and the hook
  invalidates the prior pass, which is where the 3 come from.

  **A fix that changes specified behaviour updates the spec in the same commit.** If a
  Gate-B fix alters something the approved spec pins down — an ordering, a terminal
  state, a contract — the spec is stale the moment you commit, and the next reader
  trusts it. Update both, and let the re-review cover both. This is not hypothetical:
  a Gate-B fix here reordered a precedence rule and added a terminal state, the spec
  was left describing the old behaviour, and a PR bot found the disagreement after
  merge-readiness. Neither gate caught it *in that run*: Gate A had already passed the
  spec before the fix existed, and the Gate-B call was given only the diff. A reviewer
  handed both artifacts could catch it — which is why this is a rule about what you
  commit, not a claim about what the gates detect.

  Same coverage rule as Gate A: put "report every finding with severity and confidence; say
  `NO FINDINGS` if clean" in `additionalContext`, with the same one-line format.
  You filter to Blocker/Major, Codex never does.

  **Standing lens, every Gate-B call: "which existing statements does this diff falsify?"**
  A change makes sentences wrong in files it never touches. Checks scoped to the edited
  paths — a parity diff, a resync, a grep of your own edits — do not look there, because
  the file was correct until your change landed elsewhere. This lens is prompt text: it
  asks, nothing enforces the ask or validates the answer, and no comprehensive check
  covers arbitrary semantic drift. Ask anyway — in one cycle it surfaced a shipped command
  that would have let a one-line fix skip Gate B entirely, plus two user-facing docs
  teaching a rule the same change had just narrowed. **Name what this diff changes the
  size, value or position of** — a list, a count, a version, an identifier, a cited
  line — and grep for where each is described elsewhere, because asked as an open
  question alone this lens missed three such statements in one cycle while being carried
  with unusual force.

  **What counts as prose (the only Gate-B exemption).** Every staged path is
  explanatory documentation — `docs/**.md`, `README.md`, `MANIFEST.md` → N/A.
  These describe the product rather than being it, so a wrong sentence costs a
  confused reader, not broken behaviour; that is why they carry no gate at all,
  not because some earlier gate covered them (Gate A runs on specs and plans,
  which a README edit doesn't have). **Prompts are not prose:** `CLAUDE.md` and
  `AGENTS.md` themselves, and anything under a `.claude/`, `plugins/`, `skills/` or
  `commands/` directory **at any depth** — skills, commands, agent definitions, hook
  reminder text, inline templates — are the product (@AGENTS.md, "What this project is"), so they
  fire full Gate B even though they are `.md`. So does any mixed commit, and any
  non-`.md` file. The hook classifies paths the same way, matching those directory
  names at any depth on purpose: root-level `skills/` and a monorepo's
  `packages/*/.claude/` are both real layouts, and missing one would be a false
  "N/A" — the dangerous direction. The price is that prose under a directory that
  merely shares the name (`docs/commands/reference.md`) fires too, which is the
  redundant reminder invariant 2 accepts by name.

### Profiles — how much review this story gets

A story may carry a profile in its header: `**Risk:**` (`trivial|standard|high`),
`**Security:**` (`none|standard|high`), and a `**Validation:**` mode derived from them
(`battery` / `battery+check` / `battery+check+verification`, plus `+abuse-path` when and
only when security is `high`). The **story header is the single writable copy** — specs,
plans, commit bodies and this file's prompts carry the story **path** and read the values
fresh at each pass, never a remembered or copied value.

**The axes steer the questions; the mode steers the evidence.** Separate levers: one aims
the reviewer, the other obliges the author.

**Lens sets, appended to the gate prompt:**
- **risk `high`** → threats, abuse, rollback, data loss, idempotency, compatibility,
  observability.
- **security `standard` or `high`** → assets, trust boundaries, roles, external systems,
  abuse paths.
- **both** → the union appended **once**, each lens labelled with the axis that motivated
  it; risk's *abuse* and security's *abuse paths* are **one lens carrying both labels**,
  not two questions.

Lenses are **different questions, not more passes.** The 3-pass floor, the Blocker/Major
filter, the file-first findings protocol and the clean-final-pass rule are unchanged.

**Reading the profile — three cases, three answers:**
1. The artifact **cites no story** → run unprofiled and **say so** in the pass. Artifacts
   predating this rule are the common case; stopping on them would halt in-flight work.
2. The cited story has **no profile line** → same: today's behaviour.
3. A profile is **present but unresolvable** → **stop and surface the cause**. That covers
   the syntactic failures — unparseable line, a value outside the enums, two profile
   blocks, a citation resolving to nothing — **and the semantic ones**: a `**Validation:**`
   value disagreeing with `max(risk, security)`, or `+abuse-path` present without security
   `high` or absent with it. Only the **latest `mode override`** in the log, moving in a
   direction compatible with the current value, can explain such a mismatch — and if the
   log also contains an `axis change`, only when that override was recorded **after** the
   latest one, since an axis change voids every prior override. A log with no `axis
   change` at all is the ordinary intake-time override, and its entry resolves the
   mismatch on its own. A well-formed value can still be the wrong value, and a stale mode steers
   weaker evidence while looking entirely valid; recomputing it is a profile change like
   any other — proposed, human-confirmed, logged. Falling back to the lighter behaviour on
   a malformed profile would under-review exactly the stories most likely to have one.

**The Gate-B triviality skip needs two independent conditions**, and an eligible profile
never makes a behaviour-changing diff skippable: the change itself is **behaviourally
trivial** (the pre-existing judgement, unchanged by profiles), **and** for a profiled story
`max(risk, security)` is 0 — risk `trivial` *and* security `none`, never risk alone. The
**skip reason is recorded in the commit body** — not in the profile log, which records
profile *changes*, and a skip changes no profile value. **A skip removes the review, never
the evidence**, and what is owed follows the profile: a skipped **profiled** story runs the
battery and lands its evidence entry beside the reason; a skipped **unprofiled** story
records the reason and the battery result and nothing more, because it owes no mode-derived
entry and keeps exactly today's judgement-based skip.

**A cycle citing several stories** aggregates along separate dimensions, never through one
winning mode: the **battery runs once** for the cycle; **each cited _profiled_ story
satisfies its own mode and suffix**, with its own named evidence entry, while a cited
**unprofiled** story has no mode and owes no entry; the **lens sets are unioned** across
all cited stories; and the cycle is skip-eligible only if **every** cited story is. A
single "max" would either under-serve the strictest story or impose its obligations on
unrelated ones.

**What the author owes before Gate B**, by mode: `battery` = the quality battery green ·
`battery+check` = battery + **a check that fails without the change** ·
`battery+check+verification` = battery + that check + a **named** verification of the risk
path · `+abuse-path` = one **named** abuse scenario plus evidence that the expected control
rejects or contains it. Level 2's two obligations are distinct; one artifact serves both
only if it demonstrates both.

A check need not be an automated test — where none is possible, a **named verification**
satisfies it and the entry says which route was taken and why. Either route owes the
**counterfactual**: the observation against the prior state. An **unobservable
counterfactual is a blocking evidence gap**, not a free pass — stop and surface; the human
may then lower the mode as a logged override. A fabricated test satisfies nothing. **Name
the observation that would exist if the claim were false, and confirm the wiring could
have produced it** — a check that supplies its own input, runs where the defect cannot
appear, or uses a fixture that never reaches the branch it covers reports success because
of how it was wired, not because the thing it checks succeeded.

**The evidence entry lives in the commit body** (see Mechanics), carries the **story path
and the named evidence but not the mode value**, and is **revalidated before every Gate-B
re-review and before the cycle-closing amend** — a fix changes the diff even when the
profile sits still. If revalidation changes the entry, the clean pass no longer covers what
is being committed: fix, re-review, close on the entry that pass validated.

**Every Gate-B call and re-review carries the path of every cited story**, so the reviewer
reads each profile itself, **plus the current evidence entry, quoted verbatim, for each
cited *profiled* story** — an unprofiled one owes no mode-derived evidence, so it
contributes a path and nothing else. One profiled story means one pair; a cycle citing
several carries all of them, because the reviewer cannot union lenses it cannot see or
judge evidence it was never given. A reviewer handed neither can only review the diff —
the lenses and the evidence obligations would exist and never be consumed.

**Two evidence gaps, two different answers.** Evidence that is *absent or inadequate* for
the mode is a **work gap**: produce it, then call. A project whose `AGENTS.md` names **no
verified quality command** cannot satisfy even `battery` — a **setup gap**: say what is
missing (`/workflow-init`'s battery step) rather than reviewing around it. Neither is a
reason to call Gate B against a weaker claim.

**Changing a profile:** the pass **proposes the complete resulting header** — both axes,
the recomputed mode, any renewed override — and the **human confirms it**, in both
directions; an agent never moves it alone. On confirmation, correct the header and append
one profile-log line. Any axis change **voids every prior override**, raised or lowered,
and `+abuse-path` follows the current security value. Passes already run under the lower
profile **keep counting** toward the floor; only the **final clean pass** must run under
the current profile. Inside an active Gate-B cycle, fold the edit into the active `WIP:`
snapshot by amend — a non-`WIP` commit reads to the hook as the cycle closing and would
discard the accumulated passes.

**What this does not do:** nothing checks which file a model actually read, whether the
header changed mid-call, or whether the lens sets were appended. This is instruction-backed
like the rest of §5; the detection is a reader comparing the pass against the story.

### Mechanics (reference)
- **Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw →
  rework) → both must resolve. Minor · Nit → collect, never iterate.
- **Tool routing:** docs (spec/plan, incl. code snippets) → `mcp__codex__exec`;
  implemented diff → `mcp__codex__review`. Never `review` a doc — it reads the
  git range, not the text.
- **`baseSha`:** against main = merge-base with main (`headSha` = HEAD);
  pre-commit, `baseSha` = HEAD is an empty range (HEAD..HEAD) — make a WIP commit
  and set `baseSha` to its parent. **Name that commit `WIP: …`** — the hook treats a
  `wip`-prefixed commit message as cycle-internal, so it neither fires a Gate-B STOP
  nor resets your pass counters. A pre-review snapshot named anything else reads as a
  real commit and closes the cycle, discarding the passes you just accumulated.
  **Finishing the cycle:** after the final clean pass, close it with
  `git commit --amend -m "<real message>"` — that replaces the WIP commit, and the hook
  reads the amend as the real cycle-closing commit. If several WIP snapshots piled up,
  `git reset --soft <parent-of-first-WIP>` first, then commit once. Amend rather than a
  follow-up commit for two reasons: a `WIP: …` commit left in history defeats the naming
  convention it exists for, and a follow-up commit has nothing to commit when the review
  produced no fixes.
  **The closing message carries the validated evidence entry for every cited profiled
  story** — one each, and none for a cited unprofiled story, which owes no entry. The
  amend replaces the WIP message wholesale, so an entry written only into the WIP body is
  destroyed exactly when the cycle closes. The final commit body is the durable record;
  a PR shows commit messages, so there is no second home to keep in sync.

  **On squash-merge, copy every evidence entry and every human-exception record in the squash range into the squash body — the squash commit is the only body the merge carries into `main`'s history, so anything left behind is unreachable from it.**

  **Recording a human exception.** Where a human decides that something **no applicable rule
  required** was nonetheless worth skipping — an optional check this environment cannot run, a
  review someone asked for and then stood down, a courtesy step — that decision goes in the
  closing commit body:

  ```
  Human exception: <handle> · <date>
  Not done: <what was skipped, specifically>
  Accepted because: <one line>
  ```

  **Which commit:** an ungated change records it in that commit; a Gate-A cycle in the spec or
  plan commit; a Gate-B cycle in the WIP commit, restated by the closing amend. Several records
  accumulate; order means nothing.

  **A decision made after its commit closed** — during PR review, say — goes in whichever of
  these exists: the next commit on the branch, the squash body, or a follow-up commit after the
  merge. If none does — the branch is closed, unmerged, and heading for an ordinary or rebase
  merge — **add a commit for it.** An empty commit carrying only the record is a legitimate
  destination: it changes no content, so it raises no review obligation. A record with nowhere
  to go would otherwise be a record that does not exist.

  **Do not expect silence from the gate hook, and do not read a reminder as a gate
  reopening.** It is advisory, so it never blocks the commit attempt. What is exempt is the
  **empty diff**, which `git show --stat` confirms — never a reminder that merely looks the
  same on a commit carrying content.

  Copy every record into the squash body alongside the evidence entry (Mechanics,
  squash-merge carry). **Nothing performs that carry and nothing checks afterwards that it
  happened** — it is on whoever prepares the merge. If two copies of one record disagree, that
  is a copying error: stop and fix it rather than picking one.

  **Scope, and it is narrow. This form supplies no permission.** It records a decision that
  was already the human's to make about something genuinely optional. It is **never** the answer to a
  below-floor pass, an unclean final pass, a `STOP and surface`, a Gate-A or Gate-B
  obligation, or a profile-derived evidence requirement — and more generally **it authorizes
  nothing that any mandatory rule in this file or in `AGENTS.md` requires.** Those have their
  own terminal actions and this paragraph changes none of them: on a STOP you still stop, and
  neither a human's assent nor this record lets an agent close or continue a cycle.

  **"Mandatory" is not limited to this file.** A rule in `AGENTS.md`, a project doc, CI, a
  branch policy or the platform is equally out of reach — under **Wait for**,
  `docs/pr-review-bots.md` requires a bot review unless an explicit recorded human decision
  permits proceeding without it, and this form is not that decision. If you are reaching for it to get past something mandatory, the answer
  is no — take the operational route or stop.

  **Nor is it for things that were simply never owed.** An absent review from a bot routed
  **opportunistically** blocks nothing and needs no exception and no record;
  `docs/pr-review-bots.md` says so deliberately, and writing one anyway would rebuild the
  per-quiet-bot ceremony that routing removed. Record a decision, not a non-event.

  **What the record is worth.** It is an **unverified assertion**, and reads as one: nothing
  checks that the handle belongs to whoever decided, that a human was asked, or that the
  reason is honest. A reader of history learns that *the commit claims* a human chose, what
  it says was skipped, and why — no more. It supports no claim of authorization or review,
  and satisfies no evidence obligation. It exists because an exception nobody wrote down is
  invisible, not because writing it down makes it sound.
- **Timeout / abort:** a codex call that dies at the MCP tool-call timeout is retried
  once before surfacing to the user, and that retry *is* the single shared recovery
  attempt above — not a second one. An abort is an incomplete pass, so treat it as one:
  it may have left a partial or stale target file, so delete the targets and confirm them
  gone before retrying, then validate the result like any other pass. Whether it moved the
  hook's counter depends on the shape it returned and on which hook version is installed:
  as of 0.8.0 a recognized failure envelope, the recognized backgrounding notice and a
  result yielding no usable text are all withheld from the count, while a reordered,
  reworded or unrecognized shape still counts fail-open. Do not reason from the counter
  either way — an incomplete pass is discounted whatever it says. Counter and workspace
  state persist in `.context/`; the *pass* does not.

## 6. Context Canary

Begin every response to the user by addressing him as "Daniel."

**Why:** it is a context canary. These guidelines are only in force while this file is in
context, and nothing signals when it falls out. The address is a per-response marker: if
it disappears, CLAUDE.md is gone from context and the user knows to reload rather than
discovering it through work that quietly stopped following §1–§5.

**Scope: conversational responses only.** Never in file contents, commit messages, code,
or gate artifacts. §5's findings file admits no line that is not a finding line or the
terminator, and its reply is exactly one line per branch — a greeting there is a malformed
pass, so a canary that reached into artifacts would break the protocol it sits beside.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

Project architecture, stack-specific patterns, and invariants live in @AGENTS.md
(single source of truth — also read directly by Codex and the PR review bots). The
Cross-Model Review gates (§5) check against the invariants there.
