# `/dev-workflow:claude-init` — design and target text

**Story:** `docs/superpowers/stories/2026-09-17-claude-init-command-story.md` — read the profile from
its header at every gate call; it is the only writable copy.

This spec carries **every string the change installs**, in final form. The plan cites sections here
by name and does not restate them: a second copy of normative text is the defect the loop-rule cycle
spent most of its findings on.

---

## §1 What is being added

**One command file**, `plugins/dev-workflow/commands/claude-init.md`, loaded by convention from
`commands/` — **no manifest key** (invariant 6). It carries its template inline (invariant 8).

**One rule**, `### Don't guess`, added at the end of section 1 in **three** copies:

| # | File | Position |
|---|---|---|
| 1 | `plugins/dev-workflow/commands/claude-init.md` | inside the new inline template, end of §1 |
| 2 | `plugins/dev-workflow/commands/workflow-init.md` | inside the existing inline template, end of §1 |
| 3 | `CLAUDE.md` (this repository's own) | end of §1 |

**Byte-identical in all three**, including line wrapping, so parity is decidable by `diff` and needs
no new mechanism. On `main` the three §1 bodies are already byte-identical, which is what makes this
possible.

**Three inventory sites**, and no others: `README.md`'s component table, `AGENTS.md`'s layout tree,
`docs/architecture.md`'s layout tree. `MANIFEST.md` is **not** among them — it inventories
`source-files/`, the frozen extraction seed, and a command with no seed origin has no row there.

**One version bump and one changelog entry** (invariant 12): **`0.11.0` → `0.12.0`**, decided by
Daniel on 2026-09-17, with `claude-init` planned as **the first of the two in-flight changes to
merge**. That is release sequencing and **not** permission to merge. `0.13.0` was explicitly rejected
as a way to reserve `0.12.0` for the unfinished `loop-rule-consolidation` branch.

**The integration base is rechecked before the version is finalized**, never taken from this
sentence. Verified when it was written: `origin/main` and local `main` are both
`7c0d475b9a4a1897e8b03dfa20ec058b9ce09ba6`, its manifest is `0.11.0`, `CHANGELOG.md`'s newest entry
is `0.11.0`, and no pull requests are open — so `0.12.0` is free. `main` can move, and
`scripts/check-version-bump.sh` is blind to exactly this case ("two PRs branched from the same
version each bumping to the same new one"), so the recheck is the only thing standing in for it.

**The `loop-rule-consolidation` branch is not edited by this change.** Its plan pins `0.12.0` for
itself; reconciling that belongs to that cycle, on that branch.

## §2 What the command does, and what it refuses to do

**Its only write to a target project is `CLAUDE.md`.** Not a marker, not a README note, not an
`AGENTS.md`. One file.

**It requires nothing that initializing a file does not require, with one named exception.** No
superpowers plugin, no Codex MCP server, no `gh`, no package manager, and **no git repository**. It
does not invoke `/workflow-init`, does not run `git init`, installs nothing, writes no `.context/`
marker, and **does not commit**. **The exception is the create branch**, which needs an
already-present Python 3 runtime for its exclusive-create operation (§2, *Writing*); a directory
alone is enough to read and to propose, and where that runtime is absent the create branch stops
without writing rather than falling back to a weaker write.

**Existing-file behaviour**, matching invariant 9's shape without inheriting its scaffolding. **Two
questions are asked, in order, and the first has nothing to do with content:** what *kind* of path is
this, and only then what does it *contain*. Pass 1's Major 1 was that the earlier table asked only
the second, so a path that could not safely be classified fell into a content branch anyway.

### Step one — the path must be one of exactly two kinds

Anything else **stops without writing**. This is a partition over what the filesystem can present,
not over what the file says.

| Path observed | Action |
|---|---|
| **Absent** — nothing at that path, and not a dangling symlink | Eligible for the create branch. |
| **An existing, readable, regular file** | Eligible for the content branch. |
| A symlink — resolved or dangling | **Stop. Write nothing.** Report the path and where it points. |
| A directory, or any other non-regular file | **Stop. Write nothing.** Report what was observed. |
| Present but unreadable | **Stop. Write nothing.** Report the failure. |

**Why each stop, rather than one "cannot write".** A **live symlink redirects the write into another
file**, which breaks the one-file contract silently. A **dangling symlink reads as absent** to an
ordinary existence test and would be written through. A **directory** cannot hold the template. An
**unreadable file cannot be classified at all**, and "cannot classify" is not "different" — treating
it as different would offer a diff computed from nothing.

**The kind test must not follow the link.** `test -e` and `test -f` both resolve symlinks, so a
dangling link answers *absent* — the exact misread that would overwrite through it. Test with
`test -L` **before** any existence test, or read the kind with `ls -ld`. **Report which row was
observed**, not a single generic failure: each of the five has a different fix, and a reader who is
told only "cannot write" retries the thing that already failed.

**A failed write is an outcome, not silence.** If the create write is attempted and fails, report
the failure and the path's observed state afterwards. `written` and `unchanged` are claims about an
**observed** result; neither may be reported from a write whose result was not seen.

### Step two — content, for a target that passed step one

| State found | Action |
|---|---|
| Absent | Create the file with the template, and **only through a qualifying create operation** — see *Writing* below. Report `written`. Where no such operation is available, stop without writing and report that. |
| Present, and the rules it carries are equivalent | Report `unchanged`. **Add nothing, duplicate nothing.** |
| Present, with different or partly overlapping rules | Show a **focused proposed diff** — the sections that differ, not the whole file — and **ask**. On approval, hand back the proposed result and **stop**. The command never writes over an existing `CLAUDE.md`; see *Writing* below. |

### Writing — which branch writes, through what, and what that actually gives

**Exactly one branch writes: the create branch.** A target that already exists is never written
over by this command. Where the rules differ or overlap, the command produces the proposed result,
asks, and — approval or not — **stops without writing**. Decided 2026-09-21, recorded in the story's
§5 item 5.

**Why the merge write was removed rather than qualified.** Pass 1's Major 2 was that the earlier
text computed a diff, waited for a human, and merged with no second look; **that wait is
human-length** — minutes — and the likeliest concurrent writer is the person being asked, in their
editor, looking at the file the command just showed them. The repair named `Edit` and claimed its
exact-string check as write-time preimage rejection. **Gate-A spec pass 3 found that claim
unsupported**, and it could not be rescued: an operation was measured to publish by **replacing the
file**, and an atomic replacement of a file is not an atomic check-and-replace of content read
earlier — POSIX `rename()` guarantees only that the destination name keeps referring to one file or
the other throughout, and imposes **no condition on the destination's content**
([XSH rename](https://pubs.opengroup.org/onlinepubs/9799919799/functions/rename.html)). The
alternative on offer was an **operating assumption** that no other writer touches the file during
the run. An assumption is not a guarantee, and **D2** — *"Where §5 and its gates are present, they
stay. There is no remove, disable, or downgrade path"* — is stated absolutely. A command that can
discard a live gate under an assumption it does not enforce breaches D2 whatever the assumption
says. So the write went, not the obligation.

**What that costs, stated plainly:** where a project already has a `CLAUDE.md`, the user applies the
proposal themselves. The command's convenience shrinks; nothing it claims becomes conditional.

**Two limits on the proposal itself, because not writing is not a licence.**

- **A proposal must preserve what a write would have had to preserve.** Unrelated project content
  and existing mandatory rules stay in it, and it never removes, disables, weakens or renumbers a
  gate. **A harmful proposal is not made acceptable by the user being the one who applies it** —
  D2 and the preservation rule bind the content of the proposal, not only the act of writing.
- **Approval opens no write path inside this command.** "Proposal produced and approved" is **not**
  a merge that was applied, must never be reported as one, and must not be followed by a write
  through any other operation. The command has no route from approval to an existing file.

**On the create branch, re-read immediately before attempting the create.** Compare the target
against the state observed at step one; changed → report what changed and stop rather than
attempting. **This is not the guard** — the guard is the exclusive-create operation below, which
refuses the target outright. What the re-read buys is a better report: the command can name what
appeared, instead of only relaying an `EEXIST` from the attempt. **It narrows a window; it does not
close one.**

**The create branch has one admission rule, and it admits no exceptions.** Between the final
absence check and the write, another writer can create something at that path. **A write that
overwrites it and discloses the overwrite afterwards is not preservation** — the file it destroyed
could hold unrelated project rules, or a full §5 with live gates, which D2 forbids removing. So:

> **Create only through an operation whose verified semantics refuse an existing destination of
> every kind** — regular file, symbolic link resolved or dangling, FIFO, device, directory. **If no
> qualifying operation is available, stop without writing and report the limitation.**

That is the shape step one already uses for every unsafe path kind, now applied to the window after
step one has run. **Whether a route qualifies is decided by reading its specification, never by
assuming a capability**, and a route that qualifies for some destination kinds and not others does
not qualify.

**Three routes have been checked against that rule. One qualifies.**

**The agent's ordinary file-writing tool does not qualify** — it offers no create-exclusive mode and
refuses nothing, so it is forbidden here — as is every other write into an existing path, on every
branch.

**`set -C` plus a `> CLAUDE.md` redirect does not qualify either, and POSIX is quoted rather than
paraphrased.** Redirecting Output (XCU 2.7.2) says the redirection *"shall fail if the noclobber
option is set … and the file named by the expansion of word exists and is either a regular file or a
symbolic link that resolves to a regular file"*, and that it *"may also fail if the file is a
symbolic link that does not resolve to an existing file"*. The rationale adds only that *"the
restriction on regular files is historical practice"*
([XCU 2.7.2](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#tag_19_07_02),
[rationale](https://pubs.opengroup.org/onlinepubs/9799919799/xrat/V4_xcu_chap01.html)). So **three
gaps, read off that text**: a dangling symlink is *"may also fail"*, which is permission and not a
requirement; a FIFO, a device or a directory is not covered at all; and nothing outside regular
files is required to fail. **Narrowing the description of noclobber does not turn it into a
qualifying operation** — it is the same operation, described more accurately. **Measured here, its
worst case is not a wrong answer but a hang**: against a FIFO the redirect neither refused nor
returned, blocking past a five-second limit, because the open waits for a reader.

**`os.open(path, O_WRONLY | O_CREAT | O_EXCL)` qualifies, and POSIX is quoted for it too.** `open()`
says *"If O_CREAT and O_EXCL are set, open() shall fail if the file exists"* — `shall`, not `may` —
and, in the sentence that closes exactly the gap noclobber leaves, *"If O_CREAT and O_EXCL are set,
and path names a symbolic link, open() shall fail and set errno to [EEXIST], **regardless of the
contents of the symbolic link**"*
([XSH open](https://pubs.opengroup.org/onlinepubs/9799919799/functions/open.html)). A dangling
symlink is therefore required to fail, not permitted to; and an existing FIFO, device or directory
is an existing file, so it fails too. **This is the admission rule's requirement met by
specification, not by observation.**

**Observation was taken as well, and it is reported as what it is.** A probe in one environment —
Darwin 25.6.0, Python 3.12.1, Apple's `/bin/sh` — ran both routes against six destination kinds in
throwaway directories:

| Destination | `os.open` `O_CREAT\|O_EXCL` | `sh`: `set -C` then `>` |
|---|---|---|
| absent | created | created |
| existing regular file | refused, `EEXIST` | refused |
| directory | refused, `EEXIST` | refused |
| FIFO | refused, `EEXIST` | **not refused — blocked past 5 s** |
| symlink → regular file | refused, `EEXIST` | refused |
| dangling symlink | refused, `EEXIST` | refused |

**Read this table the right way round.** It is evidence about one implementation on one machine, and
one row shows why that is not enough on its own: this `sh` refuses a **dangling symlink**, which
POSIX only permits it to do. A conforming implementation that declined that
permission would create straight through a dangling symlink, and this column would read
differently on the same machine tomorrow if the shell changed. **The guarantee is the specification; the probe only
shows the two routes are not interchangeable in practice either**, and it is not an end-to-end test
of the command, which has none.

**The price, accepted rather than hidden: creating requires a Python 3 runtime that is already
present.** The command installs nothing, adds no package manager, and introduces no lock, marker or
helper subsystem. **Where no qualifying operation is available it stops without writing and reports
the limitation** — the admission rule's own second sentence, and there is no weaker fallback. The
runtime was observed on the machine this was written on; **that says nothing about a user's project**,
which is exactly why the stop is the other half of the rule and not an error path nobody expects.

**Why this needed a decision, and why D3 was not the reason.** D3 forbids a new **synchronization**
mechanism — the parity checker for the three template copies — so a lock directory would breach it
and a single standard-library call would not. What made this the maintainer's call is narrower and
real: it is a **new precondition** on a command whose story said it demands nothing an initializer
does not need — a sentence this decision amends rather than quietly outgrows. Recorded as settled on
2026-09-21, in the story's §5, and the story's own wording was corrected in the same round.

**What the qualifying operation does not give, so that nothing later reads it as more.** It makes
the creation of the **directory entry** exclusive. It does **not** make writing the template's bytes
atomic, and it does **not** protect the file from any change made after the write returns. A write
that begins and then fails leaves a partial file, and that is an outcome to report, never a
`written` claim — the rule above already says a result may only be reported from a result that was
observed.

**No lock, no marker file and no synchronization mechanism is introduced.** There is no state here
worth a subsystem. This change carries exactly one new precondition — the runtime above — and
inventing a synchronization mechanism would be a second one of a different kind, which it does not
carry.
**Unresolved guarantee, named — and now only one branch has a sequence to be unresolved about.**
`O_EXCL` gives an exclusive directory entry at creation; it does **not** make the whole
observe-then-create sequence atomic, and nothing available to this command does. The other branch
has no such gap because it performs no write.

**Unrelated project content and existing mandatory rules are preserved in every branch.**

**Where the full workflow is already installed** — §5 present, gates in force — the command **says so
and changes nothing about them.** It never removes, disables, weakens or renumbers a gate, and it
offers no downgrade path. This is the lighter entry point, not an exit.

**Equivalence is judged by a reader, and the command says so.** No fingerprint, no checksum, no
normalizer. A rule set that says the same thing in different words is equivalent; the command reports
`unchanged` and explains what it matched. This is a stated limit, not a guard.

## §3 What the template omits, and why each omission is required

| Omitted | Reason |
|---|---|
| §4's closing sentence — *"The work loop includes the review gates: **spec ready → Gate A (spec) → plan ready → Gate A (plan) → execute → tests green → Gate B → commit** (see §5)."* | It routes into a §5 this template does not write. Keeping it would ship a dangling reference. |
| §5 entirely | The command installs no gates. |
| §6 | This repository's own §6 is a personal context canary. It is in no template today and joins none. |
| The closing pointer — *"Project architecture, stack-specific patterns, and invariants live in @AGENTS.md … The Cross-Model Review gates (§5) check against the invariants there."* | Two dangling references in one sentence: `AGENTS.md`, which this command does not write, and §5, which does not exist here. |

**Kept, and deliberately:** the `# <project>` heading, the `**Tradeoff:**` line, all of §1–§3, §4
minus its last sentence (**including** the ground-your-progress-claims paragraph, which depends on no
gate), and the closing `**These guidelines are working if:**` line, which references nothing.

## §4 Target text — the `Don't guess` rule

Installed verbatim at the end of section 1 in all three copies. **This block is normative in its
bytes**, wrapping included, because parity is checked by comparing the three copies.

```
### Don't guess

Applies to factual claims in every answer, not only implementation. Confidence is not evidence.

**Leave gaps visible.** Do not invent missing or ambiguous facts. State what is unknown and why. In extraction
tasks, leave unsupported fields blank where the format permits; otherwise use the format's defined missing-value
handling.

**Separate evidence from inference.** Cite the relevant source for factual conclusions. Identify deductions and
assumptions as such, with their basis. For extraction tasks, label populated fields EXTRACTED or INFERRED and
explain each inference where the required output format permits. If neither annotations nor accompanying
explanations are permitted, preserve the required format. This does not permit inventing unsupported values.

**Keep decisions distinct from facts.** Make reasonable design and implementation choices within the authorized
scope, describing them as choices rather than source facts. Ask when missing information changes correctness or
scope.

**Verify before claiming.** Report a test or action as completed only when its result was observed. Preserve
required output formats; put explanations outside structured artifacts where permitted.
```

**Placement in each copy:** immediately after §1's last bullet (`- If something is unclear, stop.
Name what's confusing. Ask.`), separated by one blank line, and immediately before `## 2. Simplicity
First`, separated by one blank line.

## §5 Target text — the minimal `CLAUDE.md` template

**The complete content the command writes.** In the command file this is wrapped in a ````markdown
fence (four backticks), because the block below contains a three-backtick fence of its own.
`<project>` is the target directory's name unless the user says otherwise.

````
# <project>

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### Don't guess

Applies to factual claims in every answer, not only implementation. Confidence is not evidence.

**Leave gaps visible.** Do not invent missing or ambiguous facts. State what is unknown and why. In extraction
tasks, leave unsupported fields blank where the format permits; otherwise use the format's defined missing-value
handling.

**Separate evidence from inference.** Cite the relevant source for factual conclusions. Identify deductions and
assumptions as such, with their basis. For extraction tasks, label populated fields EXTRACTED or INFERRED and
explain each inference where the required output format permits. If neither annotations nor accompanying
explanations are permitted, preserve the required format. This does not permit inventing unsupported values.

**Keep decisions distinct from facts.** Make reasonable design and implementation choices within the authorized
scope, describing them as choices rather than source facts. Ask when missing information changes correctness or
scope.

**Verify before claiming.** Report a test or action as completed only when its result was observed. Preserve
required output formats; put explanations outside structured artifacts where permitted.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

Ground progress claims: before reporting a step as done, audit the claim against a tool result from this session ("tests green" needs a test run to point to). Report unverified work as unverified — this keeps status reports factual on long runs.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
````

**Every line above except the `### Don't guess` block is taken unchanged from `workflow-init`'s
template as it stands BEFORE this change.** The only edits are the four omissions in §3 and the one
insertion in §4. **That is the derivation, and it is the pre-change comparison only** — §7 row 4a.

**After this change the two templates differ by three omissions and no insertion**, because
`workflow-init`'s template gains the same `Don't guess` rule and has no §6 of its own to omit. §7
row 4b is that comparison. **Conflating the two was pass 1's Major 4**: a verifier holding the shipped
pair to the derivation's transformation rejects a correct change. (Pass 1's row stated that as a
hunk list; neither row requires a hunk shape now — see 4b.)

## §6 Prompt-standards conformance

**Invariant 11 owes all twelve items of `docs/prompt-standards.md`, and the scripts reach three of
them.** Pass 1's Major 6 was that this section addressed two items and §7 then claimed the scripts
established conformance. They do not: `AGENTS.md` invariant 11 says so itself — the checks in
`scripts/check-invariants.sh` "are a floor, not coverage. Every other item is judged by a reader."

### The three items a script touches, and the discovery that gates them

- **Item 1 — `Target model:`.** A `Target model: Claude via Claude Code.` line goes in the command
  body, matching `workflow-init.md` and `process-pr-review.md`.
- **The declaration check only runs on files the scan selects, and the selector is a content
  marker, not a path list.** `scripts/check-invariants.sh:313` builds its file set with
  `grep -rl 'prompt artifact and follows'`. **The command body must therefore carry that exact
  phrase** — the spelling `workflow-init.md:9` uses, *"This command is a prompt artifact and follows
  …"* — or the file is outside the scan and its declaration is never counted.
  **Verified, not assumed:** `process-pr-review.md` carries a `Target model:` line and **not** the
  marker, so it sits outside the scan today. A `claude-init.md` written without the marker would too,
  and §7's check would be green about a file nothing looked at.
  **So the check on the check:** after the command file exists, confirm its path **appears in the
  scan's own output** (`grep -rl 'prompt artifact and follows' --include='*.md' .`) before treating a
  green `check-invariants.sh` as evidence about it.
- **The template must not contain a `Target model:` line.** `workflow-init.md` records this as a
  reasoned `n/a` in a note **outside** its fence, because the scaffolded file's executing model is
  whichever model the target project runs. `claude-init.md` carries the same note, in the same place,
  for the same reason — and a second `^Target model:` line in the file would make its declaration
  count 2 and fail the check.
- **The checklist-count check does not cover this file.** `check-invariants.sh` parses the count
  claim in `docs/prompt-standards.md` and in `workflow-init.md` **by name**. `claude-init.md` is not
  in that pair, so it must simply **make no numeric checklist-count claim**; if it ever does, the
  checker will not verify it.

### The other nine items are owed to a reader, and the plan assigns the review

**The plan carries an explicit twelve-item review of `claude-init.md`** — every item of
`docs/prompt-standards.md` answered, in writing, with either the answer or a **reasoned `n/a`** in
the shape `workflow-init.md` already uses for item 1 of its scaffolded template. Items 2 (success
criteria), 3 (stop conditions), 4 (output format **with an example**), 5 (structured sections), 6
(rules carry their why), 7 (no contradictions with `CLAUDE.md`/`AGENTS.md`), 8 (token-lean), 9
(positive instructions), 10 (diagnostic states name their causes), 11 (enforcement claims name their
mechanism) and 12 (calibrated emphasis) **have no mechanical check at all** and are satisfied only by
that review being done and recorded.

**The same review covers the changed prompt text elsewhere in this change** — the `Don't guess` rule
as it lands in `workflow-init.md`'s template and in this repository's own `CLAUDE.md`.

**Item 11 applies to this spec too**, and pass 1 found it violated four times. Any sentence here
saying something is enforced must name the mechanism and stop at what that mechanism compares.

## §7 Verification — what is checked, and how

**Every row states only what its own command compares.** Where a claim is broader than its check, the
check's scope is the claim and the remainder is assigned to the walkthrough below. Pass 1's Majors 4
and 6 and Minor 7 were all rows that did not do this.

| # | Claim — exactly as wide as the check | Check |
|---|---|---|
| 1 | The `Don't guess` block is byte-identical in all three copies | Extract each copy's block and `diff` them pairwise; expect empty. |
| 2 | The template contains none of the spellings `Gate A`, `Gate B`, `§5`, `Cross-Model` | `grep -c` for each inside the template fence; expect 0. **This is absence of those spellings, not absence of gate obligations** — a sentence demanding approval before every commit passes it. |
| 3 | The template contains neither the spelling `AGENTS.md` nor `(see §5)` | `grep -c` for each inside the fence; expect 0. **Absence of those spellings, not absence of dangling references** — a pointer to `@POLICY.md` passes it. |
| 4a | **Pre-change derivation.** The proposed template equals `workflow-init`'s template **as it stands before this change**, with exactly the four §3 omissions applied and the `Don't guess` rule inserted | Build that expectation mechanically from the pre-change fence and compare for **exact equality**; expect byte-identical. |
| 4b | **Post-change comparison.** The shipped `claude-init` template equals the shipped `workflow-init` template with exactly **three** omissions applied and **no insertion** | Build the expectation mechanically from the shipped `workflow-init` template by removing §4's closing gate-chain sentence, §5, and the closing `@AGENTS.md` pointer, then compare it with the shipped `claude-init` template for **exact equality**; expect byte-identical. The transformation applies **no insertion** — both templates carry `Don't guess` after this change — and **removes no §6**, because `workflow-init`'s template has none. **No number of diff hunks is required**: how many hunks a rendering shows is a property of the renderer's context window, not of the change. |
| 5 | No `commands` key was added to the plugin manifest | `grep -c '"commands"' plugins/dev-workflow/.claude-plugin/plugin.json`; expect 0. **This is one key.** Invariant 6 as a whole — no `skills`, `agents` or `hooks` key either — is checked separately by `scripts/check-invariants.sh`. |
| 6 | The version was bumped and logged | `scripts/check-version-bump.sh` against the PR's own base ref, plus a `CHANGELOG.md` entry for the new version. **Verifies a bump is present, not that it is correct** — the script's own documented limit. |
| 7 | The three mechanical prompt-conformance spellings hold, and the pinning and manifest invariants hold | `sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh`. **This is not prompt conformance** — `AGENTS.md` invariant 11 calls these three "a floor, not coverage"; the other nine checklist items are judged by the §6 review. |
| 8 | The commands in `AGENTS.md` § Commands exit 0 | The full quality battery. **Tested coverage, not "nothing broke"** — the battery covers shell lint, the hook suites and the two checkers, and nothing in this change is executable. |
| 9 | `claude-init.md` is inside the conformance scan | `grep -rl 'prompt artifact and follows' --include='*.md' .` lists it. **Without this, row 7 says nothing about the new file** (§6). |

**Rows 2, 3, 4a and 9 are the `battery+check` counterfactual, and the counterfactual is
demonstrated rather than asserted.** Run against `workflow-init`'s template, rows 2 and 3 go red:
the six greps return **6, 12, 3, 2, 7, 10** where the new template returns **0** for each. Row 4a's
expectation is built from a source that must be transformed to match, so an untransformed template
fails it. Row 9 goes red on any file lacking the marker — `process-pr-review.md` is a live example.

**Row 4b has no counterfactual and is not offered as one.** It compares two files that will both be
correct or both be wrong, so it detects divergence between them and not an error common to both.

**What is not checked mechanically, stated rather than implied.** Nothing verifies the command's
*behaviour* in a target project — that a new target receives only `CLAUDE.md`, that a second run adds
no duplicate, that an overlapping file triggers the ask, that each of step one's five path kinds
stops where it should. Those are **prompt instructions read by a model**, and this repo has no
harness that executes a command against a fixture project. They are verified by a **walkthrough** — a
reading of the command text against each case — and a walkthrough is evidence about the text, **not**
an execution. Any report saying otherwise is false.

**The walkthrough also carries what rows 2 and 3 cannot reach.** Those rows establish the absence of
four and two *spellings*. The **semantic** questions — does the template impose any gate obligation
in any wording, does it point at any file this command does not write — are read by a human against
the template text, and the report says which rows were mechanical and which were read.

### Accounting — what the pass-1 repair kept, moved and dropped

`AGENTS.md`: *"Never replace a decision procedure without accounting for its old conditions."* The
pass-1 §2 table and §7 table were both replaced; every condition they carried is listed.

| Old condition | Fate |
|---|---|
| Absent → write, report `written` | **Kept**, now in step two, reachable only after step one. |
| Equivalent → report `unchanged`, add nothing | **Kept**, unchanged, now in step two. |
| Different/overlapping → focused diff, ask before merging | **The diff and the ask are kept**; the merge that followed them is **dropped** — the branch now proposes and stops. `AGENTS.md` invariant 9 and the story both require only *show the diff and ask*; *before merging* was this spec's own addition, so what is dropped is the spec's, not theirs. Pass 3's Major. |
| "Unrelated project content and existing mandatory rules are preserved in every branch" | **Kept**, moved below step two so it governs both steps. |
| "Equivalence is judged by a reader … a stated limit, not a guard" | **Kept**, verbatim, in place. |
| Full workflow present → say so, change nothing | **Kept**, verbatim, in place. |
| §7 row 1 (three-copy parity) | **Kept**; claim narrowed to the `Don't guess` block, which is what the check extracts. |
| §7 rows 2–3 (gate obligations, dangling references) | **Kept as checks**; their claims **narrowed to spellings**, with the semantic remainder **moved** to the walkthrough. |
| §7 row 4 (template derivation) | **Split** into 4a (pre-change derivation, exact equality) and 4b (post-change comparison, three omissions, no insertion). The original single row asserted a post-change diff that cannot exist. |
| §7 row 5 (manifest) | **Kept**; claim narrowed to the `commands` key, with invariant 6 as a whole named as a separate check. |
| §7 row 6 (version) | **Kept**; the script's own "present, not correct" limit added. |
| §7 row 7 ("invariants and prompt conformance hold") | **Kept as a check**; the claim **dropped** to the three spellings it actually tests, with the nine reader-judged items moved to §6. |
| §7 row 8 ("nothing else broke") | **Kept as a check**; the claim **dropped** to "the battery's commands exit 0". |
| The counterfactual paragraph | **Kept and corrected**: it named rows 2–4, and row 4b has no counterfactual, so the set is now 2, 3, 4a and 9. |
| **Nothing was dropped without a replacement** | The only outright drops are two overclaims (rows 7 and 8), and in both cases the check survives and only the sentence about it shrank. |

### Accounting — what the pass-2 and pass-3 repairs kept and dropped

Three decision procedures were replaced across these rounds: the create branch's write rule (§2),
the **merge** branch's write rule (§2), and row 4b's check (§7). The merge branch's rule was
replaced once, by removal, after Gate-A spec pass 3; two new conditions came with that removal — the
proposal must preserve what a write would have had to preserve, and approval opens no write path —
and they are stated in §2 rather than here, because this table accounts for **old** conditions.
**The create branch's rule was replaced three times** — first to stop the overwrite-and-disclose
fallback; then again once POSIX was read against the remaining route and `set -C` turned out not to
satisfy the rule either, which left the branch unable to write at all; then a third time when a
qualifying operation was admitted and the maintainer accepted its precondition. All three are
accounted for below, and where a later one undid part of an earlier one the row says so. Every condition each procedure carried is listed, kept or dropped on
purpose.

| Old condition | Fate |
|---|---|
| Create branch: re-read immediately before writing | **Kept**, now stated for the create branch alone, since it is the only branch that writes. Its value is **re-described**, not re-claimed: it improves the report, it is not the guard — the exclusive-create operation is. |
| Create branch: `set -C` is the named operation | **Dropped.** The first replacement kept it and narrowed its claimed guarantee; the second removed it as a route, because a narrower description does not make an operation qualify. XCU 2.7.2 requires failure only for an existing regular file or a symlink resolving to one, makes a dangling symlink *"may also fail"*, and says nothing about FIFOs, devices or directories. Pass 2's Major 2, and the contradiction that survived its first repair. |
| Merge branch: apply the merge as `Edit` operations, never a whole-file `Write` | **Dropped.** The branch no longer writes, so there is no operation to constrain. The sentence was not wrong about `Write`; it is simply moot. |
| Merge branch: "`Edit` rejects a changed preimage" and "the outside-region limit costs nothing here" | **Dropped as unsupported.** Pass 3's Major. `Edit` was measured to publish by replacing the file, and an atomic file replacement is not an atomic check-and-replace of previously read content; POSIX `rename()` imposes no condition on the destination's content. Neither the concrete loss nor its absence was proven — what failed is the **support for the guarantee**, which is enough to stop claiming it. |
| "Only preimage rejection is a guarantee, and it is available on one branch and not the other" | **Dropped.** It was the frame that made an unsupported guarantee look like the strong half of a pair. With one writing branch there is no pair, and the create branch's guarantee is named where it is used. |
| Create branch: a residual remains and is named | **Dropped.** A named residual presupposes a route used in spite of the rule. The qualifying route has no such residual at creation; what it does *not* cover — atomicity of the content write, and any later change — is stated as a scope limit, which is a different claim. |
| Create branch: the write happens, subject to a caveat | **Dropped**, then **restored on a different footing.** The second replacement removed the write entirely, because no route qualified. The third admits `O_EXCL` and the write returns, so the branch is functional again — not by relaxing the rule, which is unchanged, but by finding an operation that meets it. |
| Step two: "Absent → create the file, report `written`" | **Kept as the intended outcome**, now conditional on a qualifying create operation and naming the stop when none is available. The condition is normally satisfied; the stop is the honest other half, not an afterthought. |
| Create branch: the maintainer's open decision | **Closed on 2026-09-21** in favour of admitting `O_EXCL` and accepting its precondition, recorded in the story's §5. The alternative — weakening the preservation guarantee — was rejected while a qualifying standard operation existed. |
| "every candidate route breaches D3" | **Dropped as an overclaim, and it was mine.** D3 forbids a new *synchronization* mechanism; a lock directory breaches it, a single standard-library call does not. What made this the maintainer's call was a **new precondition** on a command whose story says it demands nothing an initializer does not need. |
| §2: "no lock, no marker file, no synchronization mechanism" | **Kept**, verbatim through all three replacements. The second introduced no mechanism because it removed a write; the third adds none either — `O_EXCL` is a standard-library call, not a lock, a marker or a subsystem. What it *does* add is a runtime precondition, a different kind of cost, priced separately in the row above. |
| Create branch: where the ordinary file tool is used, write anyway and disclose the race | **Dropped deliberately**, replaced by *stop without writing and report* — the shape step one already uses. Disclosure after an overwriting write is not preservation, and D2 forbids the gate removal it permits. Pass 2's Major 1. |
| §2: "preserved in every branch" | **Kept**, verbatim, and the reason it holds on the create branch has now changed twice. An earlier wording of this row said it held because the branch could not write — true then, and an overstatement dressed as a guarantee. It now holds because the create operation **refuses every existing destination by specification**, so no existing entry is written through. That is a real guarantee about the directory entry, and **only** about the directory entry. |
| Row 4b claim: three omissions applied, no insertion | **Kept**, verbatim. |
| Row 4b check: expect exactly the three omission hunks | **Dropped**, replaced by exact equality against a mechanically transformed source — the shape 4a already uses. A hunk count is a property of the renderer, not of the change, and the measured count for this pair is not three. Pass 2's Major 3. |
| Row 4b: no `Don't guess` hunk, no §6 hunk | **Kept as statements about the transformation** — no insertion, no §6 removal — rather than as expectations about a rendered diff. |
| Row 4b has no counterfactual | **Kept**, unchanged; exact equality does not give it one. |

## §8 Deliberately out of scope

- **A parity checker for the three template copies.** Named as a cost in the story (D1/D3), not
  solved here. If drift is observed it earns a ledger row.
- **Any hook change.** The gate hook is untouched.
- **Any change to `/workflow-init`'s behaviour** beyond inserting the one rule into its template.
- **Any change to the active `loop-rule-consolidation` work.** Different branch, different cycle.
