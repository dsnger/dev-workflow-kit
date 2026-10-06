## From PR #47 — backlog only, nothing implemented here

- **Intake amendment route: a dependent artifact is also one whose statements the change
  falsifies** (hardening, docs-drift twelfth occurrence, pending in `docs/hardening-log.md`).
  The vision's change record (decision 2) listed "Dependent artifacts: none" because the
  pilot story's *requirements* did not change, while the story's §5 still called the
  decided question open; Greptile caught it. Sharpen the route's *Dependent artifacts* field
  (`plugins/dev-workflow/skills/intake/SKILL.md`, "The change record") so a file the change
  makes false — an open question now answered, a status now outdated — counts as dependent,
  not only one whose requirements change. A `plugins/` change, so it needs its own story and
  a version bump; PR #47's story excludes `plugins/` (its AC-9).
