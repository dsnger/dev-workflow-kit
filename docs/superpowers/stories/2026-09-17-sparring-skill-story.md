# `dev-workflow:sparring` — an explicitly invoked advisory-session skill — Story

**Date:** 2026-09-17 · **Size:** story
**Risk:** standard · **Security:** none · **Validation:** battery+check

**Profile log:**
- 2026-09-17 · adoption · proposed at intake as `standard` / `none` / `battery+check`; **confirmed by
  Daniel on 2026-09-17, exactly as proposed.** Gates read this header, which is the only writable
  copy. Derived floor **3** — max(risk `standard` = 1, security `none` = 0) = 1, and only a value of
  0 gives a floor of 1. Floor 3 means **three valid passes and a clean final pass**, not three clean
  passes; the zero-finding early exit below the floor stands, and every other duty is unaffected.

## 1. Problem statement

**The advisory layer exists, works, and is not shippable.** Two documents describe it:
`docs/sparring-briefing.md` (tracked) carries the role's working knowledge, and
`docs/SPARRING-PARTNER.md` (untracked, project-local) carries the stable role and intake
instruction. Both are hand-written instances belonging to **this** repository. A user of the
`dev-workflow` plugin gets neither.

**The route into that role today is a copied paragraph.** `docs/SPARRING-PARTNER.md` ends with a
"copy-ready intake prompt" the human pastes into a fresh chat. That works and it does not travel: it
names this repo's file paths, it names Daniel, and it survives only as long as someone remembers to
paste it.

**What is missing is a front door, not a new capability.** The role is already specified. What the
plugin lacks is an explicitly invoked entry point that establishes the advisory posture in a fresh
chat, in any project, without dragging this repository's documentation layout along.

**Two things make this a skill rather than a command.** It is invoked by name and then governs the
rest of the conversation — that is a skill's shape. And a skill can carry
`disable-model-invocation: true`, which is the only mechanism that keeps the model from pulling the
advisory posture into an implementation session on its own.

## 2. Desired outcome

**One new skill, `plugins/dev-workflow/skills/sparring/SKILL.md`, invoked only by the user**, that
orients a fresh chat into advisory work: read-only investigation, evidence-separated assessment,
report verification against current files, and bounded copy-ready prompts for a **separate** coding
agent.

**It is for a separate chat the user opens.** It does not convert the session it finds itself in.
Where the visible context shows implementation under way, it says so and asks the user to open a
separate chat and invoke it there. **It does not launch, fork, or delegate a chat**, and it makes no
claim to detect session isolation — it cannot.

**It is project-neutral.** No Daniel, no absolute paths, no task ids, no model-family claims, no pass
counts. It reads whatever project instructions exist and an **optional** `docs/SPARRING-PARTNER.md`
for local context; **a missing optional file is a fact to note, never a trigger for scaffolding,
`/workflow-init`, or a setup requirement.**

**It changes no gate.** Advisory work is not a review pass, invoking the skill starts no cycle, and
every mandatory stop stays binding.

## 3. Acceptance criteria

1. **`plugins/dev-workflow/skills/sparring/SKILL.md` exists**, loaded by convention from `skills/` —
   **no manifest key** (invariant 6) — and carries `disable-model-invocation: true` in its
   frontmatter.
2. **Explicit invocation only.** No automatic activation, and no workflow handoff into it from
   `intake`, `harden-finding`, or any command.
3. **`intake` is unchanged.** It captures stories; this skill orients an advisory session. Neither
   references the other as a handoff.
4. **Read-only by instruction, described as instruction.** Default posture is investigate, advise,
   verify reports, and draft prompts. No implementing, committing, gate-running, agent dispatch, or
   contacting others. **A prompt request authorizes the prompt, not its execution.** The skill must
   not describe this as a technical sandbox.
5. **Saving requires an explicit request covering that document**, and such permission authorizes no
   implementation. Session summaries stay in chat unless saving is asked for.
6. **Project-neutral**, with language preference read from the user rather than hardcoded.
7. **Optional local context**: project instructions plus an optional `docs/SPARRING-PARTNER.md`.
   Absence causes no scaffolding and no setup demand, and the kit's internal documentation layout is
   not required of consumer projects.
8. **Snapshot first**: establish the current task and repository state where available; current files
   and diffs outrank stale reports; observations, inferences, recommendations, reported tests and
   unknowns are distinguished; missing consequential information is asked about.
9. **Bounded prompts**: goal, verified snapshot, exact scope, boundaries, observable completion
   criteria, escalation conditions.
10. **Prompt-standards conformance** — all twelve items of `docs/prompt-standards.md`, with the
    `Target model:` line and the `prompt artifact and follows` marker the conformance scan selects on.
11. **Inventory and layout documentation name the new skill** — `README.md`'s component table,
    `AGENTS.md`'s layout tree, `docs/architecture.md`'s tree.
12. **Version bump and `CHANGELOG.md` entry** (invariant 12).

## 4. Settled inputs — decided, not to be reopened

- **D1. The user opens the separate chat.** The skill never launches, forks or delegates one, and
  never claims it can verify it is running in one. The most it can do is read the visible context and
  ask.
- **D2. No new machinery.** No session management, no hooks, no memory service, no automatic rollup
  persistence, no new review mechanism, no cross-client installer.
- **D3. Read-only is a set of instructions, not a sandbox.** Saying otherwise would be an enforcement
  claim with no mechanism, which `docs/prompt-standards.md` item 11 forbids.
- **D4. `intake` stays exactly as it is.**
- **D5. The two source documents are inputs, not cargo.** `docs/sparring-briefing.md` and
  `docs/SPARRING-PARTNER.md` are read as product requirements for the skill's content. Neither is
  shipped, scaffolded, or required to exist downstream.
- **D6. No other workstream is touched.** `loop-rule-consolidation` and `claude-init-command` are
  neither modified nor resumed.

## 5. Settled by Daniel on 2026-09-17 — no longer open

1. **The profile is confirmed** as `standard` / `none` / `battery+check`, exactly as proposed, and is
   recorded in the profile log above. Accepted on this reasoning: the skill ships into other people's
   projects, and its failure mode is an advisory session that writes, commits, or claims an isolation
   it does not have — bounded, but not inconsequential. `trivial` would read a prompt that governs a
   whole session as harmless.

2. **The release number's value is not chosen here, and this story reserves none. Its timing is
   governed by the spec's §2, which is the single operative statement of it.**
   **Verified 2026-09-17:** `main` and `origin/main` are both
   `7c0d475b9a4a1897e8b03dfa20ec058b9ce09ba6`, the manifest there is `0.11.0`, `CHANGELOG.md`'s
   newest entry is `0.11.0`, and **there are no open pull requests**. **Two unmerged workstreams
   already intend `0.12.0`** — `loop-rule-consolidation` pins it in its plan text, and
   `claude-init-command`'s spec records Daniel's decision of 2026-09-17 assigning it there with
   claude-init "first to merge" — but **neither has committed a bump**; both branches still read
   `0.11.0`.

   **No number is reserved here for an unfinished branch**, in either direction — this story does
   not claim `0.12.0` and does not step aside from it.

   **The timing was corrected on 2026-09-18, after Gate-A spec pass 1's Major 5.** The earlier wording
   — "chosen at the Gate-B closing commit" — had no executable sequence: `AGENTS.md:273–277` says
   `check-version-bump.sh main` compares **commits** and belongs at the Gate-B WIP commit, and it sits
   in the battery (`AGENTS.md:250`) that must be green **before** Gate B. A WIP commit still at the
   base version fails it; a bump added after the final clean pass puts unreviewed content in the
   closing commit.

   **The corrected sequence:** inspect the current integration base · choose the candidate's version ·
   put the manifest bump and the changelog entry **in the Gate-B WIP commit** · run the required
   battery · review **that** candidate · close only under the existing rules. The closing-time
   recheck is a **consistency check, not permission to introduce an unreviewed bump**; if the version
   must change, that change carries whatever verification and review existing policy requires, and
   **no promise is made that it costs exactly one further pass.**

   **This corrects timing and grants no release priority.** Two recorded statements conflict —
   `claude-init-command`'s spec assigns `0.12.0` to itself as "first of the two in-flight changes to
   merge" (written when two were in flight; there are now three), and `loop-rule-consolidation`'s plan
   pins `0.12.0` for itself. **Neither has committed a bump.** Reconciling them is the maintainer's,
   is **required before this change prepares a Gate-B candidate**, and **does not block this spec
   cycle**. Neither other branch is edited.

## 6. A conflict with existing project policy, surfaced rather than resolved

**`docs/sparring-briefing.md` says this change should not happen by reflex.** Its closing section,
*What this document is not*, reads:

> Not a plugin feature, not scaffolded by `/workflow-init`, and not a template — it is one project's
> hand-written instance. If the pattern proves itself across several projects, promoting it to a
> scaffolded template is a todos entry with a trigger, not a reflex.

**No such `todos.md` entry exists.** Verified: `todos.md` mentions sparring only in the
prompt-standards re-check row (lines 646–652), which is about model-generation changes, not
promotion.

**This is not read as a blocker.** Daniel has approved the product direction, and that is the human
decision the sentence defers to. **But the sentence becomes false the moment this ships**, and
`AGENTS.md`'s standing lens — *"which existing statements does this diff falsify?"* — makes
correcting it part of this change, not a follow-up. **Scope consequence:**
`docs/sparring-briefing.md` is edited to record that the pattern was promoted by decision rather than
by trigger, and to say what the shipped skill is relative to this repo's own instance.

**Two things this change does not do:** it does not scaffold either document into consumer projects,
and it does not invent a trigger retroactively to make the promotion look procedural.

## 7. Suggested size

**Small.** One new skill file, one edit to `docs/sparring-briefing.md`, three inventory lines, one
version bump, one changelog entry. No executable code, no hook change, no change to any gate, and no
change to `intake`.
