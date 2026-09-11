# Gate-B pass 1 — dispositions

Range f9ed886..f964bc5, `reviewType: full`. Both branch files validated after a
single-branch spec resume (see the pass-1 note at the end).

Union of the two branch files, deduped. Blocker/Major resolved; Minor/Nit collected.

## Applied — committed diff

1. **MAJOR (both branches) — spec still claims backdating is mechanically checked.**
   ACCEPTED, verified independently. `grep` over the spec found two survivors of the
   four-line correction: line 287 "Backdating is forbidden and mechanically checked",
   and line 753 "while the check enforces only non-decreasing recorded dates". Both
   contradicted the corrected line 176, §8's "Check 1e is therefore not implemented …
   No chronology validation exists", the plan's line 87 and `todos.md`. Fixed both.
   Re-swept by claim rather than by phrase, per the AGENTS.md Don't: every remaining
   hit is a correct *negative* claim or a conditional about the unimplemented 1e.

2. **MAJOR — §8 says an extra inert entry is "detected by nothing".** ACCEPTED after
   independent verification. This finding came from the *clobbered* first spec file
   and appears in neither validated branch file; it is recorded here as the reader's
   own observation, not as a counted pass-1 finding. Spec Check 3's cardinality oracle
   requires the entry to "resolve to exactly one position", and `check-c3.sh`
   implements it as `nent != 1` — so a second entry-shaped line *is* caught, once, on
   this change. Narrowed the headline to check 1d and named check 3 as what sees it;
   also corrected the companion sentence "every stated check will accept it".

## Applied — scratch harness (never committed; it is the evidence, not the product)

3. **MAJOR (both branches) — C1d identifies the mandated entry positionally.**
   ACCEPTED. It took "the first candidate not present at BASE", so an unrelated or
   mistyped earlier entry would decide the verdict. Spec §8 states the opposite order:
   *identify the §3.1-mandated entry in current content, then prove it was added*.
   Rewritten to select by date + row date + fingerprint, require exactly one match,
   and only then assert it is absent at BASE. `entry-good` now passes because the
   entry is the right one rather than because it happens to come first.
   Consequence: two fixtures mutate the entry's own date, so `matrix.sh` now passes
   the entry date for those rows — which makes each test its advertised dimension
   (the on-or-before bound) instead of testing findability.

4. **MAJOR (both branches) — `matrix.sh` folds stderr into the exit status.**
   ACCEPTED as a real masking path, though verified LATENT: no fixture row emits
   anything on stderr today, so no current verdict rested on the fold. Stderr is now
   an unconditional disagreement, decided before the PASS/FAIL comparison.

5. **MAJOR (quality) — fixture builders assert nothing about their anchor.**
   ACCEPTED as real, verified LATENT: every fixture was checked and all sixteen differ
   from `baseline.md`. `sub_line`/`after_line` now assert the anchor matched exactly
   once and that the result differs from its input.

6. **MAJOR (both branches) — `parse_entry` splits the whole line on ` · `.**
   ACCEPTED. §2.2 forbids the separator only in the two prose fields, so a fragment
   quoting a `finding` that contains ` · ` is legal and was being rejected — a grammar
   narrower than the product's. Rewritten to parse the locator left-to-right and bound
   the fragment by its quotes, splitting only the remainder. No effect on this change's
   evidence: the mandated entry is fragmentless.

7. **MINOR (both branches) — sentinel cardinality counted by line, not occurrence.**
   ACCEPTED; cheap and correct. Now uses `occurs_exactly 1`.

8. **MINOR (quality) / MAJOR (spec) — C2b compares regions after `join_paragraphs`.**
   ACCEPTED. Byte-identity is what the two-surface parity requirement claims, and
   normalizing line breaks away could pass a wrap-only divergence. Now compares the
   raw regions. Verified latent first: the two regions are byte-identical as they
   stand (70 lines each).

9. **MAJOR|medium (spec) / MINOR|medium (quality) — `delete e` is not POSIX awk.**
   ACCEPTED. Correct: whole-array delete is a common extension. Replaced with a
   `clear()` helper deleting key by key.

10. **MAJOR (spec) / MINOR (quality) — `rows-escapes` exercises no parser.**
    ACCEPTED. The escape-heavy row carries no mandated locator, so C1a and C1d never
    had to parse it. `build-fixtures.sh` now asserts the row round-trips through
    `rowline` byte-identically — which it can only do if the escaped pipe was not read
    as a delimiter, the doubled backslash was, and the digits were not coerced.

## Checked and NOT a finding

- **Spec line 832's "twenty-two current rows".** A first count said 19 and was wrong:
  it split on `|` naively and mis-parsed rows carrying escaped pipes. Re-counted with
  the escape-aware parser: 22. The spec is correct; nothing changed.

## Pass-1 protocol note

The `full` call returned four protocol lines, not two: both reviewers wrote both
slots. The spec branch reported `spec | 7 / quality | 5`; the quality branch reported
`9 / 9`; the disk held `9 / 9`, and both files read as quality-axis reviews. The spec
branch's seven spec-compliance findings had been overwritten — §5's stated race, with
every mechanical check still passing. Treated as an INCOMPLETE pass, not counted; the
single recovery attempt was spent on a write-only resume of the spec session
(`reviewType: spec`, its own `sessionId`), deleting only the failed branch file. That
returned one clean line and a valid 7-finding file.

**Passes 2 onward run as two sequential single-branch calls** — `reviewType: spec`,
then `reviewType: quality` — each naming only its own slot. `full` shares one
`additionalContext` between two parallel reviewers, and naming both slots in it is
what let each write both.
