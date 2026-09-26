# Gate A — spec — pass 8 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
9 findings: **1 Blocker**, 6 Major, 1 Minor, 1 Nit. All read as correct. **None applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. Same as passes 4–7.

## The trajectory broke

Passes 4 → 8: **11, 14, 16, 15, 9**. First real drop, and — more telling — the *character*
changed. Pass 7 was design holes in a boundary that kept regenerating. Pass 8 is almost entirely
**sites I failed to sweep when deleting that boundary**: findings 1, 3, 5, 6 and 9 are each a
sentence written for the old design and left standing. Finding 4 is a stale count. Only
**finding 7** is a new observation about the design as it now stands, and it is narrow.

Nothing in pass 8 says the boundary-free convention is unsound. That is the difference from
every pass since 4.

## The blocker is a self-inflicted leftover

**Finding 1.** `docs/coding-workflow.md:204` — *"The ledger is append-only **once an entry has
merged**: merged history is never rewritten…"*. I wrote that qualifier during the reachability
design, when a pre-merge amendable class existed. The class is gone; the qualifier reinstates it
in prose, in a file outside the spec, and it directly contradicts AC 3's literal reading. It is
a genuine blocker and a two-line revert.

## Verified, not taken on the reviewer's word

| # | Claim | Result |
|---|---|---|
| 1 | `coding-workflow.md:204` reinstates a pre-merge amendable class | **Confirmed**, quoted above. My edit, from the deleted design. |
| 4 | §8's unanchored list is stale | **Confirmed.** Three items it calls unanchored are anchors 13, 18 and 19 (`:382`, `:387`, `:388`). The list was written against the 16-anchor set and never re-derived for the 24. The distinguishing-fragment fallback is anchored nowhere *and* missing from the list. |
| 6 | the plan's quarantine note asserts the narrowing | **Confirmed**, `:3–10` — it says the design "narrowed it to *never edit a landed row*". Written before the restoration; the note meant to quarantine stale history now carries it. |

| # | Sev | Verdict | Note |
|---|---|---|---|
| 1 | **Blocker** | **Valid, confirmed** | See above. Revert to absolute, keep the supersession sentence. |
| 3 | Major | **Valid** | The Scope paragraph still lists the `harden-finding` phrase while §4 and the version-bump paragraph say the skill is untouched. Two authoritative statements disagreeing about the plugin change surface — invariant-11 scope depends on it. |
| 2 | Major | **Valid** | §3.1 *still* says "falsification-scoped, not row-scoped". Pass 7 found this exact leftover; it was cited in my own applied list and the edit never landed. The worked example is the most-copied part of the document. |
| 4 | Major | **Valid, confirmed** | Gate-proof Don't: the residual list misdescribes what the check covers, in both directions. |
| 5 | Major | **Valid** | §8 still says nothing validates "that a row was landed when superseded" — a precondition from a deleted procedure, preserved as an unstated assumption. |
| 6 | Major | **Valid, confirmed** | See above. |
| 7 | Major | **Valid — the one genuinely new finding** | "No single-writer assumption is needed… nothing to overwrite" is justified only for two-branch union merges. Inserting an entry above `Columns:` is a read-modify-write on one file, so two writers in **one worktree** can lose an entry before git's union driver is ever involved. The claim is true of merges and overstated as written. |
| 8 | Minor | **Valid** | Story §5 points at "§7 check 2"; validation is now §6. Renumber fallout. |
| 9 | Nit | **Valid** | §4 claims all three story amendments use kept/narrowed/dropped; pass 1 uses kept/moved/dropped and pass 8 restored/dropped/kept. |

## Recommendation

Apply all nine. Eight are deletion-sweep or wording; finding 7 needs one scoped sentence
(the guarantee holds across independently committed branches; same-worktree concurrent writers
are unsupported). Then pass 9. On this trajectory the story does **not** need to park.
