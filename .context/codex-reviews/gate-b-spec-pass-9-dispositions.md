# Gate B — spec branch — pass 9 dispositions

1 finding, Major. Accepted.

1  MAJOR docs/getting-started.md still says "Trivial changes skip the ceremony" — ACCEPT, and it is the most interesting finding of the pass because the sentence is PRE-EXISTING and untouched by this change. It was true before profiles and is false after them: it keys skipping on triviality alone, implies the whole ceremony can go, and would let a risk-trivial but security-relevant story skip Gate A. My change invalidated a sentence I never edited, which no parity check or resync could ever have caught — only a reader comparing old prose against new rules.
   Qualified: a `trivial` profile unlocks the GATE-B skip only, only at effective level 0, with the battery still owed and Gate A's floor unchanged; an unprofiled story keeps the prior judgement-based skip.
