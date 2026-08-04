# Hardening taxonomy — dev-workflow-kit

Project-specific fingerprint classes, extending the stack-neutral **base taxonomy**
in the `dev-workflow:harden-finding` skill. The skill reads both on every fingerprint
step; the base classes are not repeated here.

A class belongs here (not in the base list) when it names *this* project's entities,
frameworks, or invariants — e.g. a class about a specific table, a specific auth
helper, or a specific framework's API.

**Before minting:** grep the base list and this one for a near match. A slightly
imprecise class you reuse beats a precise class nobody greps for — recurrence
detection is the entire value, and it only works when the same defect maps to the
same string twice.

**Format:** kebab-case `domain-problem-class`, one line, with an alias hint naming
the synonyms a future reader might search for instead.

## Classes

- `prompt-diagnostic-cause-unnamed` — a prompt reports a failure state but names only
  one of the causes that produce it, so the reader gets a fix that cannot work.
  Aliases: misleading remedy, wrong-fix loop, undiagnosed state, symptom collision,
  "restart the session" for a cause a restart never fixes.

- `unverified-enforcement-claim` — a prompt, spec or doc asserts that something is
  enforced, caught, guaranteed or prevented, where no mechanism does it. Aliases:
  claimed guarantee, asserted enforcement, false backstop, "the check catches it",
  security theatre, a rule described as automatic that is instruction-only.

  **Not the same as `docs-drift`**, though they overlap. `docs-drift` is two documents
  (or a document and the code) disagreeing; grep it when the fix is to make them
  agree. This class is a single claim that is untrue on its own terms even with
  nothing to contradict it — "output validation catches a budget overrun" was false
  because the output carries no call count, not because another file said otherwise.
  The fix differs too: drift is detected by comparing the two artifacts and fixed by
  updating whichever is stale; this one is fixed by verifying the mechanism exists
  before the sentence is written.

- `artifact-version-not-bumped` — a change to a versioned artifact this repo *ships*
  merges without changing the version consumers key on, so installed copies stay on the
  old code with no signal. Aliases: stale install, cache key unchanged, forgot to bump,
  release not cut, propagation failure, "it's merged but my machine still runs the old
  one".

  **Not `dependency-unpinned`**, though both are about versions. That class is about
  *this* repo consuming something floating — the risk runs inbound, and the fix is to
  pin. This one runs outbound: our own artifact fails to reach its consumers, and the
  fix is to force the version forward. Grep this one when the sentence is "nobody got
  the change"; grep the other when it is "we don't know what we got".

- `truncated-tool-output-read-as-complete` — a tool result that arrived incomplete is
  consumed as if whole, because nothing in it distinguishes the two. Aliases: cut-off
  response, output limit hit, silent drop, partial list read as the full list, "the
  reviewer only found three things", findings lost in transport, response persisted to
  disk and never re-read.

  **Not the same as `verification-masks-failure`**, the nearest class, though the
  surfaces rhyme — both end with a bad signal accepted as a good one. The difference is
  origin and fix. There, an author wrote a check that reports the wrong thing (a pipe
  returning grep's exit status instead of the runner's), and the fix is to make the
  check report the real status. Here the author's reasoning is sound and the *delivery*
  drops data underneath it, so the fix is to make incompleteness detectable — a
  terminator, a declared count, a re-read. Grep this one when the sentence is "we never
  saw all of it"; grep the other when it is "we looked at the wrong thing".

- `verification-masks-failure` — a check reports success because of how it was wired,
  not because the thing it checks succeeded. Aliases: exit status swallowed, pipeline
  status masked, green that proves nothing, the check that cannot fail, asserting on the
  wrong command's result.

  (Defined here retroactively: the 2026-07-20 ledger row used this class before any
  definition existed. Recorded now so the recurrence grep has something to land on.)

- `rewrite-drops-prior-condition` — a rule with several conditions is rewritten, the new
  condition survives, and one of the conditions the old prose carried disappears with it. Aliases: lost
  precondition, half a rule, the summary that kept the new half, condition dropped in
  restatement, "we fixed it and it got weaker".

  **Not `docs-drift`.** Drift is two artifacts disagreeing and is fixed by updating the
  stale one; here a single rewritten rule is wrong on its own terms, and the fix is to
  restore the condition. Detect it by diffing the old prose against the new for
  conditions, not by comparing artifacts. Ten instances in the profiles cycle, one of
  which briefly authorized a substantial fix to skip Gate B because its story's profile
  was eligible — a gate-off path invented by a rewrite meant to narrow one.

- `session-bound-context-not-durable` — reasoning that has to outlive a session is left in
  chat history, so it is gone at the next session, model change or tool switch. Aliases:
  lost rationale, why-did-we-dismiss-that, undocumented decision, no resume state,
  context died with the session, "it was in the chat".

  **Not `docs-drift`.** Drift is two artifacts *disagreeing*; this is one artifact never
  existing. The fix differs too: drift is repaired by updating whichever is stale, this by
  writing the thing down at all. Also not `truncated-tool-output-read-as-complete` —
  nothing here is truncated or misread as complete; the content was simply never durable.

- `mechanical-check-skipped-before-review` — an artifact carrying machine-checkable assertions
  goes to an expensive read pass before anything parses it, so attention is spent on what a
  tool decides in seconds. Aliases: `sh -n` after the fact, the parser would have caught it,
  read pass before the sweep, manual review of machine-decidable claims.

  **Not `verification-masks-failure`.** There a check ran and could not fail; here the cheap
  check never ran at all. Grep this one when the sentence is "a parser would have found it
  immediately"; grep the other when it is "the check passed and proved nothing".

**Promotion candidate.** These classes are stack-neutral, not project vocabulary, so
they belong in the `harden-finding` base list rather than here. They live here because
the skill says to mint into this file (the plugin ships the base classes, the project
owns its own). Move them up when the base taxonomy is next revised.
