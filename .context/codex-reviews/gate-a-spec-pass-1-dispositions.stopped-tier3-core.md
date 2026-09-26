# Gate A — spec — pass 1 dispositions (stripped design)

28 findings (4 BLOCKER, 20 MAJOR, 4 MINOR). None dismissed. Enum held a seventh time.

## The strip worked

| Cycle | Blockers by pass |
|---|---|
| Three-tier | 4 → 4 → 6, stopped |
| Two-tier with debt machinery | 7 → 8 → 12, stopped |
| **Stripped** | **4** |

More important than the count: **none of the four says the mechanism cannot exist.** Every
prior cycle's blockers were "this control is unenforceable" or "this state needs the gate
that is unavailable". These four are ordinary design holes with named fixes.

## Blockers — all accepted, fixes taken

**3. The outage calls are not required to be canonical gate calls.** `attempt-failed` also
admits a failure that happened *after* a review actually ran — an output-write or validation
failure. So unavailability can be manufactured: send a malformed request, point at the wrong
tool, or induce a findings-write failure, and then waive a reviewer that was perfectly able
to review. This contradicts the stated "cannot run at all" boundary. **Fix:** the initial
call, the recovery and the revalidation must each be a **canonical gate call** — correct
tool, correct working directory, the current artifact or range, the cited story paths and
evidence entries — and a request-shape, validation or output-protocol failure is explicitly
**not** proof of unavailability. The marker records which canonical call class failed.

**6. A Gate-A waiver does not require a docs-only closing tree.** Nothing stops a staged
prompt, script or code change riding inside the Gate-A closing commit under an A-spec marker,
with §4's precedence rule excusing the Gate-B STOP it would raise. That is a second gate-off
path in the dangerous direction. **Fix:** a Gate-A waiver requires a **positively determined**
docs/artifact-only tree containing the named artifact and allowed supporting prose, records
the complete prospective tree id, and refuses any mixed or product path outright — no
separately authorized Gate-B waiver riding along inside it.

**7. Nothing atomically compares the authorized tree with what `git commit` writes.** "If the
tree changes, re-authorize" is a rule with no observation behind it, and another process can
mutate the index between check and commit. **Fix:** commit from a dedicated fixed index,
compare the committed tree id to the authorized tree id immediately afterward, and define the
mismatch path as an incident requiring re-authorization.

**9. Gate-A authorization is consumed too early to survive the reminder it must survive.** The
close happens at the docs commit, but the hook emits the Gate-A below-floor reminder later, at
`executing-plans` — and §4 grants precedence at *one* closing transition while telling later or
resumed sessions to obey the hook. A correctly waived plan therefore cannot proceed to
implementation. **Fix:** define the continuation rule explicitly — how the next skill
invocation discovers and validates the immediately preceding A-plan marker across a resume —
rather than pretending the authorization is spent where the reminder is not.

## Majors that change the document's claims

**1. §2's structural argument is a false dichotomy, and it is mine.** It presents
unenforceable prose and recursively gated state as the only options, when a CI rule, an
append-only check or a protected external record could preserve the record without asking the
unavailable reviewer to review each transition. Removing the debt machinery was a sound
**cost and trust decision**; calling it structurally impossible overclaims, and it tells
future readers not to evaluate feasible alternatives. **Fix:** recast §2 as the trade-off it
is, name the alternatives considered and why each was rejected, and keep §12's trigger.

**23. The `+check` harness does not exist as an artifact.** Withdrawing the mode override
rested on a "prompt-harness scenario", but the repository has no such harness and the design
names no driver, fixture, oracle, command or repeatability criterion. Calling an unspecified
future scenario a check is the unverified-evidence claim the withdrawal was meant to fix.
**Fix:** specify it concretely — frozen old/new prompt inputs, the exact scenario, the
observable assertion per precondition branch, and how a nondeterministic agent result is
handled — with rider (b)'s automated `IMPORTANT`-fixture check carrying the mechanical half.
If that specification cannot be made concrete, the evidence gap returns and needs a valid
**whole-mode** human-confirmed override, not the withdrawn per-portion one.

**14. A surviving dependency on the removed machinery, in the story.** Story §5 still says the
profile "scales the repayment" while the design now defines no repayment at all. The
withdrawal is incomplete until that is amended.

## Majors — accepted without further comment

2 (Gate-A evidence is close to vacuous — needs a non-vacuous checklist and durable result, or
must be labelled syntax hygiene rather than compensating evidence), 4 (no transition table from
a fresh observation to an enum value), 5 (revalidation happens before an unbounded human pause;
needs a max age and a final probe **after** the answer), 8 (authorization binds to the tree but
the marker, evidence entry and decision live in the commit *message*, which is not in a tree),
10 (no fail-closed rule when a prior findings file is missing or unreadable — and this cycle
has already lost artifacts to slot collision), 11 (the decision block has no `Gate:` field but
is keyed by gate), 12 (no grammar, escaping, length bound or timezone for handles and reasons
interpolated into a line-oriented protocol), 13 (ordinary merge is permitted but only the squash
chain is specified), 15/16/17/18/19 (five more inventory dispositions wrong **by effect** —
recovery-by-source, Gate-A's two loops, the lens sets having no prompt to attach to at tier 3,
profile resolution not required at Gate A, and the skip rule marked untouched on the same
noun-based reasoning row 49 correctly rejects), 20 (`docs/pr-review-bots.md` asserts every PR
head has passed Gate B — a site I missed), 21 (`docs/coding-workflow.md`'s "What is essential"
section names two independent gates as load-bearing — also missed), 25 (rollback ignores
downstream scaffolded copies and version-keyed plugin caches), 28 (Gate B's precondition says
"the profile's mode" singular where §5 requires per-story modes, suffixes and lens unions).

## Minors — collected

22 (marketplace.json does **not** actually carry the two-gates claim — my site row asserts a
premise the file does not support, and the mechanical sweep should have caught it), 24 (§5.1
cross-references §11 for validation; validation is §10), 26 ("a line on main that every reader
sees" overstates commit-body visibility), 27 ("later sessions treat the hook as authoritative"
still implies authority the hook lacks).

## Status

Not clean; floor not met. No new decisions needed — every fix above is takeable without
Daniel, including 23's, which is a specification task inside his standing "+check stands"
instruction.
