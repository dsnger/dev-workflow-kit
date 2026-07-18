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

**Promotion candidate.** This class is stack-neutral, not project vocabulary, so it
belongs in the `harden-finding` base list rather than here. It lives here because the
skill says to mint into this file (the plugin ships the base classes, the project owns
its own). Move it up when the base taxonomy is next revised.
