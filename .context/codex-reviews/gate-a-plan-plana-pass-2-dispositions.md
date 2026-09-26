# Gate A — Plan A cycle — pass 2 dispositions

Advisory human note. Not a findings file; participates in no pass validation.

## Result

Artifact 83b17e0 (revision 2). VALID pass: terminator exact, 16 finding lines, 0
non-finding lines. **6 BLOCKER · 8 MAJOR · 2 MINOR = 14 Blocker/Major.**

Routed contract: pass 2 <= 8 B/M, converging <= 4; **above ~12 routes back**. 14 is above
it. **Routed, not iterated** — and see the tells below, which make it mandatory rather
than discretionary.

## Curve, Plan A cycle

| pass | findings | Blockers | Majors | B+M |
|---|---|---|---|---|
| 1 | 21 | 7 | 10 | 17 |
| 2 | 16 | 6 | 8 | 14 |

## The tells — two present, so stopping is mandatory

§5 owes these lines from pass 4; reading them at pass 2 is free and they already fire.

1. **Finding count rising** — NO. 21 → 16, falling.
2. **Blocker count failing to fall** — 7 → 6. A fall of one across a full repair round.
   **Ambiguous, leaning present.**
3. **Findings clustering on the INSTRUMENT rather than product behaviour** — **PRESENT,
   overwhelmingly.** Five of six Blockers are broken checks, not wrong rules: B1 quotes a
   replacement boundary mid-line; B3's three fixed-string greps address text that does not
   exist on disk as contiguous bytes; B4's marker is split across lines and its `grep -cF`
   pattern begins `- `, which grep reads as an option and exits 2; B5's end anchors do not
   occur on any line. Majors 4, 5, 7 and Minor 10 are the same class.
4. **Findings clustering on PROSE ABOUT either** — **present.** M2, M3, M6 and MINOR 10
   are about the plan's own accounting and its own self-review claims.
5. **A require↔withdraw pair** — none identified.

**Tells 3 and 4 are present, so stop-and-surface is mandatory, not discretionary.** The
routed >12 threshold points the same way. Both are reported to the sparring session.

## Root cause — one error, not fourteen

Every instrument finding is the same mistake: **I wrote checks against Markdown prose and
asserted they would work instead of executing them against the actual post-edit bytes.**
The four shapes it took:

- a phrase containing `**emphasis**` matched as if it were plain text;
- a phrase split across a line break matched as one contiguous string;
- a `grep -cF` pattern beginning `- ` passed without `--` or `-e`, so grep parses it as an
  option and exits 2;
- an `awk` range whose end anchor does not exist on any line, so the range runs to EOF.

**Codex found these by building a sandbox at `.context/plan-a-pass2-sim/`, applying Tasks
1-5 in sequence, and running the checks.** I did not. That asymmetry is the whole finding:
the reviewer executed the plan and I only read it.

## Findings verified against source before routing

- **M1 — CONFIRMED, and it is the third failure of one sentence.** The text on disk is
  `Re-review after every fix — a fix changes the diff and the hook` / `invalidates the
  prior pass, which is where the 3 come from.` My replacement swaps only the second line,
  so the shipped sentence reads **"a fix changes the diff and the hook no longer covers the
  artifact"** — the hook is *still* the grammatical subject and the causal claim is still
  wrong. Round 1 claimed the number came from invalidation; round 2 made the hook the cause;
  round 3 leaves the hook as the subject. The `AGENTS.md` entry says this took four Gate-B
  rounds because each correction searched for the previous **phrase** rather than the
  **claim**. Three rounds here, same mechanism. **The fix is to replace both lines.**
- **M2 — CONFIRMED, and it refutes my own pass-1 verification.** I reported the Gate-A
  passage as byte-identical across copies. It is not: over its **full** extent (30 lines vs
  29) `CLAUDE.md` carries `` (`docs/prompt-standards.md`, "coverage first, filter later") ``
  which the template **drops entirely** — substantive, not wrapping. My check compared
  `C 300-312` against `T 485-497`, a 13-line window that **stops before the divergence**,
  and I reported IDENTICAL. A check wired so it cannot observe the thing it claims to
  check — while verifying a finding *about* identity claims. The accounting's shared-row
  structure is therefore unsound for this passage too, not only for the pass-report one.
- **B3 — CONFIRMED mechanically.** `grep -c 'you report the tells' CLAUDE.md` returns **0**;
  the phrase breaks after `you report` at line 144.

## Disposition

All 14 Blocker/Major carried open. No fixes applied.

The repair is mechanical and bounded, and it is one action rather than fourteen: **build the
simulated post-edit tree, run every check in the plan against it, and ship only checks that
demonstrably produce their stated output.** That is the validation pass I skipped, and
`.context/plan-a-pass2-sim/` already exists as a starting point. B6 is the one finding
outside that class — it is a real gap in the newly-decided one-WIP topology (no immutable
pre-cycle base SHA, so stacked WIPs pass `CYCLE OPEN` while `git diff HEAD~1` silently omits
an earlier WIP from the only Gate-B review) and needs a topology answer, not a better check.

The two Minor are collected, not iterated.
