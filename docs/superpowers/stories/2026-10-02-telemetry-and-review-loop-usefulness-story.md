# Telemetry and review-loop usefulness (dark-factory vision step 2c) — Story

**Date:** 2026-10-02 · **Size:** epic-needs-splitting
**Risk:** standard · **Security:** standard · **Validation:** battery+check

## 1. Problem statement
The kit cannot see what its own work costs. P8 (`scripts/ledger-metrics.py`, PR #33) reads the
ledger and the recorded review curves, but it is read-only by design and cannot say how long a
step took, how many tokens or how much money a gate pass spent, or how often a call was retried.
The vision (`docs/superpowers/specs/2026-08-30-dark-factory-vision.md` §7, §10) names the
consequence: "absent real-time cost visibility is what makes a token furnace invisible".

Review loops are judged only by finding counts. The vision §4 records that "few findings do not
establish poor usefulness … and many findings do not establish high usefulness", and that review
effort should follow evidenced product impact (Daniel, 2026-09-17). Nothing measures that today.

Two more gaps sit here. A spec edited during a build leaves no mechanical record of what changed
(§10, "spec-delta"). And nothing links a story's artifacts across stages: no trace ID runs from
intake to merge.

The vision's autonomy steps (4–6) depend on this evidence: "No autonomy expansion ahead of the
measured evidence" (§8).

## 2. Desired outcome
Every run of the workflow leaves a local, attributable record of what each step cost and how long
it took, tied to the story it served. Review loops get an explained usefulness assessment rather
than a bare finding count. Spec changes during a build are captured as a delta a reviewer can see.
Once the measurements exist, they can feed the existing INCOMPLETE semantics so a suspiciously
cheap gate pass does not count — without changing what a pass is today until that sub-story lands.

## 3. Acceptance criteria
- [ ] For each workflow step that runs (at least every Gate A and Gate B call), a record exists
      with its duration and, where the source attributes them, tokens, cost and retry count; a
      value the source does not provide is recorded as unknown, never as zero.
- [ ] Every record carries a trace ID that identifies the story it served, and the same ID can be
      found in that story's stage artifacts (story, spec, plan, closing commit). In the closing
      commit it is carried by records that already exist (the provenance line's story set and
      the evidence entry), so no record format changes.
- [ ] Recording never blocks or fails the workflow step it measures; a measurement that could not
      be written is visible as missing, not silently absent.
- [ ] Stored run data has a stated retention rule: what is kept, for how long, and how it is
      compacted or deleted. The rule is in force from the first sub-story that writes data.
- [ ] A review loop's usefulness is shown along the vision §4 dimensions (yield, repair effects,
      effort, coverage), with an explained traffic-light assessment. Unknown evidence stays
      visible, and no composite score appears before its calibration is supported by data.
- [ ] A spec change made after the spec's Gate-A cycle closed is captured as a delta and is
      available to the Gate-B reviewer beside the diff.
- [ ] A gate pass whose measured cost or duration is below a stated minimum, or whose measurement
      is missing or unattributable, reads as INCOMPLETE. This criterion lands only in the last
      sub-story, and no earlier sub-story changes pass validity.
- [ ] P8 stays read-only and unchanged in scope; nothing in this epic writes to the hardening
      ledger or to commit-body record formats.

## 4. Affected AGENTS.md invariants
- `### Hook` — "1. **The hook always exits 0.** It is advisory; a reminder that can fail closed
  would make the workflow unusable whenever Codex is down or the environment is odd."
- `### Hook` — "4. **POSIX `sh`, and `jq` is optional.**"
- `### Packaging` — "5. **Every version pinned exactly.**"
- `### Packaging` — "12. **A plugin change requires a version bump.**"
- `### Prompts and scaffolding` — "11. **Prompt changes pass `docs/prompt-standards.md`**"
- `## Don'ts` — "**Never describe what a gate proves without checking what it actually
  compares.**"

## 5. Open questions
- Which sources can attribute tokens and cost per gate call: Codex session logs, Claude Code
  transcripts, the MCP server's result envelope? Their availability decides which values are
  measurable and which are permanently unknown.
- Does run data stay per-clone (like `.context/`), or is any of it ever committed?
- Is telemetry part of the shipped plugin (every consumer project) or repo-local first, like P8?
- **Part 4's central question (2026-10-04, from the reviewer's assessment
  `.context/sparring/20261004-101100-pr37-merge-and-p5-assessment.md`):** when does low effort
  actually indicate an incomplete review? Few tokens or a short run alone do not answer it.
- What minimum cost or duration makes a gate pass suspicious? Vision §10 proposes the signal but
  sets no number; calibration needs sub-stories 1 and 2 first.

## 6. Suggested size
epic-needs-splitting — four sub-stories, in this order (Daniel, 2026-10-02):
(1) run analytics, trace ID and retention; (2) review-loop usefulness assessment;
(3) spec-delta capture; (4) live cost counters and the minimum-cost INCOMPLETE signal. Part 4
changes gate pass validity and needs its own profile, risk high.

**Part 4 split 2026-10-05 (Daniel).** Measurement first: part 4a, live effort counters
(`docs/superpowers/stories/2026-10-05-live-effort-counters-story.md`, risk standard), changes no
pass validity. Part 4b, the minimum-cost INCOMPLETE signal, comes later, on calibrated data; it keeps
the risk-high profile above and the central question in §5.

**What a 4b threshold decision needs (recorded 2026-10-05, after part 4a shipped).** 4b stays behind
its calibration trigger, and no other story builds the calibration on the side. Real cycles are the
measurement opportunity: before each worktree is removed, `python3 -B scripts/run-analytics.py`
stores its gate calls (a session habit since part 1, not a written workflow step). A later threshold decision needs, per gate kind
(Gate-A spec, Gate-A plan, Gate B):
- the effort of each **valid** pass: duration and tokens, with unknown values counted as unknown,
  never as zero;
- the effort of each pass **known to be incomplete**: a failed envelope, an `INCOMPLETE` reply or a
  findings file that failed validation, so the two groups can be compared;
- each valid clean pass that a **later** review contradicted: a PR bot or later pass finding a true
  defect in the same reviewed range, with the commit pair, since a cheap pass that missed something
  is the case 4b exists for;
- the size of what was reviewed (artifact length or diff size), since a small diff may honestly
  need a short review.

The decision states its own sample size and why that is enough; this note sets no number. A cheap
or short pass is still not, on its own, evidence of an incomplete review.

**Part 2 narrowed 2026-10-03 (Daniel).** Part 2 delivers a warning light over recorded counts and
stored effort (`docs/superpowers/stories/2026-10-02-review-loop-usefulness-assessment-story.md`).
It does not satisfy criterion 5: confirmed distinct yield, repair origin, reviewed coverage and a
judgement of whether a loop was worth its effort remain open here and in `todos.md`.
