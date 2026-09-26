# Gate A — spec — pass 14 dispositions

Artifact: `docs/superpowers/specs/2026-08-05-hardening-ledger-supersession-design.md`
3 findings: 1 "Blocker", 1 Major, 1 Minor. **Two valid, one misdiagnosed.** None applied.

Reviewer: `mcp-codex-dev@1.0.1`, `codex-cli 0.144.5`, model `gpt-5.6-sol`. No stray artifact.

Passes 4 → 14: **11, 14, 16, 15, 9, 10, 5, 12, 8, 6, 3.**

## Finding 1 — the "Blocker" is misdiagnosed, and is not a blocker

Codex states the terminator is `/date + anchor\)\.$/` with an unescaped `+`, so the range would
never terminate and the fence would checksum to EOF.

**The spec does not say that.** `:489` reads `/date \+ anchor\)\.$/` — the `+` **is** escaped.
Verified with `cat -A`, and both the spec form and Codex's suggested `[+]` form terminate
correctly on the awk here (`awk version 20200816`). The pass-14 harness had already run this
fence against the post-change fixture and it exited 0 with clean stderr, which it could not have
done if the range ran to EOF.

**Dismissed as stated.** The *remedy* is still worth taking: `\+` inside an ERE is undefined
behaviour in POSIX, so `[+]` is unambiguous and costs nothing — applying it as portability
hardening, not as the bug Codex described.

## Finding 2 — valid, reproduced, and the real defect of this pass

The `finding`-column extraction uses `sed 's/\\|/\001/g' … sed 's/\001/|/g'`. In `sed`, `\001` in
the replacement is the literal text `001`, not a control byte, so the restore rewrites **every**
`001` in the column.

Reproduced against a row whose `finding` is `case 001 and a pipe \| here`:

```
extracted: [ case | and a pipe | here ]
```

`case 001` became `case |`. So a fragment match can reject a valid locator or accept one that is
not in the `finding` at all. This is the pass-13 fragment fix — right in design, wrong in one
mechanical detail — with the detail one layer deeper than last time. My fixtures used a `finding`
containing neither `\|` nor `001`, so nothing exercised it. Fix: extract column 4 in one
escaped-pipe-aware `awk` pass, with no textual sentinel, and add fixtures containing both.

## Finding 3 — valid

The dates fence's `grep | cut | tr` producer is unchecked, so an unreadable ledger leaves an
empty temp file and the fence exits 0 while emitting a grep error. It reports chronology success
without reading its input. (The harness's stderr rule would catch the *error*, but the fence
itself must fail.)

## Read

Two real findings and one misdiagnosis. Both real ones are in the same fence, and both are the
now-familiar shape: correct design, one mechanical detail that makes the check pass when it
should fail. The design questions are closed — nothing in this pass touched a settled decision,
the convention prose, the story, or any claim about what the gates prove.
