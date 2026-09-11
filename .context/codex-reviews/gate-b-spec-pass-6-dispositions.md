# Gate-B pass 6 — dispositions (spec branch) + the systematic check-claim sweep

Range f9ed886..556cbfe. Spec branch: 4 findings, all verified accurate before acting.
Quality branch was not run at this commit — the sweep below changes the spec, so both
branches run together at pass 7.

**Human decision, taken at the stop:** replace incremental site-by-site correction with one
systematic sweep of every check-claim sentence in §4, §6 and §8, fixed as a single edit set,
with the inventory recorded here. Reason: findings 1 and 2 below were *introduced by this
cycle's own earlier fixes* — one site corrected, its synonym left standing — which is the
defect class `AGENTS.md` names as the repo's most persistent, recurring inside the review
meant to catch it. Patching instances was reproducing it.

## The sweep — method

`grep -nE 'check ?1|check ?2|check ?3|C1[a-f]|catch|detect|validat|enforce|prove|guard|confine|
reject|nothing (checks|consumes)'` over §4 (370–403), §6 (419–706) and §8 (743–931), then every
hit read against what the harness actually does. A second pass grepped the scope-overclaim
vocabulary — `anywhere`, `whole file`, `entire file`, `unconstrained` — because that is the
wording the earlier misses hid behind.

## Inventory — claim → what the harness does → verdict

| # | Site | Claim | Harness | Verdict |
|---|---|---|---|---|
| 1 | §6 preamble | "each check gives the observation that fails without the change" | `C1b`/`C1c` pass on the untouched base by construction; `1e` unimplemented | **WRONG — fixed** |
| 2 | §6 `1d` oracle | "the mandated entry, and only entries this change **adds**" | selects by date+rowdate+fingerprint, *then* proves absent at base | **WRONG — fixed** |
| 3 | §6 Check 3 intro | "check 1 matches the entry anywhere in the file" | `C1a`/`C1d` confine candidates to the label-to-`Columns:` interval; an absent/duplicated/reversed interval exits 2 | **WRONG — fixed** |
| 4 | §8 held item 3 | marked `*Done:*` at pass 3 | the *check* was fixed then; the oracle wording only now | **INCOMPLETE — fixed** |
| 5 | §4:393 | "check 2 treats a missing end sentinel as a failure, anchors fail first" | `C2a` runs before `C2b`; both fail pre-change | accurate |
| 6 | §6:512 | "no check validates pre-existing entry immutability" | nothing does | accurate |
| 7 | §6:593 | "check 1 would pass with the template untouched" | `C1a`/`C1b`/`C1d` read only the ledger; `C1c`'s paragraph is identical either way | accurate |
| 8 | §6 Check 3 "what it does not do" | "confirms only that the template carries no *label*" | `tpl_label_count_is_zero` counts the label alone | accurate |
| 9 | §8:744-754 | "three checks run once, nothing standing" | true; correctly says "beyond check 1's one-time assertion" | accurate |
| 10 | §8:790-792 | "a live entry in the template without a label is caught by nothing" | `C3` tests the label only; `C2`'s region ends at the sentinel, above the block | accurate |
| 11 | §6:486 | 1c's four-input guard rationale | delimiters asserted present and unique in all four inputs before any comparison | accurate |
| 12 | §6:548, 587 | "nothing validates fragment-narrowed matching / entry prose" | no fragment in this change; `1f` is a human read | accurate |

Four wrong, eight accurate. The four were fixed in one edit set; nothing else in §4, §6 or §8
makes a check-claim that the harness contradicts.

## The fixes

1. **§6 preamble** now splits falsifying observations into two kinds and names the labels:
   `1a`, `1d`, `2a`, `2b`, `3` fail on the untouched base; `1b` and `1c` are protective and
   green there by construction; `1e` is unimplemented; `1f` is a named read, not an executable
   label. Matches the plan's own per-label table exactly, which was checked before writing.
2. **§6 `1d`'s scope oracle** now states the two-step order — identify the §3.1 entry by its
   fields, *then* prove it absent at base — and says why the order must be stated rather than
   inferred from this change, where the base carries no block and the steps coincide.
3. **§6 Check 3's introduction** now says what check 1 already establishes (interval
   confinement, undecidable-interval handling) and limits check 3 to the actual remainder:
   the sentinel lower bound, entry-shaped lines outside the interval, blank-line structure,
   and the template label.
4. **§8 held item 3** now records that the check was corrected at pass 3 and the oracle wording
   only at pass 6 — with the gap named, since the item stood marked done in between.

## Finding 3 — the plan. Human decision: leave it.

Plan line 243 specifies `entry-bad-date-entry` as `2026-02-30`; the harness uses `2026-08-32`.
**The plan is not amended.** It landed in `f9ed886`, outside the reviewed range, and is the
record of what was intended at execution time — this repo does not rewrite executed plans to
match later rules (§4's change-surface row says exactly that of another plan). No `todos.md`
row either: a historical record needs no reconciliation.

**Why the harness diverged, stated in full and carried into the commit body:** `2026-02-30` is
lexically *earlier* than the locator's `2026-07-20` row, so with calendar validation removed it
is still rejected — by the on-or-before bound — and the fixture proves nothing about the
property it names. The fixture value must be calendar-invalid **and** lexically on or after the
locator row date. `2026-08-32` is both. Mutation-tested: replacing `isdate` with a shape-only
check flips exactly that row and `entry-bad-date-locator`, leaving the other 28 unchanged.

## State after this pass

Battery green. Harness green: 30 matrix rows, 0 disagreements under `sh` and `dash`; C1/C2/C3
0 failures on the real tree. Fixes amended into the WIP; pass 7 runs both branches.
