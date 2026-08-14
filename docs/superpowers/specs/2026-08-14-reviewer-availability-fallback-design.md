# Reviewer-availability fallback — a two-tier ladder with a mid-flight human exception — Design

**Story:** `docs/superpowers/stories/2026-08-13-reviewer-availability-fallback-story.md`
— the story header is the single writable copy of the profile. Every gate call carries that
path and reads the axes, the mode and the lens sets fresh from it; this document never
restates them as values.

**History.** A three-tier design was reviewed at Gate A over three passes (37, 39, 40
findings; **none dismissed**; blockers rising 4 → 4 → 6) and stopped under §5's stuck
condition. Tier 2 and rider (a) were split out, each carrying its blockers as opening
evidence:
`docs/superpowers/stories/2026-08-14-tier-2-same-family-reviewer-story.md` and
`docs/superpowers/stories/2026-08-14-sequential-branch-calls-hook-story.md`. Findings and
dispositions: `.context/codex-reviews/gate-a-spec-pass-{1,2,3}{,-dispositions}.md`.

## 1. Problem

Both gates depend on one external reviewer. §5 requires a **minimum of three passes** per
gate with only the **final** pass clean, and permits an early exit below three only on a
pass returning zero findings. Out of quota, no pass can be taken at all, so no cycle closes
and all work stops. Observed: a five-day full process stall, 2026-08-05 to 2026-08-10.

`/workflow-init` §2.13 does not reach this. It fires at **init time**, when the preflight
finds Codex unconfigured, and scaffolds a project that is explicitly gateless. A configured
project that loses its reviewer mid-flight falls outside it — and the human running that
project has no sanctioned way to close a cycle at all.

So the gap is narrow and specific: **there is no authorized way to close a gate cycle when
no reviewer can run.** Work stops, and the only alternative reachable today is to abandon
the gates entirely.

## 2. Settled decisions

1. **Two tiers.** Tier 1 (cross-model) and tier 3 (a mid-flight human exception). The
   same-family tier-2 reviewer is a separate story; every blocker that stopped the first
   cycle except rider (a)'s belonged to it.
2. **Tier 3 is a gate waiver, and the design says so** — a zero-pass closure, not a cycle
   with a weaker reviewer.
3. **No hook change, and no `codex-gate.off`.** See §4.
4. **Every tier-3 closure owes a cross-model re-review debt**, at any profile.
5. Riders (b) and (c) ride along, as §10.

## 3. Tier 3 — the mid-flight human exception

**A new exception, stated as one.** Calling it existing practice would be false: §2.13's
init-time gateless path closes no active gate, and a profile override changes evidence mode
rather than authorizing a zero-pass closure. Tier 3 authorizes something neither has.

- **Precondition:** tier 1 is unavailable — a tier-1 call cannot complete. Quota
  exhaustion, authentication failure, sustained timeout, or the server absent. Not slow, not
  inconvenient, not expensive. Either a tier-1 call was attempted and failed with its single
  recovery attempt spent, **or** the outage is independently confirmed, in which case the
  recovery attempt is expressly waived and who confirmed it is recorded.
- **Authority: the human.** An agent may propose tier 3 and may never enter it. The actor
  whose work is under review must not be the actor who waives the review. §13 records
  exactly what this does and does not achieve.
- **Effect:** the cycle closes with **no qualifying passes**. It has no pass count, no
  final-pass-clean signal, and no per-pass record, because it has no passes.
- **Record:** the logged-human-decision block (§5) in the cycle-closing commit body.
- **Debt:** every tier-3 closure owes a re-review (§7).

Tier 3 is distinct from §2.13's init-time gateless path, which is not a tier and does not
close a mid-flight cycle.

## 4. Why there is no sentinel, and no invariant to amend

An earlier draft prescribed `.context/codex-gate.off` for the duration of degraded
operation, to suppress the Gate-B STOP that would otherwise fire. Gate-A review found that
this silences reminders for **unrelated** commits in the workspace — the missed-commit
direction invariant 2 names as dangerous — and that no amount of residual-naming makes it
compliant.

With tier 2 gone, the whole apparatus is unnecessary. **A tier-3 closure is a single
commit, not a cycle of passes.** The hook fires its Gate-B STOP once, on that commit, with
the human present and having just authorized the waiver. Proceeding past one STOP knowingly
**is** what a documented human exception looks like; suppressing it would remove the last
place the situation is visible.

So: **invariant 2 is untouched, `.off` keeps its existing meaning ("the gates still
apply"), and the hook is unmodified.** The STOP the operator sees is correct — Gate B
genuinely is not satisfied — and the closing commit body says why.

**What the hook does, stated exactly:** it reports the floor unmet, because it is. Nothing
here makes the hook aware of tier 3, and nothing should: a hook that recognized waivers
would be a hook that could be told a waiver happened.

## 5. Two record schemas

Both are prose blocks in a commit body. Neither is machine-validated — §13.

**Tier-3 cycle marker:**

```
Reviewer-tier: 3 — human exception, gate waived, no qualifying passes
Gate: A-spec | A-plan | B · cycle: <cycle-id>
Authorized-by: <accountable handle> · <date>
Cause: <one value from the closed set below>
Cross-model re-review: owed — todos.md "<row key>"
```

`Cause` comes from a **closed set** — `vendor quota`, `authentication failure`, `service
unavailable`, `sustained timeout`. Raw error payloads, endpoints, account identifiers and
tokens are **never** written to a commit body or a `.context/` file; the failure is recorded
as its enum value, not its text.

`Authorized-by` is an **accountable handle**, not necessarily a personal name — a public
commit body is a poor place to require one, and the point is accountability rather than
identity.

**Logged human decision** — one schema, three uses (authorizing a tier-3 closure, accepting
a debt without the review, and any later extension):

```
Human decision: <accountable handle> · <date> · authorizes: <what> · reason: <why>
```

**Deduplication key** for the multi-WIP collapse: gate + cycle id. Two markers sharing it
collapse to one; two disagreeing on any other field are a **conflict that stops the close**
rather than being merged.

## 6. Disclosure, and the carry chain

The marker travels:

- **Gate A** → the **spec or plan commit body**. Both Gate-A cycles complete before any WIP
  commit exists, so a WIP-only chain would lose them. Carried forward into the
  implementation cycle's closing body; if work stops before Gate B, the docs commit is
  already the durable record.
- **Gate B** → the **WIP commit body**.
- **The closing amend** replaces the WIP body wholesale **except** that disclosure content
  is stated explicitly in the closing message. Nothing is preserved automatically; the
  author writes it.
- **The multi-WIP collapse** (`git reset --soft <parent-of-first-WIP>`): every marker in
  every collapsed body is collected, deduplicated by the §5 key and validated before the
  single replacement commit.
- **The squash body**: **both** the tier markers **and** every profiled story's evidence
  entry are copied in explicitly. Carrying only the marker would satisfy the ladder while
  deleting the evidence the profile requires on `main`.

`Gate-A docs commit → WIP → amend → squash → main`.

**Merge-time ownership.** The person performing the merge is responsible for the squash
body, and the author **verifies by reading `main` after the merge**. Until that read, story
AC 2 is not demonstrated. If verification fails, the remedy is a **corrective disclosure
commit** on `main` naming what was lost — the rewrite cannot be undone, so the answer is to
add the record back, not to pretend it survived.

**Supported merge strategies:** squash and ordinary merge. Rebase-merge and cherry-pick
rewrite the landed identity outside the reconciliation rule in §7 and are a **stop
condition** for a tier-3 cycle, not a silent gap.

**Never in the findings file** — its grammar admits no non-finding line.

## 7. The re-review debt

**Every tier-3 closure owes one, at any profile.** This departs from the earlier
level-2-only rule, and the reason is that tier 3 changed shape: a zero-pass closure means
**no review happened at all**. Under tier 2 a weaker review still ran, so scaling the debt
by profile was coherent. Waiving the gate entirely on a `standard` story would otherwise
leave a change that never met any reviewer, which is not a thing this workflow should be
able to produce silently. **Profile scales the repayment, not whether one is owed.**

**Gate-matched.** A waived Gate-A **spec** cycle owes a cross-model review of the **spec**;
a Gate-A **plan** cycle, of the **plan**; a Gate-B cycle, of the **diff**. Reviewing a
landed diff does not recover a missed design review.

**Identity, in two stages** — the landed SHA cannot exist inside the commit that records the
row:

1. **Pre-land**, in the closing body and the `todos.md` row: the story path, the cycle id,
   and the reviewed `baseSha`. All knowable at closing time.
2. **Post-land reconciliation:** after merge, the row is edited to add the landed commit and
   the base it should be read against — for a squash, the squash commit and its first
   parent. The row key is the cycle id, so the edit is idempotent. This edit touches
   `todos.md` only and is the row's own maintenance.

**Repayment protocol.** A **full tier-1 cycle** on the matched artifact — same floor, same
clean-final-pass rule, same profile lenses, same file validation. A single token pass does
not discharge it.

**Run it in a separate `git worktree`.** A repayment review calls the same `exec`/`review`
tools as a live gate, so run in the main checkout it would increment the current cycle's
counters and fingerprint the current workspace rather than the historical range. A separate
worktree has its own root and therefore its own `.context/`, which keeps repayment state
out of live gate state using tooling that already exists.

**Findings from a repayment land forward.** Remediation necessarily lands in a later commit,
so re-reviewing only the original range would keep seeing the defect. The debt is discharged
against **the original range plus the named remediation range**.

**Closing conditions, and only these two:**

1. The repayment ran to a clean final pass and every Blocker/Major is remediated, or
   dispositioned **by the human** — an agent may propose a dismissal and may not accept one
   for this purpose.
2. A **logged human decision** accepting the debt without the review — **and not in the
   cycle that created it.** The same mechanism must not both waive the gate and erase the
   obligation the waiver produced.

**Checked** whenever a tier-3 closure is authorized, and at the start of any Gate-B cycle in
a workspace with open rows. §13 records that nothing enforces this.

**Multiple cited stories:** per §5's existing rule each cited story satisfies its own
obligations, with no winning max. One row per cited story; one repayment discharges several
only if it names each.

## 8. Old-condition inventory — CLAUDE.md §5

Derived from §5 rather than summarized by theme, because a partial inventory is the specific
failure the AGENTS.md decision-procedure Don't exists to catch.

| §5 condition | Disposition |
|---|---|
| Two gates, cross-model reviewer | **Kept** — tier 1 is unchanged and is still the only reviewer |
| **The gate itself is not optional** | **OVERTURNED for tier 3**, deliberately and by name. Tier 3 is a waiver. This is the single most consequential condition this change touches |
| Minimum 3 passes, final pass clean | **Kept** at tier 1; **N/A** at tier 3, which has no passes |
| Zero-finding early exit below 3 | **Kept** |
| A satisfied pass count is not a clean review | **Kept** |
| Blocker/Major must resolve; Minor/Nit collected | **Kept** |
| File-first findings, terminator, acceptance rules | **Kept** |
| An incomplete pass is not a review and is discounted | **Kept** |
| One shared recovery attempt per pass | **Kept**, and it is a tier-3 precondition (§3) |
| Resume passes `reviewType` with `sessionId` | **Kept**, untouched |
| Delete every target before each call, confirm gone | **Kept**, untouched |
| `reviewType: full` default and two-file acceptance | **Kept, untouched** — rider (a) moved to its own story |
| One-slot concurrency limitation | **Kept** as a stated limitation, untouched |
| TodoWrite a pass per Codex pass | **Kept**, untouched |
| A dismissed finding gets a one-line reason | **Kept** |
| Two separate Gate-A loops (spec, then plan) | **Kept**, and tier 3 is available to each independently |
| Mechanical sweep before each read pass | **Kept**, untouched |
| Profile resolution; stop on unresolvable | **Kept**, untouched |
| Evidence gaps: work gap vs setup gap | **Kept**, untouched |
| Story path + evidence entry on every Gate-B call | **Kept**, and the tier marker joins them |
| Re-review after every fix | **Kept** |
| A fix changing specified behaviour updates the spec | **Kept** |
| The standing falsification lens | **Kept**, untouched |
| Prose-vs-product classification | **Kept**, untouched |
| Final clean pass runs under the current profile | **Kept** |
| Timeout/abort handling | **Kept**, and feeds tier 3's precondition |
| Dispositions/resume companions are advisory | **Kept** — rider (b) narrows this in one named scope only (§10) |
| WIP is cycle-internal; amend closes the cycle | **Kept**, extended by §6's carry |
| `.off` opt-out; "the gates still apply" | **Kept, untouched** — §4 |
| Docs-only prose exemption | **Kept**, untouched |
| Gate-B triviality skip needs two conditions | **Kept**, untouched |

## 9. Sites

Found by searching the **claim**, not a prior phrase.

| Site | Change |
|---|---|
| `CLAUDE.md` §5 | Tier 3, the schemas, the carry chain, the debt, riders (b) and (c) |
| `/workflow-init` inline §5 mirror | The same edits — this is AC 9, and the mirror is a change surface for **every** §5 edit, verified by extracted parity |
| `/workflow-init` §2.13 | Init-time scope stated explicitly; **gateless answer unchanged** |
| `docs/coding-workflow.md` § *The two gates…* | The gate is no longer unconditionally mandatory; **heading not renamed**, `README.md` links its anchor |
| `README.md` product summary | The mandatory-gate claim gains the exception |
| `plugins/dev-workflow/.claude-plugin/plugin.json` | Its description carries the same claim |
| `.claude-plugin/marketplace.json` | Same claim in marketplace metadata |
| `AGENTS.md` § *What this project is* | Gains a clause admitting the waiver |

**Not changed:** the four same-model prohibition sites and `docs/sparring-briefing.md`. They
forbid a **same-model reviewer**; a human exception is not a model reviewing its own work.
Their accounting is inherited by the tier-2 story.

## 10. Riders

**(b) Canonical syntax, and a tolerant reader.** **Canonical:** severity is
`BLOCKER | MAJOR | MINOR | NIT`, uppercase — what the prompt demands of the writer.
**Reader:** normalization applies **only** to an otherwise-valid six-field line whose
severity field is non-empty and unrecognized; it maps to `MAJOR` — fail toward review. Every
**structural** failure stays INCOMPLETE: a missing field, an extra unescaped separator, an
empty severity, a wrapped continuation, or `NO FINDINGS` mixed with finding lines. The pass
is valid only if that pass's dispositions file records the token, the count and the mapping;
without the record it is INCOMPLETE. The recording is what makes the tolerance legitimate
rather than silent, and it is the one named scope in which the advisory companion becomes
required. Motivating incident: PR #23's Gate-B pass 3 returned all four findings at
`IMPORTANT`; the file was otherwise well-formed and passed every check.

**(c) Squash-merge carry** — §6, covering both markers and evidence entries.

## 11. Validation evidence

**Battery** — the `AGENTS.md` quality command, green.

**Prompt conformance** — every changed prompt artifact (§5, the inline mirror, §2.13) is
reviewed against all 12 items of `docs/prompt-standards.md`. The battery's two mechanical
checks cover one spelling each and are a floor, not coverage (invariant 11).

**Check that fails without the change.** Run one scratch tier-3 closure twice — once
following the **pre-change** §5 text, once the **new** text, same inputs — and assert the
canonical marker and the debt row appear **only** under the new procedure. This
discriminates: the old text has no marker rule, so its closing body cannot contain one.

**Named verification** — a state matrix, each row an observable outcome in a scratch
workspace:

| Case | Assertion |
|---|---|
| Gate-A spec waiver | marker in the spec commit body; identifiable from history alone |
| Gate-B waiver, full cycle | marker survives WIP → amend → squash; readable from `main` alone |
| Marker omitted | identification **fails** |
| Multi-WIP collapse | all markers collected; conflicting markers **stop the close** |
| Squash carry | tier marker **and** evidence entry both present on `main` |
| Hook at the closing commit | STOP fires, correctly — the floor genuinely is unmet |
| Debt row lifecycle | created pre-land, reconciled post-land, closes only on the two conditions |
| Debt accepted in the creating cycle | **refused** |
| Repayment in a separate worktree | live `.context/` counters and fingerprint **unchanged** |
| Enum drift with dispositions record | pass valid, mapping recorded |
| Enum drift without the record | pass **INCOMPLETE** |
| Structurally broken finding line | **INCOMPLETE**, never normalized |

## 12. Packaging and backlog

- `todos.md`: **occurrence 3** appended to the compound-commands row (story AC 8) — `git
  add` and `git commit` in one Bash call, empty staged set at `PreToolUse`, loose STOP;
  observed on PR #23's close. Same shape as occurrence 2 and, like it, a **false positive**
  — the safe direction under invariant 2. Appended to the existing row, never edited or
  duplicated.
- `prompt-vague-criteria` (severity enum) closes. `unverified-enforcement-claim` (sequential
  calls) **stays open** and its row re-points at the new hook story.
- **Gate-cycle slot collision — trigger fired, row stays open.** This cycle's pass 1 deleted
  its predecessor's `gate-a-spec-pass-1.md` and dispositions before the surviving 44
  artifacts were archived by hand under a `.pre-2026-08-14` suffix. The manual archive is
  the interim; the naming fix is still that row's own work.
- **New parked row:** tier-2 counting and containment, pointing at the tier-2 story.
- Version **0.8.2 → 0.9.0** (`plugins/dev-workflow/.claude-plugin/plugin.json`) with a
  `CHANGELOG.md` entry — invariant 12, since this changes paths under `plugins/`. Verified
  by `scripts/check-version-bump.sh` against the PR's base.

## 13. What this does not do

Residuals known at design time; the list is **not** exhaustive.

- **Tier 3 waives the gate.** A change closed this way has had **no** independent review,
  and the record says so rather than compensating for it.
- **Human authority is a prose block an agent can write.** Nothing verifies that a human
  authorized a waiver. Every schema in §5 is a **recorded assertion**, not proof — nothing
  binds a marker to a validated artifact or to an actual human interaction.
- **Nothing detects availability's return.** The debt check is an instruction at named entry
  points; no automation fires, and nothing fails if a row is never closed or never
  reconciled.
- **The squash hop depends on whoever merges.** The post-merge read is an instruction; a
  corrective commit is the only remedy once the body is written.
- **`main`'s history can be rewritten.** A later force-push can remove a marker, and nothing
  detects it.
- **Rollback:** reverting the ladder prompts leaves markers and debt rows in place, as
  records of what happened — but removes the procedure that knows how to service them.
  Open debts should therefore be repaid or explicitly accepted **before** rollback; nothing
  enforces that either.
