# `/dev-workflow:claude-init` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Story:** `docs/superpowers/stories/2026-09-17-claude-init-command-story.md` — read the profile from its header at every gate call; it is the only writable copy.

**Spec:** `docs/superpowers/specs/2026-09-17-claude-init-command-design.md`

**Goal:** Ship one new slash command, `/dev-workflow:claude-init`, that writes a single
`CLAUDE.md` of general working rules into a target project — without the review workflow — and add
the `Don't guess` rule to the two existing copies of section 1.

**Architecture:** No executable code. Five text artifacts change: one new command file carrying its
template inline, two existing copies of section 1, three inventory sites, and the manifest plus
changelog. Every check in this plan is a shell command comparing files; there is no test framework
and no harness that executes a command against a fixture project.

**Tech Stack:** Markdown prompts, POSIX shell for checks, `shellcheck` and `claude plugin validate`
via the repository's quality battery.

## Global Constraints

Exact values, copied from the spec and `AGENTS.md`. Every task's requirements implicitly include
this section.

- **Invariant 6 — no manifest key.** `commands/` is convention-loaded. `plugins/dev-workflow/.claude-plugin/plugin.json` gains **no** `commands` key.
- **Invariant 8 — the template stays inline** in the command body. `${CLAUDE_PLUGIN_ROOT}` is not expanded in command markdown.
- **Invariant 11 — all twelve items** of `docs/prompt-standards.md` are owed. Three are mechanically checked; nine are judged by a reader and must be answered in writing.
- **Invariant 12 — version bump.** `0.11.0` → `0.12.0`, plus a `CHANGELOG.md` entry.
- **Invariant 5 — exact pinning.** Nothing in this change installs or references a floating version.
- **Story §5 item 4** — the create branch uses `os.open(path, O_WRONLY | O_CREAT | O_EXCL)` and an **already-present** Python 3 runtime. Where no qualifying operation is available it **stops without writing**. No weaker fallback, nothing installed.
- **Story §5 item 5** — the command **never writes over an existing `CLAUDE.md`**. It shows a focused diff, asks, hands back the proposed result and stops. Approval opens no write path.
- **Story D2** — existing gates stay. No remove, disable, weaken or renumber path, and the *proposal's content* is bound by this too, not only the act of writing.
- **Story D3/D4** — no new synchronization mechanism; the command writes exactly one file.
- **The `Don't guess` block is normative in its bytes**, wrapping included (spec §4).
- **No normative text is copied into this plan.** Spec sections are cited by name. A second copy of normative text is the defect this project spends most of its findings on.

## Gate and commit handling

**Every commit in this plan is a `WIP:` commit.** Spec §4's rule applies: a `wip`-prefixed message
is cycle-internal, so the gate hook neither fires a Gate-B STOP nor resets the pass counters. The
plan touches `plugins/`, so the change is **not** prose-exempt and owes a full Gate B.

**Sequence, none of it performed by this plan:** this plan itself owes a **Gate-A plan cycle**
before execution begins. After the tasks are done and the battery is green, one **Gate-B cycle**
runs at the derived floor, and the WIP commits are collapsed with `git reset --soft` and replaced by
one real commit carrying the provenance line, the curve and the evidence entry. See `CLAUDE.md` §5
Mechanics.

**That closing commit must carry exactly the reviewed content, and that is not automatic.** `git reset --soft` moves `HEAD` and **leaves the index alone** — including every
unrelated staged entry the five tasks deliberately kept outside their own commits. A plain
`git commit` afterwards consumes all of it, so the single commit that reaches `main` would be the
only one in the whole cycle carrying somebody else's work, and no later inspection can undo a
commit that has already happened. **The close is `CLAUDE.md` §5 Mechanics' own procedure** — soft
reset to the parent of the first WIP commit, then one commit — **with two guards in front of it**:

```sh
git diff --quiet '<reviewed-headSha>' HEAD \
  || { echo 'NOT CLOSING: HEAD differs from the reviewed commit' >&2; exit 1; }
git diff --cached --quiet '<reviewed-headSha>' \
  || { echo 'NOT CLOSING: the index differs from the reviewed commit' >&2; exit 1; }
git reset --soft '<parent-of-the-first-WIP-commit>' \
  || { echo 'NOT CLOSING: reset failed' >&2; exit 1; }
git commit -m '<real subject>' -m '<provenance line, curve, evidence entry>' \
  || { echo 'CLOSING COMMIT FAILED: stop and surface' >&2; exit 1; }
git diff --quiet '<reviewed-headSha>' HEAD \
  || { echo 'CLOSING TREE DIFFERS from the reviewed commit: stop and surface' >&2; exit 1; }
git rev-parse --verify 'HEAD^'
git show --format=full --stat HEAD
```

**Two values go in, and where each comes from matters.**

- **`<reviewed-headSha>`** is the full 40-character `headSha` kept with the final clean Gate-B pass,
  per `CLAUDE.md` §5 Mechanics — never whatever `HEAD` is at closing time.
- **`<parent-of-the-first-WIP-commit>`** is resolved **before** the first task commit and noted in
  the Gate-B working record. **It is not the review's `baseSha`**: Gate B may be run against the
  merge-base with `main`, and on this branch the approved spec and story commit sits above that
  merge-base. Resetting to the merge-base would fold that already-closed Gate-A commit, and the
  provenance line and curve in its body, into the closing commit.

**The two guards are the whole mechanism, and neither covers the other.** `git commit` with no
paths commits the **index**, and the soft reset discards every commit above the parent — so both
must match the reviewed commit before anything moves. **`HEAD`'s tree** against it refuses a WIP
commit landed after the final pass, even one whose index was afterwards put back to the reviewed
tree. **The index** against it refuses unrelated work staged in the index and new content staged on
a reviewed path. An **unstaged** worktree edit is not committed — `git commit` does not read the
worktree — and stays where it was.

**Unrelated staged work stops the close rather than being carried around it.** The tasks keep such
entries out of their own commits; at closing, `CLAUDE.md`'s procedure would take them. Stop and
surface them to the user — **do not unstage someone else's work yourself**, because an entry's staged
content can differ from its worktree content and unstaging loses it.

**On any stop after the guards, do not retry and do not repair.** A repository's own commit hooks
can change the index or the worktree during `git commit`, whether it then succeeds or fails, so no
fixed recovery command is promised here. Inspect `HEAD`, the index and the worktree, surface what
you found, and re-establish a reviewed snapshot before closing again.
**`git rev-parse --verify 'HEAD^'` must print `<parent-of-the-first-WIP-commit>`.**

**What the comparisons establish, and what they do not.** They compare **trees**: `HEAD`'s and the
index's against the reviewed commit's before the close, and `HEAD`'s against it after. A late commit
whose tree equals the reviewed one — an empty WIP — passes and is folded into the close, which loses
nothing but its message. They do not
establish what the reviewer actually read; `CLAUDE.md` §5 says the same of `headSha` itself.

The block begins with `git`, contains no `"` and carries no `-m` starting with `wip`, so the hook
reads it as the cycle closing and clears the Gate-B state — correct on success. **It does so whether
or not the close succeeded**, because the hook cannot see an exit status (`codex-gate.sh`'s own
comment at the reset). A failed close therefore costs a further Gate-B pass after restoring, which
is the safe direction.

**Measured under `sh` and `dash`**, running the block above verbatim with its placeholders filled,
in a throwaway repository shaped like this branch — an approved document commit above the base,
then two `WIP:` task commits:

| scenario | exit | where it stopped | state afterwards |
|---|---|---|---|
| ordinary close | 0 | — | one closing commit on the parent of the first WIP; the approved document commit **kept**; tree equal to the reviewed commit's |
| unrelated work staged in the index | 1 | the index guard | untouched; the unrelated entry still staged |
| a WIP commit landed after the final pass | 1 | the `HEAD` guard | untouched; the late commit kept |
| the same, with the index afterwards put back to the reviewed tree | 1 | the `HEAD` guard | untouched; the late commit kept |
| new content staged on a reviewed path after the pass | 1 | the index guard | untouched |
| an unstaged worktree edit after the pass | 0 | — | closed with the reviewed content; the edit still unstaged in the worktree |
| unresolvable parent | 1 | the reset | untouched |
| a pre-commit hook that stages a change and then fails | 1 | the commit | `HEAD` at the parent, index changed by the hook — the case the no-fixed-recovery rule exists for |

For comparison, the canonical procedure **without** the guard, with an unrelated path staged:
the closing tree differs from the reviewed tree and the unrelated path is inside the closing commit.

The block run through `codex-gate.sh`, with and without `jq`, under `sh` and `dash`: read as the
cycle closing in all four.

**This is the link the previous round's end-to-end probe stopped short of.** That probe ran the
tasks and the evidence amend and reported green; the cycle closing was never exercised, and the
defect lived there.

**Profile:** Risk `standard` · Security `none` · Validation `battery+check` — read fresh from the
story header at each gate call, never from this line. `battery+check` owes **the quality battery
green plus a check that fails without the change**, with its counterfactual observed against the
prior state. Every task below is written so its check *is* that counterfactual: the check is run and
seen to fail before the change exists.

**Lens sets: none.** Risk is not `high` and security is neither `standard` nor `high`.

## The commit procedure — one procedure, used by every task

Every task in this plan ends with a commit, and **all of them use the block below**. Three
independent defects found in Gate-A plan passes 1–3 lived in per-task commit spellings that drifted
apart; unifying them is the repair. Substitute only the `set --` line and `SUBJECT`.

```sh
git status --porcelain
git --literal-pathspecs add -- '<path one>' '<path two>' \
  || { echo 'STAGING FAILED — not committing' >&2; exit 1; }
git --literal-pathspecs commit --only -m 'WIP: <subject>' -- '<path one>' '<path two>' \
  || { echo 'COMMIT FAILED' >&2; exit 1; }
git show --stat --format='%H %s' HEAD
git status --porcelain
```

**Substitute the path literals and the subject; nothing else changes.** The block carries no
comments, and three properties of its *shape* are load-bearing rather than stylistic — they are
what the gate hook's `jq`-free parser needs, and they are stated as rules here because the block no
longer explains itself inline:

1. **The Bash call begins with `git`.** No leading comment, no blank line, no variable assignment.
2. **No `"` appears before the end of the `-m 'WIP: …'` argument.** After that argument, double
   quotes are harmless.
3. **Every path is a single-quoted literal, spelled out on both the `add` and the `commit`** —
   repeated rather than held in `"$@"`, because `"` is what the parser truncates on.
4. **No Bash call that is *not* a commit may contain the substring `commit`** — not in a comment,
   not in a `^{commit}` peel, not in a word like "uncommitted". `is_commit` is
   `git[[:space:]].*commit` over the whole call, so any call starting with `git` and containing
   that substring is classified as a commit; with no `-m …wip` in it, the hook deletes `gateB`,
   `passCount` and `freshCount`. **Two such calls were found in this plan by running every block
   through the hook** — a `refs/remotes/origin/main^{commit}` peel in the integration-base block,
   which cleared the state whenever `jq` was installed, and a `# … is uncommitted` comment on a
   bare `git status`, which cleared it in all four configurations. Both are repaired; the rule is
   here because neither was visible by reading.

A subject containing an apostrophe is written `'\''` inside the single-quoted argument — for
example `-m 'WIP: add the Don'\''t guess rule'`. Verified to parse under `sh` and `dash` and to be
recognised by the hook with and without `jq`.

**Why those three rules, measured rather than asserted:** *The `jq`-free parser* below.

**Why each part is there. Every clause answers a finding, not a preference.**

- **`||` after `add`, and `exit 1`.** `git add` and `git commit` as separate unguarded lines let a
  failed stage be followed by a commit that records an older index or unrelated staged content.
  Reproduced under **both `sh` and `dash`** with a stubbed `git`: with `add` returning non-zero,
  **`commit` still ran**. The guard is what stops that; `&&` would do as well, `;` would not.
- **`--only -- '<path>' …`.** It commits the named paths' working-tree content and **excludes anything
  else that happens to be staged**, leaving those entries staged and untouched. Without it, every
  already-staged unrelated path enters this task's commit, and no later inspection can undo a commit
  that already happened.
- **Single-quoted path literals, and `--literal-pathspecs` on top.** The two guard different
  stages and **neither substitutes for the other**: quoting stops the **shell** from word-splitting
  and glob-expanding the names, and `--literal-pathspecs` stops **git** from reading a leading `:`
  as pathspec magic. An earlier version of this procedure used an unquoted `$PATHS` and credited
  `--literal-pathspecs` with protection it cannot give — measured, `*.txt` reached git as two
  arguments under both `sh` and `dash`. The version before this one used `set -- "…"` with `"$@"`,
  which gives the **same** shell-level protection and was replaced for an unrelated reason: its
  double quotes are what the hook's `jq`-free parser truncates on. Single-quoted literals carry
  that protection unchanged; the price is repeating each path on the `add` and on the `commit`,
  and that price is the entire reason for the change.
- **The subject is passed with a literal, single-quoted `-m` beginning with `WIP:`, and none of
  that is cosmetic.** The gate hook recognises a cycle-internal commit only from that spelling:
  `is_wip_commit() { printf '%s' "$1" | grep -Eiq -- "-m[[:space:]]*['\"]?[[:space:]]*wip"; }`.
  **A message supplied through `-F` does not match** — the hook then takes its real-commit path and
  runs `rm -f "$state_file" "$count_file" "$fresh_file"` (`codex-gate.sh:886-888`), **clearing the
  Gate-B fingerprint and the pass counters**. That is the failure `CLAUDE.md` §5 warns about by
  name. Where a body is needed, add a **second `-m`**, which **may** be double-quoted because it
  comes after the recognised argument — `-m 'WIP: …' -m "<body>"`, verified recognised with and
  without `jq`.

  **Testing that predicate on its own is not enough, and that is how this survived a round.** The
  predicate is fed by a parser, and the earlier version of this plan checked only the predicate.
  The parser is what the next section measures.
- **The two inspections afterwards.** `git show --stat` confirms the commit contains only the
  intended paths; the second `git status --porcelain` confirms nothing this task owns is still
  outstanding and that unrelated staged entries survived.

### The `jq`-free parser — the constraint this plan works around, and what it is not

`AGENTS.md` invariant 4 makes `jq` **optional**, so the hook has to be correct without it. Without
`jq` it lifts the command out of the JSON payload with

```sh
printf '%s' "$payload" | sed 's/.*"tool_input"[[:space:]]*:[[:space:]]*{//' \
  | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -n1 | sed 's/^.*:[[:space:]]*"\(.*\)"$/\1/'
```

(`codex-gate.sh:27-36`). Two consequences follow, and both were measured **through the real hook**,
not against the predicate alone:

1. **`[^"]*` stops at the first `"` in the command.** Every double quote in the shell command is
   `\"` in the payload, so the hook sees only the prefix in front of it.
2. **`is_commit` is anchored `(^|[^[:alnum:]])git[[:space:]]`, and a newline inside the payload is
   the two characters `\n`.** The character preceding a `git` on a continuation line is therefore
   the letter `n`, which is alphanumeric — so only a `git` at the very **start** of the command can
   satisfy the anchor.

Measured in a throwaway repository carrying the adoption marker, running
`plugins/dev-workflow/hooks/codex-gate.sh` under **`sh` and `dash`**, **with `jq` present and with
`jq` removed from `PATH`** — four runs per row, both shells agreeing in every one:

| command shape | with `jq` | without `jq` |
|---|---|---|
| starts with `git`, `-m "WIP: …"` **double**-quoted | WIP, state kept | **read as a real commit — `gateB`, `passCount`, `freshCount` deleted** |
| `git status …` first, then `commit … -m "WIP: …"` | WIP, state kept | **same: state deleted** |
| a **leading comment**, then that same commit | WIP, state kept | silent — the commit is never seen |
| **this plan's block**: starts with `git`, `-m 'WIP: …'`, no `"` before it | WIP note shown | **WIP note shown — identical** |
| the closing real commit, starting with `git` | state cleared | state cleared |

**Row three is why "just single-quote the `-m`" was not the fix.** The previous version of this
block opened with a comment containing `"$@"`, so the parse truncated inside that comment: the hook
saw no commit and therefore deleted nothing. The block was protected **by accident**, and any
reordering would have removed the protection without changing a visible behaviour. Row four is the
fix, and it is the only shape in the table that behaves the same with and without `jq`.

**Stated narrowly, because the distinction is the point.** This is a **plan-level workaround for a
hook defect**. It makes the commands *this plan* issues survive the `jq`-free parser. It does
**not** repair the parser: any other command that opens with a comment, or carries a `"` ahead of
its `-m WIP`, is still mis-read. Repairing `codex-gate.sh` is a separate change with its own scope
decision — **this plan does not touch the hook**, and nothing here should be read as a claim that
the parser defect is closed.

**The one case this block cannot handle: a path carrying both task-owned and unrelated edits.**
`--only` selects **whole paths**, so it cannot split one. **Stop and surface that overlap rather
than committing a mixture** — no flag resolves it and inventing a split here would be a mechanism
the story does not carry.

**This procedure was executed in a throwaway repository, not reasoned about.** A fresh `git init`
with one owned file, one **unrelated file staged in the index**, and one untracked file:

| case | observed |
|---|---|
| `--only -- owned.txt` with `foreign.txt` staged | the commit contained **only** `owned.txt`; `foreign.txt` stayed `M ` — staged and outside |
| `add` stubbed to fail, under **`sh`** and **`dash`** | `STAGING FAILED — not committing`, the commit never ran, in both |
| new untracked file, `--only` **without** `add` | `error: pathspec 'new.txt' did not match any file(s) known to git` — so the `add` is required, which is why Task 2 must not drop it |
| `-m 'WIP: …' -m "<body>"` | subject and body land separately, verified with `git log --format='%s' / '%b'` — **re-run in the single-quoted spelling this plan now uses** |
| the hook predicate against all three planned spellings | all three **recognised**; the old `-F` spelling **not**. **This row is the shallow test** — it exercised the predicate and not the parser feeding it; see *The `jq`-free parser* |

**And then the whole sequence end to end, including the evidence amend**, in a repository holding
an owned file, **a path containing a space**, and an unrelated staged file — run under **`sh` and
`dash`**:

| checked after the full run | `sh` | `dash` |
|---|---|---|
| the space-containing path arrived as **one** path | yes | yes |
| the unrelated staged path stayed staged and out | `M  foreign.txt` | `M  foreign.txt` |
| the tree was **unchanged** by the amend | yes | yes |
| the evidence body landed in the commit | yes | yes |

**Extended to the cycle-closing commit, and repeated with `jq` removed from `PATH`.** The run
executes the Task 1–4 commit blocks, then **one of the two Task 5 routes**, then the closing block,
each **verbatim as this plan prints it** with only its placeholders filled, in a repository shaped
like this branch — an approved document commit above the base — and checks every exit status. It
runs once with the index otherwise clean and once with an unrelated path staged before the first
task commit:

| checked after the full run, `sh` and `dash` agreeing in every cell | empty route | owned route |
|---|---|---|
| every task block, the evidence commit and, on the owned route, the amend exited 0 | yes | yes |
| `WIP:` commits before the close | 5 | 5 |
| **index otherwise clean:** close exited 0; tree equal to the reviewed commit's; parent is the first WIP's parent; approved document commit kept; provenance line in the body | yes | yes |
| **unrelated path staged:** every task commit kept it out; the close **stopped at the guard**; nothing moved; the path still staged | yes | yes |

Every commit-bearing block and the evidence amend, run through `codex-gate.sh` under `sh` and `dash`
with and without `jq`: every WIP call recognised, the closing call read as the cycle closing.

**A correction to the previous version of this table.** It reported a single run that included "the
Task 5 empty evidence commit, the evidence amend" and marked it green. The amend in that run had
**failed** — `git commit --amend --only` on an empty commit refuses with *"would make it empty"* —
and the harness did not check its exit status. The plan never prescribes that sequence: the amend
belongs to the owned route only. The table above runs the two routes separately and checks every
exit status.

**That end-to-end run is the one that mattered**, and its absence is why an earlier version of this
table could be entirely green while two defects were still present: each operation was correct in
isolation, and the **transition** to the amend was never exercised.

**It happened again one link further along, and that is worth stating plainly.** An earlier version
of that run stopped at the amend, so the **cycle closing** was never exercised — and the closing commit was
where the ownership scoping was lost. It also ran only with `jq` installed, so the supported
`jq`-free configuration was never exercised either. Both gaps are closed above, and the rule this
plan now follows is: **the sequence is run to its last commit, in every supported configuration.**

Earlier rounds checked these sequences by reading them and missed a defect each time. This is the
method change: the stateful part is executed against a real index, **as a whole sequence**.

**Worktree checks run before the commit; committed-tree checks run after it.** That split is not
stylistic: `scripts/check-version-bump.sh` reads `HEAD` and the merge-base
(`git ls-tree -d --name-only HEAD plugins/`, `git diff --quiet "$mb" HEAD`, `tree_has HEAD`), so it
cannot see a working-tree edit and **cannot pass before the commit that carries it**. Any check that
reads committed trees belongs after the commit, in every task, including on a conditional route.

---

## File Structure

| File | Responsibility | Task |
|---|---|---|
| `CLAUDE.md` (repo root) | copy 3 of the `Don't guess` rule | 1 |
| `plugins/dev-workflow/commands/workflow-init.md` | copy 2, inside its inline template | 1 |
| `plugins/dev-workflow/commands/claude-init.md` | **new** — the command body and copy 1 inside its inline template | 2 |
| `README.md` | component-table row | 3 |
| `AGENTS.md` | layout-tree entry | 3 |
| `docs/architecture.md` | layout-tree entry | 3 |
| `plugins/dev-workflow/.claude-plugin/plugin.json` | version `0.12.0` — **no** new key | 4 |
| `plugins/dev-workflow/CHANGELOG.md` | the `0.12.0` entry | 4 |

Task 5 writes no product file; it records the twelve-item review in the execution report.

---

### Task 1: Add `Don't guess` to the two existing copies

Copy 3 in this repository's own `CLAUDE.md` and copy 2 inside `workflow-init.md`'s inline template.
Doing these first means Task 2's template can be derived and checked against a settled source.

**Files:**
- Modify: `CLAUDE.md` — end of `## 1. Think Before Coding`, after the bullet `- If something is unclear, stop. Name what's confusing. Ask.`, before `## 2. Simplicity First`
- Modify: `plugins/dev-workflow/commands/workflow-init.md` — the same position inside the `````markdown` fence that opens at line 199

**Interfaces:**
- Consumes: nothing.
- Produces: two byte-identical `### Don't guess` blocks. Task 2 derives copy 1 from the
  `workflow-init.md` one and compares all three.

**Placement, exactly as spec §4 states it:** immediately after §1's last bullet, separated by one
blank line, and immediately before `## 2. Simplicity First`, separated by one blank line.

- [ ] **Step 1: Write the parity check and watch it fail**

Create `/tmp/dg-parity.py` (a scratch check, not a shipped file). **This script was run against
the current tree while the plan was written**: it reports `OK` on the spec, `MISSING in CLAUDE.md`
on the unmodified root file, and exits 1 in the second case.

```python
"""Extract each `### Don't guess` block and compare them. Files are read with newline="",
so line endings are not translated: for valid UTF-8, equal decoded text is equal bytes.
A block runs from its heading to the blank line after the `**Verify before claiming.**`
paragraph. Exit 0 only when every named file has one and all are identical."""
import io, sys, difflib

def block(path):
    lines = io.open(path, encoding="utf-8", newline="").read().split("\n")
    heads = [i for i, l in enumerate(lines) if l.strip() == "### Don't guess"]
    if len(heads) != 1:
        return "%d" % len(heads)
    s = heads[0]
    v = next(i for i in range(s, len(lines)) if lines[i].startswith("**Verify before claiming.**"))
    e = next((i for i in range(v, len(lines)) if not lines[i].strip()), len(lines))
    return lines[s:e]

blocks = {}
for p in sys.argv[1:]:
    b = block(p)
    if isinstance(b, str):
        print("FAIL %s: expected exactly 1 '### Don't guess' heading, found %s" % (p, b)); sys.exit(1)
    blocks[p] = b

ref = sys.argv[1]
ok = True
for p in sys.argv[2:]:
    if blocks[p] != blocks[ref]:
        ok = False
        print("DIFFERS: %s vs %s" % (ref, p))
        print("\n".join(list(difflib.unified_diff(blocks[ref], blocks[p], ref, p, lineterm="", n=1))[:20]))
print("OK: the one block in each of %d files is identical, %d lines each" % (len(blocks), len(blocks[ref])) if ok else "FAIL")
sys.exit(0 if ok else 1)
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `python3 /tmp/dg-parity.py CLAUDE.md plugins/dev-workflow/commands/workflow-init.md`
Expected: `MISSING in CLAUDE.md`, exit 1. **This is the counterfactual for this task.** Record the
output; `battery+check` owes the observation against the prior state, not the claim.

- [ ] **Step 3: Insert the block into `CLAUDE.md`**

Copy the block verbatim from spec §4's fence, wrapping included. Do not retype it, do not reflow
it, and do not assert a line count anywhere — the count is whatever the fence holds, and a stated
count that drifts is this project's most common defect. Insert one blank line, the block, one blank line, before `## 2. Simplicity First`.

- [ ] **Step 4: Insert the block into `workflow-init.md`'s template**

Same block, same placement, inside the `````markdown` fence. The fence is four backticks because the
template contains three-backtick fences of its own; do not close it early.

- [ ] **Step 5: Run the parity check again**

Run: `python3 /tmp/dg-parity.py CLAUDE.md plugins/dev-workflow/commands/workflow-init.md`
Expected: `OK: the one block in each of 2 files is identical, <n> lines each`, exit 0.

- [ ] **Step 6: Confirm the insertion is the ONLY change, by reconstruction**

A file count plus "no line was removed" is **not** that check: it is satisfied by any number of
extra insertions anywhere in either file. Instead, remove the authorized block from the result and
compare the remainder with the file's own pre-task bytes, read from the committed tree — no fixture
is saved.

Create `/tmp/only-insert.py`:

```python
"""For each file: build the ONE expected result from its pre-task bytes -- the authorized block
inserted immediately before `## 2. Simplicity First`, after the blank line already there, followed
by exactly one blank line -- and require the working-tree file to equal it. Any other difference
-- an extra insertion, a missing or doubled separator, a different position -- fails.

Files are read with newline="" and git output is decoded from raw bytes, so no line ending is
translated: for valid UTF-8, equal decoded text is equal bytes."""
import io, subprocess, sys, difflib

PRE_REV = "REPLACE_WITH_THE_COMMIT_BEFORE_TASK_1"

def pre(path):
    return subprocess.run(["git", "show", "%s:%s" % (PRE_REV, path)],
                          capture_output=True, check=True).stdout.decode("utf-8").split("\n")

def now(path):
    return io.open(path, encoding="utf-8", newline="").read().split("\n")

def block_from_spec():
    S = now("docs/superpowers/specs/2026-09-17-claude-init-command-design.md")
    i4 = next(i for i, l in enumerate(S) if l.startswith("## \u00a74 Target text"))
    o = next(i for i in range(i4, len(S)) if S[i].strip() == "```")
    c = next(i for i in range(o + 1, len(S)) if S[i].strip() == "```")
    b = S[o + 1:c]
    while b and not b[-1].strip():
        b.pop()
    return b

def expected_after(before, block):
    hits = [k for k, l in enumerate(before) if l.startswith("## 2. Simplicity First")]
    if len(hits) != 1:
        return None, "expected exactly 1 '## 2. Simplicity First' in the pre-task file, found %d" % len(hits)
    i = hits[0]
    if i == 0 or before[i - 1] != "":
        return None, "the pre-task file has no blank line before '## 2. Simplicity First'"
    return before[:i] + block + [""] + before[i:], None

block = block_from_spec()
ok = True
for path in ("CLAUDE.md", "plugins/dev-workflow/commands/workflow-init.md"):
    before = pre(path)
    after = now(path)
    expected, err = expected_after(before, block)
    if err:
        print("FAIL %-52s %s" % (path, err)); ok = False; continue
    if after == expected:
        print("OK   %-52s equals its pre-task bytes plus exactly the authorized insertion" % path)
    else:
        ok = False
        print("FAIL %-52s differs from its pre-task bytes plus exactly the authorized insertion" % path)
        print("\n".join(list(difflib.unified_diff(expected, after, "expected", "working tree",
              lineterm="", n=1))[:20]))
sys.exit(0 if ok else 1)
```

Replace `PRE_REV` with the same commit id Task 2 Step 4a pins.

Run: `python3 /tmp/only-insert.py`
Expected: two `OK` lines, exit 0.

**This procedure was exercised in memory while the plan was written**, against a stand-in block: the
authorized insertion alone leaves a remainder identical to the original, and adding one unrelated
line elsewhere makes the remainder differ. The check detects what its title claims.

- [ ] **Step 7: Commit**

```sh
git status --porcelain
git --literal-pathspecs add -- 'CLAUDE.md' 'plugins/dev-workflow/commands/workflow-init.md' \
  || { echo 'STAGING FAILED — not committing' >&2; exit 1; }
git --literal-pathspecs commit --only -m 'WIP: add the Don'\''t guess rule to the two existing section-1 copies' -- 'CLAUDE.md' 'plugins/dev-workflow/commands/workflow-init.md' \
  || { echo 'COMMIT FAILED' >&2; exit 1; }
git show --stat --format='%H %s' HEAD
git status --porcelain
```

This **is** the commit procedure above with its path literals and subject filled in — issued as **one** Bash call beginning with `git`.

---

### Task 2: Create `claude-init.md`

The new command file: frontmatter, the conformance declaration, the operational body, the reasoned
`n/a` note, and the inline template.

**Files:**
- Create: `plugins/dev-workflow/commands/claude-init.md`
- Read (do not modify): `plugins/dev-workflow/commands/workflow-init.md` — the model for frontmatter, the declaration line at `:9`, and the `n/a` note that sits outside the fence

**Interfaces:**
- Consumes: Task 1's `workflow-init.md` template, which now carries `Don't guess`.
- Produces: the shipped template that Task 5's row-4b check compares, and the file path Task 3
  writes into three inventories.

**Spec sections this task installs, cited not copied:** §2 (behaviour), §3 (what the template omits
and why), §4 (the `Don't guess` rule), §5 (the minimal template), §6 (the declaration and the
marker).

**The template transformation is deterministic and was verified in memory before this plan was
written.** Applying the operations below to `workflow-init.md`'s template reproduces spec §5's
normative template **byte for byte** — 85 lines, 3708 bytes, counting the payload as the lines
between the fences joined with LF, without the LF before the closing fence. The boundaries below are the exact ones
that produce that result; the spec's §3 table names the four omissions, and this is where their
edges are pinned.

- [ ] **Step 1: Confirm the target file does not exist yet**

Run: `test ! -e plugins/dev-workflow/commands/claude-init.md && test ! -L plugins/dev-workflow/commands/claude-init.md && echo 'absent, as expected'`

`test -e` follows symlinks, so a dangling link at the path reads as absent; `test ! -L` is what stops on it.
Expected: `absent, as expected`. If it exists, **stop** and report the collision; another task may
own it.

- [ ] **Step 2: Write the command file's head**

Frontmatter and body opening, modelled on `workflow-init.md:1-12`. Three things are load-bearing and
each has a stated reason:

1. A `Target model: Claude via Claude Code.` line — prompt-standards item 1.
2. The exact phrase **`This command is a prompt artifact and follows`** — `scripts/check-invariants.sh:313`
   builds its file set with `grep -rl 'prompt artifact and follows'`. Without the phrase the file is
   outside the scan and its declaration is never counted, so a green checker would be green about a
   file nothing looked at.
3. **Exactly one** `^Target model:` line in the whole file. A second one makes the declaration count
   2 and fails the check — which is why the `n/a` note in Step 6 must not be phrased as one.

- [ ] **Step 3: Write the operational body**

Spec §2 is the source; do not restate it, implement it. The body must instruct the agent through:

- **Step one — the path kind**, five outcomes, with the rule that `test -e`/`test -f` resolve
  symlinks so `test -L` comes first. Report **which row** was observed, not a generic failure.
- **Step two — content**, three outcomes: absent → create; equivalent → report `unchanged`, add
  nothing; different or overlapping → focused diff, ask, hand back, stop.
- **Writing** — the create branch only, through `os.open(path, O_WRONLY | O_CREAT | O_EXCL, 0o644)`
  in an already-present Python 3. **Pass the mode explicitly**: the default is `0o777`, which under a
  conventional umask creates the file executable. Where no qualifying operation is available, stop
  without writing and report the limitation.
- **Report forms** — prompt-standards item 4 owes an output format **with an example**. **Eight**
  states need one, and the last three cover spec §2's requirement *"A failed write
  is an outcome, not silence"*:
  `written` · `unchanged` · `proposal produced` (approved and declined are the same state for this
  command — it writes in neither) · `stopped: path kind` · `stopped: no qualifying create operation`
  · **`stopped: create refused`**, where the exclusive create returned `EEXIST` because something
  appeared in the window · **`failed: partial write`**, where the exclusive open succeeded and the
  template was then written only in part · **`failed: create write`** for every other failed
  create attempt, including failure before an entry was created or after open but before any
  template bytes were written. `EACCES`, `EROFS` and `ENOSPC` are examples, not a closed error list.
  For each unsuccessful attempt, report the observed error, whether exclusive open succeeded, and
  the path's observed state afterwards; if that state cannot be inspected, report that limitation.
  **`written` may be reported only from an observed completed write.** An `os.open` that returned is
  not that observation — the guarantee is over the **directory entry**, not over the bytes, and a
  failed write may leave an empty or partial file. Describe only the state actually observed, with
  the failure's cause per item 10. Spec §2's qualifying-operation rule still applies; a failure
  opens no fallback write path.
- **The two limits on a proposal** — it preserves unrelated content and existing gates (D2 binds its
  content), and approval opens no write path. "Proposal produced" is never reported as an applied
  merge.

- [ ] **Step 4: Run the negative case, then write the template, then run both derivations**

Insert spec §5's template inside a FENCE-markdown fence (four backticks — the template contains
three-backtick fences). Produce it by applying these operations to `workflow-init.md`'s template,
**not** by retyping. The boundaries below were executed in memory against the real files while this
plan was written and reproduce spec §5's template **byte for byte**: 85 lines, 3708 bytes (the LF
before the closing fence not counted).

1. **Delete** from the line beginning `The work loop includes the review gates:` up to, but **not
   including**, the first line that is exactly `---` after it. That removes §4's closing sentence,
   the blank line after it, all of `## 5.`, and the blank line before the separator.
2. **Delete** everything after the line beginning `**These guidelines are working if:**`. That
   removes the blank line, the second `---`, its blank line, and the three-line `@AGENTS.md`
   pointer.
3. **No §6 removal is performed.** Neither the pre-change nor the post-change `workflow-init.md`
   template contains a `## 6.` — measured, `False` in both. Spec §3 lists it among the omissions;
   here it is an **already-satisfied absence**, asserted rather than executed.
4. **Insertion applies to row 4a only.** Row 4a derives from the **pre-change** source, which has no
   `Don't guess` yet, so its derivation inserts the block. Row 4b derives from the **post-change**
   source, where Task 1 already placed it, so its derivation inserts nothing.

Create `/tmp/tmpl-derive.py`:

```python
"""Rows 4a and 4b as two SEPARATE exact-equality comparisons, per spec §7.

Row 4a's source is the template **as it stands before this change**, read from the commit
this branch sat on before Task 1 — an identified revision, not a saved fixture.
Row 4b's source is the working-tree template after Task 1.

`actual` is passed in explicitly, so the negative case reaches the comparison instead of
throwing while looking for a file. No hunk count is asserted anywhere: how many hunks a diff
renders is a property of the renderer, not of the change.

A payload is the lines strictly between its opening and closing fence, joined with LF; the LF
before the closing fence is not part of it. Files are read with newline="" and git output is
decoded from raw bytes, so no line ending is translated and no trailing line is stripped: for
valid UTF-8, equal payload text is equal payload bytes.
"""
import io, subprocess, sys, difflib

FENCE = "`" * 4
PRE_REV = "REPLACE_WITH_THE_COMMIT_BEFORE_TASK_1"   # see Step 4a below

def fence_after(lines, i):
    o = next(k for k in range(i, len(lines)) if lines[k].startswith(FENCE))
    c = next(k for k in range(o + 1, len(lines)) if lines[k].strip() == FENCE)
    return lines[o + 1:c]

def from_rev(rev, path):
    return subprocess.run(["git", "show", "%s:%s" % (rev, path)],
                          capture_output=True, check=True).stdout.decode("utf-8").split("\n")

def from_file(path):
    return io.open(path, encoding="utf-8", newline="").read().split("\n")

def idx(t, pred, start=0):
    return next(i for i in range(start, len(t)) if pred(t[i]))

SPEC = "docs/superpowers/specs/2026-09-17-claude-init-command-design.md"
S = from_file(SPEC)
target = fence_after(S, next(i for i, l in enumerate(S) if l.startswith("## §5 Target text")))
i4 = next(i for i, l in enumerate(S) if l.startswith("## §4 Target text"))
o4 = next(i for i in range(i4, len(S)) if S[i].strip() == "```")
c4 = next(i for i in range(o4 + 1, len(S)) if S[i].strip() == "```")
dg = S[o4 + 1:c4]
while dg and not dg[-1].strip():
    dg.pop()

def omissions(t):
    t = list(t)
    a = idx(t, lambda l: l.startswith("The work loop includes the review gates:"))
    b = idx(t, lambda l: l.strip() == "---", a)
    del t[a:b]
    c = idx(t, lambda l: l.startswith("**These guidelines are working if:**"))
    del t[c + 1:]
    return t

def insert_dg(t):
    t = list(t)
    i = idx(t, lambda l: l.startswith("## 2. Simplicity First"))
    return t[:i] + dg + [""] + t[i:]

def norm(t):
    return "\n".join(t)

def compare(label, expected, actual):
    if norm(expected) == norm(actual):
        print("OK   %s" % label)
        return True
    print("FAIL %s" % label)
    print("\n".join(list(difflib.unified_diff(norm(expected).split("\n"), norm(actual).split("\n"),
          "expected", "actual", lineterm="", n=2))[:40]))
    return False

WI = "plugins/dev-workflow/commands/workflow-init.md"
pre_lines = from_rev(PRE_REV, WI)
pre_src = fence_after(pre_lines, next(i for i, l in enumerate(pre_lines) if l.startswith(FENCE + "markdown")))
post_lines = from_file(WI)
post_src = fence_after(post_lines, next(i for i, l in enumerate(post_lines) if l.startswith(FENCE + "markdown")))

mode = sys.argv[1] if len(sys.argv) > 1 else "all"
if mode not in ("negative", "4a", "4b", "all"):
    print("unknown mode %r: use negative, 4a, 4b or all" % mode); sys.exit(2)
ok = True

if mode in ("negative", "all"):
    print("-- negative case: an explicitly UNTRANSFORMED source must not equal the target")
    ok &= not compare("negative: untransformed pre-change source vs spec §5 target", target, pre_src)
    ok &= not compare("negative: deletions without the insertion vs spec §5 target",
                      target, omissions(pre_src))

if mode in ("4a", "all"):
    print("-- row 4a: PRE-change source + the insertion + the deletions")
    ok &= compare("row 4a", omissions(insert_dg(pre_src)), target)

if mode in ("4b", "all"):
    print("-- row 4b: POST-change source + the deletions, no insertion")
    ci = from_file("plugins/dev-workflow/commands/claude-init.md")
    shipped = fence_after(ci, next(i for i, l in enumerate(ci) if l.startswith(FENCE + "markdown")))
    ok &= compare("row 4b", omissions(post_src), shipped)
    ok &= compare("row 4b, shipped template vs spec \u00a75 target", target, shipped)

no6 = not any(l.startswith("## 6.") for l in pre_src) and not any(l.startswith("## 6.") for l in post_src)
print("no §6 in either source:", no6)
ok &= no6
sys.exit(0 if ok else 1)
```

- [ ] **Step 4a: Pin the pre-change revision and run the negative case — before the template exists**

Replace `PRE_REV` with the commit this branch sat on **before Task 1** — `git rev-parse HEAD`
taken before Task 1's commit, or equivalently `git log --format=%H -1 <task-1-commit>^`. It must be
a real commit id, not `HEAD`, which moves.

Run: `python3 /tmp/tmpl-derive.py negative`

Expected: **two `FAIL` lines and exit 0.** Read that pairing carefully — in `negative` mode a
*differing* comparison is the assertion passing, so the `FAIL` labels are the desired outcome and
the exit status reports that the negative case held. **Exit 1 here would mean an untransformed
source unexpectedly equalled the target**, which is the real failure.

**This is the counterfactual, and it reaches the comparison**: both inputs exist, so no file lookup
or fence search can throw instead. A traceback here is a setup defect, not evidence.

**Both expectations were observed while this plan was written** — run against the tree at
`c1e727f`, `negative` produced exactly two `FAIL` lines and exit 0, and `4a` produced `OK row 4a`
with exit 0.

- [ ] **Step 4b: Run row 4a — still before the template exists**

Run: `python3 /tmp/tmpl-derive.py 4a`
Expected: `OK row 4a`, exit 0. **This is the check spec §7 row 4a actually specifies** — the
proposed template against the template *as it stood before this change*, with the insertion applied.
It reads no working-tree command file, so it runs before Task 2 writes anything.

- [ ] **Step 4c: Write the template, then run row 4b**

Now install the template in `claude-init.md` and run: `python3 /tmp/tmpl-derive.py 4b`
Expected: `OK row 4b`, `OK row 4b, shipped template vs spec §5 target`, `no §6 in either source:
True`, exit 0. The second comparison is what ties the shipped template to the normative target
directly, rather than only through the post-change `workflow-init` template.

**Row 4b has no counterfactual and is not offered as one** — it compares two files that will both be
correct or both be wrong. Row 4a's negative case, above, is the one that carries evidence.

**What this pair checks and what it does not.** Both comparisons read without line-ending
translation and without stripping, so for valid UTF-8 they establish that the compared **payloads**
are byte-identical — the fenced templates, not the whole files around them — and they say nothing
about either source being correct on its own. **Row 4a** ties the pre-change `workflow-init` template
to spec §5; **row 4b** ties the shipped template to both the post-change `workflow-init` template and
spec §5. The post-change `workflow-init` template itself is tied to its pre-task bytes by Task 1's
`only-insert.py`, which is only as current as its last run — rerun it if either file changes.

- [ ] **Step 5: Add the reasoned `n/a` note, outside the fence**

`workflow-init.md:190-197` is the model. Same reason, same place: the scaffolded file's executing
model is whatever the target project runs, so a `Target model:` line inside the template would be
false in every repo it lands in. **Outside the fence so it never scaffolds, and deliberately not
phrased as a `Target model:` line.**

- [ ] **Step 6: Run the spelling and manifest checks**

```sh
# Rows 2 and 3 — absence of four and two spellings inside the fence. Absence of SPELLINGS,
# not absence of gate obligations or dangling references; the semantic question is the walkthrough's.
python3 - <<'PY'
import io
L = io.open("plugins/dev-workflow/commands/claude-init.md", encoding="utf-8").read().split("\n")
o = next(i for i,l in enumerate(L) if l.startswith("````markdown"))
c = next(i for i in range(o+1,len(L)) if L[i].strip()=="````")
body = "\n".join(L[o+1:c])
for s in ("Gate A","Gate B","§5","Cross-Model","AGENTS.md","(see §5)"):
    print("%-14s %d" % (s, body.count(s)))
PY
# Row 5 — one key. Invariant 6 as a whole is checked separately by check-invariants.sh.
grep -c '"commands"' plugins/dev-workflow/.claude-plugin/plugin.json
# Row 9 — the file is inside the conformance scan at all.
grep -rl 'prompt artifact and follows' --include='*.md' . | grep -Fx './plugins/dev-workflow/commands/claude-init.md'
# Exactly one declaration line.
grep -c '^Target model:' plugins/dev-workflow/commands/claude-init.md
```

Expected: all six spelling counts `0`; `"commands"` count `0`; the scan prints exactly
`./plugins/dev-workflow/commands/claude-init.md` and that pipeline exits 0 — `grep -Fx` matches the
product path only, so this plan's and the spec's own mentions of `claude-init` cannot satisfy it;
declaration count `1`.

- [ ] **Step 7: Run the three-copy parity check**

Run: `python3 /tmp/dg-parity.py CLAUDE.md plugins/dev-workflow/commands/workflow-init.md plugins/dev-workflow/commands/claude-init.md`
Expected: `OK: the one block in each of 3 files is identical, <n> lines each`, exit 0.

**What this establishes, and what it does not.** It finds the single `### Don't guess` heading in
each file and compares the blocks. It does **not** establish **where** the block sits — in
`claude-init.md` a block moved out of the template into the command's prose would still compare
equal here. Position inside the scaffolded template is row 4b's job: it compares the whole shipped
template with spec §5's target, which carries the block at the end of section 1. **Story criterion 5
is discharged by this check and row 4b together**, not by either alone.

- [ ] **Step 8: Commit**

```sh
git status --porcelain
git --literal-pathspecs add -- 'plugins/dev-workflow/commands/claude-init.md' \
  || { echo 'STAGING FAILED — not committing' >&2; exit 1; }
git --literal-pathspecs commit --only -m 'WIP: add the claude-init command with its inline template' -- 'plugins/dev-workflow/commands/claude-init.md' \
  || { echo 'COMMIT FAILED' >&2; exit 1; }
git show --stat --format='%H %s' HEAD
git status --porcelain
```

This **is** the commit procedure above with its path literals and subject filled in — issued as **one** Bash call beginning with `git`.

**`claude-init.md` is new and untracked**, so the `git add` in that procedure is what makes
`--only` able to name it. Do not drop the `add` for this task.

---

### Task 3: Name the command in the three inventory sites

**Files:**
- Modify: `README.md` — the component table, rows at `:23` and `:25` show the shape
- Modify: `AGENTS.md` — the layout tree, `commands/{workflow-init,process-pr-review}.md` at `:46`
- Modify: `docs/architecture.md` — the layout tree, same line shape at `:25`

**Interfaces:**
- Consumes: the file path created in Task 2.
- Produces: nothing later tasks depend on.

**`MANIFEST.md` is deliberately not among them** (spec §1): it inventories `source-files/`, the
frozen extraction seed, and a command with no seed origin has no row there.

- [ ] **Step 1: Run the reference grep `AGENTS.md` requires before touching layout documentation**

```sh
grep -rn 'commands/{workflow-init' --include='*.md' . | grep -v source-files/
grep -rniE 'declare[sd]?|convention[- ]load' --include='*.md' . | grep -v source-files/
```

Expected: the first names exactly the two tree sites. **Read the second's hits rather than counting
them** — it is there because a sentence about what the manifest declares must be checked against the
manifest in the same change, and this change adds a convention-loaded component.

- [ ] **Step 2: Write the check and watch it fail**

```sh
grep -c '^| `/dev-workflow:claude-init` | command' README.md
grep '^| `/dev-workflow:claude-init` |' README.md | grep -c 'Python 3'
```

```sh
got=$(git diff HEAD -U0 -- AGENTS.md docs/architecture.md | grep '^[-+@]' | grep -v '^--- \|^+++ ' | sed 's/^\(@@ [^@]*@@\).*/\1/')
want=$(printf '%s\n' '@@ -46 +46 @@' '-  commands/{workflow-init,process-pr-review}.md' '+  commands/{workflow-init,process-pr-review,claude-init}.md' '@@ -25 +25 @@' '-  commands/{workflow-init,process-pr-review}.md' '+  commands/{workflow-init,process-pr-review,claude-init}.md')
if [ "$got" = "$want" ]; then echo 'OK trees: the text diff is exactly one in-place line replacement in each'; else echo 'FAIL trees: unexpected diff'; printf '%s\n' "$got"; exit 1; fi
```

**What each line compares, and nothing more** — spec §7's rule: a row claims only what its command
compares, and the rest goes to a named reading check.

- The two README lines match the row's opening and the Python 3 disclosure **anywhere in
  `README.md`**. They do **not** establish that the row sits in the component table — Step 5's
  reading check does.
- The tree block compares the **text** diff of the two layout files with the one expected text diff:
  the tree line replaced **in place**, at `AGENTS.md:46` and `docs/architecture.md:25`, and no other
  content line changed. A line moved out of the tree, an extra content edit, or a misspelling all
  produce a different diff. It reads the text diff only, so a file-mode or other metadata change is
  **outside** it; the commit's own `git show --stat` is where such a change would show. The `sed`
  only drops the context label git appends to hunk headers.

Expected before: `0`, `0`, then `FAIL trees: unexpected diff` with an empty diff and exit 1 —
**the counterfactual**.

- [ ] **Step 3: Add the README component-table row**

One row in the same voice as its neighbours, **starting ``| `/dev-workflow:claude-init` | command —``**
like the `workflow-init` row above it — the check in Step 2 matches that opening: what the command is,
and what it writes. Say that it
writes `CLAUDE.md` only and installs no gates, so a reader can tell it from `/dev-workflow:workflow-init`
in the row above. **Disclose the create-branch Python 3 requirement here** — this is the only
inventory site a user reads before running it.

- [ ] **Step 4: Update the two layout trees**

`commands/{workflow-init,process-pr-review}.md` → `commands/{workflow-init,process-pr-review,claude-init}.md`
in both `AGENTS.md:46` and `docs/architecture.md:25`. Same spelling in both; they are two copies of
one tree.

- [ ] **Step 5: Run the check again**

Same commands as Step 2. Expected: `1`, `1`, then `OK trees: the text diff is exactly one in-place
line replacement in each`, exit 0.

**Then the reading check for placement**, which the greps do not carry: open `README.md` at its
component table and confirm the new row is **inside that table, directly below the
`/dev-workflow:workflow-init` row**, and that no second `/dev-workflow:claude-init` row exists
elsewhere. Record the observed line number in the Gate-B working record.

- [ ] **Step 6: Commit**

```sh
git status --porcelain
git --literal-pathspecs add -- 'README.md' 'AGENTS.md' 'docs/architecture.md' \
  || { echo 'STAGING FAILED — not committing' >&2; exit 1; }
git --literal-pathspecs commit --only -m 'WIP: name claude-init in the component table and both layout trees' -- 'README.md' 'AGENTS.md' 'docs/architecture.md' \
  || { echo 'COMMIT FAILED' >&2; exit 1; }
git show --stat --format='%H %s' HEAD
git status --porcelain
```

This **is** the commit procedure above with its path literals and subject filled in — issued as **one** Bash call beginning with `git`.

---

### Task 4: Version bump and changelog entry

**Files:**
- Modify: `plugins/dev-workflow/.claude-plugin/plugin.json` — `"version": "0.11.0"` → `"0.12.0"`
- Modify: `plugins/dev-workflow/CHANGELOG.md` — a `0.12.0` entry at the top, newest first

**Interfaces:**
- Consumes: nothing.
- Produces: the version `check-version-bump.sh` reads in Task 5.

**Recheck the integration base before finalizing the number.** Spec §1 requires it and says why:
`scripts/check-version-bump.sh` is blind to exactly this case — "two PRs branched from the same
version each bumping to the same new one". The recheck is the only thing standing in for it.
`loop-rule-consolidation` pins `0.12.0` for itself in its own plan text; **that branch is not edited
here**, and reconciling it belongs to that cycle.

- [ ] **Step 1: Recheck the integration base — a live check, not a cached one**

**Resolve the integration revision once and read everything from it**, so the manifest and the
changelog cannot come from two different states:

```sh
git fetch origin '+refs/heads/main:refs/remotes/origin/main' \
  || { echo "FETCH FAILED: integration-base check stopped" >&2; exit 1; }
BASE=$(git rev-parse --verify 'refs/remotes/origin/main') \
  || { echo "cannot resolve fetched origin/main" >&2; exit 1; }
echo "integration revision: $BASE"
git show "$BASE:plugins/dev-workflow/.claude-plugin/plugin.json" | grep '"version"' \
  || echo "READ FAILED or no version key in the manifest at $BASE"
# First release heading, no line cutoff. The file opens with a convention preamble, so the
# first `## ` is NOT in the first twenty lines — measured: it is at line 25.
git show "$BASE:plugins/dev-workflow/CHANGELOG.md" > /tmp/cl.$$ \
  || { echo "READ FAILED: changelog not readable at $BASE"; }
if [ -s /tmp/cl.$$ ]; then
  grep -m1 -E '^## ' /tmp/cl.$$ || echo "NO RELEASE HEADING found in the changelog at $BASE"
fi
rm -f /tmp/cl.$$
gh pr list --state open
```

The explicit refspec requests remote `main` and updates `origin/main`; the checked fetch status
stops execution before `BASE` is read on failure. Git's error output supplies the cause. Successful
fetch establishes the fetched snapshot, not that the remote cannot move afterwards.

**Three outcomes are deliberately distinguishable** — a read that failed, a file with no release
heading, and a heading whose version conflicts with the manifest. A single silent empty result
would conflate them, which is what the earlier fixed-prefix form did.

Expected at the spec's writing: `origin/main` at `7c0d475…`, manifest `0.11.0`, first changelog
heading `## 0.11.0`, no open PRs — so `0.12.0` is free. **If any of these has moved, stop and
report**; choosing a version against a stale base is the defect the checker cannot see.

- [ ] **Step 2: Run the check and watch it fail — after Tasks 1–3, before the bump**

Run: `sh scripts/check-version-bump.sh main`
Expected: it reports the plugin changed without a version change, exit non-zero — **the
counterfactual**.

**The checker reads committed trees, not the working tree**, and that governs where both runs go.
Its own usage line says *"compares HEAD against the merge-base with &lt;base-ref&gt;"*, and it works
through `git ls-tree -d --name-only HEAD plugins/`, `git diff --quiet "$mb" HEAD -- "$dir/"` and
`tree_has HEAD "$manifest"`. So this negative run needs Tasks 1–3's WIP commits to exist — against a
clean tree it passes uselessly — and **the positive run cannot be made until the bump is
committed**. That is why Step 5 below comes after the commit, not before it.

- [ ] **Step 3: Bump the manifest**

`"version": "0.11.0"` → `"version": "0.12.0"`. **Change nothing else in that file** — invariant 6
means no `commands`, `skills`, `agents` or `hooks` key is added.

- [ ] **Step 4: Write the changelog entry**

Newest first. The file's own header states the convention: entries are written from `git log` over
`plugins/`, not from memory, and carry **no dates**. Cover the plugin-touching commits of this
change: the new command, and the `Don't guess` rule added to `workflow-init.md`'s template.

- [ ] **Step 5: Check the working tree — the two things that are readable before a commit**

```sh
grep '"version"' plugins/dev-workflow/.claude-plugin/plugin.json
grep -c '"commands"\|"skills"\|"agents"\|"hooks"' plugins/dev-workflow/.claude-plugin/plugin.json
grep -m1 -E '^## ' plugins/dev-workflow/CHANGELOG.md
grep -n '^## ' plugins/dev-workflow/CHANGELOG.md
awk '/^## /{n++; next} n==1' plugins/dev-workflow/CHANGELOG.md | grep -c 'claude-init'
awk '/^## /{n++; next} n==1' plugins/dev-workflow/CHANGELOG.md | grep -c "Don't guess"
```

Expected: the manifest reads `0.12.0`; the key count is `0`; the newest changelog heading is
`## 0.12.0`, **the same version as the manifest**; and the **body of the newest entry** — the lines
after the first release heading and before the next, which is what the `awk` prints — mentions both
plugin-touching changes: the last two counts are non-zero. Before Step 4 the first line is
`## 0.11.0` and both counts are `0`, which is this check's counterfactual.

**Uniqueness of the release heading is a reading check, not a count.** The `grep -n '^## '` line
prints every release heading with its line number: **read it** and confirm that `0.12.0` heads the
list and appears in no other heading, in any spelling — trailing spaces, a `v` prefix or a second
entry included. Record what you saw in the Gate-B working record. It reads the entry's text for the two change
names; whether the prose describing them is right is the reviewer's judgement, not this grep's. **The version checker is deliberately
not run here** — it would still read `0.11.0` from `HEAD` and fail a correct change.

- [ ] **Step 6: Commit**

```sh
git status --porcelain
git --literal-pathspecs add -- 'plugins/dev-workflow/.claude-plugin/plugin.json' 'plugins/dev-workflow/CHANGELOG.md' \
  || { echo 'STAGING FAILED — not committing' >&2; exit 1; }
git --literal-pathspecs commit --only -m 'WIP: bump dev-workflow to 0.12.0 with its changelog entry' -- 'plugins/dev-workflow/.claude-plugin/plugin.json' 'plugins/dev-workflow/CHANGELOG.md' \
  || { echo 'COMMIT FAILED' >&2; exit 1; }
git show --stat --format='%H %s' HEAD
git status --porcelain
```

This **is** the commit procedure above with its path literals and subject filled in — issued as **one** Bash call beginning with `git`.

- [ ] **Step 7: Now run the positive comparison**

Run: `sh scripts/check-version-bump.sh main`
Expected: exit 0. **This is the first point at which it can pass**, because the bump is now in
`HEAD`'s tree.

**Use the same base the release decision used.** Step 1 resolved an integration revision and read
the manifest and changelog from it; if `main` and that revision have diverged since, pass the
resolved revision here instead of the bare `main` and say which was used. **Verifies a bump is
present, not that it is correct** — the script's own documented limit.

---

### Task 5: Record the twelve-item review, run the battery, and demonstrate the counterfactual

No product file changes. This task produces the written evidence the profile owes and the green
battery Gate B expects — and **names where each piece is retained**, because "the execution report"
is not a destination.

**Files:**
- Write: `.context/codex-reviews/gate-b-<nonce>-resume.md` — the Gate-B cycle's working record,
  which `CLAUDE.md` §5 already sanctions as an advisory companion. **The twelve-item review, the
  walkthrough and the measured counterfactual values are retained there**, in the artifact the
  Gate-B cycle already owns. No new artifact kind is introduced, and nothing about that record is
  load-bearing: it is advisory, and the findings file plus its terminator remain the only hard
  requirement.
- Commit body: **the story's named evidence entry**, which `CLAUDE.md` requires to live in the
  commit body and to be restated by the closing amend. It is not a file.

**Interfaces:**
- Consumes: everything Tasks 1–4 produced.
- Produces: the evidence entry the Gate-B closing commit carries.

- [ ] **Step 1: Answer all twelve prompt-standards items for `claude-init.md`, in writing**

Every item of `docs/prompt-standards.md`, answered with either the answer or a **reasoned `n/a`** in
the shape `workflow-init.md:190-197` uses. The three with a mechanical check (item 1 plus the two
narrow spellings) still get an answer; the other nine have **no mechanical check at all** and are
satisfied only by this review being done and recorded. Item 4 needs the output-format example from
Task 2 Step 3; item 11 needs every enforcement claim to name its mechanism and stop at what that
mechanism compares.

**The same review covers the changed prompt text elsewhere in this change** — `Don't guess` as it
lands in `workflow-init.md`'s template and in this repository's own `CLAUDE.md`.

- [ ] **Step 2: Run the semantic walkthrough and label it correctly**

Read the command text against each case: a new target receives only `CLAUDE.md`; a second run adds
no duplicate; an overlapping file triggers the ask and no write; each of step one's five path kinds
stops where it should; the create branch stops where no qualifying operation exists.

Also trace the attempted-create failures from spec §2: `EEXIST` refusal; an open error before
creation (`EACCES`, `EROFS`, `ENOSPC`, and an error outside those examples); successful open followed
by failure with zero bytes written; and a partial write. In each case, locate the instruction and
report example that name the failure and the observed path state afterwards, or the inability to
inspect it. Confirm none reports completed creation or takes a weaker fallback. These cases check
the general failure rule as well as its refusal/partial-write examples; they do not execute writes.

**A walkthrough is evidence about the text, not an execution.** This repository has no harness that
runs a command against a fixture project. Any report saying otherwise is false. Also read the
**semantic** questions rows 2 and 3 cannot reach: does the template impose any gate obligation in
any wording, and does it point at any file this command does not write.

- [ ] **Step 3: Demonstrate the counterfactual, measured rather than asserted**

Run the six spelling greps from Task 2 Step 6 against **`workflow-init.md`'s template** instead.

Expected: `7, 12, 3, 2, 7, 1` where the new template returns `0` for each. These are
**occurrence** counts — the probe uses `body.count` — measured against the current source; the first
is `7` because one line carries `Gate A` twice. **Measure these; do not
copy the numbers from the spec** — §7 records the sixth as `10`, which is a standing collected Minor
(pass 4, finding 11), and the measured value is `1`. Row 4a's expectation is built from a source
that must be transformed to match, so an untransformed template fails it. Row 9 goes red on any file
lacking the marker; `process-pr-review.md` is a live example.

**Row 4b has no counterfactual and is not offered as one** — it compares two files that will both be
correct or both be wrong.

- [ ] **Step 4: Run the full quality battery**

Run the whole chained command from `AGENTS.md` § Commands, verbatim. It needs `shellcheck`, the
`claude` CLI and **`dash`** — the hook suite runs twice, once with the hook under `sh` and once
under `dash`, because Ubuntu's `/bin/sh` is dash and a dash-only defect shipped once already.

Expected: exit 0. Nothing in this change is executable, so this is **tested coverage, not "nothing
broke"**.

- [ ] **Step 5: Retain the records and carry the evidence in a commit body**

Write the twelve-item review, the walkthrough and the measured values into the Gate-B cycle's
working record. Then account for what actually changed, and pick the route that matches:

```sh
git status --porcelain                 # what, if anything, is outstanding
```

Classify outstanding changes as **task-owned or unrelated**, inspecting both index and worktree
diffs as well as untracked paths. Record their paths and why any task-owned changes remain. Leave
unrelated changes, including their staged state, untouched. If ownership is uncertain or a path
mixes task-owned and unrelated edits, stop and surface that overlap before staging or committing.
The routes below select whole paths; they cannot isolate ownership within one path.

**Both routes carry the evidence through a second `-m`, never `-F`.** `-F` is what broke the
hook's WIP recognition; the commit procedure above states the predicate and the consequence. The
subject stays `WIP: record the battery run and the evidence entry`; `$BODY` is the story's named
evidence entry.

- **No task-owned changes remain** — the expected case, since Tasks 1–4 committed their own files
  and the working record is under `.context/`, which is git-ignored. Record the evidence with an
  empty commit, which changes no content and therefore raises no review obligation:

  ```sh
  git commit --only --allow-empty -m 'WIP: record the battery run and the evidence entry' -m "$BODY" \
    || { echo "COMMIT FAILED" >&2; exit 1; }
  git show --stat --format='%H %s' HEAD
  ```

  **The `SUBJECT=` assignment is gone on purpose.** A Bash call that opens with a variable
  assignment does not begin with `git`, and the `jq`-free parser then fails the `is_commit` anchor
  and never sees the commit at all — the earlier spelling was protected only by that blindness. The
  subject is inlined and single-quoted; `-m "$BODY"` stays double-quoted because it follows the
  recognised argument. `$BODY` must be exported into this call, not assigned ahead of the `git`.

  `--only --allow-empty` **without paths** creates an empty commit even when unrelated changes are
  staged, so this route cannot capture them. It is the only route that skips the shared procedure's
  `add`, because there is nothing to stage.

- **Task-owned changes remain** — finish and validate those changes first, then run **the commit
  procedure** above with the reviewed task-owned paths as single-quoted literals and the same
  subject, adding the `-m "$BODY"` argument after the subject. This route commits content, so it owes a content
  review under the existing Gate-B rules; the empty-commit rationale does not apply.

  **Then rerun the committed-tree checks — this is the ordering the earlier text got wrong.**
  Reruning affected checks *before* this commit does not cover the tree it creates:
  `scripts/check-version-bump.sh` reads `HEAD`, so a task-owned manifest edit could pass a
  pre-commit battery and land in `HEAD` with no version observation of the resulting tree. After the
  commit:

  ```sh
  sh scripts/check-version-bump.sh main    # or the resolved integration revision from Task 4
  ```

  and rerun any other check that reads committed trees. **Then refresh the evidence entry** to
  describe the tree that now exists, and amend it into this commit with
  `git commit --amend --only -m 'WIP: record the battery run and the evidence entry' -m "$BODY"` —
  the call begins with `git`, the WIP argument is single-quoted, and the body follows it, per the
  three shape rules in the commit procedure — before Gate B is called. An evidence body describing a pre-commit state is not evidence
  about the reviewed range.

  **`--only` is load-bearing on the amend, and its absence was a real hole.** A plain
  `git commit --amend` commits the **current index**, which still holds every unrelated staged path.
  Measured in a throwaway repository: after a correctly scoped first commit containing only
  `owned.txt`, a plain amend produced a commit containing `foreign.txt` **as well**, and the tree
  changed from `8071d7d8…` to `b6bc185a…`. With `--amend --only` and no paths, the tree was
  **byte-identical** and the unrelated path stayed staged. Amending without it would re-cross the
  ownership boundary **and** invalidate the committed-tree checks just run against that tree.

On either route, a failed commit stops this step; do not call Gate B with a missing evidence body
or task changes outside the committed range. After success, inspect `git show --format=full --stat
HEAD` and `git status --porcelain`: confirm the evidence body is present, the commit contains only
the intended task changes (none on the empty route), and no task-owned change remains uncommitted.
The stateful sequence is pending execution; this plan does not claim it has been run.

**The closing amend restates the evidence entry.** The amend replaces the WIP message wholesale, so
an entry written only into a WIP body is destroyed exactly when the cycle closes. The final commit
body is the durable record.

**None of this is executed by the planning assignment** — these commands describe the execution
stage.

---

## What this plan does not do

- **It does not run either gate.** This plan owes a Gate-A plan cycle before execution; Gate B runs
  after Task 5, at the floor derived from the story's profile.
- **It does not repair the 15 collected Minor and Nit findings** from the spec cycle. They are
  reference material. Two of them are load-bearing here and are handled inside tasks rather than as
  repairs: the `os.open` mode argument (Task 2 Step 3) and the measured sixth spelling count (Task 5
  Step 3). Everything else stays collected.
- **It does not edit the spec or the story.** If a task cannot proceed without changing an approved
  decision, that is a stop-and-surface, not an edit.
- **It does not touch `loop-rule-consolidation`.**
- **It adds no new checker, synchronization layer or gate machinery.** The two scratch scripts live
  in `/tmp` and ship nothing.

## Accounting — what the pass-1 repair kept, moved and dropped

`AGENTS.md`: *"Never replace a decision procedure without accounting for its old conditions."* Seven
procedures were replaced. Every condition each carried is listed.

| Old condition | Fate |
|---|---|
| Task 4: run the version checker once, after editing the manifest | **Split.** The negative run is **kept**, moved to after Tasks 1–3's commits; the positive run is **moved** to after the bump commit, because the checker reads committed trees. Nothing about what it verifies changed. |
| Task 4: "it compares *commits*, so run it with the WIP commits already made" | **Kept and made load-bearing** — it was already true and is now the stated reason for the ordering, with the checker's own lines cited. |
| Task 4: `head -20 CHANGELOG.md \| grep '^## '` | **Dropped.** Measured: no match, the first heading is at line 25. Replaced by `grep -m1 -E '^## '` with no cutoff, read from the resolved integration revision, with read failure, absent heading and version conflict kept distinguishable. |
| Task 4: read the manifest from `origin/main`, the changelog from the working tree | **Dropped.** Both now come from one resolved revision, so they cannot describe two states. |
| Task 2: one check, run after the template is written, expected to FAIL beforehand | **Dropped as unreachable.** The script raised `FileNotFoundError` on the prescribed pre-template state. Replaced by an explicit `actual` input and three ordered runs — negative, 4a, then 4b — so the negative case reaches the comparison. |
| Task 2: "both comparisons use the post-change source, and that is deliberate" | **Dropped, and the reasoning with it.** Spec §7 row 4a requires the template *"as it stands before this change"*. Row 4a now derives from an identified pre-Task-1 commit and runs separately from 4b. The earlier collapse changed an approved verification contract. |
| Task 2: the transformation's two deletions and the §6 no-op | **Kept, verbatim**, and still reproduce spec §5's template byte for byte. What changed is which source each row applies them to, not the operations. |
| Task 2: five report states | **Kept**, plus **two added** — `stopped: create refused` and `failed: partial write` — which spec §2 requires with *"A failed write is an outcome, not silence"*. |
| Task 1 Step 6: two changed paths and no removed lines | **Dropped as an overclaim.** It is satisfied by arbitrary extra insertions, while its title claimed "nothing else changed". Replaced by reconstruction: remove the authorized block, compare the remainder with the file's pre-task bytes, and check the block's placement. |
| Task 5: "Modify: none", results in "the execution report" | **Dropped.** The review and measured values now go to the Gate-B cycle's working record — an artifact `CLAUDE.md` §5 already sanctions — and the named evidence to the commit body, where `CLAUDE.md` puts it. |
| Task 5: `git add -A` | **Dropped.** Replaced by two named cases: an empty records commit when nothing is outstanding, or staging by path. Broad staging in a worktree that may hold unrelated work is the hazard. |
| The five-task structure, the task boundaries, the criterion coverage, the no-duplicated-normative-text rule | **Kept, untouched.** Pass 1 raised no Major against any of them. |

**Scope of this repair, stated so it is not read as more.** Only the seven Majors. The eleven Minor
and four Nit findings stay collected and were not swept. **Two of them touch mechanisms these
repairs necessarily rewrote**, and the dependency is named rather than used to claim the class is
solved: the comparison scripts' text-mode reads and trailing-newline stripping are now **described
accurately** where they run — the checks establish agreement of decoded text, not byte identity of
files — and the parity extractor's scoping is unchanged and still collected.

## Accounting — what the pass-2 repair kept, moved and dropped

The pass-1 accounting above records that earlier repair. This round replaces three procedures:

| Previous condition | Fate |
|---|---|
| Task 2 Step 3: examples for five original states, `EEXIST` refusal and partial write; success observed; directory-entry limit; failure cause and observed state | **Kept.** Added a catch-all failed-create state, covering failures before creation and after open with zero bytes; unsuccessful attempts report open outcome and any inability to inspect the path. The closed seven-state coverage and the claim that a failed write necessarily leaves a partial file are **dropped**. The qualifying-operation requirement stays. |
| Task 5 Step 2: new target, repeat, overlap, five path kinds, unavailable operation, semantic gate/reference questions; text-only evidence | **Kept.** Added refusal, generic open error, zero-byte and partial-write cases and their reports. No execution claim or fallback is added. |
| Task 5 Step 5: working-record destination, evidence body, WIP subject, empty route, staging by name, path report, closing-amend carry | **Kept.** The branch condition changes from any outstanding work to task ownership, and the owned branch now commits before Gate B. Broad staging remains excluded; `--only` excludes unrelated staged paths. Mixed/uncertain ownership stops. Evidence is refreshed when its inputs change; commit failure and post-commit verification are explicit. |
| Task 4 Step 1: fetch origin, resolve once, read manifest and changelog at that revision, distinguish read/heading/conflict outcomes, inspect open PRs and stop on movement | **Kept.** The refspec explicitly refreshes `origin/main`, fetch failure stops before resolution, and the ref must resolve to a commit. Acceptance of a cached ref after fetch failure is **dropped**; the later checks and release-decision conditions stay. |

Only the three Majors from pass 2 are repaired here. Its 17 Minor and 7 Nit findings remain
collected. The failure reports and walkthrough overlap the reporting/coverage mechanisms named
by Minors, but this round adds only the Major's failed-create cases; it does not claim those
broader findings resolved.

## Accounting — what the pass-3 repair kept and dropped

`AGENTS.md`: *"Never replace a decision procedure without accounting for its old conditions."*

| Old condition | Fate |
|---|---|
| Five per-task commit spellings, each written separately | **Replaced by one shared procedure.** The drift between them was where three of the cycle's Majors lived. Each task now supplies only its `set --` line and `SUBJECT`. |
| Tasks 1–4: `git add <paths>` then `git commit -m …` on separate unguarded lines | **Dropped.** Reproduced under `sh` and `dash`: a failed `add` was still followed by the commit. Replaced by `\|\| { …; exit 1; }` after the stage. This defect predates every repair round — it was in the plan's first version. |
| Tasks 1–4: plain `git commit`, which includes everything already staged | **Dropped.** Replaced by `--only -- "$@"`, tested with an unrelated path staged: it stayed staged and out of the commit. The pass-2 repair applied ownership handling to Task 5 only; this extends it to every path. |
| Task 5: `-F /tmp/evidence-msg.txt` on both routes | **Dropped.** `is_wip_commit()` matches only a literal `-m …wip`, so `-F` read as a real commit and the hook would clear the Gate-B fingerprint and counters. Replaced by a second `-m` carrying the body, which keeps the recognised first argument. **This spelling entered in the pass-1 repair round, not the pass-2 one** — the later round propagated it to the second route. |
| Task 5 owned route: rerun affected checks, then commit, then `show --stat` and `status` | **Re-ordered.** `check-version-bump.sh` reads `HEAD`, so committed-tree checks now run **after** the commit, followed by refreshing the evidence body and amending it in. A pre-commit pass is not an observation of the tree the commit creates. |
| Task 5 empty route: `--only --allow-empty` without paths | **Kept**, and re-tested: it commits nothing even with unrelated paths staged. Only its message spelling changed. |
| "Quote each path and use literal pathspecs" | **Kept**, moved into the shared procedure as `--literal-pathspecs`. |
| The mixed-ownership stop | **Kept**, and its reason sharpened: `--only` selects whole paths and cannot split one, so no flag resolves the case. |
| Shared procedure: unquoted `$PATHS` with `--literal-pathspecs` credited for protection | **Dropped as an overclaim.** The shell splits and globs before git runs; measured, `*.txt` reached git as two arguments under `sh` and `dash`. Replaced by `set -- "…"` and `"$@"`, with `--literal-pathspecs` kept for the separate job it does do. |
| Task 5 owned route: `git commit --amend` for the refreshed evidence | **Dropped.** A plain amend commits the current index, so unrelated staged paths re-enter. Measured: the tree moved from `8071d7d8…` to `b6bc185a…`. Replaced by `--amend --only`, which left the tree byte-identical. |
| The five-task structure, task boundaries, criterion coverage, the transformation, the derivation checks | **Kept, untouched.** Pass 3 raised no Major against any of them. |

**Scope:** the four Majors of pass 3 only. The twenty Minor and seven Nit findings stay collected
and were not swept.

## Accounting — what the pass-4 repair kept, moved and dropped

`AGENTS.md`: *"Never replace a decision procedure without accounting for its old conditions."*

| Old condition | Fate |
|---|---|
| `set -- "<path>" …` with `"$@"` on the `add` and the `commit` | **Moved.** The shell-level protection it gave — no word-splitting, no globbing — is unchanged, now carried by single-quoted path literals. It was replaced only because its double quotes truncate the hook's `jq`-free parse. The cost is repeating each path twice per task, and it is paid deliberately. |
| `SUBJECT="<subject>"` as a separate assignment | **Dropped.** A call opening with an assignment does not begin with `git`, so `is_commit`'s anchor fails without `jq` and the commit is never seen. The subject is inlined into the `-m` argument. |
| The explanatory comments inside the procedure block | **Moved** into the prose below it, unchanged in substance. A leading comment breaks the `^git` anchor, and a comment containing `"` truncates the parse — the block's old first line did both. |
| `-m "WIP: …"` (double-quoted) | **Dropped.** Measured end to end through the hook, without `jq`: the parse truncates at that quote, the remainder is still read as a commit but no longer as a WIP commit, and `gateB`, `passCount` and `freshCount` are deleted. Replaced by `-m 'WIP: …'`, which is recognised identically with and without `jq`. |
| "The `-m` beginning with `WIP:` is what the hook recognises", evidenced by testing `is_wip_commit` directly | **Kept as a claim, replaced as evidence.** The predicate test was one layer too shallow: a parser stands in front of it. The claim now rests on runs of the real hook under `sh` and `dash`, with and without `jq`. |
| A second `-m` for the body, double-quoted | **Kept.** Double quotes *after* the recognised argument change nothing — verified in both configurations. |
| `--only -- <paths>`, the `\|\|` guard, `--literal-pathspecs`, the two `git status --porcelain` inspections, the mixed-ownership stop | **Kept, untouched.** Pass 4 raised no Major against any of them, and none depends on the quoting change. |
| Cycle closing stated as "collapsed with `git reset --soft` and replaced by one real commit" | **Replaced by an explicit, scoped procedure.** A soft reset leaves the index intact, so a plain closing commit consumed every unrelated staged entry the five tasks had preserved — measured under `sh` and `dash`. The closing commit now names its paths with `--only` and is checked by comparing the committed tree against the reviewed tree. |
| The end-to-end probe as sufficient evidence for the commit handling | **Kept and extended.** It ran the tasks and the amend with `jq` present, and stopped there. It now runs to the **cycle-closing commit** and in the **`jq`-free** configuration, which is where both of pass 4's Majors lived. |
| The five-task structure, task boundaries, criterion coverage, the transformation, the derivation checks | **Kept, untouched.** Pass 4 raised no Major against any of them. |

**Scope:** the two Majors of pass 4 only. The twenty-one Minor and seven Nit findings stay
collected and were not swept. **The hook itself was not touched** — the parser defect is worked
around here and remains open.

## Accounting — what the pass-5 repair kept, moved and dropped

`AGENTS.md`: *"Never replace a decision procedure without accounting for its old conditions."*

| Old condition | Fate |
|---|---|
| Closing block: first reading `git rev-parse 'HEAD^{tree}'` taken at closing time, described as "the tree Gate B reviewed" | **Dropped as an overclaim.** It read whatever `HEAD` was at closing, so a WIP commit landing after the final pass became the "reviewed" tree. Replaced by `git diff --quiet '<reviewed-headSha>' HEAD`, pinned to the `headSha` kept with the final clean pass. |
| Closing block: `git reset --soft '<parent-of-the-first-WIP-commit>'`, resolved before the cycle | **Moved.** The base is now the `baseSha` kept with the final clean pass — the same value, taken from the record the pass already owes rather than a second note. |
| Closing block: reset, commit and inspections as unguarded lines | **Dropped.** Each mutation now stops the block on failure and says what state it left. Measured under `sh` and `dash`: late WIP commit, unresolvable base and incomplete path list each exit 1 at the intended step. |
| Closing block: the second tree reading compared by eye with the first | **Replaced** by `git diff --quiet '<reviewed-headSha>' HEAD` after the commit, which fails the block rather than relying on a reader. |
| Closing block: `--only -- '<paths>'`, no `"` anywhere, begins with `git`, no `wip` subject | **Kept.** Re-verified through the hook in all four configurations. |
| The prose "they diverge exactly when the path list is incomplete or a worktree edit arrived" | **Dropped as an overclaim.** Tree inequality does not identify its cause. The failure list now names the usual cause without claiming equivalence. |
| End-to-end table: one run including the empty evidence commit **and** the amend, reported green | **Dropped as false.** The amend in that run had failed and its exit status was not checked. Replaced by one run per Task 5 route, every exit status checked. |

**Scope:** the two Majors of pass 5, plus the end-to-end table, whose "verbatim" claim the closing
block's rewrite made false and which turned out to be false already. The twenty-seven Minor and ten
Nit findings of pass 5 stay collected.

## Accounting — what the pass-6 repair kept, moved and dropped

`AGENTS.md`: *"Never replace a decision procedure without accounting for its old conditions."*
**This round deletes a mechanism rather than repairing it a third time.** The closing block written
in the pass-4 round and rewritten in the pass-5 round drew both Majors of pass 5 and both of pass 6.
It is replaced by `CLAUDE.md` §5 Mechanics' own closing procedure plus one guard.

| Old condition | Fate |
|---|---|
| Closing commit scoped with `--only -- '<every path the five tasks owned>'` | **Dropped.** It committed the named paths' **worktree** content rather than the reviewed content, rewrote their index entries so a soft reset no longer restored them, and made a path-list error indistinguishable from new content. Replaced by a plain `git commit`, which commits the index, behind a guard that the index equals the reviewed tree. |
| Reset target: the final pass's `baseSha` (pass-5 round), described as "the same value" as the first WIP's parent | **Dropped as false.** Gate B may run against the merge-base with `main`; on this branch the approved spec and story commit sits above it, and resetting there would fold that closed Gate-A commit and its records into the closing commit. Reverted to the parent of the first WIP commit, resolved before the first task commit — `CLAUDE.md`'s own wording. |
| Pre-close check `git diff --quiet '<reviewed-headSha>' HEAD` (committed trees only) | **Replaced** by `git diff --cached --quiet '<reviewed-headSha>'` — the index against the reviewed tree — because the index is what `git commit` records. It covers everything the old check did and also staged changes after the pass and unrelated staged work. |
| Unrelated staged work preserved **through** the close | **Dropped, deliberately.** The close now stops on it and hands it to the user; unstaging it is not done by the agent, because staged and worktree content can differ. The tasks still keep such work out of their own commits, unchanged. |
| Post-close `git diff --quiet '<reviewed-headSha>' HEAD`; every mutation guarded; `git rev-parse --verify 'HEAD^'`; no `"` in the block; begins with `git`; no `wip` subject | **Kept.** Re-verified: six failure and success scenarios under `sh` and `dash`, and the hook in all four configurations. |
| Recovery `git reset --soft <reviewed-headSha>` after a failed commit | **Kept, and now true.** With no `--only`, a failed commit leaves the index untouched, so the soft reset restores the pre-close state exactly. |
| End-to-end table asserting the unrelated path stayed staged **through** a successful close | **Replaced** by two runs per route — index clean, and unrelated path staged — matching the new behaviour. |

**Scope:** the two Majors of pass 6. The twenty-six Minor and nine Nit findings stay collected.

## Accounting — what the pass-7 repair kept, moved and dropped

| Old condition | Fate |
|---|---|
| Pass-6 claim: the index guard "covers everything the old check did" | **Dropped as false.** A late WIP followed by restoring only the index passed it. The `HEAD`-tree guard from the pass-5 round is **restored** beside the index guard; each covers a state the other does not. |
| Pass-6 claim: after a failed commit `git reset --soft <reviewed-headSha>` "restores the pre-close state exactly" | **Dropped as false.** A pre-commit hook can stage changes and then fail. No fixed recovery command is promised; the instruction is to stop, inspect and surface. |
| The "final comparison should be unreachable" sentence | **Dropped** with the claim it supported; the post-close comparison itself is **kept**. |
| Canonical close, index guard, parent of the first WIP as reset target, no `"`, begins with `git` | **Kept.** Re-verified in eight scenarios under `sh` and `dash`, and through the hook in all four configurations. |

**Scope:** the two Majors of pass 7. The thirty Minor and ten Nit findings stay collected.

## Accounting — what the pass-8 repair changed

| Old condition | Fate |
|---|---|
| Task 2 Step 3: the success report token `created` | **Dropped — it contradicted the approved spec.** Spec §2 reports `written` throughout (`:92`, `:99`, `:230`). Reported by Codex as a Minor across passes; **upgraded to Major** under `CLAUDE.md`'s severity test, because the executor consumes this list and would author the command with the wrong output. Both occurrences now read `written`. |

**Scope:** that one finding. Pass 8 raised no Blocker and no Major of its own; the other thirty-one
Minor and ten Nit findings stay collected.

## Accounting — what the pass-9 repair kept, moved and dropped

| Old condition | Fate |
|---|---|
| `dg-parity.py`, `only-insert.py`, `tmpl-derive.py`: text-mode reads (`io.open` without `newline=""`, `git show` with `text=True`) | **Dropped.** They translated CRLF to LF, so a copy with different line endings compared equal while story criterion 5 and spec §7 rows 1, 4a and 4b require byte equality. Measured: each old script reported **OK** on a CRLF copy; each patched script reports **FAIL**. |
| `tmpl-derive.py` `norm()`: `.rstrip("\n")` on both sides | **Dropped.** It hid a differing number of trailing blank lines inside a template. Measured: an extra blank line before the §5 closing fence — old **OK**, new **FAIL**. |
| The prose describing these checks as "decoded text, not byte identity" | **Replaced.** That prose was accurate about the old scripts and is the reason pass 9 upgraded this: describing a weaker check accurately does not discharge a byte-equality requirement. The prose now states what the patched reads establish. |
| `85 lines, 3708 bytes` | **Kept, and its unit defined**: the payload between the fences joined with LF, without the LF before the closing fence (3709 with it). |
| Block definitions — the `Don't guess` block ends at the blank line after its last paragraph; trailing blank lines are popped from the §4 source block before insertion | **Kept.** They define the unit being compared, applied identically to every copy; they are not a loosening of the comparison. |
| Positive results on the real tree | **Re-run with the patched scripts:** `tmpl-derive.py negative` two `FAIL` and exit 0; `4a` `OK` exit 0; `only-insert.py` and `dg-parity.py` `OK` on a correct LF insertion. |

**Scope:** the one Major of pass 9. Its thirty Minor and eleven Nit findings stay collected.

## Accounting — what the pass-10 repair kept, moved and dropped

Pass 10 returned **nine** Majors, all of them findings collected as Minors in earlier passes and
re-rated after the gate prompt, from pass 9 on, stated `CLAUDE.md`'s instrument carve-out explicitly
("a check that can report success against a requirement it does not meet is not a Minor"). **None is
in text a previous repair wrote.** Each was reproduced before repair and re-run after it.

| Old condition | Fate |
|---|---|
| Task 5 Step 3 expected `6, 12, 3, 2, 7, 1` | **Corrected to `7, …`**: the probe counts occurrences, and one line carries `Gate A` twice. |
| `dg-parity.py`: first `### Don't guess` heading anywhere | **Dropped.** Exactly one heading per file is now required; an explanatory copy ahead of the shipped block makes the check fail instead of selecting it. |
| `tmpl-derive.py`: the no-§6 predicate printed but not part of the result | **Dropped.** It now contributes to the exit status. |
| Task 3: `grep -c 'claude-init'` per file | **Dropped.** Replaced by three matches on the required entries — table row, Python 3 disclosure in it, exact tree line. |
| `only-insert.py`: `remove_once` plus a placement scan that skipped blank lines | **Deleted.** Replaced by one equality against the single expected file — pre-task bytes with the block inserted after the existing blank line and followed by exactly one. Missing or doubled separators now fail. |
| Rows 4a and 4b as the only link between the three templates, with prose claiming they establish agreement | **Extended and re-described.** Row 4b also compares the shipped template directly with spec §5; the prose names which comparison ties which pair, and that Task 1's check must be current. |
| Task 2 Step 1: `test ! -e` | **Extended** with `test ! -L`; a dangling symlink now stops it. |
| `tmpl-derive.py`: any unrecognised mode ran nothing and exited 0 | **Dropped.** Unknown modes exit 2 before any comparison. |
| Task 2 Step 6: `… \| grep claude-init` | **Dropped.** `grep -Fx` on the exact product path; the plan's and the spec's own mentions no longer satisfy it. |

Verified: the three scripts as the plan now prints them — every positive case exit 0 on the real
tree or a correct construction, every counterfactual above non-zero; the three shell checks under
`sh` and `dash`, before, after and with an incidental mention.

**Scope:** the nine Majors of pass 10. Its twenty-one Minor and eleven Nit findings stay collected.

## Accounting — what the pass-11 repair kept, moved and dropped

| Old condition | Fate |
|---|---|
| `dg-parity.py`'s result described as "N copies identical", and Step 7 as discharging criterion 5 | **Narrowed, not extended.** The check establishes that the single block in each file is identical, and says so; **position** is row 4b's. Adding template-scoped extraction was the alternative and was declined: each extraction rule added in this cycle drew the next counterexample. Criterion 5 is now stated as discharged by the two checks together. |
| Task 3 tree check `grep -c 'commands/{…,claude-init}.md'` (regex, unanchored) | **Dropped.** Replaced by `grep -cxF` over the whole line, plus a count of the old tree line, which must reach `0`. Measured under `sh` and `dash`: the new line only in prose, and a `}Xmd` typo, both now fail. |
| Task 4: no post-edit read of the changelog | **Added** to Step 5: newest heading equals the manifest version, and the entry names both changes. Measured: before `## 0.11.0 0 0`; complete entry `## 0.12.0 1 1`; incomplete entry `## 0.12.0 0 0`. |

**Scope:** the three Majors of pass 11. Its twenty-two Minor and thirteen Nit findings stay collected.

## Accounting — what the pass-12 repair kept, moved and dropped

Both Majors of pass 12 were counterexamples to checks the pass-11 repair wrote. **The rule applied:
no further counting checks; compare against the one expected result**, the principle behind
`only-insert.py`, which has drawn no Major since it was introduced.

| Old condition | Fate |
|---|---|
| Task 3: whole-line fixed-string counts for the new and old tree lines | **Dropped.** Replaced by a comparison of the whole working-tree diff of the two layout files with the single expected diff — one line replaced in place in each. Measured under `sh` and `dash`: in place OK; line moved after the fence, an extra edit, a misspelling, and no change all fail. |
| Task 4: `sed` range over `## 0.12.0` headings | **Dropped.** It included the next heading and restarted on duplicates. Replaced by an `awk` that prints only the newest entry's body, plus a count requiring the `## 0.12.0` heading exactly once. Measured: empty entry with names in the next heading → body counts `0`; names only in a later duplicate → heading count `2`, body counts `0`. |
| Task 3: README row and Python 3 disclosure matches | **Kept.** Pass 12 raised nothing against them. |

**Scope:** the two Majors of pass 12. Its twenty-two Minor and thirteen Nit findings stay collected.

## Accounting — what the pass-13 repair kept, moved and dropped

**Method change, decided by Daniel on 2026-09-23 after pass 13:** each check claims only what its
command compares, and the remainder is carried by a **named reading check** — spec §7's own rule.
Byte comparisons the spec prescribes (rows 1, 4a, 4b) stay mechanical. The severity sentence the gate
prompt carried from pass 9 on is withdrawn: `CLAUDE.md`'s severity test sets a ceiling, not a floor.

| Old condition | Fate |
|---|---|
| Task 3 tree block's claim "nothing else changed" | **Narrowed.** It compares the text diff only; the claim now says so, and names file-mode and metadata changes as outside it. |
| Task 3 README greps presented as matching "the required entry" | **Narrowed**, and placement in the component table **moved to a named reading check** in Step 5. |
| Task 4 `grep -c '^## 0\.12\.0$'` presented as "occurs exactly once" | **Dropped.** Replaced by printing every release heading with `grep -n '^## '` and a **named reading check** for uniqueness in any spelling. |
| Task 4 newest-heading and newest-entry-body checks | **Kept.** Pass 13 raised nothing against them. |

**Scope:** the three Majors of pass 13, each disposed of individually. Its twenty-four Minor and
fourteen Nit findings stay collected.

## Self-review against the spec

**Story acceptance criteria, each to a task:**

| # | Criterion | Task |
|---|---|---|
| 1 | command file exists, inline, no manifest key | 2 (Steps 2–4, 6) |
| 2 | a new target receives `CLAUDE.md` and nothing else, where the operation is available | 2 (Step 3) · walkthrough in 5 (Step 2) |
| 3 | a repeated invocation adds no duplicate | 2 (Step 3) · walkthrough in 5 (Step 2) |
| 4 | no gate obligation, no dangling reference in the template | 2 (Step 6 spellings) · 5 (Step 2 semantics) |
| 5 | `Don't guess` byte-identical in all three copies | 1 (Steps 1–5) · 2 (Step 7, with row 4b for position) |
| 6 | the three inventory sites name the command | 3 |
| 7 | version bumped, changelog entry | 4 |
| 8 | battery green, twelve items answered | 5 |

**Spec sections, each to a task:** §1 → 2, 3, 4 · §2 → 2 · §3 → 2 (Step 4) · §4 → 1 · §5 → 2
(Step 4) · §6 → 2 (Step 2), 5 (Step 1) · §7 → distributed, rows named where they run · §8 → the
out-of-scope list above.

**Known gap, named rather than left to be discovered.** Spec §7 says nothing verifies the command's
**behaviour** in a target project, and this plan does not change that. Criteria 2 and 3 are answered
by a walkthrough of the text. Building a fixture harness would be a new mechanism and is out of
scope; if that trade is ever unacceptable, it is a scope decision to surface, not a step to add.
