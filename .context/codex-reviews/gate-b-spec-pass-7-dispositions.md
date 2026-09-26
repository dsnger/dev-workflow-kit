# Gate-B pass 7 — dispositions (spec branch)

Range f9ed886..68c99c5, after the systematic sweep. 2 findings, both verified, both fixed.
Quality branch not run at that commit — these fixes change the spec, so both branches run
together at pass 8.

## Applied

1. **MAJOR — the parity narration understates what 2b proves.** §4 said the two files are
   "byte-identical **modulo hard-wrap position**", and §6's 2a oracle said "Both surfaces are
   hard-wrapped **at different columns**". Verified against the tree: the two delimited regions
   are byte-identical including line breaks — `cmp` clean, 70 lines each — because the text is
   generated once and inserted into both. And since pass 3, 2b compares them **raw**, so a
   rewrap of one surface alone fails it.

   **Another stale claim created by one of this cycle's own fixes**: "modulo wrap position" was
   accurate while 2b compared paragraph-joined views, and became an understatement the moment
   pass 3 changed 2b to a raw comparison. Third instance of that shape this cycle.

   Fixed both sites. §6's oracle now separates the two directions explicitly — wrap-insensitive
   **presence** for 2a, because anchors straddle line breaks *within* a surface; byte-exact
   **parity** for 2b, with a note that the wrap-insensitivity must not leak from one into the
   other.

2. **MINOR — the C1d oracle names a fixture that does not exist.** It cited "the fragmentless
   locator matching **both** `2026-07-18` `docs-drift` rows" as the many-match fixture. The
   harness has no such fixture; `rows-two-matching` synthesises a second row carrying the
   *mandated* `2026-07-20` locator. Verified both halves: the docs-drift pair really is repeated
   in the ledger (checked with an escape-aware parser — it is the only repeated date+fingerprint
   pair, so §2.2's non-uniqueness claim stands), but the mandated entry's locator does not match
   it, so it cannot exercise C1d's many-match branch at all. The spec had conflated "the ledger
   contains a non-unique pair" with "that pair is the fixture". Fixed to name the constructed
   fixture and say why the real pair cannot serve.

## The sweep's vocabulary was too narrow — widened

Pass 6's sweep grepped for check names and enforcement verbs. **Neither pass-7 finding names a
check**: one is a claim about the artifacts ("byte-identical modulo wrap"), the other about a
fixture. The sweep was re-run with a widened vocabulary — parity/identity/wrap terms, and every
fixture name in the harness cross-checked against every fixture the spec names. That found
exactly these two and nothing further.

Recorded because the lesson generalises: a check-claim sweep that greps only for *check names*
misses claims about what the checked artifacts are, which is the same defect one level down.

## State

Battery green. Harness green: 30 matrix rows, 0 disagreements under `sh` and `dash`. Fixes
amended into the WIP (`5f24776`). Pass 8 runs both branches.
