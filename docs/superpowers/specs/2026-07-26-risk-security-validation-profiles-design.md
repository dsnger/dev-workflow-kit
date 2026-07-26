# Risk, security, and validation profiles — Design

**Date:** 2026-07-26 · **Story:**
`docs/superpowers/stories/2026-07-26-risk-security-validation-profiles-story.md`

Design altitude on purpose: this states WHAT each profile level changes, where the
values live, and how an upgrade is recorded. The exact wording of the lens paragraphs
and the template diffs are plan and implementation territory — prose review stops
converging on wording (nine plan passes in the last round re-proved it), and procedure
converges at Gate B.

## 1. Problem and goal

Review cost is the workflow's limiting factor, and every story pays the same price
regardless of what it risks (counted evidence in the story's §1: 51 Gate-A pass files
on one product project's 2 stories; 23 pass files and 160 findings in this repo's
just-closed round, 8 of them on prompt-text and docs alone). The gates have one
intensity and no vocabulary separating a payments migration from a copy tweak.

Goal: two human-confirmed axes per story — **risk** and **security relevance** — plus a
**validation mode derived from them**, steering *what the gates ask* and *what the
author must show*, without adding passes and without switching any gate off.

## 2. Decisions, with what would reopen each

| # | Decision | Why | Reopens when |
|---|---|---|---|
| D1 | The two axes are proposed by the agent and **confirmed by the human**; the validation mode is **derived**, never asked | A third question invites an answer inconsistent with the first two | — |
| D2 | Profiles apply to stories **entering intake after this ships**; no retrofit | Retrofitting settled artifacts is a metadata backfill that changes no decision | An in-flight story may **adopt** a profile voluntarily at any natural checkpoint via the upgrade mechanism (§6). Adoption allowed, retrofit not required |
| D3 | `trivial` does **not** relax Gate A's floor or skip Gate A | A spec misjudged as trivial skips design review entirely and everything downstream inherits it — strictly more dangerous than a diff misjudged as trivial, which the documented Gate-B skip already covers | Field evidence that trivial stories burn Gate-A passes. Trigger discipline as usual: evidence, then a story |
| D4 | The **story header is the single writable copy**; spec and plan cite the story path; the gate prompt reads the header fresh at each pass | A second copy is a sync surface, and stale-copy drift is this repo's most recurrent defect class (§5 documents an incident) | — |
| D5 | The validation mode governs **evidence the author must produce**; risk governs **questions the reviewer asks** | Orthogonal levers. Had the mode also steered the gates it would be a second name for risk | — |
| D6 | Profiles never switch a gate off and never change the 3-pass floor | The mandatory-gates promise is the product; an economics lever that can disable review is not an economics lever | — |

Rejected, for the record: the mode as a **gate schedule** (full / reduced / minimal) —
it would let profiles switch gates off, the exact promise D3 protects; and the mode as
**artifact depth** (full spec vs. design note vs. story-only) — "depth" is not checkable,
and prose review never converges on it. A **spec-header echo** of the profile was
considered and rejected under D4.

## 3. The two axes

Recorded in the story header, one line beside `Date` and `Size`:

```
**Risk:** trivial | standard | high · **Security:** none | standard | high · **Validation:** <derived mode>
```

**Risk** answers *what does this break if it is wrong*. `high` is **proposed whenever
the story hits a named trigger**: auth, permissions, payments, migrations, data
deletion, public APIs, personal data, supply chain. The list is domain vocabulary, not
stack vocabulary, so it stays in the shipped skill (invariant 10 holds); a project that
needs more triggers adds them to its own `AGENTS.md`, not to the skill.

**Security relevance** answers *does this touch assets, trust boundaries, roles, or
external systems*. `none` is a real answer and the common one; it must not read as an
admission of carelessness, or every story drifts to `standard`.

**Confirmation and the default.** Intake proposes all three values with a one-line
reason each; the human confirms or corrects; the story is not written until they do —
the existing one-round pause governs. If the human says "proceed anyway" or does not
know, the recorded value is **the agent's proposal and never lower than it**. That is
invariant 2 ("loose in the firing direction") applied to intake: a redundant lens costs
a paragraph, a missing one costs a review.

## 4. The derived validation mode

Effective level = `max(risk, security)` over `none|trivial → 0`, `standard → 1`,
`high → 2`. The effective level names the mode; security `high` adds one obligation on
top of whichever mode applies.

| effective | mode | the author must show, before Gate B |
|---|---|---|
| 0 | `battery` | the project's quality battery green |
| 1 | `battery+test` | battery + a test that fails without the change |
| 2 | `battery+test+verification` | battery + tests + a **named** verification |
| security `high` | `+ abuse-path check` | added to the mode above |

`max()` is deliberate at the corner: a change judged `trivial` that sits on
security-relevant surface still lands at the security level's evidence. Trivial is a
statement about blast radius, not about where the code lives.

**"Named" is the honest-claim rule made checkable.** A mode-satisfying entry names the
concrete check and its recorded result: a test path, a reproducible command with its
output, or a documented manual check with its outcome. The word "verified" without a
named artifact does not satisfy any mode. The entry travels in the Gate-B call and the
PR body — the commit message body in projects that never open PRs — so no new file and
no new story section is introduced to hold it.

**Forward-compatible by design.** Today `named verification` and `abuse-path check`
resolve to whatever a project's battery and manual practice provide. When a project
grows the parked validation lane (agentic smoke, coded E2E), those become additional
ways to satisfy the *same* obligations — no renaming, no second axis. That lane is not
designed here.

## 5. What the profile changes at the gates

§5 gains one short **Profiles** subsection — the axes, the derivation, and the two lens
sets named — in both copies (this repo's `CLAUDE.md` and the inline template
`/workflow-init` writes). The gate-prompt rule gains one instruction: **read the story
header fresh at each pass, and append the lens set(s) the current values call for.**

- **risk `high`** → risk lens set: threats, abuse, rollback, data loss, idempotency,
  compatibility, observability.
- **security `standard` or `high`** → security lens set: assets, trust boundaries,
  roles, external systems, abuse paths.
- **risk `trivial`** → nothing appended. It unlocks the *existing* Gate-B triviality
  skip, which now requires a recorded reason in the story rather than unrecorded
  judgement.

Lenses are **different questions, not more identical passes** — the 3-pass floor,
the Blocker/Major filter, the file-first findings protocol and the clean-final-pass rule
are all unchanged. The coverage rule is unchanged too: Codex reports every finding with
severity and confidence; the filtering stays downstream.

## 6. Upgrades (and how they interact with the floor)

Any pass may reveal that the profile was set too low. Then:

1. The story header value is **corrected**, and a line is **appended** beneath it: date ·
   old → new · the finding that triggered it · what it changes downstream.
2. The edit is **committed docs-only at the next natural commit point**. An uncommitted
   upgrade exists on one machine's disk, while the profile is input to the gates.
3. The new profile takes effect **at the next pass**, mechanically, because the prompt
   re-reads the header rather than remembering a value quoted in an earlier pass.

**Downgrades** are possible but never automatic: human confirmation, same appended line.

**Upgrade × the 3-pass floor.** Passes already run under the lower profile **keep
counting** toward the floor — the floor is per cycle, and re-running them would be the
more-identical-passes this design exists to avoid — but the **final clean pass must run
under the current profile**, which the fresh header read guarantees mechanically. Net
effect: an upgrade costs at minimum one additional pass, never a restart of the cycle.
It is the Gate-B rule "the last review must cover the current state", applied to
profiles.

## 7. Compatibility and scope

A story with **no profile line behaves exactly as today**: standard intensity, no lens
sets appended, no triviality skip available. That is what makes D2 free — nothing in
flight breaks, and adoption is a one-line edit through the §6 mechanism whenever a
story wants it.

**Surfaces touched:** `plugins/dev-workflow/skills/intake/SKILL.md` (proposal step +
header line in the story template), `CLAUDE.md` §5 and the inline §5 template in
`plugins/dev-workflow/commands/workflow-init.md` (both in the same commit — docs-drift
class), `todos.md` (P2+P6 closed; P5 light's trigger re-pointed at the first story that
runs under profiles), CHANGELOG + plugin version bump (invariant 12).

**Non-goals:** no hook change (the hook counts passes and does not need to know
profiles); no new script; no new scaffolded file; no standalone security section in any
template — security content lives in the spec's existing sections and in AGENTS.md
invariants, and the security lens set is the mechanism that forces those concerns to be
addressed there. If field use later shows high-security content scattering incoherently
across specs, that recurrence is the trigger for a dedicated section. Stable AC-/SEC-IDs
(P5 light) are deferred by the same reasoning that dated their trigger: profiles are
what the IDs would number.

## 8. Invariants this change touches

- **8** — the §5 template stays inline in the command body; the Profiles subsection is
  written there, not read from disk.
- **9** — `/workflow-init` stays idempotent; a template that changed means show-the-diff
  and ask, never a silent overwrite.
- **10** — the trigger list and lens sets stay stack-neutral; project vocabulary belongs
  in that project's own files.
- **11** — every touched prompt passes all 12 items of `docs/prompt-standards.md`.
- **12** — the plugin change carries a version bump.
- **Don'ts** — no doc section renamed or deleted without grepping references first; no
  sentence claiming what a gate proves beyond what it actually compares. The profile
  changes the *questions* a gate asks; it changes nothing about what either gate
  compares.
