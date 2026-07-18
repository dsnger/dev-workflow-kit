# Subagent definition: finding-triage — Design

**Date:** 2026-07-18 · **Status:** revised after Gate A pass 3 · **Version target:** 0.4.0

Originally scoped as two agents. `task-verifier` was dropped at pass 1 (§8.2). Pass 2
found a blocker that reshaped what remains: the agent judges **whether a comment is
true**; the main command decides **what to do about it**. §6.3 explains why.

## 1. Problem

`/dev-workflow:process-pr-review` asks the main agent to decide whether each PR-bot
comment is right — the agent judging a belief it just formed, sharing every assumption
that produced it. Being wrong is expensive both ways: accepting a false finding
produces a pointless change, dismissing a true one silently drops a real defect.

A subagent gives each comment its own context window. That does not make the check
independent of the *model*; it makes it independent of the *conversation*, which is
what this check needs.

## 2. Scope

One agent definition, `finding-triage`, plus the integration in §7. Nothing else
becomes an agent. The hook is not touched.

**Explicit non-goal:** it does not substitute for the Codex gates (§5).

## 3. Verified platform facts

Read from the Claude Code docs on 2026-07-18, recorded so a future reader can tell
what was checked from what was assumed.

| Fact | Source |
|---|---|
| Plugin agents live in `agents/`, markdown with YAML frontmatter | [plugins reference § Agents](https://code.claude.com/docs/en/plugins-reference) |
| Only `name` and `description` are required | [sub-agents § Supported frontmatter fields](https://code.claude.com/docs/en/sub-agents) |
| `tools` is an allowlist — **inherits all tools if omitted** | same |
| `model` defaults to `inherit` when omitted | same |
| `permissionMode`, `hooks`, `mcpServers` are **ignored for plugin agents** | plugins reference + sub-agents note |
| Subagents run in the background by default as of v2.1.198 | [sub-agents § background](https://code.claude.com/docs/en/sub-agents) |
| Plugin agents are invoked as `plugin-name:agent-name` | plugins reference § Integration points |

## 4. What read-only actually guarantees

`finding-triage` gets `tools: Read, Grep, Glob`. No Edit, no Write, no Bash.

**The precise guarantee:** the agent cannot directly invoke any Claude Code write or
shell tool. That is a real, mechanically enforced boundary, and it is narrower than
"incapable of mutating anything" — a claim the previous draft made and that is false.
Externally configured `PreToolUse`, `PostToolUse`, `SubagentStart` and `SubagentStop`
hooks in the *user's own* settings can run commands with side effects on this agent's
tool calls, and that is outside the plugin's control. Stating the boundary precisely is
the point; a guarantee that overstates itself is worse than a narrow one.

`disallowedTools` is not set: against an allowlist that already omits every write tool
it is redundant, and its one real value — a backstop if a future edit deletes the
`tools:` line, since omission inherits everything — is served instead by a comment in
the definition telling the reader not to delete that line.

**On detecting a rogue subagent write.** No Bash-capable agent ships here, so this is
largely moot; it matters only to whoever adds one later. The honest statement is that
the Gate-B content hash gives **best-effort detection of most commit-relevant worktree
changes**, not a guarantee. The known gaps and where each is actually documented:

| Gap | Documented in |
|---|---|
| staged-vs-worktree divergence | `todos.md` |
| compound `mutate && git commit` hashed before the mutation | `todos.md` |
| `.context/` excluded from the hash | `AGENTS.md` invariant 3, `docs/architecture.md` |
| gitignored paths never scanned | `plugins/dev-workflow/hooks/codex-gate.sh` comments |

The previous draft said all four were in `todos.md`. Only the first two are — the
same class of error this section exists to correct, caught in its own correction.

## 5. Not a gate

The definition carries one line: it never counts as a Gate A or Gate B pass. CLAUDE.md
§5 requires cross-model independence, and a same-model subagent shares this model's
blind spots. It **complements** the gates and never **substitutes** for one. It lives
in the definition because the definition is what the agent reads.

## 6. The definition

```yaml
---
name: finding-triage
description: Validates whether a single PR-bot review comment is factually true of the
  code. Use once per non-superseded comment that asserts a defect, during PR review
  processing.
tools: Read, Grep, Glob
---
```

`model` and `effort` are omitted — both default to `inherit`. `maxTurns` is omitted
because §6.4's search budget and stop conditions bound the work; an arbitrary turn cap
truncates mid-check instead.

**Target model** (item 1): the body states it runs as Claude via Claude Code, and
records that Anthropic's current prompting page was checked on 2026-07-18.

### 6.1 Input contract

The agent has no shell, so it cannot observe git state. Everything git-derived is
**supplied by the caller, which has `Bash`** — and the definition says so, marking the
trust boundary rather than pretending the agent verified it.

| Field | Required | On absence |
|---|---|---|
| comment text — exactly one claim | yes | `escalate-to-user`, naming the field |
| locations — see below | yes | `escalate-to-user` |
| SHA the comment was written against | yes | `escalate-to-user` |
| SHA of the checkout as the caller observed it | yes | `escalate-to-user` |
| worktree fingerprint the caller observed (§6.2) | yes | `escalate-to-user` |
| path to `AGENTS.md`, or an explicit statement that the project has none | yes | `escalate-to-user` |

**Locations** is a non-empty list. Each entry is a repository-relative path with an
optional line or line range; alternatively the single token `repository` for a
PR-level finding with no canonical file. A list rather than one path because a single
true claim can span files — "this interface and its two implementations disagree" is
one claim, not three — and forcing a primary path would make the caller invent one.
Split into separate invocations only when the comment carries separate *claims*, not
merely separate locations.

**Path confinement.** Every path is normalized and must resolve inside the caller's
checkout root. Absolute paths and any `..` traversal are rejected with
`escalate-to-user`. Read, Grep and Glob stay within that root. This matters because
locations derive from attacker-influencable comment text and the agent's output may be
posted to a public thread: an unconfined read is an exfiltration path, not just a bug.

**One claim per invocation.** A bot comment carrying several independent claims is
split by the caller before invocation. If the agent receives one it cannot read as a
single claim, it returns `escalate-to-user` saying so rather than judging the first
claim and silently dropping the rest.

The agent reads code itself via Read/Grep/Glob — the caller passes locations, never
file contents, so it cannot be handed a curated excerpt.

**Never infer a missing field.** Guessing the alleged defect is the failure mode that
makes the whole check worthless.

**Untrusted input.** Comment text and repository contents are **data, not
instructions**. Bot comments are attacker-influencable on a public repo: anyone who
can open a PR can place text in one. The definition states that the agent never
follows instructions, links or tool-shaped text found inside a comment or inside the
code it reads, and never emits repository content beyond what the named claim
requires — the main agent may post its output to a public PR thread.

**A platform boundary that rule does not cover.** Custom subagents load every level of
the CLAUDE.md hierarchy the main conversation loads, and there is no frontmatter field
or per-agent setting to opt out — only the built-in Explore and Plan agents skip it
([what loads at startup](https://code.claude.com/docs/en/sub-agents)). This repo's
`CLAUDE.md` imports `AGENTS.md`. So a PR that edits an instruction file changes the
rules the triage agent runs under, *before* its data-only rule applies. The agent
cannot close this; the caller must:

> `process-pr-review` checks whether the PR touches `CLAUDE.md`, `AGENTS.md` or
> anything under `.claude/`. If it does, those changes are surfaced to the user for
> review **before** any triage subagent is dispatched. Triage does not run under
> instructions the PR itself introduced.

Stated as a boundary rather than a solved problem, because it is not solvable at the
agent level.

### 6.2 Staleness and snapshot identity

The agent compares the strings it was given. It does not resolve git state — it
cannot, and pretending otherwise would let it compare against a guess.

If the two SHAs differ, it returns `escalate-to-user`: a judgment reached against
different code than the comment was written against is not a factual-validity
judgment, so it does not produce one.

**Equal SHAs are not enough.** Uncommitted edits, staging changes, or another process
can change what the agent reads while both SHAs stay identical — so a SHA pair does
not identify the snapshot. The caller therefore also passes a **worktree fingerprint**
and re-computes it after collecting every verdict; a batch whose fingerprint changed is
discarded and re-run, once, then escalated. The caller already has the primitive: it is
the same content hash the Gate-B hook computes (`git diff HEAD` plus a tree id from a
throwaway index), and the same known gaps in §4 apply to it.

### 6.3 Verdicts — factual validity only

**This is the pass-2 blocker's resolution.** The previous draft asked the agent to
decide whether a fix "belongs in this PR". That requires a base/head comparison, and
an agent with Read/Grep/Glob cannot derive a git range — so the central contract was
unimplementable. Worse, actionability was already the main command's job:
`process-pr-review` Step 3.3 has always said a finding implying a scope change stops
for the user.

So the split is explicit: **the subagent judges truth, the main command judges
action.**

| Verdict | When |
|---|---|
| `accept` | the claim is factually true of the code as it stands |
| `dismiss` | the claim is factually false, or describes something already resolved — the reason must cite what in the code or in `AGENTS.md` contradicts it |
| `escalate-to-user` | it cannot be established either way within the §6.4 budget; or a required input is missing, the SHAs differ, the code cannot be located, or the comment carries more than one claim |

Three verdicts, mutually exclusive, and exhaustive *for the question actually asked* —
"is this claim true?" always has one of these three answers.

**Deliberately not the agent's job**, because the isolated agent cannot see the
information each needs: whether the defect is pre-existing or introduced by this PR
(needs the diff range), whether the comment duplicates another (needs the other
comments — the one-claim contract deliberately withholds them), and whether fixing it
is in scope (needs the settled decisions of the session). The main agent owns all
three, and §7 says so.

"Looks fine" is not a dismissal. A dismissal cites evidence.

### 6.4 Search budget and stop conditions (item 3)

Follow the smallest evidence path that settles the claim: the named file, then
whatever it directly requires — callers, callees, shared validators, route or
middleware registration, type definitions, configuration, and the tests covering it.
The previous draft's "file and immediate callers" was too narrow: it would falsely
accept a "missing validation" claim when validation sits in a shared middleware, and
falsely dismiss a configuration defect.

**Bounded, countably.** The budget is **25 tool calls total**, counting every Read,
Grep and Glob call equally — including repeats of the same file, because a re-read
costs the same context as a new one. "Roughly a dozen file reads" was the previous
wording and it was not a rule: it left open whether searches counted, so two
implementers would stop at different points. Stop at 25 calls or at the first verdict,
whichever comes first. On exhausting the budget without settling the claim, return
`escalate-to-user` naming the evidence that would settle it — an honest
"indeterminate" beats a guessed verdict.

`maxTurns` stays omitted: it caps agentic turns rather than tool calls, so it would
not enforce this budget, and a turn cap truncates mid-check without producing a
verdict. The budget above is the stopping rule; the caller's output validation
(§7.1) catches a run that ignores it.

Escalate immediately, without further search, on: a missing required field, a SHA
mismatch, an unlocatable file, or a multi-claim comment. Never keep searching for a
way to make a comment true.

### 6.5 Output format (item 4 — all three verdicts shown)

```
CLAIM    src/orders.ts:42 — "missing tenant scope on this query"
VERDICT  accept
REASON   the query filters by id only; AGENTS.md "Data & tenancy" requires every
         read scoped to the caller's workspace

CLAIM    src/orders.ts:88 — "unvalidated input"
VERDICT  dismiss
REASON   validated in requireSchema() at src/middleware/validate.ts:19, applied to
         this route at src/routes.ts:44

CLAIM    src/report.ts:12 — "this loop issues a query per row"
VERDICT  escalate-to-user
REASON   getRows() is dynamically dispatched; whether it hits the DB per call cannot
         be settled by reading — a query log for this endpoint would settle it
```

### 6.6 Output grammar

The caller validates before trusting. A reply is well-formed only if it is exactly one
block of these three labelled fields, in this order, with no surrounding prose:

```
CLAIM    <the claim, echoed>
VERDICT  accept | dismiss | escalate-to-user
REASON   <one or more lines; cites file:line evidence for accept and dismiss>
```

`VERDICT` must be one of the three literal values. `REASON` must be non-empty. Anything
else — no block, more than one block, an unrecognised verdict, extra commentary around
the block — is malformed, and §7.1 says what the caller does about it.

## 7. Integration

Every mention uses the scoped name `dev-workflow:finding-triage`; frontmatter carries
the unscoped `finding-triage`. Same name, differently qualified.

| # | File | Change |
|---|---|---|
| 1 | `commands/process-pr-review.md` Step 3 | see §7.1 — more than one sentence, because the command's current contract contradicts the new one |
| 2 | `README.md` component table | one row |
| 3 | `docs/getting-started.md` step 8 | one sentence |
| 4 | `AGENTS.md` architecture tree | add `agents/` |
| 5 | `AGENTS.md` **Boundaries** | add `agents/` to the convention-loaded enumeration |
| 6 | `AGENTS.md` **invariant 6** | add `agents` to what the manifest must not re-declare |
| 7 | `AGENTS.md` **invariant 11** | add agent definitions to the governed prompt artifacts |
| 8 | `AGENTS.md` **"What this project is"** | the product-is-prompts sentence enumerates skills, commands, hook messages, templates — add agent definitions |
| 9 | `docs/architecture.md` | layout tree **and** the convention-loading prose |
| 10 | `docs/prompt-standards.md` scope paragraph | add agent definitions |
| 11 | `commands/workflow-init.md` — inline `prompt-standards.md` template | same enumeration change as row 10, worded to read correctly for a project with no agents yet (invariant 8: templates stay inline) |
| 12 | `CLAUDE.md` §5 | the Gate-B artifact-kind list names skills, commands, hook text, templates — add agent definitions, so a `.md` agent edit is not mistaken for prose |
| 12b | `commands/workflow-init.md` — inline `CLAUDE.md` template | the scaffolded §5 carries its own copy of that artifact-kind list and its own `.claude/ plugins/ skills/ commands/` enumeration; update both in lockstep with row 12, or initialized projects inherit a Gate-B rule blind to agent definitions (invariant 8) |
| 13 | `skills/harden-finding/SKILL.md` | rung `P` describes prompt artifacts; add agent definitions to its examples |
| 14 | `.claude-plugin/marketplace.json` | the plugin description enumerates components and would go stale — add finding triage, or restate at mechanism level so future components do not stale it again |

Rows 4–13 are additions to the original brief, required by the Don'ts rule that
enumerations drift when files are added. Rows 7, 10, 11 and 12 close a gap **this
change itself creates**: those files currently enumerate skills, commands, hook
messages and templates. Adding `agents/` is exactly what makes the enumeration
incomplete, so the change that opens the gap closes it.

**On the grep recipe.** The AGENTS.md Don'ts recipe found most of these, not all: it
matches `convention[- ]load`, which by that rule's own note misses the reverse word
order — and `AGENTS.md` Boundaries says "loaded by convention". The sites above came
from the recipe **plus manual inspection**, and the spec says so rather than claiming
the recipe is complete.

**Invariant 6:** `agents/` is convention-loaded, so nothing is added to `plugin.json`;
`scripts/check-invariants.sh` already greps for an `agents` key.

**No length cap on `getting-started.md`.** Pass 1 flagged the previous draft's
100-line budget as invented, and that authorizing "trim adjacent prose" to meet an
invented number licenses unrelated edits against CLAUDE.md §§2–3. Add the sentence and
judge readability.

### 7.1 Reconciling `process-pr-review` Step 3

Step 3 today says "Verdict per comment: accept or dismiss" — two verdicts — and
handles scope separately at 3.3. The agent introduces a third verdict and takes over
factual validity, so the command changes as follows:

- **3.0 (new, before anything else)** — if the PR touches `CLAUDE.md`, `AGENTS.md` or
  anything under `.claude/`, surface those changes to the user and wait. Triage must
  not run under instructions the PR itself introduces (§6.1).
- **3.1** — each comment that asserts a defect is split into single claims, and each
  claim is validated by a `dev-workflow:finding-triage` subagent with fresh context, in
  parallel. Three verdicts, factual only.
- **3.2 (new) — classify actionability, before implementing anything.** For each
  `accept`, the main agent decides using git: is the defect introduced by this PR's
  diff or pre-existing; is fixing it in scope; does it contradict a settled decision.
  **`accept` never authorizes a fix on its own** — it establishes only that the claim
  is true. This ordering is the point: the previous draft implemented every accepted
  finding and only then asked whether it belonged, which re-created the exact
  truth/actionability conflation the subagent split was meant to end.
- **3.3** — implement the accepted **and** actionable findings. Severity gate
  unchanged.
- **3.4** — everything else goes to the user: `escalate-to-user` verdicts, plus
  accepted-but-not-actionable findings (pre-existing, out of scope, contrary to a
  settled decision). This is today's 3.3, now fed by two sources instead of one.
- **Done condition** — every *claim* has a verdict; every *comment thread* has a reply;
  and each claim ends in a fix, a documented dismissal, or an escalation the user has
  answered. An escalated claim cannot be mistaken for a processed one.

**Compound comments.** Splitting a comment into claims means tracking is claim-level
while replies stay thread-level. Each claim keeps its parent thread id; the single
reply on that thread reports every claim's verdict and disposition. A comment is done
only when all of its claims are. Without this, a three-claim comment could be marked
processed on the strength of one verdict.

**Skips, stated:** a comment asserting no defect (praise, a summary, a bot status
note), and a claim already superseded by another. Deduplication happens here, before
invocation — the subagent cannot see other comments and must not be asked to judge
duplication.

**Deduplication is by claim, not by location.** File and line are used only to *group
candidates* for comparison; two claims are duplicates when they assert the same defect
about the same evidence. Two distinct defects frequently share a line, and one defect
often spans several — so collapsing by location alone would silently drop valid claims
before they were ever checked.

**Snapshot barrier.** Subagents run in the background by default, so the main agent
collects **all** verdicts before applying any fix. Mutating the tree while triage
agents are still reading would have them judging different states from the SHA they
were given. If the checkout changes mid-batch, the batch is re-run.

**When the subagent fails**, the main agent retries once, then escalates to the user.
Failure means any of: the agent did not complete successfully (launch failure, spawn
limit, timeout, transport or API error) — **regardless of whether partial output
happens to contain a well-formed block**, since a cut-off run may have stopped
mid-evidence; or the output fails §6.6 validation. It does **not** silently fall back
to validating the comment itself: that is the self-review the agent exists to replace,
and a silent fallback would make the feature indistinguishable from not having it.

## 8. Not built

### 8.1 `ledger-scribe`

Scoped to map a finding to taxonomy classes and draft a ledger row for approval.

The motivation was real: the unwritten ledger row at the end of a long cycle, when
attention is spent. That concern is already carried by `harden-finding`'s own flow and
`process-pr-review` step 4, which mandates the ledger check — the problem was
**located elsewhere, not dismissed**.

**Expressible but redundant.** Expressible: with `tools: Read, Grep, Glob` it cannot
directly invoke a Claude Code write or shell tool, so it cannot itself write
`docs/hardening-log.md` — the same precise boundary as §4, with the same caveat that
externally configured hooks lie outside it. (The previous draft said "mechanically
incapable of touching", reintroducing the absolute claim §4 exists to correct.) Redundant: `harden-finding`
already greps both taxonomies and maps the finding to a canonical class. That
redundancy alone is sufficient. A secondary judgment — that fresh context is a
disadvantage for fingerprinting — is opinion, not fact: `harden-finding` takes an
explicit intake contract, so a parameterized agent could receive the same inputs.

What would have to change for it to be worth adding: `harden-finding` losing its
fingerprint step, or classification becoming genuinely context-free.

### 8.2 `task-verifier`

Scoped to verify an implemented plan task against its success criteria with fresh
context. Dropped at pass 1.

**Duplicates an existing mechanism.** `superpowers:subagent-driven-development` already
dispatches "a task review (spec compliance + code quality) after each" task, with a
re-review loop after fixes — and "spec compliance" is "checks the success criteria".
The remaining path, `executing-plans`, says: "If subagents are available, use
superpowers:subagent-driven-development instead of this skill." So on the platform
where a subagent can run, the reviewer already exists; the path lacking one cannot run
subagents. The niche collapses. This is the same redundancy test applied to
`ledger-scribe`, applied consistently.

**The residual distinction is real but thin.** Per-criterion verdicts backed by
self-produced evidence serve CLAUDE.md §4's "ground progress claims against a tool
result" *outside* plan execution — for example, fixes made during `process-pr-review`,
where no superpowers reviewer is dispatched.

**Trigger condition.** If progress claims outside `subagent-driven-development`
repeatedly turn out ungrounded in real use, that recurrence justifies a narrowly-scoped
verifier — rescoped to **claims**, not plan tasks, and reconciled against superpowers'
reviewer inside the definition. Until that recurrence, adding it is speculative
(CLAUDE.md §2).

## 9. Verification

No new tests. Prompts have no typechecker; this repo's answer is review against
`docs/prompt-standards.md`.

- the canonical quality command from `AGENTS.md § Commands` is run **verbatim** and its
  observed result reported — not a hand-picked subset. `claude plugin validate .
  --strict` is part of that command and covers the new `agents/` directory
- the definition is self-reviewed against all 11 prompt-standards items, result stated
  per item
- nothing in `hooks/` changes
- naming: prose uses `dev-workflow:finding-triage`, frontmatter uses `finding-triage`.
  The check is that the unscoped basename matches and the scope prefix suits the
  context — not literal string equality, which the settled naming rule fails by design

## 10. Delivery

**One commit.** With `task-verifier` dropped the change is one coherent unit; three
commits would create three Gate-B cycles for it, and no commit could share a final
pass. One commit, one cycle, one Gate-B loop.

Version `0.4.0` in `plugins/dev-workflow/.claude-plugin/plugin.json` — minor, new
capability, no breaking change. Nothing else in that manifest changes (invariant 6).
