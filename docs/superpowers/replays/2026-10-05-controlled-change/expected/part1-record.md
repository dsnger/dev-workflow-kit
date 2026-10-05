**Criteria amended 2026-10-02, during the spec's Gate-A pass 1.** The first version asked for the
account's credit-balance change per call. Measured on this machine, the balance does not move inside
a gate session's logs: all three files of one review showed one identical value. It cannot measure a
call's cost, so it was removed. Criterion 1 also keyed the record on the Codex log being present.
A Codex log alone cannot show that a session was a gate call, so the criterion now starts from the
Claude Code transcript, where a gate call is identifiable, and treats the Codex log as the source of
the token values.

**Scope narrowed 2026-10-02 after Gate-A pass 4 (Daniel, on the reviewer's assessment
`.context/sparring/20261002-132344-telemetry-t1-scope-triage-assessment.md`).** What changed:

| Earlier criterion or promise | Fate |
|---|---|
| Desired outcome: "for any review cycle or story" | **Narrowed.** Story totals cover closed cycles only and are labelled attributed effort; all observed effort stays visible. |
| Criterion 1: every Gate A and Gate B call in a transcript | **Narrowed** to calls shown to run in this clone. Calls from removed worktrees or other clones are outside v1 coverage, and the report says so. |
| Criterion 2: attributed "wherever determinable" | **Replaced.** Only an unambiguous closing provenance line attributes a story. Reconstruction from story mentions or artifact headers is dropped. Unattributed records are still stored. |
| Criteria 3–7 | **Kept.** |
