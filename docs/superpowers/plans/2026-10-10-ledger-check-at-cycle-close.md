# Ledger check at every review cycle's close — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-08-04-ledger-route-without-pull-requests-story.md` — read its profile fresh at each pass.

**Spec:** `docs/superpowers/specs/2026-10-10-ledger-check-at-cycle-close-design.md` (Gate-A spec cycle `vs1f6lw7nub1`, closed in `3a1651f`). The spec decides behaviour; this plan decides order, files, tests and the remaining local choices. Where they seem to differ, the spec wins and the difference is a finding.

**Goal:** every Gate-A and Gate-B cycle that repaired findings checks them against the ledger before it closes, records the result durably in git, and later hardening records its outcome against that record.

**Architecture:** prose rules in `.claude/review-gates.md` and their identical copy in `/workflow-init`'s template `### 2.1a`; one sentence in `process-pr-review` step 5; one new narrow conformance check (4h) with its suite; the five Python reports taught to recognize and set aside the new records; a replay package as the named verification.

**Tech stack:** Markdown prompts, POSIX `sh` (`sh` and `dash`), `shellcheck` 0.11.0, Python 3.8+ (reports), git 2.36+.

## Global constraints

- Invariant 8: both rule copies stay inline and carry the changed passages identically.
- Invariant 9: adoption only through `/workflow-init`'s diff-and-ask; nothing here writes into another project.
- Invariant 11: every changed prompt passage passes `docs/prompt-standards.md` (12 items), in particular item 10 (a diagnostic state names its cause, check and fix) and item 11 (an enforcement claim names its mechanism).
- Invariant 12: `plugins/dev-workflow/.claude-plugin/plugin.json` 0.21.0 → 0.22.0, with a CHANGELOG entry.
- The closure ordering, its branches, floors and the closing acts do not change (spec §6).
- `harden-finding` does not change (spec §3.4).
- Profile: risk `standard`, security `none`, mode `battery+check` → floor 3, no security lens set.

## Carried from Gate A, decided here

The spec cycle closed with three Minors collected (`3a1651f`), plus one side fix Daniel added on 2026-10-10:

1. **Separator inside a quoted path (pass 5, Minor 1).** The spec commits: a path containing ` — ` "is written in double quotes", and a path with a line break stops. The note in `3a1651f`'s body, and the pass-5 disposition, proposed stop-and-surface instead and dropping the quoting. That note was a proposal for this plan, not an approved decision. Following it would change the approved spec without the amendment route, so the spec wins. This plan fills in the quoting with the provenance line's existing `<quoted>` rule: a non-empty double-quoted string whose only escapes are `\"` and `\\`. A reader splits on ` — ` **outside** quotes only. Reusing it adds no second grammar.
2. **Report compatibility (pass 5, Minor 2).** `scripts/ledger-metrics.py`'s `CANDIDATE` matches every new line, and `parse_record` rejects them. Each reader then mishandles them in its own way: `ledger-metrics.py` and `loop-usefulness.py` count them as unparsed, `run-analytics.py` and `status-view.py` discard them silently, and `spec-delta.py` annotates them as malformed. Task 4 makes them recognize the new forms and set them aside. They stay out of curve, provenance and skip grouping, and they are not counted as unparsed.
3. **Nonce-collision limit (pass 5, Minor 3).** The rules text states that `<slot>:<n>` identity and the open-obligation query inherit the nonce's probabilistic attribution. On a collision with a closed cycle, an old outcome line can make a new obligation look closed. The text points to the standing residual and does not repeat it.
4. **Side fix (Daniel, 2026-10-10, "Wie empfohlen").** The findings-file prompt block says "One finding per line in the format above", but the six-field example sits further down, in the Gate-A bullet. This is `.claude/review-gates.md:697` and `plugins/dev-workflow/commands/workflow-init.md:1228`, reported from the Child Theme project. The fix makes the sentence name the format where it is, or moves the example above it; which of the two is a local choice. It is its own named change in Task 2 and in the CHANGELOG, and it touches no Finding A rule.

## Review focus (inputs the spec implies, most likely to bite first)

1. **A cycle whose findings were all dismissed.** The closing commit must say `fixed 0, hardening owed 0`, not omit the line. Neither the replay nor check 4h exercises this. Task 2 puts a filled `fixed 0` example in the rules text, so a reader sees that form.
2. **A partial adoption downstream.** A project takes the new line and declines the dispositions duty, or the reverse. The "one contract" paragraph decides membership by its semantic sentence test, with no list to consult. The new duties pass that test, because they fix the production of a §5 cycle record and an owed file. So the stop reaches a partial adoption, within the limit the paragraph itself states: dropping a member together with every sentence that refers to it can go undetected. Task 2 also lists them in the nonce record set and the carry list, but those lists are not the test's authority.
3. **Mixed history in the reports.** `main` will hold old records next to new ones. Task 4's suites run a fixture commit with both, plus one malformed `cycle x;` line, which must still count as unparsed.
4. **A path containing the separator.** Task 2 gives a filled quoted example. Check 4h requires the quoted-path rule sentence to be present.
5. **This change's own Gate-B cycle.** Its working tree already carries the new rules, and which rules govern it is not cleanly established. Under the stricter reading it **performs the new duties**: dispositions, working record and the ledger-check line. That also exercises the rules once on a real cycle. Task 7 says so in the closing commit.

## Sources and impact boundary

**Read:** CLAUDE.md, AGENTS.md, `.claude/review-gates.md` (full); the story and both change records; the spec; `plugins/dev-workflow/commands/process-pr-review.md` items 3–6; `plugins/dev-workflow/skills/harden-finding/SKILL.md` (Flow, taxonomy, pending); `scripts/check-invariants.sh` (section index, check 4c's design notes) and the head of `check-invariants.test.sh` (the fixture baseline note for 4c); `scripts/ledger-metrics.py` (`CANDIDATE`, `parse_record`, `git_sections`); the record-reading loops in `loop-usefulness.py`, `run-analytics.py`, `status-view.py` and `spec-delta.py` (by grep for `CANDIDATE`); `docs/hardening-taxonomy.md` head; the last rows of `docs/hardening-log.md`; the `CHANGELOG.md` head; the replay READMEs of `2026-10-05-controlled-change` and `2026-10-06-compact-planning`; the previous plan's layout.

**Impact boundary:** `.claude/review-gates.md`; `workflow-init.md` template `### 2.1a`, and any template prose before it that describes the companions or the records; `process-pr-review.md` item 5; `scripts/check-invariants.{sh,test.sh}`; the five Python reports and their suites; `AGENTS.md` invariant 11's count of narrow checks ("Five narrow checks" → six, with 4h named); `docs/hardening-log.md`; `docs/hardening-taxonomy.md`; `plugin.json`; `CHANGELOG.md`; a new replay package; `todos.md` (Finding A row → "in PR #<n>"; "shipped" waits for the merge). Any doc sentence claiming step 5 is the only ledger route, found by a claim grep in Task 5. **Not touched:** the hook (`codex-gate.sh`; it reads no commit-body record, checked by grep for `ledger` and `dispositions` in Task 5), `harden-finding`, the closure ordering's branches, floors and acts.

## Handover boundary

The completed story: PR open, CI green, review bots processed, merge decision presented to Daniel. Write the handover into `.context/handover-mcp-security.md` (this checkout's existing handover file) there, and stop. The Gate-B cycle is not split across sessions.

---

### Task 0: Close this plan's Gate-A cycle before any code

Close by the Gate-A act in `.claude/review-gates.md`:
- confirm the plan file equals the text sent in the final pass's request;
- `HEAD` does not carry it, so commit it unchanged: `git add` of the plan file alone, with a message carrying this cycle's provenance line and per-pass curve;
- confirm that `git show HEAD:<plan path>` equals the file.

- [ ] Equality check, commit, post-commit check

**WIP strategy for Tasks 1–6:**
- One `WIP:` snapshot, made at the end of Task 1 with `git commit -m 'WIP: …'` and folded into by each later task with `git commit --amend -m 'WIP: …'`, so exactly one `WIP:` commit exists.
- Gate B's `baseSha` is the full 40-character name of Task 0's closing commit (the snapshot's parent). `headSha` is resolved before each call.
- The closing act in Task 7 is `git commit --amend -m "<real message>"`, which replaces the snapshot.
- Records that must survive go into that message: the evidence entry, provenance line, curve, ledger-check line, every `hardening owed` line (their number must equal the line's `<M>`), any outcome lines, and Task 2's condition-accounting list.

### Task 1: Check 4h, red against the current text

**Files:** modify `scripts/check-invariants.sh` (new `BEGIN/END check 4h` block after 4g) and `scripts/check-invariants.test.sh`.

**Outcome:** check 4h fails unless **both** rule copies carry, inside the region 4c already uses for each file (whole `.claude/review-gates.md`; the command file's `### 2.1a` section up to the next numbered heading):
- the dispositions duty with its closed verdict set (`fixed`, `not fixed`, `same as <slot>:<m>`);
- the ledger-check line form `cycle <nonce>; ledger check: fixed <N>, hardening owed <M>`;
- the owed line form;
- the three outcome forms;
- the quoted-path rule sentence.

Each item is matched as a fixed string on its own pinned line, the way 4c pins its severity line. Containment versus equality per item is a local choice, but the design note must say which was chosen and why, and what a negating line would do to it.

**Design note in the script header,** as 4c has one: what 4h proves is that the text is present in both copies. It does not prove an agent follows it, or that the surrounding prose is right. That is the limit the spec §5 states.

**Test situations** (each a reject/accept pair; the suite's fixture helpers invoke the checker with `sh`, so the harness runs under `sh` and `dash` while the checker inside fixtures runs under `sh`; the real-repo check is run under both `sh scripts/check-invariants.sh` and `dash scripts/check-invariants.sh`):
- both copies complete → pass;
- each item missing from `.claude/review-gates.md` → fail naming the item and the file;
- each item missing from the command file's `### 2.1a` region, but present elsewhere in that file → fail (placement, as 4c);
- a **frozen** copy of the 0.21.0 text of both files, as a fixture → 4h rejects it, and the reject assertion is green. This stays green after Task 2, and it is the counterfactual for the evidence entry. Separately, the **real repository** check is red on 4h before Task 2 and green after.

**Fixture baseline:** every existing fixture in the suite must carry the 4h lines, or each fails 4h for a reason unrelated to its own assertion. The suite head already explains this for 4c; extend the same baseline helper.

**Decision space:** naming of helpers; exact pinned line wording, as long as Task 2's text carries the same lines.

- [ ] Write 4h and its cases; run the suite → green, including the frozen-0.21.0 reject; the real-repo `sh scripts/check-invariants.sh` fails on 4h only
- [ ] Commit the `WIP:` snapshot

### Task 2: The rules text, both copies

**Files:** `.claude/review-gates.md`; `plugins/dev-workflow/commands/workflow-init.md` `### 2.1a` (and template prose before it describing companions or records, if any).

**Outcome:** spec §3.2–§3.4 and §3.6–§3.7 written into the rules, identically in both copies:
- **Optional companions paragraph and the resume paragraph (line ~186):**
  - dispositions become owed for every slot with a finding of a validated pass, written before the next pass;
  - the working record becomes owed from the first dispositions file;
  - "advisory and authoritative for nothing" is narrowed to name the ledger check as the one exception.
- **A new paragraph for the ledger check at close:** scope (§3.1); input set; line format and completeness; deduplication; reconstruction or the question to the human; an undetermined check blocks the closing act; grep no-match is success; `fixed 0` example; the skip case.
- **Mechanics:** the ledger-check and owed line grammar beside the provenance and curve grammars, including the quoted-path rule (carried item 1) and a filled example of each; the outcome grammar with key semantics, closing rule, `pending` and query coverage; the nonce-collision limit (carried item 3).
- **Nonce paragraph:** the named record set gains the dispositions file, the ledger-check line, the owed lines and the outcome lines.
- **Squash-carry sentence:** gains the ledger-check, owed and outcome lines.
- **"When these rules bind":** a cycle whose starting rules cannot be established owes the ledger check, the dispositions duty and the working record ("each further rule this change ships adds its own strict reading to this list"). The same paragraph's "the working record stays optional" is narrowed to "optional until the first dispositions file", in both copies.
- **Side fix** (carried item 4), in both copies.

**Accounting** (AGENTS.md, "Never replace a decision procedure without accounting for its old conditions"):
- Before editing, list every condition the optional-companions paragraph and the resume paragraph state today.
- Mark each one kept, moved or narrowed, and put the list in the WIP commit body.
- Re-read the paragraphs around each amended rule.

**Test situations:**
- Task 1's suite and `sh scripts/check-invariants.sh` now pass.
- 4c still passes, so the severity line is untouched.
- 4e: the CLAUDE.md template size is unchanged, since only `### 2.1a` grew.
- A diff of the changed passages between the two copies shows only the documented location wording.

**Decision space:** paragraph placement inside §5; sentence wording within the spec's commitments.

- **Version bump in this task**, the first plugin change: `plugin.json` 0.21.0 → 0.22.0. The CHANGELOG entry follows in Task 5.
- **Mutation re-run** after this task is green, by the procedure in `scripts/check-invariants.sh`'s header and `check-invariants.test.sh:448-451`. The fixture baseline changed, so look at which rejects flip and confirm the accept cases stay green. Delete each 4h item from a copy and watch 4h fail. Update the suite's evidence block with the observed results.

- [ ] Accounting list; edit both copies; bump; battery slice green; mutation re-run and evidence block
- [ ] Amend into the `WIP:` snapshot

### Task 3: `process-pr-review` step 5

**Files:** `plugins/dev-workflow/commands/process-pr-review.md`, item 5.

**Outcome:** spec §3.5. The skip covers only a `hardening owed` line written by a cycle inside this PR's own range (merge-base to head), and only for the same occurrence. A reintroduction or any doubt takes the ordinary route. The report names the matched line, and owed lines are the only ones matched. Item 5 is otherwise unchanged.

**Test situation:** a reader check against prompt-standards item 10. Where a match is uncertain, the text names the route the finding takes.

- [ ] Edit; amend into the `WIP:` snapshot

### Task 4: Reports set the new records aside

**Files:** `scripts/ledger-metrics.py` and the four readers using `lm.CANDIDATE` (`loop-usefulness.py`, `run-analytics.py`, `status-view.py`, `spec-delta.py`), plus their `*.test.sh` suites.

**Outcome:** `ledger-metrics.py` gains a recognizer for the five new line forms: ledger check, hardening owed, and the outcomes `rung 1–4|P`, `pending` and `rung 0`. Each reader skips recognized lines before it counts unparsed lines or groups curve and provenance records. A recognized line also never ends a skip record's reason block in a way the old form did not. That is the "next record" scan `loop-usefulness.py` and `status-view.py` run, and the check is to confirm that adjacency still holds.

**Test situations** (one fixture commit per suite, carrying an old provenance line and curve, all five new forms including an owed line with a quoted path that contains ` — `, one malformed `cycle x;` line, and malformed lines inside the new families: a truncated owed line and an outcome with an unknown rung). Every malformed line, old or new family, keeps the existing malformed-record behaviour. Expectations differ by reader, because the readers handle malformed lines differently today:
- every reader: output equals the output for the same commit without the new lines;
- `ledger-metrics.py` and `loop-usefulness.py`, which report unparsed lines: the count equals the number of malformed lines (3), and no valid new-form line is counted;
- `run-analytics.py` and `status-view.py`, which discard unparsed lines silently: attribution and grouping are unchanged;
- `spec-delta.py`: its malformed-line annotation marks every malformed line and no valid new-form line;
- `loop-usefulness.py` and `status-view.py`: a skip record followed by its reason and then a new-form line keeps its reason.

**Decision space:** recognizer name and shape; whether the readers share one helper. A shared one is preferred where the import already exists.

- [ ] Write failing suite cases; implement; all five suites green under `sh`
- [ ] Amend into the `WIP:` snapshot

### Task 5: Ledger, taxonomy, claims, version

**Files:** `docs/hardening-taxonomy.md`, `docs/hardening-log.md`, `AGENTS.md` (invariant 11 count), `CHANGELOG.md`, plus any doc the claim grep finds.

**Outcome:**
- **Taxonomy:** the class `mandatory-step-anchored-to-optional-path`, after the near-match grep its head requires.
- **Ledger:** one row for Finding A under that class, source `manual`, rung `P`. The ref names the rules text and check 4h, and states that 4h checks presence only.
- **AGENTS.md:** "Five narrow checks" becomes six, and 4h is named in the same sentence style, including what it does not check.
- **CHANGELOG:** the 0.22.0 entry (the bump itself landed in Task 2) covers Finding A and, separately, the side fix.
- **Claim grep,** run for the claim rather than the phrase. Anything saying the ledger is reached only through PR review or step 5 is corrected:
  `grep -rniE '(only|sole)[^.]{0,60}(ledger|hardening)|(ledger|hardening)[^.]{0,60}(only|sole)|step 5' --include='*.md' . | grep -vE 'source-files/|docs/superpowers/'`
  Read every hit, not the count.
- **Hook unchanged:** `git diff --quiet <Task 0 commit> -- plugins/dev-workflow/hooks/` exits 0. That is the proof. A grep for `ledger` or `dispositions` would only show those spellings are absent.

**Test situations:** after amending into the snapshot, `sh scripts/check-version-bump.sh main` passes and the full battery is green.

- [ ] Edits; amend into the `WIP:` snapshot; full battery green

### Task 6: Replay package (named verification)

**Files:** create `docs/superpowers/replays/2026-10-10-ledger-check/` with `README.md`, a fixture builder, prompts, `expected/`, `out/` and `compare.md`, in the layout of the existing packages.

**Outcome:** spec §5's parts A and B and the counterfactual:
- **Fixture builder:** a POSIX `sh` script that builds the fixture repository in a directory given as argument, never inside this repo. It creates:
  - two passes with three repaired finding lines and two distinct defects, X and Y;
  - dispositions written as at repair time, plus the working record;
  - a fixture ledger with X's class;
  - for part B, a second history whose `main` holds one squash commit with three owed lines and their outcomes: `rung 2`, `pending <ref>`, none.

  The README records why Y warrants no class.
- **Runs:**
  - one fresh `claude -p` session per part, **started in the fixture root**, never a subagent of this session. A subagent would load this checkout's CLAUDE.md, which points at the host's new rules;
  - the fixture carries the selected rules as its own `CLAUDE.md` and `.claude/review-gates.md`, copied by the builder from a full commit ID: the branch head at Task 6 for the new rules, `main`'s full commit ID (0.21.0) for the counterfactual. The prompt and all non-rule inputs are identical between the variants;
  - the package records the sha256 of each copied rule file and the source commit, and Task 7 confirms the new-rules hashes equal the files in the closing tree, so the tested bytes survive the WIP amends;
  - user-level instructions (`~/.claude/CLAUDE.md`, memory) still load. That is recorded as a limit, together with what the session reported loading;
  - part B removes `.context/codex-reviews/` before the session starts.
- **Expected results:**
  - A: `fixed 2, hardening owed 1`, X's class and severity;
  - B: two open obligations, the pending one blocked with its `ref`, each with a complete intake and no question back;
  - counterfactual: no ledger-check line **and** no owed obligation recorded.
- **Recording:** `compare.md` records each observation against its expectation. If the counterfactual produces either a ledger-check line or an owed obligation, the claim is false: stop and surface.
- **Limits** as spec §5 states them, in the README.

**Decision space:** fixture contents beyond the pinned facts; prompt wording, which is recorded verbatim in the package.

- [ ] Build the fixture; run A, B and the counterfactual; write `compare.md`
- [ ] Amend into the `WIP:` snapshot

### Task 7: Gate B, close, PR

- **Evidence entry** (story path, no mode value): check 4h with its counterfactual case from Task 1, and the replay package with its counterfactual from Task 6.
- **Gate B:** floor 3. Two sequential single-branch calls per pass, on the same full 40-character SHAs.
- **Cycle duties, by the strict reading of review focus 5:** this cycle's governing rules are not cleanly established, so it performs the new duties — dispositions per slot, working record, the ledger-check line and owed lines at close. The closing commit says this, and claims no old-rules start.
- **Closing commit:** the amend described in Task 0's WIP strategy. Its message carries the provenance line, curve, evidence entry, ledger-check line and Task 2's accounting list. Afterwards, `git log` shows no `WIP:` commit and the tree equals the reviewed head.
- **PR:** push the branch and open the PR. Then mark the Finding A row in `todos.md` as "in PR #<n>" in a docs-only follow-up commit; "shipped" waits for the merge. The body carries every cycle record of the branch: spec cycle `vs1f6lw7nub1`, this plan's cycle, the Gate-B cycle.
- **Bots:** process them with `process-pr-review`.
- **Handover:** write it at the boundary and present the merge decision to Daniel.

- [ ] Gate B to closure; PR; bots; handover
