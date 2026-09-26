# Field evidence — sfx-bricks-api-builder review-loop economics

Observed 2026-09-17 at Daniel's request. Bounded, read-only inspection of the
consumer project; no tests, gates, instrumentation or updates were run there.
This report informs the [dashboard and usefulness requirements](../superpowers/specs/2026-08-30-dark-factory-vision.md)
and does not authorize changes to either project's review rules.

## Snapshot and workflow provenance

Consumer: `sfx-bricks-api-builder`, branch `calendar-prototype`, HEAD
`1f9f93234355b883da8c406d5a955f909437600e`. No tracked changes were reported;
16 untracked status entries were present, including review directories.
All consumer paths below are relative to that repository, at this snapshot
unless stated otherwise; its artifacts are not copied into the kit.

- **Observed installation:** the user-scoped entry in
  `~/.claude/plugins/installed_plugins.json` names
  `dev-workflow@dev-workflow-kit` **0.9.1**, commit `baa75c1516dccff5e9fe04fd6b1b6bb3a5ad4dad`.
  The cached plugin manifest independently says 0.9.1. User settings enable it;
  inspected project/ancestor settings contain no plugin override. The kit's
  source manifest currently says **0.11.0**. No plugin update was performed.
- **Observed local rules:** `CLAUDE.md` still requires a fixed three-pass floor
  (line 80); it lacks the kit's newer five-tell stop procedure and detailed
  consequence-based severity procedure. Its blob is
  `d21bec36e998f151679bfaf2f384cb249873f9d2`, last changed by `b50f42c`.
  Installed package version and project-local rule revision are separate facts.
- **Unverified:** which version the currently running agent process loaded, and
  the exact package/rule combination used by each historical pass. The latest
  inspected session log supplied no cache-path reference that settled this.
  These cycles are not an effectiveness test of the current 0.11.0 rules.

## Recounted observations

Source directory: `docs/superpowers/reviews/2026-09-16-poi-sync-gate-a/`.
Counts below were recomputed from severity-prefixed finding lines in the
`gate-a-poi-sync-{spec,plan}-pass-N.md` files; each matched its final terminator.
This verifies counts, not finding validity, deduplication or pass acceptance.

| Cycle | Findings by pass | Blockers by pass | Majors by pass |
|---|---|---|---|
| POI specification | 74 → 52 → 42 | 20 → 15 → 13 | 47 → 33 → 18 |
| Joint POI plan/specification | 46 → 33 → 19 → 30 | 11 → 5 → 4 → 6 | 29 → 23 → 13 → 18 |

The plan pass-4 dispositions label 16 of 30 findings as induced by the previous
revision, with their item numbers. That attribution is the author's report;
it was not independently reconstructed across all revision diffs. The same
corpus records repairs to Minor/Nit findings too. This demonstrates recorded
repair scope, not that those repairs caused later findings or wasted time.
No attributable per-pass cost/duration series was established by this inspection.

The primary findings mix very different consequences. Plan pass 4 item 2 concerns
an in-flight write reopening an abandoned run after tombstone deletion; item 5
specifies a private method that another class must call; item 20 names unsupported
verification harnesses. Those are runtime design and verification consequences,
not merely textual polish because the findings live in a plan/specification.
Their historical reports were read; their failure scenarios were not executed.

## Lessons adopted into the planning requirements

1. **Separate origin, consequence and effort.** A repair-induced finding can
   still expose a serious product defect. Record origin with evidence and
   attribution confidence separately from severity, affected behaviour and
   repair effort. Count optional Minor/Nit repairs separately from required
   fixes. Declining raw counts or many applied repairs alone do not prove value.
2. **Classify instruments by their actual effects.** The source of
   `docs/measurements/2026-09-12-request-attribution/restore.py` declares four
   product targets and replaces their files; `instrument.py` transforms those
   targets. Their location under `docs/` is not distance from product impact.
   The package README and `.context/codex-reviews/gate-b-c1-group-6-quality-pass-5.md`
   record earlier destructive restore and evidence defects. The present source
   contains digest/preflight checks; no claim is made that the historical bugs
   still exist or that the current tools were validated by execution here.
   Earlier effort escalation for peripheral work must retain scrutiny of
   destructive effects and invalid verification results.
3. **Version the measurement context.** Display installed workflow version,
   observed loaded version when available, local rule revision and any explicit
   overrides separately. Preserve unknowns. Compare cycles within documented
   rule/profile/artifact contexts rather than treating all passes as equivalent.
   An installation update must not be assumed to synchronize local rules.
4. **Separate implementation, verification and acceptance status.** At the
   snapshot, `docs/HANDOVER.md`'s top section reports G1 implemented at WIP
   `25c8838` with Gate B in progress; current HEAD is `1f9f932`. Older sections
   still describe earlier unimplemented states. Those are historical reports,
   not current verification of this HEAD. A dashboard must bind evidence to its
   revision, preserve the historical account and show a mismatch as unknown or
   needing reconciliation. It must not collapse implemented, reported tested,
   reviewed, accepted and released into one green status.

The consumer records deliberately unclean stops and owner decisions to proceed.
These are observations of that project's decisions, not a clean-gate result or
a proposed bypass for the kit. One project's historical curves under incompletely
attributed rules cannot set numeric utility thresholds or establish that stopping
earlier improves product outcomes. Step 2c still owes calibration and its limits.
