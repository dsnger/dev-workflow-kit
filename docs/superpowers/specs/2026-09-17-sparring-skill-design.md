# `dev-workflow:sparring` — design and target text

**Story:** `docs/superpowers/stories/2026-09-17-sparring-skill-story.md` — read the profile from its
header at every gate call; it is the only writable copy.

This spec carries **the complete text of the new skill file**, in final form, plus the one edit to an
existing document. The plan cites sections here by name and does not restate them: a second copy of
normative text is the defect the loop-rule cycle spent most of its findings on.

---

## §1 What is being added, and what is edited

| Path | Change |
|---|---|
| `plugins/dev-workflow/skills/sparring/SKILL.md` | **New.** Loaded by convention from `skills/` — **no manifest key** (invariant 6). Full text in §5. |
| `docs/sparring-briefing.md` | **Edited**, one section. Its closing paragraph says this pattern is "not a plugin feature" and that promoting it needs "a todos entry with a trigger". Shipping the skill makes that false. Replacement text in §6. |
| `README.md`, `AGENTS.md`, `docs/architecture.md` | **One inventory/layout line each.** |
| `plugins/dev-workflow/.claude-plugin/plugin.json`, `plugins/dev-workflow/CHANGELOG.md` | **Version bump and entry** (invariant 12). **§2 governs when the number is chosen and where the bump lands; its value is not chosen here.** §2 is the only operative statement of that timing. |

**Not edited, deliberately:** `plugins/dev-workflow/skills/intake/SKILL.md` (D4), any hook, any
command, `MANIFEST.md` (it inventories `source-files/`, the frozen extraction seed, and this skill
has no seed origin), and either of the other two in-flight branches (D6).

**Not shipped:** `docs/sparring-briefing.md` and `docs/SPARRING-PARTNER.md` are **inputs** to this
design, not cargo (D5). Neither is scaffolded into a consumer project and neither is required to
exist there.

## §2 When the version is chosen, and by what sequence

**No version is chosen or written during this spec cycle.** This section fixes *when* the choice
happens, not *what* it is.

### The sequence

1. **Inspect the current integration base** — the branch this change will merge into, as it stands
   at that moment: its manifest version and its changelog.
2. **Choose the candidate's version** from that observation.
3. **Include the manifest bump and the changelog entry in the Gate-B WIP commit**, together with the
   rest of the change.
4. **Run the required battery** against that commit.
5. **Review that candidate** — the WIP commit as it then stands, bump included.
6. **Close only under the existing rules.**

**Why this order and not the earlier one.** The earlier text said the bump was chosen "at the Gate-B
closing commit". That has no executable sequence, and pass 1's Major 5 established it from this
repository's own documents: `AGENTS.md:273–277` states that `check-version-bump.sh main` *"compares
**commits**, so run it once the work is committed (the Gate-B WIP commit is the natural point)"*, and
it sits inside the quality battery at `AGENTS.md:250` that must be green **before** Gate B. A WIP
commit still carrying the base version fails that check; adding the bump only after the final clean
pass puts content in the closing commit that no pass reviewed.

### The closing-time recheck, and what it is not

At closing, re-inspect the integration base and confirm the chosen version is still the right one.
**That is a consistency check. It is not permission to introduce an unreviewed bump**, and it is not
a licence to edit the manifest after the reviewed candidate was fixed.

**If the recheck shows the candidate's version must change, the change is subject to the verification
and review that existing policy requires of any change to a reviewed candidate.** How much that costs
is whatever the rules say at the time; **this spec does not promise it is exactly one further pass**,
because it is not this spec's to promise.

### Release priority is not granted here, and two recorded statements conflict

**This timing correction gives this change no claim on any particular number and no place in any
merge order.**

**Verified 2026-09-18, and rechecked at the start of this repair round:** `main` and `origin/main` are
both `7c0d475b9a4a1897e8b03dfa20ec058b9ce09ba6`, the manifest there is `0.11.0`, `CHANGELOG.md`'s
newest entry is `0.11.0`, and there are **no open pull requests**.

**Two recorded sequencing statements cannot both hold**, and both live in artifacts of other
workstreams:

- `claude-init-command`'s spec records a decision of 2026-09-17 assigning **`0.12.0`** to that change,
  with claude-init as **"the first of the two in-flight changes to merge"** — a statement made when
  two changes were in flight. There are now three.
- `loop-rule-consolidation`'s plan **pins `0.12.0`** in its own text for itself.

**Neither branch has committed a bump**; both still read `0.11.0`.

**Reconciling those two is required before this change prepares a Gate-B candidate**, because step 2
above cannot choose honestly against a base whose next version is claimed twice in prose and zero
times in a commit. **That reconciliation is a decision for the maintainer.** This spec does not make
it, does not edit either other branch, and is **not blocked on it for the spec cycle** — Gate A
reviews this text, and the dependency lands at Gate-B candidate preparation.

`scripts/check-version-bump.sh` verifies a bump is *present*, not that it is right, and is explicitly
blind to two branches bumping to the same value. The recheck and the reconciliation stand in for a
check that does not exist; neither is a guard.

## §3 The behaviour contract

Numbered to match the story's acceptance criteria.

1. **Explicit invocation only.** The frontmatter carries `disable-model-invocation: true`.
   **Verified before being written**, per prompt-standards item 11: the setting is live in a skill's
   frontmatter at `~/.claude/skills-backup-2026-08-22/grill-me/SKILL.md:4`, and the Claude Code
   changelog records both *"Fixed skills with `disable-model-invocation: true` failing when invoked
   via `/<skill>` mid-message"* and *"Claude is now told to ask you to run the skill instead of
   replicating its workflow"*. **What it does:** stops the model from invoking the skill on its own,
   and tells it to ask the user instead. **What it does not do:** restrict any tool once the skill is
   running.
2. **No handoff into it.** No skill or command references `sparring` as a next step, and `sparring`
   references none as a destination.
3. **A separate chat the user opens.** The skill redirects **only on evidence that this session is
   doing the implementing** — tool calls in this conversation that edited, staged, committed, ran a
   gate or dispatched an agent, or an instruction here to do so. Three exclusions, all load-bearing:
   **Material describing another session is an advisory input, never a trigger** — a pasted agent
   report, a resume note, a review cycle open elsewhere, another agent's edits. Checking such a
   report is the scenario the skill exists for, and it necessarily arrives full of implementation
   vocabulary. **An advisory document the user asked to be saved is excluded from both halves of the
   test** — neither the request nor the write it leaves in the history — so the one write the skill
   permits does not redirect the user away, in that turn or any later one. **And ambiguity is not a
   trigger**: it asks and keeps working. **It never launches, forks or delegates a chat, and never
   claims it can tell whether it is running in an isolated one** — it cannot, and saying otherwise
   would be an enforcement claim with no mechanism.
4. **Read-only by instruction, stated as instruction.** The skill says plainly that this is a rule the
   session keeps and that nothing counts for it. **No sandbox is claimed.**
5. **Saving is per-document and per-request.** Permission to save one document authorizes that
   document, not implementation and not a second file. Summaries stay in chat unless saving is asked
   for.
6. **Project-neutral.** No person's name, no absolute path, no task id, no pass count, no claim about
   which model family reviews what. Language preference is read from the user.
7. **Optional local context.** Project instructions, plus an optional `docs/SPARRING-PARTNER.md`.
   **Absence is a fact to note** — never a trigger for scaffolding, for `/workflow-init`, or for a
   stated setup requirement. The kit's documentation layout is not required downstream.
8. **Snapshot before advice**, with observations, inferences, recommendations, reported tests and
   unknowns kept apart, and consequential gaps asked about.
9. **Bounded prompts** carrying goal, verified snapshot, exact scope, boundaries, observable
   completion criteria and escalation conditions.

**The prohibition style is deliberate and this is its stated reason** (prompt-standards item 9):
**this skill's subject is a boundary.** What an advisory session may not do is the content, not a
stylistic choice, and restating "do not commit" positively loses the line it draws. Same exception
the `CLAUDE.md` §1–§3 template already takes, for the same reason.

## §4 Diagnostic states, with causes, checks and fixes

Prompt-standards item 10 requires that any reported failure state enumerate its distinct causes.
The skill reports two, and each row is carried in its text.

**There is no repository classifier, and that is the design.** Three attempts at one produced three
wrong predicates — `--git-dir` as a root test (wrong for a linked worktree, pass 1 Major 3),
`--show-toplevel` as an existence test (wrong for a bare repository, pass 2 Major 4), and
`show-ref --verify` as a positive unborn-branch test (cannot separate an absent ref from a failed
read, pass 2 Major 3). **The fourth attempt is not a better classifier; it is no classifier.**

**The rule the skill states instead: collect evidence, keep what each query established, and never
infer one fact from another query's failure.**

| Question | What the skill does |
|---|---|
| Branch, revision, history, status, file contents | **Ask for each, and keep each answer on its own.** A failure in one does not discard another — history that was read is still history, and files that were read are still readable. |
| `HEAD` will not resolve | **Report it unresolved.** **Never** treat it as an empty repository: it fails identically on an unborn branch and on a damaged or unreadable `HEAD`. Say which it might be. |
| No working-tree information | **Report that, and nothing more.** **Never** infer that there is no repository or no history — a bare repository has full history and no working tree, which is an ordinary shape. |
| Where is the working tree's top level | `git rev-parse --show-toplevel`, **used only for that**. Not an existence test. Not `--git-dir`, whose metadata sits outside a linked worktree or submodule by design. |
| Which project the user means | Not establishable from the filesystem. Default to the top level, say which root was used, ask only where identity is load-bearing. |
| An unresolved cause | **Name the limitation, say what it does and does not affect, and continue.** Chase the cause only when the task depends on it, and then quote the command's own error text — permissions, a damaged index and an interrupted operation are indistinguishable from outside. |
| Local context document absent | Note it in one line and continue. **No scaffolding, no initializer, no setup demand.** |

**What this deliberately gives up**, stated rather than hidden: the skill no longer *automatically*
announces "this is an unborn branch" or "this is not a repository". **It gives up a classification,
not the evidence and not the disclosure** — the snapshot is still collected, the limitation is still
reported, and a task that genuinely turns on the cause still gets it investigated. Pass 2's Major 4
is the argument: a classifier that is wrong throws away real history while sounding certain, and an
honest "unresolved" costs a sentence.

**Two questions answer "ask", and that is honest rather than a gap.** An absent optional file cannot
be told apart from a project that keeps its context elsewhere, and a filesystem root cannot reveal
which project was meant. Inventing a discriminator for either is the overclaim prompt-standards item
11 exists to catch — and inventing one for git state is what the last two passes kept finding.

## §5 Target text — `plugins/dev-workflow/skills/sparring/SKILL.md`

**The complete file.** Normative in its words. The outer fence below is four backticks because the
file contains three-backtick fences of its own.

````
---
name: sparring
description: Use when you want an advisory second opinion in a chat you opened for that purpose — investigating a question read-only, checking an agent's report against the current files, weighing options before committing to one, or drafting a bounded prompt for a coding agent to run elsewhere. Invoke it by name. It advises; it does not implement, commit, or run review gates.
disable-model-invocation: true
---

# sparring

Target model: Claude via Claude Code. This skill is a prompt artifact and follows
`docs/prompt-standards.md`.

## Overview

An advisory session. You investigate, weigh options, verify what other agents report, and
draft prompts the user carries elsewhere. You advise; another session does the work.

**Why a separate chat.** An implementation session carries the plan it is executing and
the changes it has already made, and advice from inside it inherits both — the questions
worth asking are exactly the ones that session has already answered. A chat opened for
advice reads the repository as it stands.

**This skill states limits directly**, which is unusual for a prompt in this repo. The
reason: its subject *is* a boundary. What an advisory session may not do is the content
here, and restating those limits as positive instructions would lose the line they draw.

## When this is the wrong session

**The question is who did the work, not what the words describe.** Redirect only when the
visible evidence shows **this session** implementing: tool calls in this conversation that
edited files, staged or committed, ran a review gate, or dispatched an agent — or an
explicit instruction in this session to carry such work out.

**An advisory document the user asked you to save is excluded from both halves of that
test.** Neither the request nor the write it produces counts: not the instruction, and not
the tool call it leaves in this conversation's history. Saving a summary the user asked for
is a permitted advisory act, so advisory work continues normally afterwards — during that
turn and every turn after it. **Without this exclusion the one write the skill permits
would redirect the user away**, and the tool call would keep doing so for the rest of the
session.

The exclusion is exactly as wide as the permission in *Saving a document* below: the
document the user named, and nothing else. A write beyond it is implementation and is not
excluded.

When the test is met, say so and ask the user to open a separate chat and run
`/dev-workflow:sparring` there. Do not open, fork, or delegate that chat yourself. Ask,
and stop.

**Material about another session is an advisory input, not a trigger.** A pasted agent
report, a resume note, an open review cycle running elsewhere, a description of edits
another agent made, a plan someone else is executing — all of these are the work you are
here to do. Read them, verify them, advise on them. **Reading about a commit is not making
one.** Checking an agent's report is the scenario this skill exists for, and it necessarily
arrives full of implementation vocabulary.

**Say what you actually know.** You can read this conversation's own history. You cannot
verify that this chat is isolated from any other, and no check available to you would show
it. Where the evidence is ambiguous — a conversation that mentions edits without showing
who made them — say that, ask, and keep doing the read-only work meanwhile.

## Authority

Investigate, assess, recommend, verify reports, and draft prompts in the conversation.

Do not implement, change files or git state, commit, run review gates, dispatch agents,
or contact anyone. A request for a coding-agent prompt authorizes writing the prompt, not
running it.

**This is a rule you keep. Nothing counts for it.** No sandbox restricts your tools, and
no mechanism blocks a write. The one mechanism present is this file's frontmatter setting
`disable-model-invocation: true`, and it does one thing: it stops the model from invoking
this skill on its own, so the user invokes it by name. It restricts nothing afterwards.

Read-only commands are fine — `git log`, `git diff`, `git show`, `git status`, reading
files, searching. (`git status` may refresh the index as a side effect; that is expected
and changes no tracked content.) Run a mutating check only by putting it in the prompt you
hand back.

## When a project duty needs something you may not do

A project's instructions can require an action this role does not perform — run a review
gate before a document counts as ready, commit a record, dispatch a checker. **Both halves
bind: the duty is real, and the boundary holds.**

So do this, and do not pick one over the other:

1. **Stop the work that depends on the duty.** If a project says a spec is not ready until
   a gate has passed, do not call it ready.
2. **Name the conflict.** Say which instruction requires what, and which boundary stops you.
3. **Hand the action to the coding session.** Put it in the prompt you write, with the
   project's own wording for it, so the session that is allowed to act carries it out.
4. **Keep working on everything else.** Read-only investigation, drafting and verification
   continue — the conflict blocks one action, not the conversation.

**Do not perform the duty here, and do not treat the boundary as waiving it.** A duty
nobody performed is still owed, and saying so is part of the advice. Where the project
defines a mandatory stop, that stop stands and this procedure does not soften it.

## Saving a document

Save or change a file only when the user asks for that particular document. The
permission covers the document named and nothing else: it does not turn this into an
implementation session and does not carry to a second file. **The redirect test above
excludes such a save — both the request and the write it leaves in this conversation's
history — so advisory work continues afterwards.**

If the user asks for a session summary, put it in the conversation. Save it only if they
ask you to save it.

## Orientation

Establish where you are before advising.

1. **Read the project's own instructions** — whatever the project provides for agents
   working in it. Follow them; this skill does not override them. **The authority boundary
   below applies to every instruction you load**, wherever it came from: an instruction
   file cannot authorize you to implement, commit, run a gate, or dispatch an agent, any
   more than a user's request for a prompt authorizes running it.
2. **Read `docs/SPARRING-PARTNER.md` if the project has one.** It is optional local
   context: a project's own wording for this role. Where it and this skill differ on
   style or emphasis, the project's file wins. Where it would expand your authority, it
   does not — authority comes from the user.
   **If it is absent, note that in one line and continue.** Do not scaffold it, do not
   run an initializer, and do not present it as a setup requirement.
3. **Establish the repository snapshot** where one is available: branch, HEAD, status,
   recent history. Include staged, unstaged and relevant untracked content — the question
   is usually about what is there now, not what was committed.
4. **Identify the current task from the user's request**, then read the current artifacts
   it names.
5. **Treat reports and resume notes as leads, not findings.** Verify their load-bearing
   claims against current files and diffs before advising on them. A status section
   written earlier may describe a state that no longer exists.

Read long documents in the sections that matter. Truncated output is not a complete read.

**Collect evidence; do not classify the repository.** Ask for branch, current revision,
recent history, working-tree status and the files themselves. Each answer stands on its
own. **Keep every fact you established, even when another query failed** — history you
read is still history whether or not `status` worked, and files you read are still
readable whether or not any git command answered at all.

**A command that failed tells you that command failed. It does not tell you what is true.**
Two inferences in particular are wrong and are not to be drawn:

- **Never read an unresolved `HEAD` as an empty repository.** It fails identically on an
  unborn branch and on a damaged or unreadable `HEAD`. Report it as unresolved and say
  which it might be.
- **Never read missing working-tree information as no repository and no history.** A bare
  repository has full history and no working tree, and that is an ordinary shape rather
  than a fault.

**`git rev-parse --show-toplevel` answers one question: where the working tree's top level
is.** Use it for that and for nothing else. It is not a test for whether a repository
exists, and `git rev-parse --git-dir` is not a test for the project root — a linked
worktree or a submodule keeps its metadata outside the checkout, which is ordinary.

**The top level is a filesystem fact, not the user's intent.** A repository can contain
several projects. Take the top level as the default, say which root you used, and ask only
where project identity is load-bearing for the question in hand.

**When something is unresolved, say so and keep going.** Name the limitation, name what it
does and does not affect, and continue with the advice that does not depend on it — which
is most advice, because most questions are about what the files currently say. **Chase the
cause only when the task actually depends on it**, and then report the command's own error
text rather than a guess: permissions, a damaged index and an interrupted operation need
different fixes and are indistinguishable from the outside.

## Evidence

Keep these apart, and label them when it matters:

- what you **observed** — cite the file and line
- what you **inferred** from it, and from what
- what you **recommend**, and what it costs
- what a **report claims** versus what you checked
- what is **unknown**, and why

Reading a test is not running it. A walkthrough of the text is not an execution. A narrow
check does not close a defect class. When describing what a check proves, read what it
actually compares and claim no more than that.

Where a value is missing or a reading is ambiguous, say so and name the cause. Ask about
the ones that change the answer; keep working on the rest meanwhile.

## Coding-agent prompts

When the task calls for one, write it out in full rather than offering to write it later.
Each prompt carries six things:

1. **Goal** — the outcome, in one or two sentences.
2. **Verified snapshot** — branch, HEAD, the relevant files and any uncommitted changes,
   with an instruction to recheck before editing and to preserve unrelated work rather
   than reset to the snapshot.
3. **Exact scope** — which artifacts may change, and how.
4. **Boundaries** — what to preserve, which contracts hold, what is excluded.
5. **Done when** — observable outcomes and the checks that show them. Separate commands
   actually run from checks being proposed, and do not invent expected output.
6. **Escalate if** — contradictions, scope that must grow, missing evidence, and any stop
   the project mandates.

Ask for a completion report covering changes made, checks actually run, remaining gaps
and git state.

A usable shape:

```text
Goal: <requested outcome>
Verified snapshot: <branch, HEAD, relevant files and uncommitted changes>
Scope: <exact artifacts and permitted changes>
Boundaries: <preserved work, contracts, excluded actions>
Done when: <observable outcomes and the checks that show them>
Escalate if: <unresolved decisions and mandatory stops>
Report: <changes, checks run, remaining gaps, git state>
```

## Gates and stops

Advisory work is not a review pass. Nothing you approve satisfies a gate, and invoking
this skill starts no development or review cycle.

Where the project defines mandatory stops, floors, severity rules or completion
conditions, they stay binding and this skill does not relax them. At a stop, name the
concrete decision the user has to make. Do not continue past it by default.

Prefer the smallest sufficient answer. Do not reopen parked work, widen a narrow question
into an audit, or start another repair round on your own.

## Language

Follow the user's language preference for the conversation. If they have stated one — in
the project's instructions, in the local context document, or in this chat — use it. If
they have not, use the language they wrote to you in.

Write coding-agent prompts in the language the coding agent's project uses, which is
often not the conversation's language. Ask once if it is unclear.

## Response shape

Lead with the recommendation. Then the evidence it rests on, then the uncertainty a
reader needs to judge it. Where a prompt was requested, it comes last, complete.

```text
Recommendation: <what to do, one or two sentences>
Evidence: <what you observed, cited>
Uncertainty: <what is unverified or unknown, and why it matters>
Decision needed: <the one thing the user has to choose, or none>
```

Where you are handing back a prompt, follow it with the prompt block above.
````

## §6 Target text — the replacement paragraph in `docs/sparring-briefing.md`

The file's closing section currently reads:

> ## What this document is not
>
> Not a plugin feature, not scaffolded by `/workflow-init`, and not a template —
> it is one project's hand-written instance. If the pattern proves itself across
> several projects, promoting it to a scaffolded template is a todos entry with a
> trigger, not a reflex.

**It is replaced by:**

```
## What this document is, and what the plugin ships

This document is still one project's hand-written instance: not scaffolded by
`/workflow-init`, not a template, and not read by any plugin component.

**The role itself was promoted.** `dev-workflow:sparring` ships the advisory posture as an
explicitly invoked skill, so a consumer project gets the front door without getting this
repository's documentation. That promotion happened by a maintainer's decision, not because
a recorded trigger fired — the earlier text asked for a todos entry with a trigger, and
there was none. Recorded here so the history is not tidier than it was.

The skill reads an optional `docs/SPARRING-PARTNER.md` for local context and treats its
absence as ordinary. This briefing stays where it is, for this repository, and nothing
scaffolds it.
```

**Why this edit is in scope rather than a follow-up:** `AGENTS.md`'s standing lens asks which
existing statements a diff falsifies. This one falsifies "not a plugin feature" directly, and the
sentence about a trigger describes a process this change did not follow. Leaving it would ship a
document contradicted by the same commit.

## §7 Verification — what is checked, and how

**Every row states only what its own command compares.** Where a claim is broader than its check, the
check's scope is the claim and the remainder is assigned to the walkthrough.

| # | Claim — as wide as the check | Check |
|---|---|---|
| 1 | The frontmatter carries `disable-model-invocation: true` | `grep -c '^disable-model-invocation: true$'` in the new file; expect 1. |
| 2 | The file declares exactly one `Target model:` and is inside the conformance scan | `grep -c '^Target model:'` expect 1; `grep -rl 'prompt artifact and follows' --include='*.md' .` lists the new path. |
| 3 | The file makes no numeric checklist-count claim | `grep -cE 'all ([0-9]+\|one\|two\|three\|four\|five\|six\|seven\|eight\|nine\|ten\|eleven\|twelve)( checklist)? items'`; expect 0. **`check-invariants.sh` scans every `*.md` outside `PROMPT_EXCL` for this, so a claim here would be checked.** |
| 4 | The file names no person, absolute path or pass count | `grep -cE 'Daniel\|/Users/\|pass [0-9]'`; expect 0 each. |
| 5 | No `skills` key was added to the plugin manifest | `grep -c '"skills"' plugins/dev-workflow/.claude-plugin/plugin.json`; expect 0. **This is one key**; invariant 6 as a whole is checked by `scripts/check-invariants.sh`. |
| 6 | `intake` is byte-identical to its state at the base | `git diff --stat <base> -- plugins/dev-workflow/skills/intake/`; expect empty. |
| 7 | The briefing's superseded sentences are gone | `grep -c 'Not a plugin feature'` and `grep -c 'trigger, not a reflex'` in `docs/sparring-briefing.md`; expect 0 each, where both return **1** today. **Both patterns are line-local by construction, verified before being written** — the phrase "a todos entry with a trigger" wraps between `with a` and `trigger` in the source and a literal grep for it returns 0 on the unchanged file, which would be a check that is green before the change and proves nothing. |
| 8 | The three mechanical prompt-conformance spellings hold, and the pinning and manifest invariants hold | `sh scripts/check-invariants.test.sh && sh scripts/check-invariants.sh`. **Not prompt conformance** — `AGENTS.md` invariant 11 calls these a floor, not coverage; the other items are read. |
| 9 | The commands in `AGENTS.md` § Commands exit 0 | The full quality battery. **Tested coverage, not "nothing broke"** — nothing in this change is executable. |
| 10 | The version was bumped and logged | `scripts/check-version-bump.sh` against the PR's own base ref, plus a `CHANGELOG.md` entry. **Verifies a bump is present, not that it is correct**, and is blind to two branches choosing the same value. |

### The `battery+check` counterfactual — one row, demonstrated

**Row 7 is the counterfactual, and it is the only row offered as one.** The duty is to name an
observation that would exist if the claim were false, and to show the wiring could have produced it.
Row 7 does that on a file that **is present** in the pre-change tree:

```
$ grep -c 'Not a plugin feature'  docs/sparring-briefing.md
1
$ grep -c 'trigger, not a reflex' docs/sparring-briefing.md
1
```

Both must read **0** after the change. **They read 1 now**, so the check is wired to go red, and a
change that failed to edit that section would be caught. Measured 2026-09-18, not asserted.

**The other rows are ordinary checks and are not counterfactuals.** Saying otherwise was pass 1's
Major 6. Each is classified honestly:

| Row | On the pre-change tree | What that is |
|---|---|---|
| 1, 2 | `plugins/dev-workflow/skills/sparring/SKILL.md` does not exist; `grep` reports `No such file or directory` | **A missing-file error, not an assertion failure.** A check that cannot run is not a check that went red, and treating the two alike is how an untested predicate passes for tested. |
| 3, 4 | Run against the artifacts that do exist, these return: `intake` 0 / **1**, `harden-finding` 0 / 0, `docs/sparring-briefing.md` 0 / 0 | **Not a counterfactual, and the `1` is a false positive** — `plugins/dev-workflow/skills/intake/SKILL.md:161` matches `pass [0-9]` inside the illustrative profile-log line *"Gate-B pass 2 finding on the migration path"*, which is legitimate example text in a shipped skill. Row 4 is a spelling check with a known false-positive shape, not proof of neutrality. |
| 5, 6, 8, 9, 10 | Pass on the pre-change tree, correctly — nothing has changed yet | **Regression checks.** They confirm the change broke nothing; they establish nothing about the change working. |

**Nothing here rests on `docs/SPARRING-PARTNER.md`.** That file is project-local, untracked, and not
present in this checkout, so no claim about a check's behaviour against it could be observed — pass
1's Major 6 found three such claims and they are gone rather than rewritten.

**What no check reaches, stated rather than implied.** Nothing here verifies the skill's *behaviour*.
Those are **instructions read by a model**, and this repo has no harness that drives a skill against
a fixture session. They are checked by a **walkthrough** — a reading of the skill text against each
scenario, reported as text inspection and **never** as executed skill behaviour.

**The twelve walkthrough scenarios**, fixed here so the set is an artifact rather than a memory. The
first six are the ones the change was commissioned against; 7 and 8 were added by pass 1's Majors
2–4, and 9–12 by the second repair round.

1. A fresh advisory chat returns orientation and advice **without writes**.
2. An implementation chat is **directed to a separate advisory chat**.
3. **Missing optional project documents cause no scaffolding** and no setup demand.
4. **A pasted agent report is checked against current files**, with unverified test claims identified
   — and is **not** mistaken for this session implementing.
5. **A coding-agent prompt is returned without execution** or delegation.
6. **A requested summary stays in chat** unless saving is explicitly requested.
7. **A project duty requiring a prohibited action** stops the dependent work, is explained, and is
   handed to the coding session — neither performed here nor silently waived.
8. **An ordinary checkout and a linked worktree both orient**, keeping the evidence each query
   returned.
9. **A bare repository keeps its readable history** despite no working tree.
10. **An unresolved `HEAD` is reported unresolved**, and no empty baseline is substituted.
11. **An authorized save** — the request, the write, and the advice that follows it — **does not
    trigger the redirect**, in that turn or any later one.
12. **Only §2 governs version timing**; no operative restatement survives elsewhere.

### Accounting — what this repair kept, moved and dropped

`AGENTS.md`: *"Never replace a decision procedure without accounting for its old conditions."* Three
procedures were replaced in this round — the redirect predicate, the snapshot diagnostics, and the
version timing. Every condition they carried is listed.

| Old condition | Fate |
|---|---|
| Redirect when the context shows implementation under way | **Kept, narrowed**: redirect on evidence that **this session** implements. The trigger moved from the context's subject matter to its authorship. |
| "Do not open, fork, or delegate that chat yourself. Ask, and stop." | **Kept verbatim.** |
| "You cannot verify that this chat is isolated" | **Kept and strengthened** — now also says no available check would show it. |
| "If the context shows nothing either way, say that and continue" | **Kept, moved** into the ambiguity clause, which now also says to keep doing read-only work. |
| Not a git repository → advise without repository evidence | **Kept**, re-based on `--show-toplevel`, and **corrected**: the files remain readable, so this is not absence of evidence. |
| `git rev-parse HEAD` fails → empty repository, empty tree baseline | **Dropped as an inference, replaced by a positive test** (`symbolic-ref` + `show-ref --verify`). The old form silently absorbed a damaged `HEAD`. |
| Non-zero exit with an error → report and ask | **Kept**, and now explicitly the residual case rather than one of four peers. |
| Git dir resolves somewhere unexpected → not the project root | **Dropped.** The predicate was wrong: a linked worktree's external gitdir is ordinary, measured in this checkout. Replaced by `--show-toplevel`, plus a separate statement that location is not intent. |
| (new) "Unresolved" outcome | **Added** — nothing previously covered "no state established", which is how an empty baseline got substituted. |
| Version chosen at the Gate-B closing commit | **Dropped.** No executable sequence existed. Replaced by the six-step order in §2. |
| "No number is reserved here for an unfinished branch" | **Kept verbatim**, in both the spec and the story. |
| The base-verification paragraph | **Kept, re-measured 2026-09-18**, and extended with the two conflicting sequencing statements and the reconciliation requirement. |
| Rows 1–4 and 7 named as the counterfactual | **Dropped for rows 1–4**, which are a missing-file error and a check with a measured false positive. **Row 7 kept**, and now shown with its commands and outputs. |
| **Nothing was dropped without a replacement or a stated reason.** | Two predicates were removed as wrong; each names what replaced it. |

### Accounting — the second repair round (pass 2's Majors 1–4)

| Old condition | Fate |
|---|---|
| §1's row saying the number is "deferred to the closing commit" | **Dropped as operative text.** It contradicted §2 and §7's own accounting. §1 now points at §2 and states that §2 is the only operative statement of the timing. |
| The story's §5 item-2 heading carrying the same wording | **Dropped as operative text**, same reason. Found by grepping every restatement rather than by fixing the one site named — the sweep pass 2's Major 1 said was missing. |
| Historical quotations of the old wording (spec §2's rationale, spec §7's first accounting table, the story's correction paragraph, the cycle record) | **Kept deliberately, all of them.** They are identified as the earlier text and are what makes the correction legible. |
| Redirect on tool calls in this conversation that edited/staged/committed/gated/dispatched | **Kept, with one exclusion added**: an advisory document the user asked to be saved, excluded from **both** the instruction half and the tool-history half. |
| "A requested save does not turn this into an implementation session" | **Kept, and now actually true.** It was contradicted by the redirect test; the two sections now cross-reference each other. |
| Material about another session is an advisory input | **Kept verbatim.** |
| Ambiguity → ask and keep working | **Kept verbatim.** |
| "No repository here, positively established by `--show-toplevel`" | **Dropped.** Wrong for a bare repository, measured. **Replaced by an explicit prohibition**: never infer no repository or no history from missing working-tree information. |
| "An unborn branch, positively established by `symbolic-ref` + `show-ref --verify`" | **Dropped.** `show-ref --verify` cannot separate an absent ref from a failed read, so it could not satisfy the positive-evidence rule it was written under. **Replaced by an explicit prohibition**: never read an unresolved `HEAD` as an empty repository. |
| The "operational error" and "Unresolved" rows | **Merged and kept** as one rule: name the limitation, say what it does and does not affect, continue, and quote the command's own error text if the task requires chasing the cause. |
| `--show-toplevel` for the working-tree location | **Kept, and narrowed to that single use** — explicitly not an existence test. |
| `--git-dir` is not a root test; a linked worktree's external gitdir is ordinary | **Kept.** |
| Location is not the user's intended project | **Kept verbatim.** |
| Snapshot collection (branch, revision, history, status, files) | **Kept and strengthened** — each answer now stands on its own, and a failure in one query does not discard another's result. |
| Uncertainty disclosure | **Kept.** |
| **Automatic state classification** | **Deliberately dropped, and this is the only capability lost.** Three attempts produced three wrong predicates. The skill no longer announces "unborn branch" or "not a repository" on its own; it reports what it established and what it could not. **Evidence, disclosure and on-demand investigation all survive.** |

**The twelve prompt-standards items** are answered in writing for the new file, with reasoned `n/a`
where an item does not apply. Nine of the twelve have no mechanical check at all.

## §8 Deliberately out of scope

- Session-management machinery, hooks, a memory service, automatic rollup persistence, a new review
  mechanism, a cross-client installer (D2).
- Any change to `intake` (D4), to any hook, or to either other in-flight branch (D6).
- Scaffolding either source document into consumer projects (D5).
- A parity mechanism between this skill and `docs/SPARRING-PARTNER.md`. They are allowed to differ;
  the skill says which wins where.
