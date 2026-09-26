# Gate A — spec — pass 5 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
14 findings: 11 Major, 3 Minor. All fourteen read as correct. **None applied** — the pass is
not clean, and the pinned exit sends anything new to Daniel.

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Same as pass 4.
(Recorded here rather than in the findings file: CLAUDE.md §5 admits no line there that is not
a finding line or the terminator, so a model line would make the pass malformed.)

**Seven of the eleven Majors are defects in the pass-4 fixes**, not in pre-existing text:
1, 2, 3, 4, 5, 6 and 10 all land on §7's rewritten checks or on §9's new residual bullet. The
fixes were written and reviewed in the same pass; this is what the next pass is for.

## Verified mechanically, not taken on the reviewer's word

| # | Claim | Result |
|---|---|---|
| 2 | a `grep -F` pattern beginning with `-` parses as an option | **Reproduced.** `grep -cF '- <date> · …' file` → `invalid option`. With `-e` it returns `1`. |
| 3 | `grep -c` counts matching *lines*, not occurrences | **Reproduced.** `printf 'aa xx aa\n' \| grep -cF 'aa'` → `1`, not `2`. Fatal after wrap-normalization collapses a paragraph to one line. |
| 12 | an append-only claim survives outside the change surface | **Confirmed.** `docs/coding-workflow.md:204` — "strictly append-only: history is never rewritten". Not in §4. |

| # | Sev | Verdict | Reason |
|---|---|---|---|
| 1 | Major | **Valid** | `N="$(unwrap "$F")"` captures *content*, then `grep … "$N"` uses it as a *filename*. The block is presented as commands that "must report `1`", so it has to be runnable. |
| 2 | Major | **Valid, reproduced** | The two anchors added in pass 4 to validate the format lines are exactly the two that cannot run. |
| 3 | Major | **Valid, reproduced** | Assertion 1 claims exactly-once cardinality and cannot measure it. Worse after normalization, which is the pass-4 fix that created the exposure. |
| 4 | Major | **Valid, and the pass's most important finding** | The anchor list does not support "dropping any decision §2 settles removes at least one" — the unknown-provenance default, the wrong-when-written cause, the recurrence effect, the locator fallback, the cumulative rule, cite-don't-restate and the union-merge repair are all droppable with all seven anchors intact. That claim is the AGENTS.md "never describe what a gate proves" class, committed inside the fix written to close that class. |
| 5 | Major | **Valid** | Check 3's assertions 1–3 exist only as `#` comments, and assertion 4's desired zero-match exits nonzero. Presented as mechanical; not executable. |
| 6 | Major | **Valid** | A live entry in the template without a label passes assertion 4, and §7 says check 1's named read catches it — but that read examines the repo ledger only. A second overclaim, same class as 4. |
| 7 | Minor | **Valid** | Story §1 still states the un-narrowed rule in the present tense. Defensible as pre-change framing, but it is the story's own §1 against its §1 accounting. |
| 8 | Major | **Valid** | Both fallbacks require a distinguishing fragment; neither format line shows where it goes, and the correcting line gives no per-retired-entry fragment slot. The pass-4 fix named the right field and never placed it — the same words-not-mechanism failure pass 4 found in pass 3. |
| 9 | Major | **Valid** | The six verdicts all come out as the spec says. But the cycle *close* is still defined only as "the commit that replaces the `WIP:` snapshot", so a trivial/N-A commit, an abandoned change and interleaved work have no close. Pass 4's opening fix moved the ambiguity rather than removing it. |
| 10 | Major | **Valid** | §9's new bullet asserts A's amendment "does not move" date + fingerprint. Nothing freezes either field, so B's locator can dangle, not merely lose its fallback. The residual was written as bounded without establishing the bound. |
| 11 | Major | **Valid** | Story §2 still promises a reader can tell whether *any* row describes current behaviour — the exact requirement AC 4 was amended away from. §2 was amended in pass 3 for the append-only clause and its first clause was not re-read against AC 4. |
| 12 | Minor | **Valid, confirmed** | The standing falsification lens working: `docs/coding-workflow.md:204` teaches the absolute rule and is outside §4. |
| 13 | Major | **Valid** | "Wrong when it was written" admits a row whose *hardening identity* — rung, ref, fingerprint — was never true, while the same paragraph says supersession never touches the hardening and the row keeps counting. A nonexistent hardening would stay in recurrence lineage and escalate. |
| 14 | Minor | **Valid** | The correcting line carries one row locator but the prose lets it retire "exactly the entries it names", with no requirement they concern that row. |

## Decision needed from Daniel

Findings 1, 2, 3 and 5 are mechanical and cheap — the check blocks need to become runnable
shell. Findings 4, 6 and 10 are overclaims and each has the two-way exit Daniel already set for
finding 10 of pass 4: validate it or state in §9 that nothing validates it. Findings 9 and 13
are convention-text decisions. Findings 8, 11, 12 and 14 are contained edits.
