# Gate-B cycle `rle` — dispositions at close

The cycle closed on §5's **clearly-stuck** exit (Daniel, 2026-09-02), not on a clean pass.
Every pass-5 finding gets a line. Four were repaired in the closing round because they were
unambiguously defects of mine; the rest are recorded open, each with why.

## Repaired in the closing round
- spec-2 / quality-5 — the shared `<CYCLE-FIELD>` does not link a skip record to its reason,
  since every pre-rule cycle writes `cycle none (pre-rule)`. **Fixed**: adjacency is the link —
  the reason is the text immediately following the record — and the cycle-field claim is
  withdrawn in as many words.
- spec-5 / quality-4 — the model-failure cut was incomplete. **Fixed**: the source-and-
  rejected-bytes obligation is withdrawn in the spec and in Plan B, dated.
- spec-10 — Task 23 requires the `rle` exception in the closing body while Task 24's "complete
  list" omitted it. **Fixed**: the list now carries the exception and the standing decision
  record, items 5 and 6.
- spec-9 — the dropped Tasks 19/20 were half-propagated. **Fixed**: Plan C's accounting row 19
  and its Task-12 changelog text no longer say the release ships the discriminator.

## Declined by human decision 2026-09-02 — a chosen cost, not a missed defect
- spec-3 — "`unusable` and `undetermined` intentionally collapse distinct causes and provide
  neither a discriminating check nor a per-cause fix." Correct, and deliberate. Four successive
  attempts to state the classification behind those tokens were each wrong in a different way,
  the last demonstrably so. The record now says THAT a knob was unusable and no longer WHY.
- spec-4 — "Profile case 3 says its four causes need different fixes but supplies no per-cause
  fixes and expressly declines to prescribe a discriminating check." Same decision. The order
  previously prescribed could not reach the broken-symlink cause, because ordinary existence and
  regular-file tests follow symlinks.
Both are the requirement Daniel withdrew. A gate cannot clear a finding whose resolution the
human has declined, which is the require-withdraw pair that made this stop mandatory.

## Open at close, with reasons
- spec-1 / quality-1 — the five-case partition is not mutually exclusive for **mixed** cited
  sets: case 0 is vacuously true of an empty set, and a multi-story set can satisfy several
  cases at once. Real, and the third distinct defect found in this one list across three
  rounds. Owner: the loop-rule consolidation story.
- quality-2 — removing the cause token left no rule for a readable file whose content is
  neither a positive integer nor absent, so the writer has no producible value. Real; a
  consequence of the withdrawal above and inseparable from it.
- quality-3 — the withdrawal note explaining why the hook description was deleted is itself a
  description of the hook. Correct, and self-consuming: no version of that paragraph survives
  its own rule. Recorded rather than attempted a fifth time.
- spec-7 — the shipped nonce-recovery rule narrows the spec's single-candidate rule.
- spec-8 — the story requires every cycle that ran to carry its curve; Plan C's closing body
  excludes the four pre-rule Gate-A cycles, whose record is the field report instead.
- quality-6 — logical-pass agreement compares only `headSha`, though a range is selected by
  `baseSha` too.
- spec-11, spec-12, spec-13, quality-7, quality-8, quality-9, quality-10 — Minor and Nit:
  stale accounting sentences, a release note that omits the skip-record case, and a "fourth
  case" label left over from the pre-zero-based numbering. Collected, not iterated.

## Why the cycle closed here
Five passes: 16/9 · 29/17 (discounted) · 25/15 · 25/15 · 23/16 findings/Blocker+Major.
Blocker+Major never returned to its pass-1 level and rose on the last pass. Each round's
repair produced the next round's findings on the same mechanism. Coverage is affirmatively
sufficient: across five passes the reviewers covered both prompt copies, the spec, the story,
all three plans, the hook source and the user docs; no materially unreviewed area is known.
