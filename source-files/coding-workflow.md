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

**1. Intake — from idea to story.** The front door turns a raw idea into a scoped
story that captures *what* and defers *how*: the problem, the desired outcome, the
acceptance criteria, which core invariants the change touches, the open questions,
and a rough size. The design ("how") is deliberately left out — it belongs to the
next stage. The value here is a shared, reviewable definition of done before
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
hard floor**: a minimum number of passes, re-running one broad review prompt over
the *revised* artifact each time (new findings surface precisely because the
artifact changed between passes). Only design-breaking findings — the serious
tiers — force another iteration; the final pass must come back clean. Catching a
flaw in the spec is far cheaper than catching it after it has been baked into the
plan and the code.

**4. Planning.** The spec is turned into a task-by-task implementation plan. Each
task names the files it touches, the interfaces or contracts it produces, and its
steps — and the steps begin with a *failing test* (test-first). Global constraints
are restated at the top so they aren't lost mid-build. A plan at this resolution
makes execution mechanical and the resulting diff traceable back to a requirement.

**5. Gate A on the plan.** The same independent review, now applied to the plan —
so a plan-level flaw is caught before implementation, not during it.

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
prior review. Genuinely trivial changes may skip it; documentation-only changes
are considered covered by Gate A instead, since there is no code diff to review.

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
strictly append-only: history is never rewritten, and a resolution is a *new*
entry that references the one it closes.

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
