# Execution notes — gate-pass result classification

**Gate A closed at pass 9 as a judgement exit, pre-authorized by Daniel** under a rule set
before the number arrived: *clean or Minor-only → close normally; double-digit Blocker+Major,
or any Blocker of the reading class the sweep was meant to exhaust → close there as the
second judgement exit, every open finding dispositioned by name as a Gate-B obligation. No
pass 10 either way.*

Pass 9 returned **37 findings: 2 Blocker, 31 Major, 4 Minor — 33 Blocker+Major**, and both
Blockers were reading-class. Both clauses fired.

## Nine passes, and why the count never converged

| Pass | Blockers | B+M | Total |
|---|---|---|---|
| 1 | 7 | 36 | 40 |
| 2 | 5 | 28 | 32 |
| 3 | 5 | 27 | 35 |
| 4 | 3 | 24 | 29 |
| 5 | 2 | 17 | 19 |
| 6 | 5 | 35 | 37 |
| 7 | 4 | 22 | 26 |
| 8 | 3 | 30 | 33 |
| 9 | 2 | 33 | 37 |

The watch-item never fired: A5–A7 stayed a minority in every pass, so the instability was
never where the plan predicted it.

**The plan is not what failed to converge; the review of it did.** Two human course
corrections (collapse the dual locator; narrow what the plan promises) each produced a real
drop, and each was followed by a rebound as the review reached a fresh surface — first the
harness shell, then the product prompts, then the execution procedures. What stayed constant
across passes 5–9 is a defect of *authorship*: a requirement written as prose **beside** an
artifact instead of **into** it, then dispositioned as done. Pass 9 caught three more of
those, one of which (finding 17) was a fix the mechanical sweep itself had claimed.

**The 2026-08-02 sweep was the right response and was not sufficient.** Thirteen machine
checks found and fixed eight defects that eight read-only passes had missed — including a
rollback that would have byte-verified against the wrong hook. But pass 9 showed two sweep
checks passing *for the wrong reason*: the scratch-clone dry runs defined `$EVIDENCE` and
staged the fix **themselves**, so they proved the `git` mechanics while never testing that
the plan defines either. A check that supplies the thing under test is not a check.
Sweep record: `.context/codex-reviews/gate-a-plan-sweep-2026-08-02.md`.

## Fixed at closure — three only, and why the line is there

Everything below is a Gate-B obligation, not a Gate-A fix. Three exceptions were made,
because each would have broken execution *before* Gate B could observe anything:

- **P9-19 (Blocker)** — `$EVIDENCE` was read by three commit commands and assigned nowhere.
  Task 7 gains a **Step 0** defining it, with Steps 2–5 appending to it and a
  readable-and-non-empty check before every embed.
- **P9-21 (Blocker)** — the Gate-B amend loop never staged the fix, so a bare `--amend`
  would commit nothing new: the next reviewer reads the old range while the fingerprint sees
  a changed worktree. The loop now inspects, stages the exact paths, audits the index,
  amends, and requires a clean worktree before the next call.
- **P9-17 (Major)** — Task 6's census commands were still recursive `grep`, with prose beside
  them saying they should use `git grep`. Commands replaced. *Its stated consequence is not
  currently reproducible* — the verbatim commands return **0** `.mcp/` hits today — so the
  defect is the prose-not-command gap, not the cache-hit claim.

Re-verified after those edits: all 8 fenced blocks parse under `sh -n` and pass
`shellcheck --shell=sh` at error level; the ten message assignments parse; drafts 56/56 under
`sh` and `dash`. One of those three fixes introduced a parse error of its own
(`git add <exact fix paths>` — `<` is a redirect) which the re-check caught immediately.

## Gate-B obligations — all 37 pass-9 findings, by name

Gate B inherits these the way this plan inherited spec §11's deferred contracts. Each must be
confirmed against the real implementation.

### Contract vs. code — the claim must not outrun `locate.awk` / `match.sh`

- **P9-2** — A3 says whitespace is accepted at exactly three points; `_token_ends` calls `strip_ws` after the value token, making it four. Enumerate all four sites, their shared alphabet and the 64-unit bound.
- **P9-4** — A2 says "a stray comma" is refused without scoping it to the path walked *before* selection, while the frozen verifier pins `trailing comma AFTER the selected element` as `success`. Qualify it and name that label among the non-refusals.
- **P9-6** — A2 mentions escaped *key* spellings but not that the `type` **value** is compared as raw bytes, so `text` — semantically `text` under spec §3.1 — is skipped and can yield `no-result`. State it, amend the spec, add a fixture, or implement the semantic comparison.
- **P9-32** — `UNVERIFIED_MSG` reduces locator refusals to "oversized or ambiguous", omitting unwalkable structure and the depth cap, and offers no real discriminator. Enumerate the refusal families and label the indistinguishable ones unresolved.
- **P9-35** — the "any `sed` failure maps to `unrecognized`" guarantee ignores jq-free routing, where `field()` also needs `sed`: with `jq` absent and `sed` missing the hook exits before classification. Scope the guarantee to post-routing failure and add the no-route oracle.

### Dropped or under-specified oracles

- **P9-1** — the plan claims to contain the five-row class table; it does not. Include it, or name spec §3.3 as the sole table and delete both in-plan claims.
- **P9-3** — only one past-64 fixture (after `{`). Add one per remaining `strip_ws` site.
- **P9-5** — the preceding-non-text duplicate fixture repeats only `type`; add the `text` counterpart.
- **P9-7** — with `.context/plan-drafts/` missing, the reconstruction route points at `verify.sh`, which is in the same missing directory. Track the corpus or inline a non-shell table of all 53 labels and expected classes.
- **P9-11** — `bgAdvice` is called independent but no case covers a pending disclosure composed with background advice when one family's write succeeds and the other's fails.
- **P9-14** — `unrecognized` has no four-combination matrix over default/mapped × exec/review, though the discarded classes do.
- **P9-15** — the review-side `sed`-fault label omits the usable-fingerprint oracle its `awk` counterpart carries.
- **P9-16** — `<branch>`, `<scenario>`, "all nine", "fourteen", "one composed pair" are counts and templates, not the per-test labels the settled scope requires. Enumerate them.
- **P9-18** — Task 6 Step 7 names neither prompt, label, nor independent expected source for its goldens.
- **P9-23** — the named verification demands a per-row expectation and exact row count and supplies neither table.

### State-machine and table defects

- **P9-9** — a non-writable `.context` cannot allow creating an absent `unverified` while denying deletion of `pending`; one permission governs both. Needs a selective `rm` shim or another operation-specific fault.
- **P9-10** — the A5 row "any unsuppressed event" includes flush status 1, which *is* suppression, and no row states gate-off retention. Split or rename.
- **P9-12** — `flush_notes` runs unconditionally, so pending debt can emit on a payload whose event could not be routed — contradicting spec §3.3. Gate the flush on successful routing; add a pending-plus-unroutable oracle.
- **P9-13** — one generic encoder-failure label can always fail the *first* substitution and never prove the second returns 2. Split it.

### Procedure and sequencing

- **P9-8** — Task 1 Steps 3 and 7 must share one shell and one temp locator, but Steps 4–6 intervene. Move both byte checks after Step 6.
- **P9-20** — `$BASE` must outlive shells, but no durable-note format or checked reload command is defined.
- **P9-22** — Step 4's CI evidence must bind the reviewed tree, yet it precedes the squash that creates it.
- **P9-26** — the squash's log/path/status reads do not bind the tip: a commit created between the reads and `reset --soft` is folded in silently.
- **P9-24** — the non-isolated rollback path activates 0.7.1 in the shared plugin environment with no quiescence requirement, exposing concurrent projects to the known false-checkmark and `dash`-exit behaviour.
- **P9-25** — "the newest commit whose manifest still contains 0.7.1" identifies the last *repository* bytes at that version, not bytes proven *released*; `AGENTS.md` says the version checker cannot establish release, and this repo has a history of unbumped plugin commits. Establish an authoritative release artifact or stop calling them released bytes.

### Security and privacy

- **P9-27** — captured `tool_response` blocks contain a real Codex `sessionId`, and the background capture a real task id, while the plan forbids changing any byte inside them and its own disclosure calls session identifiers sensitive. Redact without reserialization and narrow the byte-exact claim, or recapture with inert identifiers.

### Shipped prompts, against `docs/prompt-standards.md`

- **P9-28** — `Claude Code gate hook —` names the surface, not the executing model; the claimed source comment recording the prompting-page check does not exist as planned text. (Item 1.)
- **P9-29** — both background prompts require a second backgrounding to be surfaced but give no output format or example. (Item 4.)
- **P9-30** — the four cleanup instructions state the rule without its reason; the stale-artifact rationale lives only in surrounding plan prose. (Item 6.)
- **P9-31** — `FAILURE_CTX` says "every envelope whose first property is success false reaches this state", which outruns the classifier: routing, a located first text block, raw key spelling and the encoding grammar all gate it. (Item 11.)
- **P9-33** — `NORESULT_CTX` tells the model the only external cause is a *mapped* tool while `NORESULT_MSG` correctly allows an effective third-party server under the default `codex` name. The two audiences get contradictory trust-boundary diagnoses.
- **P9-34** — the unknown-tool prompt gains a prefix and paragraphs but never the tagged structure item 5 requires, so Task 6 Step 8's all-12 claim is false for a shipped prompt.
- **P9-36** — the settled §4 anchor does not require a task id, yet both background prompts unconditionally instruct stopping "by the task id in the result". Make it conditional with a no-id path, without narrowing the frozen anchor.
- **P9-37** — `UNVERIFIED_CTX`'s "repeats **only** when its marker cannot be persisted or two hook runs race" omits manual or automated marker deletion. (Item 11.)

## What Gate B should carry in, beyond these

The six harness-mechanics obligations already listed in the plan's own
**"Findings that move to Gate B"** section stand unchanged, and are additional to the above.

**Standing lens, with unusual force:** this change edits `CLAUDE.md` §5 itself. Ask which
existing statements the diff falsifies — including in files it does not touch.
