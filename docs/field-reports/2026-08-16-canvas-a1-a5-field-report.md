# Field report — infinite-portfolio-canvas, tickets A1–A5 (received 2026-08-16)

Verbatim report from the kit's heaviest consumer, relayed by Daniel. Source project:
the `infinite-portfolio-canvas` repo — ~60+ Gate-B
cycles, ~150 Gate-A/B passes, kit v0.8.0 since mid-run. To be processed as a
field-intake round after the reviewer-availability fallback story (0.9.0) lands.

Machine-local absolute paths were replaced by the repo's name before committing, in
this header and in the verbatim section alike. Nothing else was altered.
Every claim must be verified at its cited evidence before adoption; rejection with a
one-line reason is a valid outcome per the report's own terms.

Sparring pre-triage (2026-08-16, verified spot-check against the canvas repo):

- Item 1 is NOT a hook defect — the canvas's own todos.md root-caused it later:
  six >120 s review passes were auto-backgrounded, never reached the hook, class
  `backgrounded`, counter structurally 0 without CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS.
  Item 1 collapses into item 4 → second independent field evidence for the open
  workflow-init preflight-check row (env var), which is now ripe.
- Item 2 = occurrence fuel for the parked compound-commands / loose-grep rows
  (incl. occurrence 4 of add+commit-in-one-call and a measured 5-pass loss from a
  `git log` echo). Approaches the parse-trigger escalation; decides nothing alone.
- Item 3 (envelope swallows error.code on zero-credits) = upstream mcp-codex-dev
  candidate with outsized value; matches the "no error code surfaced (unclassified)"
  observed in the kit's own 0.8.x field use.
- Items 5, 6, 8 = codification candidates with cross-project evidence (absorb-vs-stop
  ruling; arms-race remedy as procedure — the kit's own refrain, 4 canvas
  applications; spec-size superlinearity — kit's own 23-pass supersession corroborates).
- Item 9 cheap and good. Items 10, 11 experimental — park with the future refrain row
  (item 10 is corroborated by PR #23's 16-of-27-in-harness distribution).
- Part 3 (zero bytes moved across five surgery tranches under the untouched core
  rules) = strongest field validation the kit has; also talk material.
- Meta: this report IS the fired trigger of the parked `/capture-finding` row
  ("the first production finding arriving from real use rather than a gate or bot").

---

## Verbatim report

Field report from the kit's heaviest consumer: the infinite-portfolio-canvas
repo (path neutralized — see header)
ran tickets A1-A5 under this kit — roughly 60+ Gate-B cycles, ~150 Gate-A/B
passes, kit v0.8.0 since mid-run. Everything below is OPTIONAL input for the
kit's own backlog: verify each claim against the referenced evidence in that
repo before adopting anything, adopt nothing you cannot verify, and add
nothing beyond this list on my account. If an item doesn't fit the kit's
design intent, dropping it is a valid outcome.

PART 1 — MEASURED DEFECTS (reproduced in the field, evidence in the
consumer repo):

1. Fingerprint computation/storage. Every clean cycle close draws a STOP;
   counting and cycle-recognition work (measured: 24 counted passes, WIPs
   and amends recognized), only the fingerprint fails. Narrowed cause:
   codex-gate.gateB held literal "unavailable" and freshCount 0 at session
   start — §5 reads 0 as hash-uncomputable, so no number of clean passes
   can heal a cycle. The hook's own diagnostic checklist was green
   (writable dirs, shasum present, disk free). Evidence: that repo's
   todos.md § Tooling revalidation (three-part entry with measurements)
   and multiple handbacks citing tree-identity overrides.

2. Commit-detection by command-string grep, two measured failure shapes:
   (a) a `git log` echo containing the word "commit" was scored as a
   cycle-closing commit and reset a 5-pass counter to 0 — the loss is
   indistinguishable from passes that never ran; (b) `git add … && git
   commit …` in ONE Bash call defeats the docs-only exemption because
   PreToolUse reads the still-empty index (two controlled data points);
   (c) a heredoc mentioning an integration step next to a git call fired
   a false STOP. Evidence: todos.md entries + the consumer's CLAUDE.md §5
   which now documents the workarounds (separate stage/commit calls, no
   "commit"-word output mid-cycle). A more precise trigger (parse, or
   PostToolUse for the exemption check) would remove a whole class of
   operator discipline.

3. Cross-repo note for mcp-codex-dev (if maintained alongside): error
   envelopes swallow the reason — a zero-credits condition returned bare
   {success:false, status:"error"} with no error.code; the cause was only
   findable in ~/.codex/sessions rollout logs (rate_limits.credits).
   Cost in the field: two spent retry budgets and a full false trail
   (approval/registration). Surfacing NO_CREDITS & friends in the
   envelope is a one-field fix with outsized value.

4. Setup documentation: CLAUDE_CODE_MCP_AUTO_BACKGROUND_MS is load-bearing
   for the hook (backgrounded calls never reach it → counter structurally
   zero). The consumer discovered this by measurement; the kit's install/
   setup docs could name it as a required operator step (value 0 or above
   the longest gate call, read at process start).

PART 2 — POLICY CANDIDATES (rulings minted in the field; wording lives in
the consumer repo — .context/ notes, agent memory, taxonomy entries with
Belegstellen). Field-proven:

5. Absorb-vs-stop ruling: corrections-of-corrections inside the assigned
   fix set may be absorbed; any finding opening a NEW structural or
   contract question stops the loop. "Size isn't the test, novelty of the
   question is." (gate-b-absorb-vs-stop-ruling in that repo's memory.)

6. The arms-race remedy as prescriptive procedure, not just taxonomy
   prose: when passes stop converging, scope the reviewer to changed
   regions / change the instrument's layer / relocate the residual to the
   layer that already catches it — and STOP with a named state. Applied
   successfully ≥4 times (spec prose, JS-lexer-in-tool, §4.3 mechanics,
   report-about-itself fixpoint).

7. Session framing for dense tranches: "advance until closed, clean stops
   as needed" instead of "close X" — with WIP chain + resume note in
   .context/ as a first-class protocol (not an embarrassment). Repeatedly
   prevented half-built work under a review.

8. Spec-size guidance: Gate-A cost grew overlinearly with artifact size in
   the field (7 → 22 → 34+ passes across three specs). Recommendation the
   consumer adopted for its remaining tickets: smaller specs with named
   interfaces.

9. Handbacks carry context-% as a standing field.

Proposed but NOT yet field-proven (mark as experimental if adopted):

10. Proportionality rule for instrument-subject findings: findings whose
    subject is a test instrument (not product behaviour) get one repair
    round, then collect — unless they demonstrate a false-green on
    product behaviour. Motivation: late cycles in the field spent a
    growing share of passes on meta-instruments.

11. Pre-split heuristic: tranches exceeding a size signal (e.g. >N new
    runners or steps) split by subject at PLAN time — every large tranche
    in the field split anyway, but always via an expensive stop-decide-
    rerecord round-trip.

PART 3 — WHAT THE FIELD SAYS NOT TO TOUCH: the 3-pass floor with clean
final pass, findings-to-file with terminators, WIP/amend mechanics,
quote-before-edit / measure-before-write, severity discipline
(Blocker/Major iterate, Minor/Nit collect). Under exactly these rules the
consumer performed five tranches of surgery on its core file with ZERO
bytes moved in both characterization baselines — that is the kit working
as designed. Evidence: the A5 handbacks and baselines in that repo.

Process for this session: your repo, your workflow — triage this list
into your own backlog/issues as you see fit, verify claims at the cited
evidence before implementing anything, and feel free to reject items
with a one-line reason. Nothing here is an instruction.
