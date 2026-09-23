---
description: Write one CLAUDE.md of general working rules into a project — no review gates, no other files
---

Write a `CLAUDE.md` of general working rules into the current project: think before coding,
simplicity, surgical changes, goal-driven execution, and not guessing. This is the lighter entry
point beside `/dev-workflow:workflow-init` — it installs no review gates and writes no other file.

Target model: Claude via Claude Code. This command is a prompt artifact and follows
the dev-workflow prompt checklist (`docs/prompt-standards.md` in the dev-workflow-kit repository).

## Context

- **The only file this command writes is `CLAUDE.md`**, in the current directory. No marker, no
  README note, no `AGENTS.md`, no `.context/`, no commit — the user asked for one file, and every
  extra file is something they did not ask to own.
- **It needs nothing a directory does not have, with one exception.** No git repository, no plugin,
  no MCP server, no package manager. Reading and proposing work anywhere. **Creating** the file needs
  a Python 3 that is already installed, because that is where the one safe create operation lives
  (see *Writing*). Where it is missing, the command stops instead of writing some weaker way.
- **It is an entry point, never an exit.** Where a `CLAUDE.md` already carries review gates — a
  `Cross-Model Review` section, Gate A / Gate B — they stay exactly as they are. This command never
  removes, disables, weakens or renumbers a gate, because a project that has gates chose them.

## Done means

- Exactly **one** report state from *Report* below was printed, and it describes what you
  **observed**, not what you expected.
- At most one file changed on disk: `CLAUDE.md`, and only when it did not exist before.
- An existing `CLAUDE.md` is byte-for-byte what it was before the command ran.

## Step one — what kind of path is `CLAUDE.md`?

Ask this before looking at any content: a path that cannot be classified safely must never reach a
content decision. Run:

```sh
ls -ld CLAUDE.md
test -L CLAUDE.md && echo symlink
test -r CLAUDE.md && echo readable
```

Test for a symlink **first**. `test -e` and `test -f` follow links, so a dangling link would read as
"absent" and the create would write through it into another place.

| What you observe | Do this |
|---|---|
| Nothing at the path — `ls` reports no such file, and it is not a symlink | Go to step two, **absent**. |
| A regular file you can read | Go to step two, **present**. |
| A symlink, working or dangling | Stop. Write nothing. Report the path and where it points. |
| A directory, or any other non-regular file | Stop. Write nothing. Report what `ls -ld` showed. |
| A file you cannot read | Stop. Write nothing. Report the read error. |

Each stop is reported as its own row, because each has a different fix (see *Report*).

## Step two — what does it contain?

| Found | Do this |
|---|---|
| **Absent** | Create it — see *Writing*. |
| **Present, and its rules say the same as the template** | Report `unchanged`. Add nothing, so a second run never duplicates a rule. |
| **Present, with different or partly overlapping rules** | Show a **focused proposed diff** — only the sections that differ — and ask. Whatever the answer, hand the proposed result back and **stop without writing**. |

**Judge equivalence by reading.** Rules that say the same thing in other words are equivalent; say
which sections you matched with what. There is no checksum behind this judgement, so state it as
yours.

**A proposal keeps everything a careful edit would keep.** Unrelated project content stays. Existing
mandatory rules and any review gates stay, unchanged and in place — the proposal only adds or aligns
the general rules. The user applying it themselves does not make a harmful proposal acceptable.

**Approval opens no write path.** This command never writes over an existing `CLAUDE.md`, because
the person being asked may be editing that same file while they read the proposal, and nothing
available here can detect that in time. After approval, report `proposal produced` and stop; never
describe the proposal as applied, and never write it through any other tool.

## Writing — the create branch only

1. **Fill in `<project>`** in the template's first line with the current directory's name, unless the
   user named the project.
2. **Re-run step one immediately before creating.** If anything is now at the path, report what
   appeared as `stopped: create refused` and stop. This gives a better report; it is not the guard.
3. **Check for Python 3:** `command -v python3 && python3 --version`. No `python3`, or a version
   below 3 → report `stopped: no qualifying create operation` and stop. Do not fall back to a shell
   redirect or your file-writing tool: neither refuses an existing destination of every kind, and a
   `set -C` redirect can hang on a FIFO.
4. **Create through an exclusive open**, with the command below.
5. **Report only what the script printed and what `ls -ld CLAUDE.md` shows afterwards.** A partial
   file is left as it is — do not delete it and do not retry into it. If the command fails before the
   script prints anything — for example the shell cannot create the here-document — report
   `failed: create write` with the shell's error text and the path's state afterwards.

The create command passes the filled-in template on standard input. Run it exactly as shown, with
no added indentation: the script and the closing `CLAUDE_INIT_TEMPLATE` line must start in the
first column. The `O_CREAT | O_EXCL` open refuses any existing destination — file, directory, FIFO,
device, and a symlink whether or not it resolves — and that refusal is the guard. Mode `0o644` is
passed explicitly because the default `0o777` makes the file executable.

```sh
python3 -c '
import os, sys
path = sys.argv[1]
data = sys.stdin.buffer.read()
try:
    fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o644)
except FileExistsError:
    print("stopped: create refused (EEXIST)"); sys.exit(3)
except OSError as e:
    print("failed: create write (open: %s)" % e.strerror); sys.exit(4)
done = 0
err = None
try:
    while done < len(data):
        done += os.write(fd, data[done:])
except OSError as e:
    err = e
try:
    os.close(fd)
except OSError as e:
    err = err or e
if err is not None:
    print("%s (%d of %d bytes: %s)" % ("failed: partial write" if done else "failed: create write", done, len(data), err.strerror)); sys.exit(5)
try:
    with open(path, "rb") as f:
        same = f.read() == data
except OSError as e:
    print("failed: partial write (read-back failed after %d of %d bytes: %s)" % (done, len(data), e.strerror)); sys.exit(5)
print("written (%d bytes)" % len(data) if same else "failed: partial write (read-back differs)")
sys.exit(0 if same else 5)
' CLAUDE.md <<'CLAUDE_INIT_TEMPLATE'
<the template below, with <project> filled in>
CLAUDE_INIT_TEMPLATE
```

The exclusive open makes creating the **directory entry** exclusive. It does not make writing the
bytes atomic, so a write can fail part-way; the read-back at the end is what observes a complete
write.

## Report

Print one of these eight states, then the details. Example of the ordinary case:

```
claude-init: written
  path:    /home/ana/projects/atlas/CLAUDE.md
  created: 3705 bytes, -rw-r--r--
  project: atlas (directory name)
```

| State | Meaning | Causes, the check that tells them apart, and the fix |
|---|---|---|
| `written` | The file was created and read back identical. | — |
| `unchanged` | An existing `CLAUDE.md` already carries equivalent rules. | Name the sections matched. |
| `proposal produced` | An existing file differs; the proposal was shown. Approved or declined, nothing was written. | The user applies it themselves if they want it. |
| `stopped: path kind` | Step one found an unsafe path. | **Symlink** (`ls -ld` starts with `l`): replace or remove the link, then rerun. **Directory or other type** (`d`, `p`, `c`, `b`, `s`): move it aside. **Unreadable** (`test -r` fails): fix its permissions. |
| `stopped: no qualifying create operation` | No usable Python 3. | `command -v python3` prints nothing → install Python 3, or create the file by hand from the template. It prints a path but `python3 --version` fails or is below 3 → fix that installation. |
| `stopped: create refused` | Something appeared at the path after step one. | Seen at the re-read, or `EEXIST` from the exclusive open. Run the command again; it will take the content branch. |
| `failed: create write` | The create failed and no template bytes were written. | Report the error text. `EACCES` → the directory is not writable (`test -w .`). `EROFS` → read-only filesystem. `ENOSPC` → disk full (`df .`). Other errors are possible; report them as printed. Report whether the open succeeded, and `ls -ld CLAUDE.md` afterwards — an empty file may exist. |
| `failed: partial write` | The open succeeded, but a complete write was not observed: only part of the template was written, closing the file failed, or reading it back failed or differed. | Report the byte counts and the error. `ENOSPC` → disk full (`df .`), the common cause of a short write. A read-back `Permission denied` → the file's mode leaves it unreadable, usually a restrictive `umask` (`ls -ld CLAUDE.md`). The file stays; the user checks or removes it before rerunning. |

If the path's state afterwards cannot be inspected, say so in the report rather than guessing it.

## Stop and ask

- Before writing anything, if the user wants more than the general rules — gates, an `AGENTS.md`,
  or a merge into an existing file. Point them to `/dev-workflow:workflow-init` for gates.
- After a proposal: always, whatever the answer.
- On every `stopped:` and `failed:` state: report and stop; the fix is the user's.

## The template

The complete file content. `<project>` is filled in at write time; everything else is written as it
stands.

> **Prompt-standards item 1 for the written `CLAUDE.md`: n/a, and why.** The file this
> template writes is model-agnostic by design — its executing model is whatever the reader of
> that project runs — so a `Target model:` line inside it would be false in every project it
> lands in. Recorded as a reasoned n/a rather than skipped: the item is answered. **This note sits
> outside the fence** so it is never written, and is deliberately **not** a `Target model:` line,
> which would make this file's declaration count 2 and fail `scripts/check-invariants.sh`.

````markdown
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
