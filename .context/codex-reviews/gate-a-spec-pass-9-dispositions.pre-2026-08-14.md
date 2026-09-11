# Gate A — spec — pass 9 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
10 findings: **2 Blocker**, 6 Major, 1 Minor, 1 Nit. All read as correct. **None applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Same as passes 4–8.

Passes 4 → 9: **11, 14, 16, 15, 9, 10.** All nine pass-8 fixes landed and none regressed — the
per-fix landing check confirmed each, and pass 9 raised no complaint about any of the nine
edits themselves. What it found is one omission beside them and a set of tightenings.

## The two blockers

**Finding 5 — the landing check's own blind spot.** §4's change-surface row still instructs
*"line 204's … qualified to merged history"* — the boundary-era instruction — while
`docs/coding-workflow.md:204` itself now correctly reads *"strictly append-only: a row is never
edited"*. §4 is the authoritative instruction an implementer follows, so the spec would have them
re-break the file the blocker fix just repaired. **My landing check missed this because it
grepped the target file, not the spec's instruction about the target file.** The rider was
right and was applied one level too shallow.

**Finding 1 — a genuine conflict in the resolution-floor sentence.** "The convention governs
committed content; an uncommitted editor buffer is below its resolution" sits against "This holds
for every row without exception". A row **already appended but not yet committed** satisfies both
descriptions and has no verdict. That is the amendable class reappearing through the sentence
written to stop it reappearing — and it needs Daniel, because he specified that sentence.

## Reproduced, not taken on the reviewer's word

| # | Claim | Result |
|---|---|---|
| 5 | §4 still instructs the merged-history qualifier | **Confirmed**, `:271` against `coding-workflow.md:203-204`. |
| 9 | union does **not** reliably keep both labels | **Reproduced.** Scratch repo, `merge=union` on `.gitattributes`, both branches adding a `**Superseded rows:**` label: the merge **coalesces** the identical label line and keeps both distinct entries. Label count **1**, not 2. §8's categorical claim is wrong; §2.2's conditional "if a union merge leaves two labels" was right all along. |

| # | Sev | Verdict | Note |
|---|---|---|---|
| 1 | **Blocker** | **Valid** | See above. Needs Daniel. |
| 5 | **Blocker** | **Valid, confirmed** | Pure omission; one row rewrite. |
| 3 | Major | **Valid** | A fragmentless locator unique when written can be made ambiguous by a *later* row sharing its date + fingerprint, and identical duplicate rows admit no distinguishing fragment at all. Entries are immutable, so there is no legal repair — AC 4 defeated with no move available. |
| 4 | Major | **Valid** | §3.1's entry and both date-bearing checks are pinned to `2026-08-05` while §2.2 defines `<date>` as the day the entry is written, and the change lands later. Pass 7 raised this; it was not in the applied set. |
| 6 | Major | **Valid** | Assertion 2's fence calls `occurrences` and `unwrap` and reads `$LED`/`$TPL` without defining them. Run as the standalone block it is presented as, it fails under `sh` and `dash`. The assertions pass only when run in one shell — undocumented shared state. |
| 7 | Major | **Valid** | §8's re-derived inventory is still not complete: the opening row-claim sentence, the `YYYY-MM-DD` format and the cite-where-the-answer-lives requirement are in neither the 24 anchors nor the list, and the start sentinel anchors only `# Hardening log`. Third pass in a row on this inventory. |
| 8 | Major | **Valid** | §8 says "no lost-update case at all" while §2.2 now names the same-worktree read-modify-write race as unsupported. The pass-8 concurrency fix scoped §2.2 and left §8 asserting the unscoped claim. |
| 9 | Major | **Valid, reproduced** | See above. |
| 2 | Nit | **Valid** | "A row records a hardening" against the phantom-hardening case the design explicitly covers. "Records a hardening claim" resolves it. |
| 10 | Minor | **Valid** | Story AC 2 — "the row no longer reads as current behaviour" — reads as demanding the forbidden edit, since the design leaves every byte of the row unchanged. |

## Read

Two blockers, but neither says the design is unsound: one is an unswept instruction, one is a
conflict inside a single added sentence. Findings 6, 7, 8 are the same three sites tightening
across passes. Nothing here reopens the boundary.
