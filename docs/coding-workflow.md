# The Cross-Model Review Workflow — A Reusable Methodology

A project-neutral description of a software workflow built around one thesis:
**quality should be a property of the process, not of any single heroic review.**
The way to get there is to make review *independent*, make enforcement
*automatic*, and make the system *record and escalate its own findings* — so
correctness compounds over time instead of depending on anyone's vigilance.

This document is tool-agnostic on purpose. It names disciplines and roles
(a "quality battery", a "cross-model reviewer", an "invariants file"), not
specific products, so it transfers to any language, runtime, or stack. A section
at the end covers how to adapt it.

---

## Part 1 — At a glance

The unit of work is a **story**: one coherent change with a defined problem and a
verifiable definition of done. Every story travels the same path:

> Idea → Story → Spec → **Gate A (spec)** → Plan → **Gate A (plan)** →
> Implement (test-first) → Quality battery → **Gate B (code)** → PR + bot review →
> Merge → enforcement

Three systems hold that pipeline together:

1. **Two independent review gates.** An outside reviewer — a *different* model
   than the one that authored the work — checks the design *before* it becomes
   code (Gate A), and checks the code *before* it lands (Gate B).
2. **An append-only hardening ledger with an escalation ladder.** Every finding
   is logged and fingerprinted; when a class of defect recurs, the response
   escalates from a note, to a lint rule, to a type constraint, to a test.
3. **Repo-enforced quality.** A single quality command runs in continuous
   integration on every change, so nothing red can merge — enforcement never
   depends on remembering to run it.

Everything else in this document is the detail behind those three ideas.

---

## Part 2 — The full explanation

### Philosophy and tradeoffs

The workflow biases toward **caution over speed** for any non-trivial work
(trivial changes use judgment). Four working rules govern how any individual step
is carried out:

**Think before coding.** State assumptions explicitly; if multiple
interpretations exist, surface them rather than silently picking one; if a
simpler approach exists, say so. Confusion is named and resolved *before*
implementation, not discovered after a mistake.

**Simplicity first.** Write the minimum code that solves the problem. No
speculative features, no abstractions for single-use code, no configurability
that wasn't asked for, no error handling for impossible states.

**Surgical changes.** Touch only what the task requires. Don't "improve" adjacent
code, don't refactor what isn't broken, match the existing style. Every changed
line should trace directly to the request.

**Goal-driven execution.** Turn a vague task into a verifiable success criterion
("add validation" becomes "write tests for the invalid inputs, then make them
pass"), then loop until it's met. Ground every progress claim in evidence: before
reporting a step done, point to a tool result that proves it — a passing test
run, a diff, a log line.

### The pipeline, stage by stage

Why each stage exists, tool-agnostically. For the *how* — one feature walked through
the actual skills, commands, agent definitions, and hook messages of this plugin — see
[`getting-started.md`](getting-started.md); it is not repeated here.

**1. Intake — from idea to story.** The front door turns a raw idea into a scoped
story that captures *what* and defers *how*: the problem, the desired outcome, the
acceptance criteria, which core invariants the change touches, the open questions,
a rough size, and a **profile** — risk and security relevance, confirmed by the human,
with a validation mode derived from the two. The two axes **add** review lenses at the
gates for a risky or security-relevant change (they never subtract a baseline question; the
floor itself derives from the profile, so it is not the same at every level), while the derived
mode calibrates
what evidence the author owes before Gate B. The design ("how") is deliberately left out —
it belongs to the next stage. The value here is a shared, reviewable definition of done before
anyone argues about approach.

**2. Brainstorming to a spec.** Approaches are explored and decisions are settled
*explicitly* — each decision recorded with its rationale and the alternatives it
beats, alongside the non-goals and the risks. The output is a spec: the artifact
the first gate will review. A good spec reads like a set of settled decisions, not
a wish list.

**3. Gate A on the spec.** An independent reviewer — a different model than the
author — reads the spec text and checks it for contradictions and internal
inconsistencies, missing requirements, unhandled state/edge/error/empty/concurrent
paths, and risks to the project's core invariants. It is run as a **loop with a
hard floor**: a minimum number of passes, re-running one broad review prompt each
time — over the revised artifact where a finding required a repair, over the unchanged
one where none did. A finding's severity decides what must be repaired, not on its own
whether another pass is owed: the review policy's closure ordering decides that. A cycle
closes on an eligible pass — clean at or above the floor, or one with zero findings — only
when every other closure condition holds, and accepting even a minor finding into the
assigned work costs a further pass. Catching a
flaw in the spec is far cheaper than catching it after it has been baked into the
plan and the code.

**4. Planning.** The spec is turned into a task-by-task implementation plan. Each
task names the files it touches, the interfaces or contracts it produces, and its
steps — and the steps begin with a *failing test* (test-first). Global constraints
are restated at the top so they aren't lost mid-build. A plan at this resolution
makes execution mechanical and the resulting diff traceable back to a requirement.

**5. Gate A on the plan.** The same independent review, now applied to the plan —
so a plan-level flaw is caught before implementation, not during it. Each Gate-A cycle
ends with its own closing act — the reviewed artifact committed with the cycle's
records — before the next stage starts.

**6. Execution.** The plan is implemented task by task, followed literally.
Bounded subtasks can be delegated to cheaper models or subagents. Discipline
holds: every changed line traces to the story; no drive-by refactors.

**7. The quality battery — repo-enforced.** A single command chains the mechanical
quality checks: a strict typecheck, a linter at zero-tolerance for warnings, a
dead-code detector, a duplication/health check against a baseline, and a test
suite across its relevant environments. Crucially, this same command runs in
continuous integration on every proposed change and on the main branch, so a red
result *cannot* merge. Enforcement that depends on a human remembering to run the
checks is not enforcement.

**8. Gate B on the code.** Before the change is committed, the independent
reviewer reads the actual *diff* and checks it against the invariants file. It is
re-run after every fix, because each fix changes the diff and invalidates the
prior review, and it closes when the review policy's closure ordering says so — never
on a clean pass alone. Trivial changes may skip it, on terms that depend on the story: an
unprofiled one keeps the judgement call, while a profiled one qualifies only at
effective level 0 — trivial risk *and* no security relevance — so a trivial-looking
change on security-relevant surface is not eligible. A skip removes the review, never
the evidence: the battery still runs, and the commit body carries the reason, the battery
result, the cycle's provenance line, a skip record in place of the curve, and one evidence
entry per cited profiled story. **Explanatory**
documentation carries no gate at all — a wrong sentence there costs a confused reader
rather than broken behaviour. Prompt artifacts are not explanatory prose: in a project
whose product is prompts, the text *is* the behaviour, so the review policy requires Gate
B for them even though they are Markdown. Which paths count is spelled out in the policy
file, and a reminder hook classifies them independently; both err toward firing, and the
hook only reminds — it never blocks, and it is not what makes the review happen. When it
is unclear whether an artifact counts, review it: a redundant pass costs minutes, a
missed one costs the defect this loop exists to catch.

**9. Pull request and bot review.** Automated reviewers comment on the PR. Their
findings are processed *systematically*: pre-existing issues are tracked rather
than fixed in this diff (keeping the diff clean and single-purpose), while
regressions the change introduced are fixed. This requires knowing each bot's
real capabilities — what it actually reports versus what it only summarizes — so
findings aren't missed or over-trusted.

**10. Merge and enforcement.** After merge, a repository setting (branch
protection requiring the quality check to pass) makes the gate mandatory for every
future change, by everyone. The process stops being a convention and becomes a
rule the platform enforces.

### The two gates, and why independence is the point

The defining feature of both gates is **cross-model independence**: the reviewer
is a different model — ideally a different family — than the implementer. A given
model tends to be blind to its own mistakes in the same way twice, so a second,
independent reviewer catches what the author's own reasoning glossed over. It is
common for an author to *sincerely believe* a change is complete — for instance,
that a security fix has fully closed a leak — while an independent reviewer
confirms a residual problem and even surfaces additional cases the author never
considered. That is the entire value proposition, and it is worth the cost.

Two properties keep the gates honest:

The gates are **advisory but mandatory**. The reviewer's findings are validated
before being applied — a dismissed finding gets a one-line reason — but the gate
itself is not optional, and a merely *satisfied pass-count is not the same as a
clean review*. The discipline is backed by instruction, not just by a counter.

The gates review **different objects**. Gate A reviews *text* — the spec, then the
plan — so the reviewer reads the artifact you hand it. Gate B reviews the *diff* —
so the reviewer reads the code range. The two must never be confused: reviewing a
design document as if it were a code range, or vice versa, produces nonsense.

**When no independent reviewer is available, be gateless — not self-reviewed.** The
tempting fallback is to let the authoring model review its own work. Don't: it
reproduces its own blind spots and returns a clean review that means nothing, which is
strictly worse than no review, because a false ✓ *stops you looking*. The honest
degraded mode is to state plainly that the gates are inactive and silence the
machinery that pretends otherwise — a reminder that fires on every commit but backs no
real check is noise, and noise trains people to ignore the gate that will eventually
matter. Being explicitly gateless is a known gap you can close; being implicitly
self-reviewed is an unknown one you cannot.

**Choosing which model reviews — and switching when one runs dry.** The invariant names a
model **family**, not a vendor: a pass satisfies a gate when the reviewer is a different family
from the implementer. That leaves the vendor free, which matters because the common failure is
not a bad review, it is **no review** — a quota limit hit mid-cycle, with work blocked and the
gate unsatisfiable. An alternative reviewer is the operational answer, and it is worth wiring
up *before* you need it.

**This section describes the mechanism, not a choice of model.** It names no models and no
recommended default deliberately: model availability, pricing and quality move faster than a
document does, and a list here would be stale before it was useful. A gateway such as
OpenRouter publishes a live catalog — read that for what exists. What follows is how the
plumbing works, so that picking a model is a one-string edit rather than a research project.

**Adding a gateway** to the Codex CLI is one provider block naming the base URL and the
environment variable holding the key:

```toml
[model_providers."<id>"]
name = "<display name>"
base_url = "<gateway base URL>"
env_key = "<ENV VAR HOLDING THE KEY>"
wire_api = "responses"
```

(The table key is quoted because `<id>` is a placeholder: TOML bare keys allow only
`A-Za-z0-9_-`, so the block would not parse with the angle brackets unquoted. Substitute a bare
id and the quotes become optional.)

Adding it changes nothing by itself; `model_provider` still decides who answers. Check
`wire_api` against your CLI version, and check it with `codex doctor` rather than at the first
call. Measured on **codex-cli 0.147.0**: `wire_api = "chat"` makes the whole config fail to
load — `codex doctor` reports `config could not be loaded` — while `"responses"` loads clean.
An arbitrary value fails identically, so `"chat"` is not specially diagnosed, it is simply no
longer accepted. That is the good failure, surfacing at load rather than silently; the version
is named because it is the one this was run against, not because earlier or later ones are
known to differ.

**Four switch surfaces, each a one-string edit**, in the order `mcp-codex-dev` resolves them
(later overrides earlier):

| Surface | Scope | Use it when |
|---|---|---|
| The config the CLI reads (`~/.codex/config.toml`) — its `model` and `model_provider` | every call, all repos | you are changing the standing default |
| `~/.mcp/mcp-codex-dev/config.json` | every repo, this MCP server only | the gate calls need a different model from what the CLI uses by hand |
| `<repo>/.mcp/mcp-codex-dev.config.json` | one repository | a project needs a different reviewer from your default |
| `CODEX_DEV_MODEL` / `CODEX_DEV_REVIEW_MODEL` | current environment — all tools / **Gate B only** | switching per-shell; the `REVIEW` variant changes the code reviewer without touching Gate A |

**One catch worth knowing before you reach for a profile:** `mcp-codex-dev` passes `--model`
and **never `--profile`**, so a CLI profile does not reach the gate calls at all. Because only
the model name is passed, `model_provider` has to be active in the config the CLI reads — a
profile cannot carry the switch. Profiles remain useful for driving the CLI by hand.

**One config, both providers.** Keep the native provider and the gateway entry in the same
config the CLI reads: the top level names no `model_provider`, so the native default answers,
and the appended gateway block is inert until a top-level `model_provider = "<id>"` line
selects it. The switch is that one line — inserted in the top-level block, since a key placed
after any `[table]` header belongs to that table — and the revert is deleting it; the default
returns to the native provider at the next call. Do not point `CODEX_HOME` at a second config
directory to get isolation: the CLI's login state lives beside the config it reads, and a
redirected directory strands the existing login.

Three timing facts decide where an edit lands and when it takes effect. The CLI is spawned
per call and reads its config at start, so the provider switch needs no restart of anything.
`mcp-codex-dev` resolves its *model* chain once per resolved project root and caches it until
the server restarts — the launch root at startup, any other root on its first call — so a model
edit must be in place before the root is first loaded, or be made under a project root the
server has not seen yet. And the key named by `env_key` must be present in the
environment the MCP server was launched with — the CLI inherits it from the server, the
server from its parent at spawn — so an export made after launch reaches nothing until that
parent restarts.

Provider selection cannot travel per-repo: the `mcp-codex-dev` config schema has no
provider key and strips unknown keys, so the per-repo file picks a *model* while
the *provider* stays global to the config the CLI reads.

**Record which model took each pass.** The gate's value comes from independence, so a pass is
only interpretable if you know who gave it. Put the model the pass *ran under* in the pass record
beside the finding count, never one recalled from memory or copied from a document. That is not
always what the config says now: per the timing facts above the model chain is resolved once per
project root and cached until the server restarts — the launch root at startup, any other root on
its first call — so a model edit landed after a root was loaded leaves the configured value and
the running one disagreeing until restart, and the configured value is the wrong one. A root the
server has not loaded yet is the exception: there the edit does take effect. Where they
can disagree, confirm by probing: call `mcp__codex__health` with the same `workingDirectory` you pass to the
gate call. It reports the server's cached per-root resolution, which is what the gate call for
that root uses — the point being that reading the config file yourself is exactly the thing that
can disagree. **Read the per-tool field, not the top-level one:** the server resolves a gate's
model as `tools.<tool>.model ?? model`, so Gate B is `checks.config.effective.tools.review.model`
falling back to `checks.config.effective.model`, and Gate A the same with `tools.exec.model`. The
top-level field alone is the wrong answer precisely where the override documented above is in
use, since `CODEX_DEV_REVIEW_MODEL` is stored at `tools.review.model`. If neither level names a
model the probe establishes nothing — the CLI then picks its own default, and the only honest
record is to set an explicit model or record the model as undetermined. Record the result beside
the finding count in **the cycle's per-pass curve**, which pins a field for it — not the
evidence entry and not the dispositions file, neither of which is keyed to a pass. The health
probe above is how the value is established; the curve is where it goes. This is
bookkeeping, not enforcement: nothing checks it, and a wrong entry looks exactly like a right
one.

**The one permanent rule here is family-level.** No model from the **implementer's own family**
satisfies a gate — whatever the vendor, whatever the gateway, whatever the transport. Routing
an Anthropic model through a third-party gateway while Claude is implementing does not make it
independent; it is the same family behind a different bill. Everything else in this section is
configuration and will change. That sentence will not.

### The self-hardening ledger

The system learns from its own findings through an **append-only ledger**. Every
finding is logged with a *fingerprint* — a taxonomy label — so that recurrence of
the same class becomes detectable across time and across different parts of the
codebase.

An **escalation ladder** decides the response to a finding: a prose note, then a
lint rule, then a type-level constraint, then a test (and, at the top, a change to
the process or prompts themselves). A first occurrence earns the lightest durable
guard that fits. **Recurrence of the same class escalates one rung harder** — if a
prose note didn't prevent a repeat, the next response is a mechanical check.

The governing principle is **close the class, not the instance.** When a defect
reappears in a new location, that is the signal to stop fixing instances one at a
time. Instead, audit the whole surface for that class in a single pass, fix every
instance together, and — if the pattern is mechanically detectable — add a
linter or static-analysis rule so it can never silently return. The ledger is
strictly append-only: a **row** is never edited, a resolution is a *new row*
that references the row it closes, and a row whose text is later found wrong
is corrected by appending a supersession **entry** rather than by editing it.
(*Row* and *entry* are distinct: rows are the ledger's records, entries are
the supersession markers that correct them.)

### Cross-cutting disciplines

**Model routing.** Match the model to the task: a literal, instruction-following
model for well-specified work; a less prescriptive model for long or ambiguous
architectural exploration; cheap models for bounded subtasks; and a *different*
model family for the review gates, to preserve their independence.

**Empirical-first configuration.** A configuration line should document a
*verified necessity*, not a hypothesis. Don't add a guard, placeholder, or
exclusion preemptively "just in case." Let the pipeline's own run prove the need —
then add the line together with a comment stating the fact it proved. The cost of
being wrong empirically is one red run and one commit; the cost of a speculative
line is a permanent entry nobody can safely remove because nobody knows why it's
there.

**Verify against ground truth.** Trust version history, file timestamps, and
actual command output over any status report — including your own. Status
messages without a corresponding artifact on disk are treated as unverified.
Before declaring work done, cite the tool result that shows it.

**The invariants file.** A single source of truth for the project's
non-negotiables (its security rules, architectural constraints, and forbidden
patterns), written so that both humans *and* the automated reviewers read the same
document. Both gates check against it, which is what lets "check it against our
invariants" be a concrete instruction rather than a vague hope.

**The baseline ratchet.** Measurement baselines — for duplication, coverage, and
similar metrics — change only in dedicated, isolated re-baseline commits, never
bundled with feature work. This keeps the baseline an honest record of a
deliberate decision rather than a number that drifts silently.

**Scope follows risk, not metrics.** Where to draw the boundary of a change is a
judgment about the risk profile, not about hitting a number. And a finding can
override the original instruction: if review reveals the premise was wrong, the
premise gives way.

**Supply-chain caution.** Pin tool versions from a single source of truth; install
from a frozen lockfile so builds are reproducible and can't silently pull new
code; and optionally gate dependency freshness (for example, refusing packages
published within the last day or two) to blunt supply-chain attacks.

### Adapting it to another project

**What is essential — keep it.** The two independent review gates; repo-enforced
quality that blocks merges; the append-only ledger with its escalation ladder; the
invariants file as a shared source of truth; empirical-first configuration; and
verify-against-ground-truth. These are the load-bearing ideas, and none of them
depend on a particular tool.

**What is swappable — choose per project.** The specific typecheck, lint,
dead-code, duplication, and test tools; the reviewer model and the PR bot; the
language and runtime; the exact number of review passes. These are
implementation choices behind the roles above.

**Minimal viable adoption.** You don't need the whole thing on day one. Start with
three pieces: an invariants file, a single repo-enforced quality command, and one
independent code-review gate. Once those hold, add the hardening ledger and the
spec-stage gate. The methodology degrades gracefully — each piece is valuable on
its own, and they compound as you add them.

### Closing note

Restating the thesis: correctness is not the output of one careful reviewer having
a good day. It is the output of a process where review is independent of the
author, enforcement is automatic rather than remembered, and the system records
and escalates its own findings so the same mistake gets progressively harder to
make. Build those properties in, and quality stops being a thing you hope for and
becomes a thing the process produces.
