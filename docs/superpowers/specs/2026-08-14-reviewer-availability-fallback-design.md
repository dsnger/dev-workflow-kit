# Reviewer-availability fallback — a degraded-mode ladder for the gates — Design

**Story:** `docs/superpowers/stories/2026-08-13-reviewer-availability-fallback-story.md`
— the story header is the single writable copy of the profile. Every gate call carries
that path and reads the axes, the mode and the lens sets fresh from it; this document
never restates them as values.

## 1. Problem

Both gates depend on one external reviewer, and §5 offers no sanctioned degraded path
when it is unavailable. Three clean passes are required per gate; out of quota, none can
be taken, so no cycle closes and all work stops. Observed: a five-day full process
stall, 2026-08-05 to 2026-08-10.

The one degraded mode that exists — `/workflow-init` §2.13 — does not reach this case.
It fires at **init time**, when the preflight finds Codex unconfigured, and its answer is
to scaffold a project that is explicitly gateless. A project already running the gates
that loses its reviewer mid-flight falls outside it.

Four shipped sites forbid the obvious fallback, in a form that covers what is proposed
here, and `docs/sparring-briefing.md` states the premise at **family** granularity ("the
same model family as the coding agent, so you share its blind spots"). So the fallback is
inside the prohibition as written, not a case it failed to anticipate.

The problem is therefore not only that availability blocks work. It is that the only
relief currently reachable is total gatelessness, and the workflow has no vocabulary for
a review that happened but was weaker than tier 1.

## 2. Settled decisions

The story carried five open questions. All five are settled, and the reasoning is
recorded here because a later reader will otherwise re-derive it wrongly.

1. **The hook is not changed.** Prompt-only. `.context/codex-gate.off` is the prescribed
   posture during degraded operation — the existing sanctioned knob, not a fourth
   mechanism.
2. **Tier 2 is a fresh-context subagent** running the same gate prompt, with repository
   read access. One mechanism, two inputs — not two mechanisms.
3. **The in-cycle tier record lives in the WIP commit body**, carried into the closing
   amend by name.
4. **A disclosed tier-2 clean pass closes any cycle permanently**; at effective level 2
   the closing body additionally records a named cross-model re-review obligation.
5. **§2.13's gateless answer is unchanged.** The ladder is mid-flight only.

The prohibition is **narrowed, not overturned**. `docs/prompt-standards.md` line 136
("Fresh-context verifier subagents outperform self-critique — independent confirmation of
the cross-model gate design") grounds *tier 2 beats nothing*; it never grounds *tier 2 ≈
tier 1*, and its own second clause reads it as support for the cross-model design. The
narrowing therefore rests on explicit disclosure and on story AC 2, not on that note.

## 3. The ladder

Three tiers, added to `CLAUDE.md` §5 and mirrored into `/workflow-init`'s inline
template.

**Tier 1 — cross-model.** A different model family than the implementer.
`mcp__codex__exec` at Gate A, `mcp__codex__review` at Gate B. The only tier that
satisfies a gate without qualification. Unchanged in every respect.

**Tier 2 — fresh-context same-family reviewer.** A reviewer instance that does **not**
inherit the implementing session's context, given repository **read** access, running the
same gate prompt. One mechanism with two inputs:

- **Gate A** — hand it the spec or plan text, as `mcp__codex__exec` receives it.
- **Gate B** — hand it `git diff <baseSha>..HEAD` **plus** repo read access. The read
  access is not a convenience: §5's standing falsification lens asks which existing
  statements the diff falsifies, and those statements live in files the diff never
  touches. A diff-only reviewer cannot answer that lens, and `mcp__codex__review` can
  because it reads the git range itself.

The file-first findings protocol, the 3-pass floor, the Blocker/Major filter, the
clean-final-pass rule, the one-recovery-attempt budget and every acceptance and
validation rule apply to tier-2 passes **unchanged**.

**Tier 3 — the documented human exception.** Unchanged.

## 4. What the hook does, stated exactly

§5 states that the hook **cannot see a tier-2 reviewer**, and names the three layers that
make it so:

- `plugins/dev-workflow/hooks/hooks.json` — the `PostToolUse` matcher is
  `^(Bash|Skill|mcp__codex__.*)$`. Nothing else is ever delivered to the hook.
- `plugins/dev-workflow/hooks/codex-gate.sh` — a `.context/codex-gate.tools` mapping is
  discarded unless the mapped name matches `mcp__codex__?*`.
- That namespace guard is **load-bearing**, per the source comment beside it:
  `reviewTool=Bash` made a `git commit` *count* as a Gate-B pass, and `execTool=Skill`
  counted a skill invocation.

So the two tool names a subagent-based reviewer would arrive under are exactly the two the
hook refuses on purpose. Tier-2 passes are **uncounted by construction**. This is
consistent with what §5 already says — the counter is not evidence, findings files are —
and it means passes are counted the way §5 already requires: by reading the findings file
for each one.

**This is a description of current behaviour, not a claim about what the hook proves.**
The hook is not modified by this change, and nothing here makes it able to distinguish a
tier-2 pass from a tier-1 pass; it simply never observes one.

## 5. Degraded posture

For the duration of degraded operation the operator touches `.context/codex-gate.off`
with a stated reason, and deletes it on return to tier 1.

The purpose is narrow: with tier-2 passes uncounted, the Gate-B floor and
fingerprint messages would fire on every commit of the cycle. Silencing them makes those
messages **absent rather than wrong** — the hook never speaks about a degraded cycle, so
it never mis-states one. Per the knob's own documented semantics, classification and state
tracking keep running, so re-enabling lands on counters carrying gate-on semantics, which
is not evidence that a review happened.

**Stated limitation:** while the file is present, *all* hook reminders are absent, not
only the gate-floor ones. This is accepted because degraded operation is temporary and
deliberately human-attended — the operator wrote the reason and will delete the file.
Nothing verifies either of those things.

## 6. Disclosure and carry-forward

The tier marker is the disclosure. Where it lives:

- **WIP commit body** — during the cycle. Chosen over the dispositions companion for
  three reasons: that companion is advisory and may be deleted or rebuilt, a zero-finding
  pass writes none at all, and `.context/` is git-ignored so it never reaches `main`.
  In-cycle memory is the known lost-on-handoff class, and a degraded cycle is precisely
  the cycle most likely to be interrupted.
- **The closing amend** replaces the WIP body wholesale **except** that disclosure
  content — tier markers and evidence entries — is carried into the closing message **by
  name**: the closing message states each one explicitly, rather than the amend preserving
  anything automatically. Nothing is preserved automatically; the author writes it.
- **The squash body**, where a PR is squash-merged: the same content is carried in
  explicitly, because `main`'s tip is the durable record. This is rider (c), and it is the
  second hop of one rule rather than a separate rule.

One carry-forward rule, two hops: `WIP → amend → squash → main`. That chain is what story
AC 2 rests on.

**Old-condition accounting** for the amend rule, per the `AGENTS.md` decision-procedure
Don't:

| Old condition | Disposition |
|---|---|
| The amend replaces the WIP message wholesale | **Kept** |
| An entry written only into the WIP body is destroyed at close | **Narrowed** — true for everything except named disclosure content, which is carried forward rather than silently destroyed |
| The final commit body is the durable record | **Kept**, and extended one hop to the squash body |

**Never in the findings file.** Its format admits no line that is not a finding line or
the terminator, so a tier marker there is a malformed pass. The dispositions companion
**may** carry an advisory tier line; it is never required and never the guarantee.

## 7. Re-review obligation

A disclosed tier-2 clean pass **closes any cycle permanently**, for every profile. Work
never blocks on availability.

At effective level 2 — `max(risk, security)` = 2 — the closing commit body *additionally*
records a **named** cross-model re-review obligation, tracked as a `todos.md` row whose
trigger is availability's return.

**What the re-review is:** a post-merge cross-model review of the landed change, Gate-B
shape, over the merge-base range. Its findings enter through the normal channels — a fix
PR, or the hardening ledger — exactly like any other post-merge finding. The row closes on
the review's recorded result.

**How the row can otherwise close:** by a logged human decision, in the same vocabulary
the profile system already uses for overrides. No new waiver mechanism is minted.

Stated once, in §5: *fail-open needs a closing mechanism, and the profile that demands
verification is the profile that demands the debt be repaid.*

## 8. The narrowing, and the sites it touches

Stated once and reused at every site:

> **Kept** — no same-model reviewer as a *standing arrangement*.
> **Narrowed** — a temporary, disclosed, human-attended fallback in a *configured*
> project that has lost its reviewer is outside the prohibition's scope.

The reason is recorded with it: a permanent tier 2 would wear its disclosure into
meaninglessness through repetition, which is implicit self-review with a marker on. That
is why §2.13 keeps its gateless answer — at init time the arrangement would be permanent.

| Site | Change |
|---|---|
| `docs/coding-workflow.md` § *The two gates, and why independence is the point* | The principle's home; the paragraph gains the narrowing. **The heading is not renamed** — `README.md` links its anchor. |
| `README.md`, the without-Codex paragraph | One-line summary updated; the existing `([why](…))` link kept as-is. |
| `/workflow-init` §2.13 | Init-time scope stated explicitly; the **gateless answer is unchanged**; the prohibition is restated as covering a standing arrangement. |
| `plugins/dev-workflow/agents/finding-triage.md` | Its "You never count as a Gate A or Gate B pass" stays **true** and is re-grounded: it does not count because it is not running a gate prompt on a gate's artifact — not merely because it is same-family, which is no longer disqualifying on its own. |
| `docs/sparring-briefing.md` | The family-granularity premise gains the fresh-context/self-critique precision, **without** claiming tier 2 ≈ tier 1. |
| `AGENTS.md` § *What this project is* | Not a prohibition site, but **falsified by this diff**: "two independent cross-model review gates" needs a clause admitting the ladder. Caught by the standing lens, and listed here so it is not found post-merge. |

## 9. Riders

**(a) Sequential single-branch gate calls become the documented default.** `reviewType:
spec`, then `reviewType: quality`, one call at a time — eliminating the concurrency rather
than detecting it. Evidence: on PR #23's Gate-B pass 1, `full` had both reviewers write
**both** paths, and every acceptance condition still passed because all of them are shape
checks and provenance is outside them; sixteen consecutive single-branch calls across
passes 2–9 of that cycle showed no recurrence.

Old-condition accounting:

| Old condition | Disposition |
|---|---|
| Delete every target file before each call and confirm it is gone | **Kept**, unchanged |
| Both branch files must satisfy every check for a `full` pass | **Narrowed** — applies only when `full` is used; a single-branch call has one target file |
| A full re-run deletes both files; a single-branch resume deletes only its own | **Kept** — and under the new default every call deletes exactly its own target, which is the same rule applied to a one-file pass |
| A resume must pass `reviewType` alongside `sessionId` | **Kept** — and it matters more, since the default is now per-branch |

**(b) The severity enum is pinned** in §5's finding-line spec and in the template:
`BLOCKER | MAJOR | MINOR | NIT`, uppercase. Motivating incident: on PR #23's Gate-B pass 3
the quality branch returned all four findings at severity `IMPORTANT`; the file was
otherwise well-formed, so it passed every check and the Blocker/Major filter had to be
applied by interpretation.

An out-of-enum token does **not** make the pass INCOMPLETE — that would invalidate
otherwise-good passes and lose real findings. Instead the reader maps it **conservatively
to `MAJOR`** — fail toward review, invariant 2's firing direction — and records the
mapping in that pass's dispositions file: the token, how many findings carried it, and the
mapping applied. Enum drift therefore stays **visible evidence** rather than silent
tolerance.

**(c) The squash-merge carry** is specified in §6 above, as the second hop of the
carry-forward rule.

## 10. Backlog and packaging

- `todos.md`: **occurrence 3** appended to the compound-commands row — `git add` and `git
  commit` issued in one Bash call, so the staged set is empty at `PreToolUse` and the
  loose STOP fires; observed on PR #23's close. Same shape as occurrence 2, and like it a
  **false positive** — the safe direction under invariant 2.
- The two rider rows — `unverified-enforcement-claim` (sequential calls) and
  `prompt-vague-criteria` (severity enum) — are closed by this change.
- **One new parked row:** honest tier-2 counting in the hook, so a degraded pass is
  counted *and* disclosed rather than silenced. *Trigger: degraded cycles frequent enough
  that the silenced reminders demonstrably cost something.*
- Version **0.8.2 → 0.9.0** (`plugins/dev-workflow/.claude-plugin/plugin.json`), with a
  `CHANGELOG.md` entry. Required by invariant 12: this change touches paths under
  `plugins/dev-workflow/`.

## 11. Validation evidence

The mode is read from the story header at each pass. What this design commits to
producing:

- **Battery** — the `AGENTS.md` quality command, green.
- **Check that fails without the change** — write a tier marker into a WIP commit body,
  run the closing `git commit --amend`, then read `git log -1 --format=%B`. Without the
  carry-forward rule the marker is **absent** from the result. That absence is the
  observation that would exist if the claim were false, and the wiring can produce it:
  the amend genuinely replaces the message, so nothing supplies the marker for free.
- **Named verification of the risk path** — in a scratch workspace with the hook
  installed, run a fresh-context subagent gate pass and observe that the pass counter
  under `.context/` **does not move**. Counterfactual: if the hook could see tier-2
  passes the counter would increment, which would falsify §4 directly.

The risk path being verified is the one the whole design exists to close: a tier-2 pass
that reads as tier 1.

## 12. What this does not do

Stated so nobody mistakes the design for a guard. The list is **not** exhaustive — it
names the residuals known at design time.

- The hook is unchanged. Nothing mechanically distinguishes a tier-2 pass from a tier-1
  pass; a cycle that simply writes no marker is indistinguishable from tier 1.
- The disclosure is instruction-backed prose plus a commit message. Nothing validates that
  a marker was written, that it was carried through the amend, or that it survived a
  squash.
- Nothing verifies that the operator touched `.context/codex-gate.off`, stated a reason,
  or deleted it on return. While it is present, every reminder is silent.
- The re-review row is tracked by the same `todos.md` discipline as every other row. No
  automation notices that availability returned, and no check fails if the row is never
  closed.
- Rider (b)'s enum-drift record lives in the dispositions companion, which §5 keeps
  **advisory** — nothing requires it to exist, and it may be deleted or rebuilt. So that
  evidence is exactly as durable as that file, and a pass that writes none leaves the
  conservative `MAJOR` mapping applied but unrecorded. The mapping itself still happens;
  only its trace is optional.
- Tier 2 is not equivalent to tier 1, and this design does not argue that it is. It argues
  that a disclosed weaker review beats no review, and that the disclosure is what makes
  the difference survivable.
