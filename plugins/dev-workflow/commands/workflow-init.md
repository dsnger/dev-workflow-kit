---
description: Scaffold the per-project files of the cross-model review workflow, then walk the user through writing AGENTS.md
---

Scaffold this project's cross-model review workflow: write the per-project files
below, then interactively author `AGENTS.md`, then print the stack-specific
checklist that stays the user's job.

Target model: Claude via Claude Code. This command is a prompt artifact and follows
the checklist it scaffolds (`docs/prompt-standards.md`).

## Rules

1. **Idempotent.** Run it twice and the second run changes nothing it already wrote.
2. **Never overwrite without asking.** For each target: missing → write it. Present
   and byte-identical to the template → report `unchanged`, touch nothing. Present
   and different → show what differs (a short diff, not the whole file) and ask:
   overwrite / merge / skip. This matters because these files accumulate real
   project content after the first run — a silent overwrite destroys it.
3. **Additive files are merged, never rewritten.** `.gitattributes`, `.mcp.json`,
   `pnpm-workspace.yaml` and `package.json` belong to the project; add the missing
   line or key and leave everything else exactly as it was.
4. **Stack-specific content is marked, not guessed.** Where a template has a
   `# TODO(stack):` marker, leave the marker in and name it in the closing checklist.
   A plausible-looking command that was never run is worse than an honest TODO.
5. **Report what happened per file** — `written` / `unchanged` / `merged` /
   `skipped (user)` / `asked, overwrote`. No silent no-ops.

## Step 1 — Preflight: check every prerequisite, then say what's missing

This is the project's one setup entry point, so it carries the whole "is my setup
complete?" answer. Check each item below, **state the result for every one** (the
detect-and-state rule governs this step — a silent pass is indistinguishable from an
unrun check), and carry every failure into the closing checklist as a named blocker.

Check, in order:

1. **git repository** — `git rev-parse --show-toplevel`. If absent, stop and ask: the
   hook's `.context/` state directory and the `.gitattributes` union merge both
   assume one, so nothing below is meaningful without it.
2. **superpowers plugin** — look for `superpowers:brainstorming`, `superpowers:writing-plans`
   and `superpowers:executing-plans` in the skills available to you *right now*. This
   is a hard prerequisite, not a nicety: the workflow's whole middle
   (spec → plan → execute) *is* those skills. Without them `intake` hands off to a
   skill that does not exist, and the gate hook's Gate-A pass counter — which only
   resets on those skill events — silently never fires, so Gate A degrades to no
   enforcement at all while still *looking* enforced. If they are absent, report
   `MISSING` with the install commands:
   `claude plugin marketplace add obra/superpowers-marketplace` then
   `claude plugin install superpowers@superpowers-marketplace`.
3. **Codex MCP** — the gates call `mcp__codex__exec` (Gate A, reviews text) and
   `mcp__codex__review` (Gate B, reviews a diff). These three states have different
   causes and different fixes, so report the one that actually holds — a single
   "codex: failed" sends the user hunting in the wrong place:

   | State | How to detect | What to report |
   |---|---|---|
   | **1 · not configured** | no `codex` entry in `.mcp.json` (or no `.mcp.json`) | `MISSING — Step 2.8 writes the entry; re-run /workflow-init or add it by hand` |
   | **2 · configured, not loaded** | the entry exists, but `mcp__codex__exec` / `mcp__codex__review` are not among your available tools | `NOT LOADED — check the six causes below in order; they need different fixes and "restart the session" only fixes the first.` |
   | **3 · ok** | both tools are available to you | `ok (pinned mcp-codex-dev@<version>)` |

   **State 2 has six causes, and reporting only the first sends the user in a loop.**
   Run `claude mcp list` and check them in this order — the fixes do not overlap:

   1. **Not yet approved** — the server is listed but the session predates
      `.mcp.json`. Fix: restart the session and approve the project server. Only this
      cause is fixed by restarting, so do not offer it as the general remedy.
   2. **A same-named server in a HIGHER-precedence scope wins.** Precedence is
      **local → project → user** ([scope hierarchy](https://code.claude.com/docs/en/mcp#scope-hierarchy-and-precedence)),
      and the whole entry from the winning scope is used — fields are never merged. So
      only a **local**-scope `codex` can shadow this project's entry; restarting will
      never change that. Fix: confirm which entry actually wins with
      `claude mcp get codex`, then remove that one by its real scope —
      `claude mcp remove codex -s <scope>`. **Renaming the project entry is not an
      alternative:** the hook is invoked by a `hooks.json` matcher of
      `^(Bash|Skill|mcp__codex__.*)$`, so a server registered under any other name puts
      its tools outside that namespace, where the hook is never invoked for them —
      `.context/codex-gate.tools` cannot map that back, because mapping is read by a hook
      that never runs. Whatever server is meant to back the gates must end up registered
      as `codex`.

      **A *user*-scope `codex` is NOT this cause.** User scope loses to project scope,
      so a user entry alongside a project entry that is merely unapproved is cause 1 —
      approve the project server. Telling someone to delete their user config there
      removes a harmless setting and leaves the real problem in place, which is the
      wrong-remedy loop this whole list exists to break.
   3. **Codex CLI not installed** — `command -v codex` finds nothing. Fix: install it,
      then re-check.
   4. **Codex CLI installed but not authenticated** — `codex login status` reports no
      session. Fix: log in; it needs an OpenAI account. Kept separate from cause 3
      because "install it" and "log in" are different actions and the symptom does not
      distinguish them.
   5. **A codex server IS connected, but exposes the wrong tools.** It answers, yet
      `mcp__codex__exec` / `mcp__codex__review` are absent — the official
      `codex mcp-server` exposes a single `codex` tool (plus `codex-reply`), and other
      servers expose other surfaces. Neither can be attributed to Gate A (reviews
      TEXT) or Gate B (reviews a DIFF), so every review through them is invisible to
      the counters. Report it as WRONG SERVER with both fixes (see the block below).
      This is numbered here, ahead of the fallback, because it is a *known* cause with
      a known fix — reaching "unexplained" with a perfectly healthy server connected
      would be the wrong answer.
   6. **None of the above** — binary present, logged in, a correctly-shaped server
      still does not come up. Say exactly that rather than guessing: report the failure
      as unexplained, quote whatever the server printed, and point at the
      mcp-codex-dev docs. An invented cause is worse than an admitted unknown, because
      the user spends their time on it. This is the catch-all, and it is strictly last —
      never reach for it while any numbered cause above is still untested.

   Check the tool *names* specifically, not just that "a codex server exists": a
   different Codex MCP may connect under the same server name while exposing a
   different tool surface, and the gates + the hook's pass counters key on
   `exec`/`review` by name. A server that is reachable but exposes neither is state 2,
   not state 3.

   This is the most likely way a setup that *looks* complete still counts nothing, so
   name it rather than leaving the user to infer it. The gates need **a Codex MCP server
   that exposes `exec` and `review`** — Step 2.8 pins `mcp-codex-dev`, which does. The
   official `codex mcp-server` is a different server: it exposes one `codex` tool (plus
   `codex-reply`), which cannot be attributed to Gate A (reviews TEXT) or Gate B (reviews
   a DIFF), so reviews run through it are invisible to the counters. If that is what is
   connected, report it as its own state and give both fixes:

   ```
   codex MCP             WRONG SERVER — connected, but exposes mcp__codex__codex, not
                                        exec/review. The gates cannot count it. Either
                                        switch to the pinned mcp-codex-dev (Step 2.8),
                                        or map the names in .context/codex-gate.tools:
                                          execTool=mcp__codex__codex
                                          reviewTool=mcp__codex__<the diff-reviewing tool>
   ```

   Prefer switching servers over mapping: a mapping can only be honest if the server
   really has two tools that split text-review from diff-review. Mapping both gates onto
   one general-purpose tool makes the counters move without either gate meaning what it
   claims — a false ✓, which is worse than the STOP it silences.

   **A mapped name must also lie in the `mcp__codex__*` namespace.** The hook is invoked
   by a `hooks.json` matcher of `^(Bash|Skill|mcp__codex__.*)$`, so a mapping naming a
   tool outside it is either never delivered — the mapping looks applied and does nothing —
   or, for the reserved names `Bash` and `Skill`, is delivered and hijacks a lifecycle
   event. The hook refuses both. (Normative statement: the design's decision 1.) Register the server under the name `codex` to place its tools there.

   With no Codex reachable, **both review gates are inoperative** — the single most
   important thing this command can tell the user. If the user chooses not to set it
   up now, switch to the degraded mode in Step 2.13 rather than scaffolding gates that
   cannot run.
4. **`gh` CLI** — `command -v gh`. **Optional**: only `/dev-workflow:process-pr-review`
   needs it. Mark it optional so a missing `gh` doesn't read as a broken setup.
5. **AGENTS.md** — present or not. Absent is normal on a first run (Step 3 writes it);
   present means Step 3 reviews and extends it instead.
6. **Stack** — package manager (`pnpm-lock.yaml` / `package-lock.json` / `bun.lockb` /
   none), language, test runner, CI provider. This resolves the `TODO(stack)` markers.
   Detect, then *state what you detected* — do not silently assume.
7. **Existing targets** — note which files from Step 2 already exist, so Rule 2 (never
   overwrite without asking) applies before you write anything.

Print the result as a status block before you write a single file, so the user sees
what's missing while it is still cheap to fix:

```
Prerequisites:
  git repository        ok
  superpowers plugin    MISSING — claude plugin marketplace add obra/superpowers-marketplace
                                  claude plugin install superpowers@superpowers-marketplace
  codex MCP             NOT LOADED — `claude mcp get codex` shows a local-scope entry
                                     winning over this project's, so exec/review never
                                     load. Restarting will not help, and renaming this
                                     entry would move its tools out of mcp__codex__*
                                     where the hook is never invoked: remove that entry
                                     (claude mcp remove codex -s local)
  gh CLI                ok (optional — only /process-pr-review needs it)
  AGENTS.md             absent — Step 3 will write it
  stack                 pnpm · TypeScript · vitest · GitHub Actions
```

A missing prerequisite does **not** stop the scaffolding (the files are still worth
having, and a user often installs the missing piece right after). The exception is the
git check, which does stop. Everything else: scaffold, and name the blocker in the
closing checklist.

## Step 2 — Scaffold the files

Write each target from the template given below. `<YYYY-MM-DD>` is today's local
date; `<project>` is the repo's directory name unless the user says otherwise.

### 2.1 `CLAUDE.md` — the discipline rules

If a `CLAUDE.md` already exists with unrelated project content, do not overwrite it:
offer to **append** sections §1–§5 (renumbering only if the file already uses those
numbers) and say so in the report.

> **Prompt-standards item 1 for the scaffolded `CLAUDE.md`: n/a, and why.** The file this
> template writes is model-agnostic by design — its executing model is whatever the reader of
> that project runs — so a `Target model:` line inside it would be false in every repo it lands
> in. Recorded as a reasoned n/a rather than skipped: the item is answered. **This note sits
> outside the fence** so it never scaffolds, and is deliberately **not** a `Target model:` line,
> which would make this file's declaration count 2 and fail `scripts/check-invariants.sh`.

````markdown
# <project>

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
gates still apply. The hook counts passes by TOOL NAME (`mcp__codex__exec` /
`mcp__codex__review`) and by RESULT ENVELOPE — it withholds the count for a routed gate
call whose result it reads as failed, backgrounded, or yielding no usable text. If your
Codex MCP server names its tools differently, map it in `.context/codex-gate.tools`
(`execTool=<name>` / `reviewTool=<name>`) — otherwise your reviews are invisible to the
counters and Gate B reports "not run" forever. A mapped name must itself start with
`mcp__codex__`, or it is refused — outside that namespace it is either never delivered
to the hook or, for `Bash`/`Skill`, hijacks a lifecycle event. Register the server as
`codex` to place its tools there.

**Both gates are a LOOP with a HARD FLOOR: a minimum number of passes per run
(Blocker/Major only), derived from the cited story's profile.**
The derivation is max(risk, security): a value of 0 gives a floor of 1; every
resolvable profile above that, and an artifact citing no story, gives 3. Two levels,
not three — `high` takes its rigor from lens sets and evidence mode, not from extra
passes. A cited story whose profile is present but unresolvable stops and surfaces
under the existing rule; it does not fall through to 3, because reading it as 3 would
turn a stop condition into a silent default. Across a cited set the floor is 1 if and
only if the set is non-empty and every member is profiled, resolvable and at level 0
— all four conditions, since "every cited story" is vacuously true of an empty set;
no story cited, or any cited story unprofiled, gives 3. One derived value governs all
three cycle *kinds*: the Gate-A spec loop, the Gate-A plan loop and the Gate-B cycle. Not
because they are one cycle — they are separate cycles, and a change carrying several plans runs
a Gate-A plan cycle per plan — but because they derive from the same
cited-story set. That value is a function of the current confirmed profiles of that set,
read fresh wherever this section already requires them to be read, so wherever a value can be
derived at all there is exactly one, because there is one source. Some states derive **no** value
rather than a second one, and each stops rather than defaulting: governing headers that
disagree; a cited profile that is present but unresolvable; and a `Story:` header that cannot
be read. A change to a profile or to the set
therefore binds every open and future cycle — a raise costs an affected open cycle a
further pass under the current profile, as the profile-change rule below requires — while a
cycle that has already closed
stands, its close having been valid under the profile current when it closed, which is the
cycle-level form of passes already run keeping their count. **The set has one authority:
the artifact's `Story:` header, which carries the path of every cited story.** Nothing else
is a citation. A story path appearing anywhere else in an artifact's body — including a
sentence placing a story *outside* this change's scope — **contributes nothing to the cited
set and nothing to the floor derivation**, which is the only claim made about it; it may still
be a perfectly good cross-reference for any other purpose. And **an agent
deriving the set reads that header and does not grep the body for story paths**, because a
grep finds mentions and cannot tell a citation from a disclaimer. **Each cycle's governing header is the
header of the artifact it reviews**: the spec's for the Gate-A spec loop, the plan's for the
Gate-A plan loop, and — since a Gate-B cycle reviews a diff and has no header of its own —
**the union of the `Story:` headers of every plan contributing to that diff, which the Gate-B
call must carry in full**, as this section already requires of every cited path. **Every expected artifact contributes a set — a spec, and every plan contributing to the
reviewed diff — and an expected artifact whose `Story:` header is absent contributes the empty
set rather than dropping out of the comparison.** **One path per entry**, and "entry" is
decidable against the form these artifacts actually carry: a single line beginning `**Story:**`,
then one or more paths, **each wrapped in backticks**, separated by `, `. Trailing prose after
the last path is allowed and contributes nothing — several headers carry a reminder to read the
profile fresh, and a reminder is not a citation. So a header citing several stories carries several entries,
one path each. Exact duplicate paths are one member; entries naming different stories are
different members; and a header that does not parse as that line is malformed and stops,
reporting that as the cause rather than as a disagreement. **Before each pass the deriving agent
compares every such set, and again before a clean pass is accepted as the cycle's final pass.**
A header or profile that changed during that pass means the pass is not final — the same
answer a change gets at every other read point. Where they name different sets the premise of a single value has
failed: **stop and surface the disagreement** rather than deriving from either, exactly as an
unresolvable profile stops rather than defaulting.

**The derived floor is the pass count a cycle owes, and the hook's ratio is a reminder
threshold that controls nothing.** The hook still counts passes, and it still can't read
findings or tell the spec run from the plan run (it resets at `writing-plans`), so
Gate A — the spec run especially — is instruction-backed: a satisfied count is not a
clean review, and a below-threshold reminder is noted in the pass report and disregarded
where the cycle's own closure rules are satisfied. This replaces the pass-count number
and nothing else. Every other rule stated here about how a cycle closes stands as
written, and none of them is restated — a summary is where their conditions would get
dropped. Nothing here writes the floor knob: it stays the user's, never written, never
removed, never read for this derivation. Open a TodoWrite "Codex pass N" per pass; fix Blocker/Major after each. Your
final pass must be clean — if the pass at the floor still finds Blocker/Major, keep going until
clean or clearly stuck → then STOP and surface to the user. The only early exit
below the floor is a pass with **zero** findings; don't manufacture findings to pad. Codex is
advisory — validate before applying; dismissed finding → one-line why.

**Named residual:** the hook's messages state its own threshold as an obligation, so at a
floor of 1 they report a shortfall the cycle does not owe. Hook text is out of scope here
by decision; what makes that tolerable is the precedence rule above plus the hook exiting
0 on every branch, not the reminder being harmless.

**The gate-off surface — routes known today, not a complete list**, since an enumeration
read as complete guarantees the routes it omits. One route is created here: a stated floor
the cited set does not license, which could not exist before there was a derived floor to
state. Pre-existing and unchanged: omitting a higher-risk cited story; minting or editing a
profile to level 0; presenting an incomplete cited set; falsifying evidence entries;
silencing reminders; or not running a pass and reporting that it ran. A user-set floor is
not the lever — it moves what the hook says, not what the cycle owes.
None of this is a guard: the floor is produced by the agent and nothing checks it against
the cited profiles.

**When these rules bind.** From the commit that ships them, and a cycle already running
finishes under the rules it started with. Where a cycle's starting rules cannot be
established it takes the stricter reading of every part this change touches — at minimum
floor 3, severity classified without the demotion, the provenance-line duty owed, the curve
duty owed, and the nonce duties at their strictest — the cycle is treated as post-rule, so it
owes a nonce, owes its provenance line and its curve or skip record, and uses that nonce in every
cycle record it does write — which changes what a record is named, never whether one is owed, so
the working record stays optional and a skipped cycle still writes no findings slots. Where it
cannot recover a nonce it starts a new cycle rather than claiming `none (pre-rule)`, that reserved
field being unavailable to a cycle whose start cannot be established. Each further rule this change ships adds its own strict
reading to this list. Not a re-derivation, which could hand a level-0
cycle a floor of 1 and skip passes on the strength of not knowing when it started. A user
knob set above 3 is not lowered by this fallback. A revert is itself a shipping commit for
the old rules, and the activation rule wins wherever the start is determinable; the
fallback covers only where it is not.

**Downstream has no shipping commit.** Adoption binds from the `/workflow-init` run that
actually writes the text — which may write nothing, be declined, or be merged in part —
so these rules bind only over the text a project's `CLAUDE.md` actually contains, and a
partial adoption can persist undetected. A project taking the floor rule without the
severity test gets a floor whose docs-only question the severity test is what settles.
**A partial adoption can leave a project's floor undefined or self-contradictory.** The rule
is a coherence requirement, stated semantically rather than as a list of spellings, and it
runs in **both** directions: **exactly one definition of the floor must be present, and every
statement that defines or constrains the floor, or makes closing depend on it, must resolve to
that one definition.** **The unknown-start fallback is not a second definition**: it is
explicitly conditional on a cycle's starting rules being undeterminable and governs only that
state, so it coexists with the predicate rather than competing with it. Everything else
likewise keeps its own footing and is **not** required to derive from the floor: **the other closure and stop predicates** — assigned-fix-set membership, a new
structural question, an accepted Blocker or Major, the tell thresholds; **independent reporting
and diagnostic ordinals**, such as a duty owed from a given pass onward; and **the hook's
reminder threshold together with any descriptive or historical pass number**, which say what a
tool reports or what once happened rather than what a cycle owes. Four states break it, and the list is **not exhaustive**: a fixed-number or
specific-pass obligation surviving beside the derived predicate; a claim or dependency on a
derived floor with no predicate to define it; **no definition at all**; and **two definitions
at once**. A
merge can produce any of them: the Gate-A loop description, the pass-1 closure rule and the
re-review rationale each carry a fixed-three claim and can be taken or left independently of
the predicate itself. In any such state nothing here resolves which rule governs: **stop, and
have a human complete or revert the adoption, before running a gate under it.** What prompt text can do about downstream
adoption is limited, and that limit is what this paragraph states.

**What a loop absorbs, and what stops it — a question of scope, not of action.** A finding
that corrects the correction you just made **and stays inside the assigned fix set** is
**inside this loop's scope**: keep it here rather than handing it back, then act on it by its
severity exactly as the severity rule already says — Blocker/Major resolve, Minor/Nit collect
and never iterate. Ancestry decides where a finding belongs; it never decides what you do
with it, and it grants no Minor or Nit a repair round it would not otherwise get. **The assigned fix set is fixed before the pass you are answering: it is the
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
overrides correction ancestry, because absorbing on ancestry is how a contract decision
gets made without anyone choosing it. Stopping this way is **not an exit from the gate**: the floor, the
Blocker/Major filter and the clean-final-pass rule all stand, and the loop resumes on the
revised artifact once the question is answered. What it prevents is a loop committing you
to a design nobody chose — a different failure from an unfinished review.

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
the only exception, exactly as above; a Blocker/Major-free pass below the floor
carrying a Minor keeps
looping.
**Surfacing does not close the cycle, and that is what makes this reachable.** You surface
*with the finding still open* — the resolve rule is not waived, no pass is credited as
clean, and the loop resumes on whatever the user decides. Reading it as "stop instead of
fixing" would put the exit in competition with the rule that every Blocker and Major
resolves, and then nothing could satisfy both.

**Every pass report states three things about the floor**, from pass 1 onward: the
derived floor, the risk and security values read, and the cited stories they were read
from. A report giving the number alone leaves a reader unable to check the derivation
while passes are still being spent — which is the only time checking it is cheap. Where
no story is cited, or a cited story is unprofiled, the report says so in place of axis
values; a multi-story set names each story and its values. This is owed by every pass;
the three lines below are owed from pass 4 and are a different obligation.

**From pass 4 onward every pass report carries three lines.** The carrier is **your own
status report to the user** — never the Codex reply, which stays exactly one line per branch,
and never the findings file, which admits no line that is not a finding or the terminator.
They are cheap because the numbers already exist: (1) the **trend** — findings and Blocker counts across the passes so
far; (2) where this pass's findings **cluster** — product behaviour, the test instrument, or
prose about either; (3) any **require↔withdraw pair** against earlier passes, meaning a pass
demanding what an earlier pass had removed.

Those three lines expose **five tells**: the finding count rising rather than falling; the
Blocker count failing to fall; findings clustering on the **instrument** rather than on
product behaviour; findings clustering on **prose about** either; and a require↔withdraw
pair. **Any two present makes stop-and-surface mandatory, not discretionary** — report the
tells and hand the decision to the user, and the "clearly stuck" reading above is not a
precondition for it. A loop can be worth stopping long before it plateaus.
**The two rules above do not compete**, and neither overrides the other: the absorb rule
decides whether *a finding* is inside this loop's scope, this reading decides whether *the
loop* can still converge. A small correction-of-a-correction that stays inside the assigned fix
set is absorbed and is not by itself evidence of a plateau. Measured once, at the precision the record keeps: nineteen Gate-A
passes over successive revisions of one design spec past 2800 lines (the exact size is not
part of that evidence), findings from 43 into a 2–19 range after pass 6 and never zero,
Blockers from 11 to 0–1 from pass 7 on, and the late Blockers were semantic contradictions
rather than wording — which is why a low count is a signal to read and not a clearance.
Hence the sizing guidance: prefer **smaller specs with named interfaces** and let the plan
carry the detail — guidance, not a threshold, because where the plateau starts is
unmeasured.

**Findings go to a FILE, not the response — both gates.** Long finding lists come back
cut off, and a cut that lands between findings is indistinguishable from a short list:
silently dropped findings, the dangerous direction. Claude Code both limits MCP tool
output (25,000 tokens by default, `MAX_MCP_OUTPUT_TOKENS`) and persists over-threshold
results to disk behind a file reference; the protocol below is correct under either,
because the response stops carrying the findings at all. Append to the gate prompt:

> Pass the reviewed repo root as `workingDirectory`. Write the FULL findings list to
> `.context/codex-reviews/<slot>.md` (create the directory if needed; the path is
> relative to that root — Codex resolves writes against its working directory, so
> without this a valid file can land in a different checkout). `<slot>` is
> `gate-a-spec-pass-<p>`, `gate-a-plan-pass-<p>`, or `gate-b-<spec|quality>-pass-<p>` for a
> cycle with no nonce; a cycle that has one writes `gate-a-spec-<nonce>-pass-<p>`,
> `gate-a-plan-<nonce>-pass-<p>` or `gate-b-<spec|quality>-<nonce>-pass-<p>` instead, and uses
> the nonce in every slot more than one cycle could write. The bare names are reserved for the
> legacy single-cycle case they already serve. **Distinct-nonce paths coexist by construction and
> are never in conflict** — a sibling cycle's slot is simply a different file.
>
> **The rule binds the deletion step, which is where the damage is done.** This section already
> requires every target to be deleted and confirmed gone before a call. A cycle holding a nonce
> **deletes only paths carrying its own nonce**; it never deletes a bare path or one carrying a
> different nonce, and an attempt to do either **stops and names the path** instead of removing
> it. That is reachable and observable: the step operates on a path it computed, and the check is
> whether that path is the cycle's own. **The case it exists for is a nonce-holding cycle
> computing a bare path** — the legacy spelling — **and deleting a file that belongs to somebody
> else**, which is exactly what happened once. **Two cycles that drew the same nonce compute the
> same paths and are indistinguishable to this rule**; what makes that unlikely is the width of
> the draw, not this rule — this section already stops on a
> target that survives deletion, and this extends that to a target that must not be deleted at
> all. That rule exists because a bare slot was in fact overwritten once, destroying a previous
> cycle's findings file.
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

**The cycle nonce.** Both shipped records below carry a **cycle field**, because a record that
cannot be attributed to a cycle cannot be told apart from another cycle's when several are read
together. That is a limitation rather than a disqualification — a human reading one cycle's
records knows which cycle they came from; what attribution buys is that a *later* reader
**usually** does not have to. Usually, not always: the guarantee is probabilistic, for the two
reasons stated at the end of this block. This section defines three **kinds** of cycle — the Gate-A spec loop, the Gate-A
plan loop and the Gate-B cycle — and **one cycle field is produced per cycle run, not per
kind**: a change carrying several plans runs a Gate-A plan cycle for each, and each of those is
its own cycle with its own nonce.

Generated once at cycle start, immutable, and collision-resistant operationally: **8 to 16
characters drawn uniformly from `[a-z0-9]`, from a source of randomness** — 8 being where
collision resistance starts and 16 where the field stops being a usable infix. **Never derived
from a name, a timestamp or a commit**, each of which collides exactly where sibling cycles do,
which is the one thing the nonce exists to prevent. The character set keeps it safe as a slot
infix and a path component.

**It appears in every record the cycle writes** — which keeps records apart **as far as distinct
nonces allow**, and no further — **and that set is named rather than left open**:
the provenance line, the per-pass curve (including a skip record standing in for one), the
cycle's findings slots, and its advisory working record. **The working record is a cycle record
too**: a cycle holding a nonce names it `gate-a-spec-<nonce>-resume.md`,
`gate-a-plan-<nonce>-resume.md` or `gate-b-<nonce>-resume.md`, and the bare names above stay
reserved for the legacy single-cycle case, exactly as the findings slots do. **Because recovery
scopes candidates by artifact as well as by kind, the record's contents name that artifact**, and
what counts as the artifact depends on the cycle kind: for a Gate-A cycle it is the reviewed
document's path, quoted by the same rule the provenance line uses where quoting is needed; for a
Gate-B cycle, which reviews a diff rather than a file, it is the **base commit's full
40-character hex object name**, the same value the cycle's reviews are run against. The filename
carries kind and nonce; the artifact key lives inside, where neither a path nor a hex name has to
survive a filename. The nonce is not
required in records this change neither introduces nor keys to a cycle — the evidence entry and
a human-exception record among them.

**A nonce is a candidate for recovery only if** it is keyed to this cycle's kind — Gate-A spec,
Gate-A plan, or Gate B — **and** this cycle's artifact, **and** that cycle is still open. **Those
three are necessary and not sufficient, and the difference matters**: two Gate-A cycles can review
the same document and two Gate-B cycles commonly share a base commit, so a sole match on kind and
artifact is **not** identity. **A candidate is adopted only if it is positively linked to this
run** — the working record this run itself wrote. A match that is merely consistent is treated as
no identity, and the cycle starts fresh; adopting a sibling on a shared key would merge two
cycles under one nonce, which is the failure this rule exists to prevent.
History normally holds many closed cycles' nonces and they are not candidates; a working record
left by a closed cycle is not one either, which is why that record is **retired at closure**
rather than left to be found later. **Recovery has two sources, and they answer different questions.** The **working record** is the
source while the cycle runs, and it is the one the candidate rules above apply to — several files
may be present and the run must decide which, if any, is its own. **History is the source once
the cycle's own commit exists**, and there is no search there: the cycle is reading **its own
commit body**, so kind and artifact are settled by which commit is being read, and the nonce is
taken from the provenance line and the curve, which must agree. A Gate-A cycle mid-run has no
such commit and therefore has only the working record. Recovering a single candidate from
**either** keeps identity **as far as the field can distinguish cycles** — two cycles sharing a
nonce are one cycle to it. **No candidate,
disagreeing sources, or more than one candidate → no identity: start a new cycle**, which costs
passes rather than letting one cycle's records read as another's — again, as far as distinct
nonces allow. **Starting a new cycle does
not close, adopt or retire the cycles those candidates belong to** — they stay open, keep their
own nonces, and are a human's to resolve; the new cycle simply does not claim them.

**A cycle does not start without a valid nonce, unique among the cycles open when it was
generated.** That is the requirement. **What the check can establish is narrower** — it compares
against the cycles it can observe — and the gap between the two is the residual set out below.
Where generation fails, make **at most three attempts in total**, then stop and
surface, **naming which of the three causes occurred**; each has its own check and its own fix,
and one token would name a symptom rather than a cause:

The three are distinguished by **where** the attempt stopped, so they cannot both apply: the
source failed to produce bytes; or it produced bytes that are not a well-formed nonce; or it
produced a well-formed nonce that is already in use. An empty result is the first, never the
second.

- **randomness unavailable** — the source errors or produces no bytes. *Fix:* retry, since the
  condition can be transient; if it persists across the attempts, make a source available or run
  where one is, which is a change to the environment rather than another draw.
- **an invalid value** — the drawn value is not 8 to 16 characters from `[a-z0-9]`. *Fix:*
  redraw. Repeated invalid output points at the generator rather than at luck, and the report
  says which.
- **a collision with a known-open cycle** — the value equals a nonce on a cycle still open.
  *Fix:* redraw. A second collision at this width is possible but unlikely enough to be worth
  reporting as a possible source defect, which the report states as a suspicion rather than a
  finding.

**Report every distinct cause observed across the attempts, in the order they occurred** — the
attempts can fail for different reasons, and naming only the last would describe the tail of the
sequence rather than what happened.

**No deterministic fallback.**

**Residuals, disclosed rather than guarded, and this list is not exhaustive.** The check compares
against cycles *known to be open*, so a nonce can repeat one belonging to a cycle nobody can see;
two cycles starting at the same moment can each check before either has published, so neither
observes the other; and the check deliberately ignores **closed** cycles, so a new cycle can
redraw a closed one's value and then write to its surviving findings slots and working record.
**What makes both unlikely is the width of the draw, not the check** — and unlikely is the
honest word. Neither is a guard.

**What follows from that, said here rather than left to be discovered.** The nonce is
collision-**resistant**, not collision-**proof**, so everything built on it inherits that bound:
two cycles sharing a nonce write to the same slots and are not refused, their records read as
one cycle's, and a later reader cannot separate them. Attribution is therefore a strong default
rather than a guarantee, and any reading of these records that would be wrong if two cycles
shared a field should say so rather than assume they did not.

**A cycle that began before these rules shipped has no nonce and cannot acquire one.** Its
records carry the reserved `cycle none (pre-rule)` field and are, by construction, not
cycle-attributable. That exception is bounded and self-terminating: it reaches only cycles
already running when the rules land, and no later cycle can enter the state.


**Accept a pass only when** the file exists and is readable; its last line is exactly
`END OF FINDINGS (<n> total)`; it contains exactly `<n>` finding lines *and nothing
else* (or the single line `NO FINDINGS` when `<n>` is 0 — "n valid lines somewhere in
the file" would accept a truncated file padded with fragments); and, for a `full` Gate-B
pass, both branch files satisfy all of that. Anything else — missing, unreadable or
empty file, wrong path, malformed terminator, count mismatch, extra lines, one branch
file, an `INCOMPLETE` reply — is an **INCOMPLETE pass**, which is not a review: don't
act on the partial list, don't count it toward the floor, and don't read "no
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
throwing or setting `isError`. A failed review therefore still looks like a successful
*tool call* — but as of 0.8.0 the hook reads the result of gate calls it can route, and
withholds the count for three **recognized** shapes: an envelope whose **first** property
is `success: false`, the harness backgrounding notice **in the wording it currently
uses**, and a result from which no usable text can be obtained. Every other routed gate
call counts, including any located text the hook cannot interpret — a reordered envelope,
a reworded notice, an unknown third-party shape — which counts **with** a disclosure that
is attempted and normally shown once per workspace, but can be lost or repeated when its
marker cannot be persisted. So does a call that returns and then fails validation. The
counter is therefore closer to the truth than it was and is still not evidence: a
"satisfied" count can still overstate the passes you actually hold, and reasoning about
which failure took which event path will get it wrong. The rule that follows is the
simple one: **discount every incomplete pass regardless of what the counter says**,
because classification cannot see whether the findings file was written.
Nothing checks the terminator mechanically; this is
instruction-backed by design, and a recurring truncation incident is the trigger to build
the checker, not a reason to build it now. Detection is conditional: it catches an absent
or malformed terminator, a count mismatch and a missing branch file *in the artifact you
actually read*; it does not catch a model that writes a wrong count with a matching
number of lines, nor a stale file if you skip the delete.

**Why `.context/codex-reviews/`:** the hook excludes `.context/` from all three of its
fingerprint components, so review artifacts cannot invalidate the review they document.
Add `/.context/codex-reviews/` to `.gitignore` — that entry specifically, not all of
`.context/`, which would strip the committed `codex-gate.on` adoption marker.

- **Gate A — Spec, then plan (TWO runs, each its own loop at the derived floor).** Run on the
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
  findings silently. Ask for one line per finding and a literal `NO FINDINGS`
  when a pass is clean — the explicit clean signal is what lets you exit the loop:

  ```
  MAJOR | high | §3 "Retry policy" | retry count unbounded | a poisoned job loops forever | cap at 5, then dead-letter
  NO FINDINGS
  ```

  Each pass: validate, revise, re-run. Before each read pass, settle mechanically what the
  artifact asserts and a machine can decide without side effects — cited paths, quoted
  passages, stated counts, the syntax of standalone fenced blocks — because a read pass
  spends expensive judgement on what a parser settles in seconds and misses it anyway,
  inspecting quoted commands rather than running them, since a command quoted in a spec
  may be destructive or an intentional failure. (Large/high-risk artifact: optional focused
  per-dimension passes on top.)
- **Gate B — Code.** Tests green, before `git commit`. Tool: `mcp__codex__review`
  (args `instruction`, `whatWasImplemented`, `baseSha`; `reviewType: full` runs
  spec + quality in parallel). Skip ONLY trivial changes. Check against
  @AGENTS.md. Re-review after every fix — a fix changes the artifact, so the prior
  review no longer covers it. The hook merely notices, at commit time.

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

  **Standing lens, every Gate-B call: "which existing statements does this diff falsify?"**
  A change makes sentences wrong in files it never touches. Checks scoped to the edited
  paths — a parity diff, a resync, a grep of your own edits — do not look there, because
  the file was correct until your change landed elsewhere. This lens is prompt text: it
  asks, nothing enforces the ask or validates the answer, and no comprehensive check
  covers arbitrary semantic drift. Ask anyway; in practice it is what surfaces them.
  **Name what this diff changes the size, value or position of** — a list, a count, a
  version, an identifier, a cited line — and grep for where each is described elsewhere,
  because asked as an open question alone this lens missed three such statements in one
  cycle while being carried with unusual force.

  **What counts as prose (the only Gate-B exemption).** Every staged path is
  explanatory documentation — `docs/**.md`, `README.md` → N/A. Those describe the
  product rather than being it, so they carry no gate at all. **Prompts are not
  prose:** `CLAUDE.md`/`AGENTS.md`, and anything under a `.claude/`, `plugins/`,
  `skills/` or `commands/` directory **at any depth**, are product even though they
  are `.md` — all fire full Gate B, as does any mixed commit or any non-`.md` file.
  Agent definitions are covered by that list, not listed separately: they live in
  `.claude/agents/` or `plugins/*/agents/`, both already matched. A bare top-level
  `agents/` is not matched, so do not add one and assume the gate sees it.
  The hook classifies paths the same way. Those directory names match at any depth
  deliberately, so a root-level `skills/` and a monorepo's `packages/*/.claude/` are
  both covered; the cost is that prose under a same-named directory
  (`docs/commands/reference.md`) fires too — a redundant reminder, never a missed
  review.

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

Lenses are **different questions, not more passes** — they change what a pass asks, never
how many a cycle owes. The Blocker/Major filter, the file-first findings protocol and the
clean-final-pass rule are unchanged. The floor is not among them: it is no longer a fixed
number but derives from the profile and the cited set.

**Reading the profile — five cases, five answers:**
0. **The ordinary case**: every cited story is readable and its profile resolves → derive the
   floor from it and run. Stated first because a partition of failures alone is not a
   partition, and an earlier revision of this list omitted it.
1. The artifact **cites no story** → run unprofiled and **say so** in the pass. Artifacts
   predating this rule are the common case; stopping on them would halt in-flight work.
2. The cited story has **no profile line** → same: today's behaviour.
3. The cited path **does not yield a readable story file** → **stop and surface which of
   these it was**, because each has a different fix: the path does not exist (a typo, or a
   file moved or deleted); it exists but is not a regular file, a directory being the common
   case; it is a symlink that does not resolve; or it exists and is a regular file but cannot
   be read for permissions. **Report what you observed; no test order is prescribed here**,
   because the obvious one is wrong — an ordinary existence or regular-file test follows a
   symlink, so a dangling link reads as absent rather than as a broken link.
   This case exists because none of the answers above is available to an agent that never
   obtained the file: it can establish neither that a profile is absent nor that one is
   present but unresolvable.
4. The story **is readable** and a profile is **present but unresolvable** → **stop and
   surface the cause**. That covers the syntactic failures — unparseable line, a value
   outside the enums, two profile blocks — **and the semantic ones**: a `**Validation:**`
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
records the reason and the battery result, because it owes no mode-derived entry and keeps
exactly today's judgement-based skip. **Neither is excused the records every cycle owes** —
the provenance line, and a skip record in place of the curve.

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
the observation that would exist if the claim were false, and confirm the wiring could have
produced it** — a check that supplies its own input, runs where the defect cannot appear, or
uses a fixture that never reaches the branch it covers reports success because of how it was
wired, not because the thing it checks succeeded.

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

**While a gate is running, the floor derives from the current profile at each pass.**
Passes already run keep counting; closing requires the floor as currently derived. These
are pass-count rules, so they apply while a gate is running and are silent otherwise —
what governs when a gate runs is unchanged and deliberately not summarised here.

**Any profile change costs at least one further pass**, in either direction and whether or
not the floor number moves, because the final clean pass must run under the current
profile — so no already-banked pass can be it. That further pass must itself be clean and
every other closure duty must be satisfied; it is one more pass, not a licence to close on
the next one. What a lowering drops is whatever the changed values drop, not a fixed pair:
a mode-only override changes the evidence obligations while leaving the axis-derived lens
sets alone, and security `high` → `standard` keeps the security lens set while changing
what evidence is owed. Every derived obligation is recomputed from the current profile.

**The cited set is re-read at each pass, and the final clean pass runs against the current
set** — whenever its membership changes, not only when the floor number moves. Adding a
high-risk story to a set already at floor 3 leaves the number alone while adding that
story's lens set, its evidence obligations and its review scope; a pass run before it
joined did not cover them. Removing a story recomputes obligations from the current set
and so does remove that story's lenses and evidence duty — but it never discharges an
accepted in-set Blocker or Major: the acceptance put that finding in the fix set, not the
citation.

**What this does not do:** nothing checks which file a model actually read, whether the
header changed mid-call, or whether the lens sets were appended. This is instruction-backed
like the rest of §5; the detection is a reader comparing the pass against the story.

### Mechanics (reference)
- **Severity:** Blocker (wrong/unsafe/breaks invariant) · Major (design flaw →
  rework) → both must resolve. Minor · Nit → collect, never iterate.

  **Deciding severity — one procedure. The subject list is illustration, not a second
  rule.** Name what in the system consumes this text — whatever *acts* on it — and the
  decision that act takes differently if the text is wrong. Both are required. If you
  cannot name both, the finding is Minor or below: collect, never iterate.

  The exclusions are contract, not commentary. The reader must consume the text in the
  system's *operation*, not in reviewing it — the review pass raising the finding is not
  an in-system reader of the text it reviews; without this the test demotes nothing.
  Gates remain legitimate readers of rule text they will later apply. A human reader never
  satisfies the test — the prose exemption already prices that cost as non-gating. The
  list of reader kinds is illustrative, not closed, because this ships into projects whose
  readers we have never seen. The test sets a ceiling, not a floor, and never chooses
  between Blocker and Major — the four definitions above still decide that. The instrument
  carve-out is symmetric: an instrument finding keeps its severity whenever it shows the
  instrument changes what a gate concludes about product behaviour — a false green, and
  equally a false red or a check blocking a valid change. Rationale prose is Minor only
  when no rule's application depends on it, not categorically: `docs/prompt-standards.md`
  requires rules to carry their why, so rationale a reader must consult to apply a rule
  passes the test. This removes arbitrariness, not judgement. Coverage-first is unchanged
  — the reviewer reports every finding with severity and confidence; the filter is ours.

  This is the finding-level analog of the path-level prose exemption: one principle at two
  granularities — text that *describes* the product versus text that *is* the product.

  **How this demotion bears on the loop-health measures — the per-pass counts, the finding
  clusters and the stop thresholds — is not settled here, and this change does not settle it.
  Until it is, a pass whose outcome would turn on that question reports the question and
  stops rather than deciding it** — the same answer any unresolved gate question gets.
- **Tool routing:** docs (spec/plan, incl. code snippets) → `mcp__codex__exec`;
  implemented diff → `mcp__codex__review`. Never `review` a doc — it reads the
  git range, not the text.
- **`baseSha`:** against main = merge-base with main (`headSha` = the full 40-character
  object name `HEAD` resolves to at that moment, never the symbolic `HEAD` — see the
  branch-agreement rule below for why);
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

  **Every cycle records one provenance line in its closing commit body** — default floor or
  not, so an absent line is never ambiguous between "the default applied" and "someone forgot".
  **One line per cycle**, so a change running five cycles records five. There is no informal
  variant; anything quoting this form elsewhere quotes an instance of it, because the deferred
  metrics work is intended to parse it — that consumer does not exist yet, and the form is pinned
  now so that it can.

  <CYCLE-FIELD>; floor <N> per <STORY-SET>; hook reminder threshold <KNOB>

  <CYCLE-FIELD> := "cycle " <NONCE> | "cycle none (pre-rule)"
  <NONCE>     := [a-z0-9]{8,16}
  <N>         := [1-9][0-9]*
  <STORY-SET> := "none" | "{" <ENTRY> ("," <ENTRY>)* "}"
                                            each <PATH> appears at most once; a repeated path,
                                            with or without conflicting levels, is malformed
  <ENTRY>     := <PATH> " (level " ("0"|"1"|"2") ")" | <PATH> " (unprofiled)"
  <PATH>      := <bare> | <quoted>
  <bare>      := [A-Za-z0-9._/-]+           contains no delimiter, quote or whitespace
  <quoted>    := a double-quoted string, non-empty, whose only escapes are \" and \\ ;
                                            a path containing a newline or other control
                                            character is NOT representable — the cycle stops
                                            and surfaces rather than emitting one
  <KNOB>      := "absent" | [1-9][0-9]* | "unusable"

  A filled instance, so the form is shown and not only described:

  cycle none (pre-rule); floor 3 per {docs/superpowers/stories/2026-08-28-review-loop-economics-pass-floor-story.md (level 2)}; hook reminder threshold absent

  It carries that cycle's **cycle field** — the nonce for any cycle started after these rules
  ship, `none (pre-rule)` only for one that began before them — the **derived floor**, and **the
  cited set that produced it**, each member with its level as a numeral. One floor and one set,
  not an entry per story, since unanimity makes the floor a property of the set. It
  distinguishes **a cited story with no profile** from **no story cited**. It records the
  **workspace knob whenever the file exists**: the value if the observer read one, otherwise
  `unusable`. **Nothing here describes what the hook does with that file, and the record does not
  say why a value was unusable** — four successive attempts to state either were each wrong in a
  different way, the last of them demonstrably so, and the rule for a claim needing a fourth
  correction is to delete it. Whoever needs to know why reads the file and the hook.

  **These records are one contract, and a partial adoption breaks it.** The nonce, the slot
  naming, the provenance line, the curve, this carry rule **and the unknown-start activation
  semantics that say what a cycle owes when its starting rules cannot be established** depend on
  one another, and the requirement is that the adopted definitions **agree**, not merely that all
  of them are present: a curve
  without a cycle field cannot be attributed, a slot rule without a nonce has nothing to key on,
  and a carry rule naming records a project does not produce is inert. **A project whose text
  carries some of them and not others, or carries all of them in versions that disagree, stops
  and has a human complete, revert or reconcile the adoption before running a gate under it** —
  disagreement is the harder case and gets the same stop, because a project holding two
  definitions of a record has no single answer to what it owes — the same answer, and for the same reason, as a partial
  adoption of the floor rule.

  **On squash-merge, copy every evidence entry, every human-exception record, the provenance lines, the curves and any skipped cycle's skip record TOGETHER WITH THE SKIP REASON IT POINTS AT in the squash range into the squash body — a skip record carried without its reason is a pointer into a body the squash has made unreachable — the squash commit is the only body the merge carries into `main`'s history, so anything left behind is unreachable from it.**

  **Every cycle records its own per-pass curve in its own commit body.** Gate B alone would
  leave the dominant cost unrecorded — the loops this rule was built from are Gate-A loops.

  <CYCLE-FIELD>; <CYCLE> (passes <SPEC>, <MODELS>): Findings <COUNTS>. Blockers <COUNTS>. Majors <COUNTS>.

  <CYCLE>    := "Gate-A spec" | "Gate-A plan" | "Gate B"
  <SPEC>     := <RANGE> ("," <RANGE>)*      strictly ascending, non-overlapping
  <RANGE>    := <p> | <p> "-" <p>
  <p>        := [1-9][0-9]*
  <COUNTS>   := <n> ("," <n>)*              exactly as many entries as <SPEC> enumerates
  <n>        := 0 | [1-9][0-9]* | "?"      "?" = the count is unrecoverable for that pass
  <MODELS>   := <model> | <PER-PASS> ("; " <PER-PASS>)*
  <PER-PASS> := "pass " <p> " " <model> ("+" <model>)*
  <model>    := <bare-model> | <quoted-model> | "undetermined"
                                            "undetermined" means the model could not be determined;
                                            a real model so named is written as <quoted-model>
  <bare-model> := [!-~]{1,} minus ; : , ( ) + " and space, and not the
                                            literal "undetermined", which is reserved
                                            printable ASCII only; a control character makes the
                                            identifier unrepresentable, handled below
  <quoted-model> := a non-empty double-quoted string, same two escapes as <quoted>;
                                            an identifier that cannot be determined, or cannot be
                                            represented, is written `undetermined`, and the raw
                                            value is NOT reproduced anywhere in the body, since a
                                            commit message cannot safely carry one (NUL cannot
                                            appear at all). The record does not say why a pass
                                            reached `undetermined`, and nothing here describes how
                                            a model identifier fails — same rule, same reason as
                                            the knob above

  Two filled instances, one ordinary and one with a split logical pass:

  cycle none (pre-rule); Gate B (passes 1-3, codex): Findings 16,29,4. Blockers 4,15,0. Majors 5,2,1.
  cycle 7b2q9xk4; Gate-A spec (passes 1,2, pass 1 codex+claude; pass 2 codex): Findings 5,0. Blockers 1,0. Majors 2,0.

  A skipped cycle writes `<CYCLE-FIELD>; <CYCLE>: skipped (see skip reason)` and no counts. **The skip
  reason it points at is the text immediately following it in the same commit body** —
  adjacency is the link. The cycle field is not: every pre-rule cycle writes
  `cycle none (pre-rule)`, so it identifies nothing when a body carries more than one.
  **`<PER-PASS>` keys must be exactly the passes `<SPEC>` expands to, each once, ascending** — a
  list that omits or repeats a pass is malformed, not partially informative — and **every model
  contributing to a split logical pass is listed**, joined by `+`, since recording one of two is
  the same loss as recording none.

  **Majors are recorded as well as Findings and Blockers**, because the severity rule moves the
  Blocker/Major line rather than the total, so totals and Blockers alone could not show even a
  change in the mix. **Subject categories are deliberately not recorded** — they are a judgement
  per finding rather than a count, and the findings files carry the material.

  **One entry per valid pass**, and since incomplete passes are excluded while still consuming
  pass numbers, the record **states which pass numbers it covers**. A valid zero-finding pass is
  recorded as zero, never omitted. **A count that cannot be recovered is written `?`, never
  guessed and never written as `0`** — a cycle keeps its identity through the nonce rather than
  through its pass files, as far as distinct nonces allow, so a resumed cycle may know a pass happened and not what it found, and
  zero and unknown are different facts. **`?` is per series**: a pass whose Findings are unknown
  may still have usable Blocker and Major counts, and a reader excludes the unknown value from
  the comparisons that read that series while keeping the pass's other series.

  A `full` Gate-B pass, separate `spec`/`quality` calls, and a single-branch recovery are
  **branches of one logical pass** contributing one summed entry — **the curve counts logical
  passes; the hook counts calls**, and where they differ the body says so **as prose beside the
  curve**: neither grammar has a field for a call count, deliberately, since the count is a
  property of how the pass was invoked rather than of what it found. **Both branches must be
  issued against the same commit**, and that — not what they read — is what this rule
  establishes. The result reports no reviewed revision, so there is nothing to read back and no
  way to confirm from the reply what either branch actually looked at. What is available is the
  request: **resolve `HEAD` to its full 40-character object name before each call and pass that
  explicit value as `headSha`**, never the symbolic `HEAD`, which two calls can resolve
  differently if a `WIP:` amend lands between them. Keep the value you passed **with that
  branch's result**, and require the two kept values — **`baseSha` and `headSha` both**, since a
  range is selected by both ends and two calls can share a head over different bases — to be
  **exactly equal** before summing the branches. Equal values mean the two calls were aimed at one commit; they are not evidence that
  either branch reviewed it, and nothing available here would be. Record it as the **full 40-character hex object name**, since abbreviations are
  ambiguous across repositories and across time; if it changed between them they are not one
  pass, the completed branch is recorded as incomplete and excluded, and the later branch begins
  a new one. Ending the pass is the conservative direction; merging two revisions would produce
  one entry describing two different artifacts.

  **What the curve is worth, stated rather than implied.** Durable **across** cycles; **not
  within** a running one, since the commit does not exist until the cycle closes. And
  **author-written and unchecked** — nothing compares it against the validated pass files, so
  whatever reads it reads a self-reported curve and must not present it as measurement.

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

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

Project architecture, stack-specific patterns, and invariants live in @AGENTS.md
(single source of truth — also read directly by Codex and the PR review bots). The
Cross-Model Review gates (§5) check against the invariants there.
````

### 2.2 `docs/hardening-log.md` — the empty ledger

Write it **empty** (header only, no rows). The header defines the format; the rows
are this project's own history and start at zero.

````markdown
# Hardening log

Append-only ledger of review findings hardened via the `dev-workflow:harden-finding`
skill. One row per hardening (rung 0 "already caught" is not logged). `fingerprint`
is a canonical class — from the base taxonomy in the `harden-finding` skill, or from
this project's `docs/hardening-taxonomy.md`; column 2 is the recurrence-grep target.
Never edit a row; resolve a `pending` row by appending a new row (same fingerprint,
`ref` naming the prior row's date + anchor).

A row records a hardening claim as of its date, and its narration may be found wrong or
made stale later. When a row's text no longer describes reality — falsified by a
later change, or wrong when it was written — append a `Superseded rows` entry rather
than editing it. One later change is **excluded**: a hardening that is itself removed,
for which this convention supplies no move at all (see the end of this paragraph). This
holds for every row without exception: the existing `Never edit a row` rule is
absolute, and correcting a row is always an append. The rule is bound to rows, not to
commits: once text exists as a row it is never edited, committed or not. Drafting
before a row exists — an editor buffer, a line not yet written — is below the
rule's resolution, and nothing checks one. Resolving a `pending` row also appends —
that is a new hardening, not a correction to a row's text. Supersession marks a row's
**text** and never alters mechanical behaviour, including when the entry records that
the row's hardening claim was itself false: the row keeps its fingerprint, keeps
matching the column-2 grep, and keeps counting. A hardening later removed is out of
scope.

**Correcting a row.** Corrections live in a `Superseded rows` block above the
`Columns:` paragraph — a `**Superseded rows:**` label carrying one appended line per
supersession, present only once at least one entry exists:

    - <date> · supersedes <row date> `<fingerprint>` "<row fragment>" · what is false · where the current answer is

`<date>` is the day the entry is written, in `YYYY-MM-DD`. A row is located by date +
fingerprint. **An entry applies to every row its locator matches** — uniqueness is
not a requirement, and an entry that matches two rows says the same thing about both.
To narrow the match, add `"<row fragment>"`, a quoted fragment of that row's `finding`
carrying no double quote, in the position shown immediately after the fingerprint. **A
fragment narrows the match set; it singles out one row only where that row has one no
sibling shares** — a sibling being another row the same date and fingerprint match.
Where it has none — an identical `finding`, one that is a substring of a sibling's,
or one whose every unique fragment carries a double quote — the entry marks every
matching row, its accurate siblings included, and no fragment prevents that. Omit it,
quotes included, when you mean every row the pair matches — including when the pair
matches only one. Name the claim that does not hold — saying whether it stopped
holding or was never true — and cite where the current answer lives; restating that
answer here only makes the entry the next stale narration. Neither of those two fields
may contain ` · `: that separator is what divides them, and free text carrying it
makes an entry parse two ways. A fragment is matched **literally and case-sensitively
against the row's `finding` as written in the file**, escapes and markup included —
what you quote is what is in the table, not what a renderer shows you. **An entry
applies only to matching rows dated on or before the entry's own date** —
supersession marks the past, so a row dated later never comes under an entry written
before it. **A row's date is the day it is appended**, and the table is chronological:
backdating a row is forbidden, which is what makes the date bound mean what it says.
Nothing can verify the append day itself, and nothing checks that dates never decrease;
the rule is stated and read. An entry whose locator matches no such row is **inert**:
it governs nothing and is not an error to repair in place — append a new entry with a
locator that matches, and leave the inert one standing as history, like every other
entry. **An entry marks a row, and the last entry for a row is the one that governs**
— where a row carries more than one, later in the file wins and the earlier ones are
history. **A later entry must therefore describe the row as it now stands, not only the
newly found fault**, or it retires a still-accurate earlier entry from a reader's view.
Entries are never edited, never removed, and never reference one another — and they
take the same floor as rows: once a line exists as a complete entry it is protected,
committed or not, while a line that is partial or does not yet carry the shape above is
still drafting and may be fixed. A mistyped locator in a complete entry is corrected
the same way everything else is, by appending. If a union merge leaves two `Superseded
rows:` labels, keep one and keep every entry under it. No standing tool reads this
block — to every grep and skill scanning the table a superseded row is unchanged,
including one whose entry says its fingerprint is wrong; prose readers get the
correction, mechanical readers do not, and nothing checks the difference.

Columns: `date` (YYYY-MM-DD), `fingerprint` (canonical class), `finding` (short,
escape `\|`, one line), `source` (gate-a|gate-b|bot|manual),
`severity` (blocker|major|minor|nit), `rung` (e.g. `2 lint`, `4 test`, `1 prose`,
`P std`, `pending`), `ref` (rule name / test path / AGENTS.md section / prior row).

| date | fingerprint | finding | source | severity | rung | ref |
|------|-------------|---------|--------|----------|------|-----|
````

### 2.3 `docs/hardening-taxonomy.md` — this project's fingerprint classes

Also written **empty of classes**. The `harden-finding` skill ships the stack-neutral
base classes and reads this file for the project's own — so the shared plugin never
carries one project's domain vocabulary.

````markdown
# Hardening taxonomy — <project>

Project-specific fingerprint classes, extending the stack-neutral **base taxonomy**
in the `dev-workflow:harden-finding` skill. The skill reads both on every fingerprint
step; the base classes are not repeated here.

A class belongs here (not in the base list) when it names *this* project's entities,
frameworks, or invariants — e.g. a class about a specific table, a specific auth
helper, or a specific framework's API.

**Before minting:** grep the base list and this one for a near match. A slightly
imprecise class you reuse beats a precise class nobody greps for — recurrence
detection is the entire value, and it only works when the same defect maps to the
same string twice.

**Format:** kebab-case `domain-problem-class`, one line, with an alias hint naming
the synonyms a future reader might search for instead.

## Classes

<!-- Add classes as harden-finding mints them, e.g.:
- `orders-missing-idempotency-key` — a retryable order write accepted without an idempotency key
-->

_None yet — `dev-workflow:harden-finding` adds them as findings arrive._
````

### 2.4 `docs/prompt-standards.md` — the prompt checklist

The "Verified model-specific notes" block below carries a **read-date**, and the
notes under it are only as true as that date. Do not copy the date across: ask the
user whether they have re-read those pages for the models *they* run. If not, write
`read <YYYY-MM-DD> — NOT YET VERIFIED for this project's target models` and carry it
into the closing checklist. An inherited date presented as fresh is exactly the
failure this line exists to prevent.

````markdown
# Prompt Standards

Skills, gate prompts (CLAUDE.md §5), hook messages, slash commands, agent definitions
(`.claude/agents/` or `plugins/*/agents/`, if this project has any), and spec/plan
templates are prompts. When authoring or changing one, it must pass the checklist below —
Gate A reviews prompt specs against these criteria via AGENTS.md.

**Ad-hoc task briefs are prompts too.** A brief handed to the coding agent for a single
task steers the same model with the same failure modes as anything above. Briefs are held
to this checklist **in spirit** — success criteria, stop conditions, verified claims —
but nobody reviews a brief against all 12 items, which is exactly why those habits have
to live in how briefs are written rather than in a review step.

Living references (consult, don't copy — copies go stale):

- Anthropic prompting best practices: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
- Model-specific pages (pick the target model's page): https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview
- OpenAI/Codex prompting guide — applies to the Codex gate prompts (Gate A/B
  run on an OpenAI model, not Claude): https://learn.chatgpt.com/docs/prompting
  (Codex-specific workflows are a section of that page.)

## Checklist (each item must be verifiably true)

1. **Target model named.** The prompt states which model executes it (Claude
   via Claude Code, or Codex via `mcp__codex__*`), and the author checked that
   model's current prompting page. Why: recommendations differ per model and
   change between generations.
2. **Success criteria explicit.** The prompt defines what "done" looks like in
   checkable terms (e.g. "typecheck exit 0", "story has ≥3 acceptance criteria"),
   never "make it good". Why: strong criteria let agents loop independently
   (CLAUDE.md §4).
3. **Stop conditions defined.** When to stop, escalate, or ask the user —
   especially for looping/agentic prompts. Why: prevents runaway loops and
   silent scope drift.
4. **Output format specified with an example.** Expected structure shown, not
   described. Why: examples constrain format better than prose.
5. **Structured sections.** Context → task → rules → output format, separated
   by headings or XML tags. Why: models parse delimited structure more
   reliably than flowing prose.
6. **Rules carry their why.** Each constraint states its reason in one clause.
   Why: models follow motivated rules better, and reviewers can judge whether
   the rule still applies.
7. **No contradictions with CLAUDE.md / AGENTS.md.** New prompt text must not
   conflict with existing instructions; if it supersedes one, update the old
   text in the same change. Why: contradictory instructions degrade
   compliance unpredictably.
8. **Token-lean.** No duplicated content from AGENTS.md/CLAUDE.md (reference
   instead), no boilerplate. Why: context budget is shared with the actual
   task.
9. **Positive instructions.** Say what to do, not what to avoid ("write
   flowing prose" instead of "don't use markdown"). Why: per Anthropic's best
   practices, positive framing steers current models more reliably. The
   CLAUDE.md §1–3 discipline rules are a deliberate exception: their subject *is*
   the prohibition ("no speculative abstractions", "don't refactor what isn't
   broken"), and restating a prohibition positively loses the boundary it draws —
   new prompts need a stated reason to do the same.
10. **Diagnostic states name their causes.** A prompt that reports a failure state
    ("NOT LOADED", "MISSING", "unavailable") enumerates the distinct causes that
    produce that state, gives a check that tells them apart, and pairs each with its
    own fix. Why: causes with an identical symptom but different fixes are the case
    the reader cannot resolve alone — offering only the most common one sends them
    round a loop that never terminates.
11. **Enforcement claims name their mechanism.** Any sentence saying something is
    enforced, caught, guaranteed or prevented names *what does it*, and the author
    verified that mechanism exists before writing it — by reading the code, running the
    command, or checking the doc it relies on. Why: an unverified guarantee is worse
    than an admitted gap, because a reader stops looking. When the mechanism turns out
    not to exist, say what actually happens instead ("this is a rule the agent keeps;
    nothing counts for it").

    **Where the reader can reach the authoritative source, cite it instead of restating
    it** — a classifier, a policy section, a config. Every restatement is a copy that can
    drift and a fresh chance to overclaim. This does not apply to text that must be
    self-contained (a scaffolded template cannot point at a file the reader does not
    have); there, restate and keep the copies in sync deliberately. **And when a claim
    about a mechanism has needed a fourth correction, delete the claim rather than refine
    it again** — successive corrections tend to be subtler versions of the same
    overclaim.
12. **Calibrated emphasis.** Reserve MUST/CRITICAL/ALL-CAPS for genuinely hard
    rules; default to plain wording ("Use X when …"). Why: current models follow
    instructions more literally and overtrigger on aggressive language
    (documented in the best-practices page). Existing heavy emphasis (e.g.
    CLAUDE.md §5 gate language) is a deliberate exception for discipline
    gates — new prompts need a stated reason to use it.

## Verified model-specific notes (read <YYYY-MM-DD> — re-verify per Revalidation)

Distilled from the model-specific pages; the linked pages are authoritative.

- **Less scaffolding on stronger models.** Skills/prompts written for prior
  models are often too prescriptive and degrade output quality on newer ones.
  On a model upgrade, test with instructions *removed* before adding more.
- **Review prompts: coverage first, filter later.** "Only report high-severity"
  makes current models silently drop real findings. The finding stage must ask for
  every issue with confidence + severity; ranking/filtering is a separate step.
  Gate B's Blocker/Major filter is downstream — the finding prompt itself must
  request full coverage.
- **Ground progress claims.** In long runs, instruct: audit each claim against
  a tool result before reporting; unverified work is reported as unverified.
  Belongs in executing/TDD prompts.
- **Fresh-context verifier subagents outperform self-critique** — independent
  confirmation of the cross-model gate design.
- **Never instruct "show your reasoning in the response".** Triggers a
  reasoning-extraction refusal on some current models; read structured thinking
  output instead.
- **Literal instruction following.** Current models don't generalize scope on
  their own — state it ("apply to every section, not just the first").

## Escalation

Recurring prompt-quality findings follow the same ladder as code findings
(CLAUDE.md): prose note → checklist item here → template change. Prompts are
artifacts; `harden-finding` treats them like code. Run the
`dev-workflow:harden-finding` skill to apply a rung and record it in
`docs/hardening-log.md`.

## Revalidation

On a model generation change (new Claude model in Claude Code, new Codex
model for the gates): re-check this doc against the then-current
model-specific pages, and update the read-date above. Tracked with the tooling
revalidation entry in `todos.md`.
````

### 2.5 `docs/pr-review-bots.md` — which bot actually finds things

The `/dev-workflow:process-pr-review` command reads this. Fill the table with the
user — ask which bots are enabled and, for each, **where its findings appear**: inline
review comments, the PR summary body, or both. Do not guess, and do not assume the
answer is stable: a bot can post a summary on one PR and inline comments on the next,
so a column may honestly read `inconsistent`. Record what was observed and when.

````markdown
# PR review bots — <project>

Which automated reviewers run on this repo, and what each one *actually produces*.
`/dev-workflow:process-pr-review` routes on the **Wait for** list below — that list is
authoritative. The table is descriptive: it records where each bot's findings have been
seen, which may be `inconsistent`.

Getting this wrong is expensive in both directions: waiting on a bot that never posts
in the channel you are watching hangs the loop, and treating a channel as context
silently drops real findings.

| Bot | Enabled | Where findings appear | Notes (plan/tier limits, completion signal, quirks) |
|---|---|---|---|
| <bot name> | yes/no | inline / summary / both / **inconsistent** | <where observed and when; how you know it has finished — a status check is not guaranteed> |

**Routing — these lists are authoritative.** Ask the user; do not derive these from
column 3, which records where findings appear rather than how to act on them.

- **Wait for (block on it):** <bots with a completion signal you can block on — usually
  a status check. Blocking on a *post* hangs when the bot finds nothing and posts
  nothing.>
- **Process opportunistically (never block):** <bots that produce real findings but give
  no reliable completion signal. Read what they have posted when the pass begins, both
  channels; handle later arrivals as a follow-up. This category exists because such bots
  are real: blocking on one hangs the loop, dropping it loses findings.>
- **Ignore:** <bots you deliberately do not act on — e.g. one that only reports it is
  disabled. Not "the summary-only bots": a summary can carry real findings.>

**Revisit when:** a bot's plan/tier changes (a Free→Pro upgrade can turn a
summary-only bot into a findings bot), or a bot is enabled/disabled.
````

### 2.6 `.gitattributes` — union merge for the ledger

**Merge, don't rewrite.** If the `docs/hardening-log.md` line is already present,
report `unchanged`. Otherwise append:

```gitattributes
# docs/hardening-log.md is an append-only ledger. Parallel worktrees may each
# append a row; a union merge keeps both lines instead of conflicting, so no
# hardening record is lost when branches merge.
docs/hardening-log.md merge=union
```

Do **not** add union merge for structured files (baselines, JSON, lockfiles) — a
union merge silently interleaves both sides into invalid state. Real changes to those
must conflict visibly so a human resolves them.

### 2.7 `todos.md` — skeleton

````markdown
# Todos — <project>

Backlog of stories, follow-ups, and prerequisites referenced by
`docs/hardening-log.md` (`pending` rows point here by `ref`).

## Now

## Next

## Someday

## Tooling revalidation
- [ ] Re-check `docs/prompt-standards.md` against the current model-specific
      prompting pages on every model-generation change (new Claude model in Claude
      Code, new Codex model for the gates).
````

### 2.8 `.mcp.json` — the Codex reviewer

**Merge, don't rewrite.** Add only the `codex` server if absent; leave any other
server untouched.

```json
{
  "mcpServers": {
    "codex": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "mcp-codex-dev@1.0.1"],
      "env": {},
      "timeout": 2400000
    }
  }
}
```

Two properties are load-bearing, so state both to the user rather than letting them
look like arbitrary numbers:
- The version is **pinned**. An unpinned `npx -y <pkg>` executes latest-on-npm at
  launch, which bypasses any dependency-freshness policy. Pin it, and check the
  current version rather than trusting `1.0.1` to still be right.
- `timeout` is explicit. The default MCP tool-call timeout is very long, so a hung
  Codex call otherwise blocks until the user notices and aborts by hand.

### 2.9 Codex CLI config — a **manual** step, printed not written

Codex reads `~/.codex/config.toml` — the user's home directory, not this repo. Do not
write outside the project. Print this for the user to add, and list it in the closing
checklist:

```toml
# ~/.codex/config.toml — gives the Codex reviewer the same MCP servers you use.
# TODO(stack): one [mcp_servers.<name>] block per server Codex should reach
# (your database/backend MCP, docs MCP, …). Example shape:
[mcp_servers.<name>]
command = "npx"
# Pin the package exactly — a bare `<pkg>` resolves to whatever is newest at run
# time, so the reviewer's own toolchain would drift between runs. Bump deliberately.
args = ["<pkg>@<exact-version>", "mcp", "start"]
```

### 2.10 CI — the enforced gate

Write `.github/workflows/quality.yml` (or the equivalent for the detected CI
provider; if it isn't GitHub Actions, print the template and say you did not write
it). The **battery steps are stack-specific and stay marked** — a CI file that runs a
command the project doesn't have is worse than one that admits the gap.

````yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

concurrency:
  # PR events share a per-PR group so new pushes supersede stale runs; non-PR
  # events (push to main) get a unique per-run group so no pending main run is
  # ever replaced or canceled.
  group: ci-${{ github.event_name == 'pull_request' && github.event.pull_request.number || github.run_id }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}

permissions:
  contents: read

jobs:
  quality:
    # Pin the runner to an OS release, not `ubuntu-latest`, and every action to a
    # commit SHA with a version comment: a major-only `@v4` moves under you, and a
    # moving CI dependency makes the run irreproducible. Bump deliberately, and when
    # you do, verify rather than trust the comment:
    #   gh api repos/<owner>/<repo>/commits/<tag> --jq .sha        # tag -> SHA
    #   gh api repos/<owner>/<repo>/releases/tags/<tag> --jq .published_at
    # The second one matters: a release published hours ago has had no time to be
    # found wanting, which is the same reason a package manager has a minimum
    # release age. The SHAs below were checked this way.
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0 # v7.0.0
        with:
          # checkout writes the job token into .git/config by default, where any
          # later step — or anything a step runs — can read it. Drop it unless a
          # later step genuinely needs authenticated git (a tag push, a release
          # commit); then set this true on that job alone, not everywhere.
          persist-credentials: false

      # TODO(stack): toolchain setup for this project's language + package manager.
      # Install from a FROZEN LOCKFILE — a resolving install can silently pull new
      # code into CI and makes the run non-reproducible.
      # (Node/pnpm example — SHAs are real and verified; re-check them when you
      # uncomment, since this template ages between releases:)
      # - uses: pnpm/action-setup@0ebf47130e4866e96fce0953f49152a61190b271 # v6.0.9 — reads packageManager from package.json
      # - uses: actions/setup-node@820762786026740c76f36085b0efc47a31fe5020 # v7.0.0
      #   with:
      #     node-version-file: package.json   # reads engines.node
      #     cache: pnpm
      # - run: pnpm install --frozen-lockfile

      # TODO(stack): ONE quality command chaining the whole battery, so there is a
      # single thing CI runs and a single thing a human runs. It must be the same
      # command named in AGENTS.md § Commands. A typical battery:
      #   strict typecheck · linter at zero warnings · dead-code check ·
      #   duplication/health check against a baseline · tests across their environments
      # - run: <quality command>

      # TODO(stack): build, if the project has one.
      # - run: <build command>

      # Red until the battery above is actually wired. A workflow whose steps are
      # all commented-out TODOs passes while verifying nothing — and a green check
      # is exactly what someone reads as "the gate is working". Failing loudly is
      # the honest direction; delete this step once the TODO(stack) blocks are real
      # commands.
      - name: Refuse to be a green no-op
        run: |
          if grep -q 'TODO(stack)' .github/workflows/quality.yml; then
            echo "::error::quality.yml still has TODO(stack) markers — the battery is not wired."
            echo "This check fails on purpose: it verifies nothing yet, so it must not report green."
            echo "Wire the toolchain + quality command (see AGENTS.md § Commands), then delete this step."
            exit 1
          fi
````

After the workflow lands **and the battery actually runs green once**, the last mile
is a **repo setting**, not a file: make the `quality` check **required** in branch
protection. Order matters — requiring the check while it is still a no-op protects
nothing and buys false confidence. Until it is required the gate is a convention;
after, the platform enforces it. This is in the closing checklist.

### 2.11 Dependency-freshness policy

Only if the project uses pnpm — append to `pnpm-workspace.yaml` (merge; don't touch
existing keys):

```yaml
# Supply-chain policy: packages must be ≥24h old at install time (guards
# against fresh malicious releases). Applies to every machine/CI, not just
# a local pnpm config. Exceptions: add the package to minimumReleaseAgeExclude
# with a justification comment — never relax the global value ad hoc.
minimumReleaseAge: 1440
```

If the project does **not** use pnpm, do not fake it. Say so, and put the equivalent
in the closing checklist as an open item: this ecosystem's way to (a) pin tool
versions from one source of truth, (b) install from a frozen lockfile, and (c) delay
brand-new releases.

### 2.12 `.context/codex-gate.on` — the adoption marker

Write an empty `.context/codex-gate.on`. The gate hook is installed globally but the
workflow is adopted per project, so the hook stays **silent** in any repo that shows no
adoption — otherwise it would STOP commits in every unrelated project on the machine,
citing a `CLAUDE.md §5` that exists nowhere.

The hook accepts either signal: the §5 gate heading in `CLAUDE.md`, or this marker. §5
alone would do for a standard scaffold; write the marker anyway, because it is the one
that survives a project keeping its gate rules somewhere other than `CLAUDE.md`, and it
states the adoption instead of inferring it from a heading someone may reword.

**Commit it.** `CLAUDE.md` is committed, so a clone is adopted the moment it lands;
leaving the marker untracked would make adoption depend on who ran this command. (The
hook excludes `.context/` from all three of its fingerprint components, so a committed
marker does not disturb Gate B.)

Say in the report that this is what makes the hook speak in this project, and that
deleting it plus the §5 heading is the way to make it stop.

### 2.13 Degraded mode — only when Codex is unavailable

If the preflight found Codex in state 1 or 2, **ask** whether the user wants to set it
up now. If they do, stop and let them; the gates are most of the point. If they say
not now, do not scaffold a workflow that lies about itself — a project with mandatory
gate instructions that cannot run, plus a Gate-B STOP on every single commit forever,
is noise that trains the user to ignore the hook, and a hook people ignore is worse
than no hook. Instead, degrade explicitly:

1. Write `.context/codex-gate.off` so the hook stays silent (it keeps classifying and
   tracking state, so re-enabling later lands on counters carrying the same semantics
   as gate-on — never evidence that a review happened).
2. Add one line at the very top of §5 in the scaffolded `CLAUDE.md`:

   ```markdown
   > **INACTIVE — Codex not configured; the gates below do not run.** Re-enable: set up
   > Codex (closing checklist item 5), then delete `.context/codex-gate.off`.
   ```

3. Make it the **top item** of the closing checklist, not a footnote.

**Do not offer a same-model fallback reviewer.** Cross-model independence is the whole
mechanism — a model reviewing its own work reproduces its own blind spots and returns a
clean review that means nothing, so being explicitly gateless is honest while being
implicitly self-reviewed is a false ✓, which is the exact failure this workflow exists
to prevent.

## Step 3 — Walk the user through `AGENTS.md`

`AGENTS.md` is the one file that **cannot** be scaffolded from a template: it is the
project's invariants, and both review gates plus the PR bots check against it. A
generic AGENTS.md is worse than none — it makes "check this against our invariants"
read as satisfied when nothing was actually checked.

So: **interview the user, write what they answer, and write nothing they didn't.**
Ask in small batches (2–4 questions), showing the section you'd write from their
answers before moving on. Where they don't know yet, write
`TODO — not yet decided` rather than a plausible guess, and carry it into the closing
checklist.

Cover, in this order:

1. **What the project is** — one paragraph: domain, users, what it does. Enough that
   a reviewer with no context can judge whether a change fits.
2. **Architecture** — the components, the boundaries between them, and the direction
   dependencies are allowed to point.
3. **Key invariants** — the heart of the file, and what Gate A/B check. These are the
   non-negotiables: every rule whose violation is a bug regardless of what the ticket
   said. Push for *specific and checkable*, not aspirational. Prompt them with the
   classes that most often belong here:
   - **Auth / authz:** what must every entry point do before touching data? Name the
     actual barrier function.
   - **Multi-tenancy:** what scopes a query — a workspace, an org, an account id?
   - **Data access:** required indexes, forbidden full scans, soft-delete semantics.
   - **Validation:** are inputs *and* outputs schema-validated at the boundary?
   - **Errors:** which error type is thrown, what may reach the client.
   - **Concurrency:** optimistic locking, idempotency keys, ordering guarantees.
   For each one they give: write the rule, and write *why* in one clause. A rule with
   its reason survives a reviewer asking "is this still true?"; a bare rule doesn't.
4. **Don'ts** — the forbidden patterns, including the dependency-freshness policy
   from §2.11 and anything the team has already been burned by.
5. **`## Commands`** — the concrete commands, because `harden-finding`,
   `process-pr-review` and the quality gate all resolve their generic "the project's
   lint/typecheck/test/quality command" against this section:

   ````markdown
   ## Commands

   | Role | Command |
   |---|---|
   | quality (the whole battery — what CI runs) | `<cmd>` |
   | typecheck | `<cmd>` |
   | lint | `<cmd>` |
   | test | `<cmd>` |
   | build | `<cmd>` |
   ````

   Only fill a row with a command you have **actually run in this session** and seen
   exit cleanly. An unverified command here silently breaks three other prompts. Run
   each one; if it fails or doesn't exist yet, write `TODO` and carry it to the
   checklist.

End Step 3 by showing the complete `AGENTS.md` and getting the user's explicit
approval before writing it — same rule as everywhere else: they see the bytes that
land.

## Step 4 — Print the closing checklist

Everything below is deliberately **not** scaffolded, because getting it wrong quietly
is worse than not having it. Print it as the last thing, tailored to what Step 1
detected and what Steps 2–3 left as TODO:

```
Remaining — stack-specific, yours to decide:

0. GATES INACTIVE — include this item FIRST, and only if degraded mode (2.13) was
   applied. Codex is not configured, so Gate A and Gate B do not run and the hook
   is silenced via .context/codex-gate.off. CLAUDE.md §5 is marked INACTIVE. This
   project currently has NO independent review gate — the cross-model check is the
   core of the workflow, so treat this as the top priority, not a nice-to-have.
   Re-enable: do item 5, then delete .context/codex-gate.off.

1. Quality battery — pick the tools behind each role and wire them into ONE
   command, then put that command in AGENTS.md § Commands and in the CI
   TODO(stack) block:
     · strict typecheck        · linter, zero warnings tolerated
     · dead-code detection     · duplication/health check
     · tests, across every environment they need
   Each tool: add it only when you have run it and seen it catch something real.
   A config line should record a verified necessity, not a hypothesis.

2. Fresh baselines — any tool that compares against a baseline (duplication,
   coverage) needs its FIRST baseline generated from this repo, in its own
   commit. Never bundle a re-baseline with feature work: a baseline that drifts
   inside a feature commit stops being a record of a decision.

3. Custom lint rules — the plugin ships two as EXAMPLES ONLY
   (examples/eslint-rules/: auth-before-db, returns-validator). They encode one
   stack's invariants and will not transfer. Read them for the shape — how an
   invariant from AGENTS.md becomes a mechanical rule — and write your own when
   harden-finding escalates a finding to rung 2.

4. Branch protection — make the CI `quality` check REQUIRED, but only AFTER the
   battery in item 1 is wired and has run green once. The scaffolded workflow
   fails on purpose while its TODO(stack) markers remain, so it cannot report a
   green check that verifies nothing. Requiring a no-op check protects nothing
   and buys false confidence; requiring a real one is the single highest-value
   item on this list.

5. Codex — the reviewer behind BOTH gates. Three parts, all required:
     · the Codex CLI, installed and authenticated (it needs an OpenAI account);
     · the codex MCP server in .mcp.json (Step 2.8 writes it, pinned), exposing
       mcp__codex__exec + mcp__codex__review — check the tool NAMES, since another
       Codex MCP can occupy the same server name with a different tool surface;
     · the ~/.codex/config.toml block printed above (home directory; not written
       by this command), giving Codex the MCP servers it should reach.
   Without all three, both gates are inoperative.

6. Superpowers — BLOCKER if the preflight reported it missing. The workflow's
   entire middle (spec -> plan -> execute) is superpowers:brainstorming /
   writing-plans / executing-plans. Without it, intake hands off to a skill that
   does not exist, and the hook's Gate-A counter never fires -- so Gate A looks
   enforced while enforcing nothing. It is an external prerequisite, not a
   dependency this plugin can vendor:
     claude plugin marketplace add obra/superpowers-marketplace
     claude plugin install superpowers@superpowers-marketplace
   (Omit this item entirely if the preflight found it.)

7. Prompt standards — set the "Verified model-specific notes (read …)" date in
   docs/prompt-standards.md by actually re-reading the model pages for the models
   you run. It is the one date in this kit that must not be inherited.
```

Then stop. Do not start using the workflow in the same turn — the user should read
what landed first.

## Report format

Close with the prerequisite block (Step 1) and the per-file table (Rule 5), then the
checklist — and nothing else:

```
Prerequisites:
  git repository        ok
  superpowers plugin    ok
  codex MCP             ok (pinned mcp-codex-dev@1.0.1)
  gh CLI                ok (optional)
  AGENTS.md             absent — written in Step 3
  stack                 pnpm · TypeScript · vitest · GitHub Actions

Scaffolded:
  CLAUDE.md                        written
  AGENTS.md                        written (3 TODOs — see checklist)
  docs/hardening-log.md            written (empty ledger)
  docs/hardening-taxonomy.md       written (no classes yet)
  docs/prompt-standards.md         written
  docs/pr-review-bots.md           written
  todos.md                         written
  .gitattributes                   merged (union-merge line added)
  .mcp.json                        merged (codex server added)
  .github/workflows/quality.yml    written (2 TODO(stack) blocks)
  pnpm-workspace.yaml              skipped (not a pnpm project — see checklist item 1)
```
