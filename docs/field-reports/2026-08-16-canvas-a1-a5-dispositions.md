# Dispositions — canvas A1–A5 field report (round closed 2026-08-17)

Input: `2026-08-16-canvas-a1-a5-field-report.md`. Story:
`docs/superpowers/stories/2026-08-17-field-intake-canvas-a1-a5-report-story.md`.

Honoring the report's own terms: every claim was verified at its cited evidence before adoption,
nothing unverifiable was adopted, and a rejection with a one-line reason is a complete outcome.

**The consumer repo was read-only throughout**, and the claim is stated at the precision it can be
held: every command this round issued against it was a read (`git log`, `git status`, `git diff`,
`ls`, `grep`, `sed -n`, `cat`), and no write, stage or commit was issued. Its `index.html` does
carry an uncommitted modification (49 insertions, 4 deletions) whose mtime falls inside this
session's window — that is the consumer's own in-flight A5/T3a work, consistent with the four
`WIP: A5/T3a` commits at its HEAD, and it is named here rather than glossed because "the repo is
unchanged" would be a stronger claim than a read-only round can make about a tree someone else is
working in.

**One disposition per item, and the eleven are exhaustive.** Where a disposition lives elsewhere,
this table points at it rather than restating it; the one rejection and the validation result
live here because they have no other home.

| # | Subject | Disposition | Where |
|---|---|---|---|
| 1 | Fingerprint computation/storage | `todos.md` row, § Parked | "Two consumer Gate-B cycles closed with no usable fingerprint persisted" |
| 2 | Commit-detection by command-string grep | `todos.md` row, § Parked | "A mere mention of \"commit\" beside a `git` command…" |
| 3 | `mcp-codex-dev` envelope swallows the reason | Upstream-candidate note, § Next | filed against `mcp-codex-dev`, not fixed here |
| 4 | `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS` in setup docs | Second field evidence appended | the `/workflow-init` preflight row, § Next |
| 5 | Absorb-vs-stop ruling | `docs/hardening-log.md` row via `harden-finding` | `prompt-missing-stop-condition`, `P std` — the rung it records is the §5 + template edit |
| 6 | Arms-race remedy as procedure | Parked as a story | `docs/superpowers/stories/2026-08-17-arms-race-remedy-as-procedure-story.md`, indexed by its `todos.md` row |
| 7 | Session framing for dense tranches | **Rejected** — see below | this file |
| 8 | Spec-size / stuck-criterion | `docs/hardening-log.md` row via `harden-finding` | `prompt-vague-criteria`, `P std` — same §5 + template edit |
| 9 | Handbacks carry context-% | `todos.md` row, § Parked | "A handback says nothing about how much context produced it" |
| 10 | Proportionality for instrument-subject findings | `todos.md` row, § Parked, marked EXPERIMENTAL | trigger named |
| 11 | Pre-split heuristic | `todos.md` row, § Parked, marked EXPERIMENTAL | trigger named |

**Item 8 carries an extension, added by the maintainer during the Gate-B cycle:** a **reporting
duty**. From pass 4 onward every pass report states three lines — the trend in findings and Blocker
counts across passes, where this pass's findings cluster (product behaviour, the test instrument, or
prose about either), and any require↔withdraw pair against earlier passes. Those expose five tells,
and **any two present makes stop-and-surface mandatory rather than discretionary**, with the stuck
reading explicitly not a precondition. Its recorded rationale is the maintainer's, not a measurement
of this repo: in another consumer all five signals were measurable by day two of a week-long loop,
and the cost was never detection but the absence of a duty to say so. It landed in the same §5 edit,
the same mirror and the same Gate-B cycle, and it is the same disposition as item 8 rather than a
twelfth item — the report's list is unchanged at eleven.

The duty was exercised on this cycle immediately: pass 5 showed the finding count rising and its
findings clustering on prose about the instrument, and the Blocker count failing to fall — it rose
from 0 at pass 4 to 4 at pass 5. **Three** tells, against a threshold of two. What is *not* among
them is a require↔withdraw pair: pass 4 required clean-completion precedence and pass 5
*qualified* it with the floor, where the tell is defined as a pass demanding what an earlier pass
had removed. Three tells made the stop mandatory rather than a judgement call.

**Reading the table.** Items 5 and 8 share one §5 edit, one version bump and one Gate-B cycle:
they are two rules landing in two adjacent paragraphs of one §5 block (and its template mirror),
and splitting them would put two cycles on one diff.
Their disposition is the **ledger row** each received — the prompt codification is the rung that
row records, not a sixth disposition form. For item 6, the disposition is the **story**; its
`todos.md` row is that story's index entry, which is how every parked story in this repo is
tracked (Finding A, Finding B, tier-2, sequential-branch-calls all carry a row *and* a story), so
the pair is one disposition and not two owners.

## The one rejection

**Item 7 — session framing for dense tranches. Rejected on scope: the artifact half already
ships, and the framing half is one consumer's session habit with no recurrence behind it.** The
resume-note-and-WIP-chain half is `CLAUDE.md` §5's "Optional companions, from field practice"
paragraph, which sanctions a cycle-stable resume note as first-class and cites *this same
consumer* as the field practice it came from. What remains is the framing — opening a session with
"advance until closed, clean stops as needed" instead of "close X". That half is **not** rejected
for having no surface: a scaffolded `CLAUDE.md` is read as session instructions and could carry
it, so the surface exists. It is rejected on **transferability**: the framing is one project's
session-opening preference, adopted once and measured nowhere, and a framing rule that turns out
wrong is read and followed by every downstream project. No policy claim is made here — this repo's
reactive-only rule permits hardening anything real use surfaces and imposes no recurrence
threshold, as items 5 and 8 in this same round demonstrate by shipping on first occurrence. The
trigger below is therefore **chosen for this item**, not quoted from policy. *Reopens when:* a
second project adopts the framing independently, or a half-built tranche under review is traced to
its absence.

## Part 3 — the validation result

**Both characterization baselines are byte-unchanged across the five A5 tranche commits**
(`5a4bf38` T0, `50184c5` T1a, `4ccf7e4` T1b, `67be9d5` T2a, `f09286b` T2b): no commit touches
`test/baseline.json` or `test/a3-baseline.json` after `f41c545`, which precedes all five, and
`.context/a5-t2b-baseline-diff.md` records `BASELINE MATCHES` / `A3 BASELINE MATCHES` per run
without the recorder being invoked.

That is the observation, and the line above is deliberately the whole of it. The report reads it
as proof that the pass floor, findings-to-file, WIP/amend mechanics, quote-before-edit and
severity discipline work as designed; this round does **not** adopt that inference. Unchanged
committed baselines establish the committed boundary bytes and nothing about which rule produced
them — the same history is compatible with any of those five mechanisms being broken and the
outcome surviving for another reason. It is a good result and it is not a causal one. No change
follows from it either way.

## The ledger rows, and the guard-scope precheck that preceded them

Items 5 and 8 were hardened through `dev-workflow:harden-finding` and appended two rows dated
2026-08-17, at rung `P std`, both `manual`/`major`: `prompt-missing-stop-condition` (nothing said
what a loop may absorb) and `prompt-vague-criteria` ("clearly stuck" named without a criterion).
Each row states the guard it installs **and** what that guard does not cover, so a later
recurrence can be judged rather than counted.

The anchored column-2 grep returned **no match** for either class, so neither is a recurrence and
nothing escalates. The precheck was still run manually against the nearest candidates, quoting the
guard examined in each case:

- `prompt-diagnostic-cause-unnamed` (2026-07-18), guard `docs/prompt-standards.md` item 10, filed
  for a preflight that "reported \"restart the session\" for every not-loaded codex, hiding a
  same-named server winning on scope precedence". The guard, quoted: "**Diagnostic states name
  their causes.** A prompt that reports a failure state (\"NOT LOADED\", \"MISSING\",
  \"unavailable\") enumerates the distinct causes that produce that state, gives a check that tells
  them apart, and pairs each with its own fix." Result: **outside**. A loop's exit criterion is not
  a failure state a prompt reports, so that rung never claimed this shape, did not fail, and
  supplies no escalation.
- `mechanical-check-skipped-before-review` (2026-08-04), whose guard reads "before each read pass,
  settle mechanically what the artifact asserts and a machine can decide without side effects —
  cited paths, quoted passages, stated counts, the syntax of standalone fenced blocks". That
  governs what a pass settles **before** reading. Result: **outside** — when the loop stops is not
  something a machine can decide without side effects, which is the guard's whole domain.
- `rewrite-drops-prior-condition` (2026-07-27) is not a candidate for recurrence — no finding here
  matches it — but its guard governs *this* change, since the §5 edit amends a decision procedure.
  The guard, quoted from that row's `ref`: "AGENTS.md Don'ts, \"Never replace a decision procedure
  without accounting for its old conditions\" — list what the previous prose required and mark
  each kept, moved, or deliberately dropped; also check the paragraphs around any criterion you
  amend". Result: **in scope, and applied** — accounted for explicitly, the floor, the
  Blocker/Major filter and the clean-final-pass rule are each named as **kept** in the shipped
  sentence, because "stops the loop" without them reads as a licensed below-floor close.

**One observation, recorded rather than acted on.** `todos.md` says the 2026-08-16 severity-enum
closure classified itself `prompt-vague-criteria`, rung `P std` — and no such row exists in the
ledger, which is why today's row is the first of that class. So a hardening was applied and never
reached the ledger, on a change that *did* go through a PR. That is one more instance of the gap
the Finding A story owns, and it is left as an observation here: appending a row for someone
else's closed change after the fact would put a date on it that its own cycle never had.

## The named verification behind the `battery+check` entry

The story's mode is `battery+check`, and for a change that is *only* prompt text no automated
test can adjudicate whether the prose decides anything. Two weaker checks were tried and rejected
by the gate: a keyword grep of the prior file (pass 1 — a self-supplied lexical oracle, since the
keywords came from the new prose), then a paragraph diff plus mirror-parity comparison (pass 2 —
which establishes that nothing was silently replaced and that the copies agree, but would pass
equally if both copies omitted the same clause). What follows replaces them.

**Method.** Nine review states are put to the *old* text (`17d5ad3:CLAUDE.md` §5) and the *new*
text (HEAD), and then independently to the `/workflow-init` inline template at both revisions,
since a rule can be present in one copy and absent from the other. Each state carries **complete
inputs** — floor status, set membership, ancestry, severity, and for a candidate stop all three
exit conditions — with **one** expected output per question.

Two questions are scored separately: **scope** (is this finding inside this loop, or does it stop
the loop?) and **action** (resolve, or collect?). The old text already decided *action* by
severity and this change does not touch that rule, so action is expected to agree everywhere —
that agreement is the check, not a score. Rows where a question does not arise are `n/a` and are
not scored.

| # | Floor | In set | Ancestry | Severity | Plateau | Coverage sufficient | B/M regenerating | Old → scope/exit | New → scope/exit | Action |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | met | yes | corrects last correction | MAJOR | n/a | n/a | n/a | undecided | in scope, keep it here | resolve |
| 2 | met | yes | corrects last correction | MINOR | n/a | n/a | n/a | undecided | in scope, keep it here | collect — ancestry grants no repair round |
| 3 | met | **no** | corrects last correction | MAJOR | n/a | n/a | n/a | undecided | **stops the loop** — out of set, though it opens no new question | resolve once the set is settled |
| 4 | met | n/a | opens a contract question the tranche never owned | MAJOR | n/a | n/a | n/a | undecided | stops the loop, surface; not a gate exit | resolve once answered |
| 5 | met | yes | both — corrects last correction *and* opens a new question | MAJOR | n/a | n/a | n/a | undecided | stops the loop; novelty overrides ancestry | as case 4 |
| 6 | **met** | yes | corrects last correction | MINOR only, no B/M open | pass came back B/M-free | yes | no | **decided already**: clean final pass → close | same — clean completion takes precedence | collect |
| 7 | **below** | yes | corrects last correction | MINOR only, no B/M open | n/a | yes | no | **decided already**: only a zero-finding pass exits below the floor → keep looping | same, and now said explicitly | collect |
| 8 | met | yes | corrects last correction | MAJOR, a new one each round | yes | yes | **yes** | undecided — "clearly stuck" has no criterion | stuck reading available; surface with the finding open, cycle not closed | resolve |
| 9 | met | yes | corrects last correction | MAJOR, a new one each round | yes | **no** — coverage never measured, a subsystem possibly unreviewed (the consumer's `docs/hardening-taxonomy.md` states exactly this) | yes | undecided — and a plain reading stops | exit **forbidden**: no affirmative sufficient-coverage judgement, and a known unreviewed area disqualifies it | resolve; keep going |

**Scored honestly, which is not 0-of-9.** On the seven rows where scope or the stuck exit is
genuinely open (1–5, 8, 9) the old text decides **0 of 7** and the new text **7 of 7**. Cases 6 and
7 are the control rows: the old text **already decides both**, via the clean-final-pass rule and the
floor's zero-finding exception, and the new text must agree rather than override — an earlier draft
did not, which is what makes them worth keeping. On **action** both texts agree in all nine rows.

**The template scores identically** at both revisions on all nine rows, which is the point of
running it twice: the counterfactual for "the rule reached only one copy" is a row where the two
disagree, and there is none.

Cases 6 and 8 are the pair that carries the most weight: they differ in whether Blocker/Major
findings keep regenerating, and they must come out differently — clean finish versus plateau. An
earlier draft collapsed them into one row that declared a converged loop "stuck", which would have
produced a false non-convergence report.
**A second table, because the first one cannot see the reporting duty.** The nine states above score
*scope* and *action*, and neither input changes when the pass-4-onward reporting duty is deleted or
reversed — all nine results would stay identical. That is a coverage hole, not a passing result, so
the second of this round's two loop rules is scored separately, on its own inputs. Deleting the duty
from both copies flips R2–R5; raising its threshold from two tells to three flips R4 and R5; moving
the three lines from the status report into the findings file or the Codex reply flips the carrier
column in R2–R5.

| # | Pass | Tells present | Old → required | New → required | Carrier |
|---|---|---|---|---|---|
| R1 | 3 | 1 | nothing | nothing — the duty starts at pass 4 | n/a |
| R2 | 4 | 0 | nothing | the three lines: trend, cluster, require↔withdraw | the agent's own status report |
| R3 | 4 | 1 | nothing | the three lines; stop **not** mandatory on one tell | the agent's own status report |
| R4 | 5 | 2 | nothing | the three lines; **stop-and-surface mandatory**, not discretionary | the agent's own status report |
| R5 | 6 | 2, and the "clearly stuck" reading unavailable | nothing | as R4 — the stuck reading is explicitly not a precondition | the agent's own status report |

R1 is the control: a pass below 4 must require nothing, and a draft that started the duty at pass 1
would fail here rather than pass silently. The old text decides **0 of 4** open states (R2–R5) by
being absent — `git show 17d5ad3:CLAUDE.md` has no reporting duty, no tells and no threshold — and
the new text decides **4 of 4**. Both copies score identically at both revisions.


**What this check has and has not caught, stated exactly, because "the matrix rejected three
drafts" was itself an overclaim an earlier pass had to remove:**

- **One draft it actually rejected.** Case 9 was run against HEAD and came out `undecided`: the
  wording then said coverage "stays a judgement you make and state", which a reader satisfies by
  stating coverage is *insufficient* and stopping anyway. Gate-B pass 2 raised the identical defect
  independently.
- **Four cases are retrospective regressions**, added after a gate pass found the defect, not
  before: case 2 (pass 3 — the absorb rule granting a Minor a repair round), case 3 (pass 4 — the
  dropped assigned-fix-set predicate), case 6 (pass 4 — a converged loop declared stuck), case 7
  (pass 5 — clean completion colliding with the floor). They are worth keeping as a regression
  suite; they are not evidence that this check would have found those defects on its own.
- **Two earlier attempts at this evidence were rejected outright**: a keyword grep at pass 1
  (self-supplied — the keywords came from the new prose) and a paragraph diff plus mirror parity at
  pass 2 (tested authorship, would pass if both copies omitted the same clause).

**What it does not establish**, the enumeration being the whole method: that either enumeration is
exhaustive — neither the nine scope/action states nor the five reporting-duty states — or that a
reader applies the decided answer. The axes the second table varies are pass number, tell count,
carrier, and whether the "clearly stuck" reading is available — R5 varies the last of these to
establish that the two-tell stop has no such precondition. That list of covered axes **is**
exhaustive. The axis it does **not** cover is which of the five tell predicates produced a given
count, so a deleted or inverted tell definition can leave every R row unchanged. That gap is
recorded rather than closed (`.context/codex-reviews/gate-b-fic2-parked-review-economics.md`).
This is a decision-coverage check on prose, not a behavioural test, and the mode's `check` is
satisfied by it only on that reading.

## What Gate B changed, and the one finding dismissed

Pass 1 (spec branch) returned 18 findings, five at BLOCKER. Four of the five were valid and are
fixed in this cycle; they are recorded here because two of them changed a *disposition*, which the
table above would otherwise present as if it had been right the first time.

- **Item 9's rejection was withdrawn.** The rejection rested on a search of the consumer's
  `.context/`, `todos.md` and `CLAUDE.md`; its `docs/handoff-cowork.md` was not searched, and it
  carries the field twice as an enforced protocol rule (lines 10 and 72). The item now has a
  parked row. A rejection is a valid outcome only when the evidence was actually exhausted, and
  here it was not.
- **The stuck criterion's figures were wrong and its claim too strong**, and they came from two
  different places, which the earlier draft of this record blurred: the line count, the Blocker
  start and the finding range came from the consumer's **memory note**, while the 34-pass total was
  **my own count of pass artifacts** in that repo, attributed to the record as though the record
  stated it. The consumer's `docs/hardening-taxonomy.md` is the later and stricter record of the
  same series: it retracts the exact line count from the evidence, gives the Blocker series as
  starting at 11 rather than 8, gives a range the memory note does not, and states plainly that *no
  instrument there measures coverage and a low Blocker count can coexist with an unreviewed
  subsystem*. The shipped rule now carries that
  caveat, and both ledger rows are corrected by supersession entries rather than edits, per the
  ledger's own convention that a row is immutable "committed or not".
- **Item 1's row inferred a hook mechanism it had not read.** A session-start `unavailable` is not
  sticky: every counted pass recomputes the fingerprint and overwrites the state file. Nor does the
  corrected row replace that with a different mechanism claim — the state write is best-effort, so
  an `unavailable` endpoint cannot separate a hash that could not be computed from a computed hash
  whose write failed. The row states the persisted endpoint values, the counts and the messages, and
  leaves per-pass computation and persistence unknown.
- **Item 4's row misdescribed the gap.** `README.md` § Setup step 2b already documents the
  variable fully, so "discoverable only by measurement" was false; the row now separates what the
  variable buys (long successful calls reaching the hook at all, *and* independence from C1's
  wording residual) from what is genuinely missing (the preflight check).

**Dismissed, one line:** the fifth Blocker held that `/capture-finding` was closed into Finding A
without the choice being put to Daniel. It was put to him and he chose it explicitly — Codex
reviews the diff and cannot see the session, so it read the absence of an in-repo record of the
exchange as the absence of the exchange.

Pass 1's remaining Minors and Nits were largely fixed rather than collected, because each was a
wrong sentence in a durable record this round is creating: the closure table's disposition labels,
the item-7 rejection's premise, a stale question count in the guard-scope story, and an internal
pointer in §5. Per §5 they were not iterated on.

## Three supersession entries in this round are themselves malformed, and what was done about it

Three entries appended during this cycle refer to another entry — "the entry immediately above",
"the earlier entry above", "the two above" — which the ledger header forbids outright: entries
"are never edited, never removed, and never reference one another". Gate-B pass 6 caught it.

The repair used is the only one the convention supplies: **append**. The header states it for a
mistyped locator — "corrected the same way everything else is, by appending" — and states that a
superseded entry is left "standing as history, like every other entry". So for each affected row a
later, self-contained governing entry was appended, naming every fault at the field that carries
it and referring to no other entry. Under last-entry-governs those are what a reader acts on, and
the malformed lines remain as history.

What this does **not** do, said plainly: it does not remove the malformed lines, and a reader who
stops at the first matching entry rather than the last will read a cross-reference the format
forbids. The convention names a repair for a mistyped locator specifically and says nothing about
an entry malformed in any other way; that gap is now a `todos.md` row rather than a silent
assumption that appending covers everything.

## One correction to the pre-triage

The pre-triage header reads item 1 as "NOT a hook defect", root-caused by auto-backgrounding and
collapsing into item 4. **The consumer's own entry does not support that**, and the row written
for item 1 says so. Backgrounding explains the *first* 2026-08-04 measurement, where the counter
was structurally zero. Item 1's evidence is the later measurements — 5 counted passes, then 24 —
taken with `CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS="0"` already set, where counting worked and the
close still drew a STOP for a different reason. Item 4 remains independently valid — as the
unbuilt **preflight check**, not as a documentation gap, since `README.md` step 2b documents the
variable in full; item 1 keeps its own row as an unexplained fingerprint defect. The instruction
to verify that entry is what surfaced this, and the collapse would have retired a live defect.

Two limits on the item-1 row, stated because it is the row a later reader will act on: this round
established neither whether the hash was computable at any given pass nor whether a computed hash
failed to persist, and it did not read the hook at the site that computes it. Its one new lead — that the second
shape's STOP arrived at a `git reset --soft`, which reaches the reset path only via `is_commit` —
ties it to the item-2 row and is a lead, not a finding.

---

## Field note added 2026-08-28 — criteria that restate the design are a Blocker generator

Observed across Gate-A passes 1–4 of the review-loop-economics cycle
(`docs/superpowers/specs/2026-08-28-review-loop-economics-design.md`): **five Blocker-severity
occurrences of one defect**, where the spec was revised and the story's acceptance criteria
still described the superseded mechanism — criterion 8 demanding a floor a risk-`high` story
cannot license; criterion 5 describing artifact-kind severity after a consequence-keyed test was
settled; desired outcome 2 keeping a false-green-only carve-out; criterion 3 reversing the
settled meanings of derived floor and hook knob; and criterion 4 requiring both shipped copies to
describe a mechanism the design had deleted — where implementing the criterion would have
recreated the rejected design in order to satisfy a criterion about it.

The cause is structural rather than carelessness: those criteria embedded **mechanism detail**,
so each had to track a design still in motion. A criterion that restates the design is a second
copy of it, and this repo's ledger already records what a second copy does — "a restatement is a
second copy that can drift".

Remedy applied in that cycle: the criteria were rewritten to state **what must be observably
true** rather than **how**, with the bound that a criterion which cannot be made observable
without naming mechanism is one where the mechanism *is* the contract, and there it stays named.

**Captured, not acted on beyond that cycle.** This is field evidence for whoever next touches
`dev-workflow:intake`, whose story template says acceptance criteria "describe observable
outcomes or constraints, never implementation steps" — the rule exists; what this record adds is
five measured occurrences of the failure it is meant to prevent, and the observation that the
drift shows up as *Blockers in a later gate* rather than as a bad-looking criterion at intake
time.

**Also observed, 2026-08-28, same cycle:** three occurrences of an agent ending a turn on an
announcement — "writing the spec now", "running pass 6" — with the named tool call never issued.
Each cost a round-trip and one cost ~90 minutes of wall clock before a peer session noticed. No
error, no timeout, nothing in flight: the announcement simply replaced the act. Remedy adopted for
the remainder of that cycle: during an active gate cycle a turn ends with the tool call actually
issued, a message sent, or an explicit statement that something is blocking — and noticing the
turn ending with the call not in flight *is* that statement.

**Prediction recorded 2026-08-28, before the pass that tests it.** Gate-A pass 7 of the
review-loop-economics cycle found that the spec's own nineteen-row condition-inventory table (§6.2)
had become the loop's largest finding source: **7 of 29 Blocker/Major, including 4 of 9 Blockers**,
every one a row contradicting the design it existed to account for. The table was split out —
method and passage list stay in the spec, the row-by-row dispositions move to an artifact produced
once against frozen text and gated before implementation.

Verbatim prediction, so it can be scored rather than remembered: **pass 8 should lose roughly 7 of
29 Blocker/Major and 4 of 9 Blockers to the §6.2 removal. If pass 8 does not fall materially, the
generator is elsewhere and the whole-artifact split becomes the live candidate.**

Worth keeping either way: this is the third site of one defect class in a single cycle — a
restatement that must track a moving original. It appeared in the story's acceptance criteria
(five Blocker occurrences), then inside the spec's own accounting table (four more). The lesson is
not "write the table more carefully"; it is that a second copy of a moving thing drifts, and the
remedy is to produce it once against something that has stopped moving.
