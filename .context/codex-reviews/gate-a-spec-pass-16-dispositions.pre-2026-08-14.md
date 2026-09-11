# Gate A — spec — pass 16 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
7 findings: 5 Major, 2 Minor. **No Blocker.** All seven valid. **None applied.**

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. No stray artifact.

Passes 4 → 16: **11, 14, 16, 15, 9, 10, 5, 12, 8, 6, 3, 4, 7.**

## Verified

| # | Claim | Result |
|---|---|---|
| 1 | §7's rider still demands §8's list be "accurate and complete" | **Confirmed**, `:794`. The completeness claim was deleted from §8 and softened in §6's two cross-references — and left standing in §7, which calls itself "verbatim in every pass prompt". The deletion falsified a statement elsewhere and I did not sweep for it. |
| 3 | `pipes < 8` accepts *more* than seven columns | **Confirmed.** A 10-pipe line is accepted: I guarded the lower bound only, while the prose claims a full seven-column row. |

| # | Sev | Verdict | Note |
|---|---|---|---|
| 1 | Major | **Valid, confirmed** | Mine. Also correct to report despite the "don't flag §8's incompleteness" instruction — this is a *wrong statement*, which that instruction explicitly still admits. |
| 3 | Major | **Valid, confirmed** | Fix: require exactly eight unescaped delimiters and a terminal one, rejecting every other shape. |
| 4 | Major | **Valid** | `[ -n "$F" ] \|\| continue` conflates "not a row" with "row whose `finding` is empty", so a fragmentless entry can be reported inert because an unrelated row has an empty `finding`. I named this risk in my own rider and shipped it anyway. Fix: return parse status separately from the value. |
| 5 | Major | **Valid** | I guarded the *base* read and left the *current-ledger* producer unguarded: a missing working-tree ledger emits stderr, yields an empty `new`, skips the loop and exits 0. |
| 6 | Major | **Valid** | Check 3 asserts `label < entry < Columns` but never that the convention's end sentinel precedes the label, nor that every entry lies inside that interval — so the block could sit above `# Hardening log`, or a second entry below the table, with all three checks green. It claims "the block is where §2.2 says, and **only** there". |
| 2 | Minor | **Valid** | §4's story row omits the pass-5 desired-outcome and pass-9 AC-2 amendments. |
| 7 | Minor | **Valid** | The residual I flagged in the prompt: check 1's row-count grep is a prefix match. Confirmed as real. |

## The pattern this pass makes plain

Findings by section across the last six passes have concentrated in the **validation scaffolding**,
not the design:

```
pass 11  12 findings   §6/§7/Check-n mentions:  5
pass 12   8 findings                            9
pass 13   6 findings                           12
pass 14   3 findings                            6
pass 15   4 findings                            5
pass 16   7 findings                           13
```

Pass 16: five of seven findings are in §6, and the two others are §4 and §7 bookkeeping. **§1–§3,
§5 and the convention prose have drawn no finding for four consecutive passes.** The design is
stable; the shell is not, and each hardening pass adds surface that the next pass finds defects in.

Count trajectory since the artifact stabilised: **3, 4, 7** — oscillating, not converging, and the
rise tracks how much shell §6 has grown.
