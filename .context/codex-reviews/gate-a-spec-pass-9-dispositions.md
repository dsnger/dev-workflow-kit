# Gate A — spec — pass 9 dispositions (salvage cycle) — **GATE A CLOSED**

9 findings (0 BLOCKER, 8 MAJOR, 1 MINOR). **None dismissed. All 9 applied.**

Closed under the exit Daniel pinned before the pass ran: *one confirming pass 9; clean or
dispositions-only closes Gate A; anything else becomes named residuals and it closes anyway;
no pass 10.* Every finding turned out cheap and to touch either shipped text or an orphan, so
**all were fixed and no residuals are carried.**

## The cut worked

| Pass | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |
|---|---|---|---|---|---|---|---|---|---|
| Findings | 15 | 25 | 23 | 20 | 16 | 12 | 16 | 17 | **9** |
| Blockers | 3 | 2 | 5 | 4 | 0 | 0 | 0 | 0 | **0** |

**17 → 9, and five consecutive zero-blocker passes.** Cutting the specification layer nearly
halved the finding rate in one step — the first structural change all cycle that moved it.
That is the termination assessment's diagnosis confirmed: the findings were living in prose
about prose, and deleting the prose deleted the findings rather than fixing them one at a time.

## What pass 9 caught, and it is a good final pass

**Two self-contradictions I introduced with the cut** — §5.2 requiring any out-of-region
occurrence to fail while its own fixture accepted a before-region copy alongside a correct one
(F2), and §2.3 still crediting the exception record with "a person re-reading the prospective
body (§2.4)" after §2.4 stopped specifying one (F8). Plus story AC 9 still promising the
enumerated anchors and extract-and-diff that the assessment deleted (F6).

**One correction that partly reverses an earlier resolution, and should.** F1: the canonical
severity line was being matched **case-insensitively**, which meant a Title-case copy of it
would pass — so the check could go green while a shipped file omitted the uppercase rule it
exists to establish. Daniel's earlier resolution was about the **reader**, and that stands
unchanged: `CLAUDE.md` Mechanics legitimately spells severities in Title case, and a model
copying that spelling is following instructions. But the canonical line is a *different
sentence*, newly written, and it is now matched byte-for-byte. **Writer syntax exact; reader
tolerant** — which is what rider (b) always meant.

**Three real gaps in shipped behaviour:**

- **F7** — a decision made after its commit closed had no destination on a branch heading for
  an ordinary or rebase merge: no next commit, no squash body, not yet merged. Now: **add an
  empty commit for it.** It changes no content, so it raises no review obligation, and a record
  with nowhere to go is a record that does not exist.
- **F9** — the reader never said whether to trim the whitespace the finding format puts around
  each separator, so `MINOR ` could fail the token match and be escalated to `MAJOR` — turning a
  collect-only finding into an iterate-and-fix one on an unstated parsing choice. Now trimmed,
  with all-whitespace treated as empty and therefore INCOMPLETE.
- **F5** — the `+check` counterfactual said to run the assertion over a scratch tree holding
  the two `df850ab` files, which would have failed other invariants and proved nothing. Now:
  copy the otherwise-green worktree, confirm exit 0, swap only those two files, require exit 1
  **carrying the 4c diagnostic and no other**. The isolation is the point; without it the
  evidence would have been green-for-the-wrong-reason.

**F3, F4** — fixtures for a template-only copy and for every fail-closed path (missing start,
missing end, unreadable input, parser failure), so 4c is not the check that fails open.

## Cycle summary

**Nine passes, 153 findings, one dismissed** — the security-axis proposal at pass 1, dismissed
by Daniel with recorded reasoning. Across the whole story: **four cycles, seventeen passes, 456
findings.**

Three deletions decided by Daniel drove the convergence, and their pattern is recorded in the
design's §1.6: the drift record (a **requirement** — removing it removed obligations, 20 → 16),
the `Ref:` identifier (an **answer** — removing it left its question standing, 16 → 17), and
the specification layer (a whole **class of question** — 17 → 9).

## Status

**Gate A closed.** Spec, both stories and the profile change are uncommitted in the working
tree. Next: `writing-plans`, then Gate A on the plan — its own three-pass loop.
