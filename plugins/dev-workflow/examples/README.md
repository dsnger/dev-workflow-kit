# Examples — read, don't install

Nothing in this directory is plugin content. These files are **one project's**
answers to questions the plugin deliberately leaves open, kept because the *shape* of
a good answer is hard to describe and easy to show.

They are Convex + TypeScript + pnpm specific. Copying them into another stack will
not work, and `/dev-workflow:workflow-init` will not install them.

## `eslint-rules/` — what a rung-2 hardening actually looks like

The `harden-finding` ladder says a mechanical, recurring defect class should become a
lint rule. These are two rules that were written exactly that way — each one is the
end state of a finding that had already come back:

- **`auth-before-db.js`** — enforces "every public handler hits an auth barrier before
  it touches the database". It began as a prose rule in AGENTS.md, recurred, and was
  escalated to a rule that fails the build. Read the header comment: it records *why*
  specific helpers are recognized, and it is honest about the rule's syntactic ceiling
  (a `ctx` passed through a renamed alias would need dataflow analysis). That honesty
  about coverage limits is the part worth copying.
- **`returns-validator.js`** — enforces that every public function declares an output
  validator, written after an audit found the codebase-wide gap that AGENTS.md had
  claimed was closed. The rule is what makes the backfill permanent instead of a
  one-time cleanup.

Each ships with its test. A lint rule with no test is a rule nobody dares change.

**The transferable lesson is the pipeline, not the code:** an invariant in AGENTS.md →
a finding that violates it → a recurrence → a rule that fails the build → a test that
pins the rule. Write your own rules for your own invariants when `harden-finding`
escalates a finding to rung 2.

## `knip.json`, `.fallowrc.jsonc` — quality-battery configs

Dead-code detection (knip) and a duplication/health check (fallow), configured for one
codebase. Included for one property worth imitating: **every non-obvious line carries
a comment stating the fact that forced it**, not a hypothesis.

Look at `.fallowrc.jsonc` — it explains *why* `ignoreExports` is used instead of
`ignorePatterns` (the latter drops files from the graph and then falsely reports their
dependencies as unused). That comment is the difference between a config line a
future maintainer can safely remove and one nobody dares touch.

This is the empirical-first rule from the methodology: a config line records a
**verified necessity**. Don't add a guard or exclusion preemptively — let a red run
prove the need, then add the line together with the fact it proved. Being wrong
empirically costs one red run; a speculative line is permanent, because nobody knows
why it's there.
