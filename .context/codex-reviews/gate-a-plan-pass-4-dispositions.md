# Gate A — plan — pass 4 dispositions — **STOPPED, oscillation rule fired**

15 findings (1 BLOCKER, 10 MAJOR, 4 MINOR). **None dismissed. None applied.**

Stopped under the exit Daniel pinned for this cycle: *"oscillation past pass 4 stops and
surfaces with the trend."*

## The trend

| Pass | 1 | 2 | 3 | 4 |
|---|---|---|---|---|
| Findings | 18 | 20 | 17 | **15** |
| Blockers | 1 | 0 | 1 | **1** |

Findings drift down slowly. **Blockers keep coming back, and both recent ones were introduced
by the previous pass's fix, in the same thirty lines of `awk`:**

- **Pass 3's blocker** — the fixtures opened their fenced template with `# Command` while the
  parser required `# <project>`. Introduced by *pass 2's* fence-anchoring fix.
- **Pass 4's blocker** — fence mode counts `ends` on every closing fence after the region
  opens, so on the real `workflow-init.md` it returns `MULTIEND` with `ends=7` and **4c can
  never pass**. Introduced by *pass 3's* MULTIEND-reachability fix. Confirmed independently:
  13 fence lines follow §5 in that file, so `ends > 1` is certain.

That is fix-of-fix oscillation on a fixed surface, which is the stop condition.

## Where pass 4's findings actually live

| Area | Findings | Count |
|---|---|---|
| 4c's `awk` region parser and its fixtures | 1, 2, 3, 4, 5, 15 | 6 |
| The two temp-tree shell recipes (mutation, counterfactual) | 8, 9, 10, 11, 12 | 5 |
| `WIP_PARENT` plumbing | 6, 14 | 2 |
| Prose placement of the §2.1 block | 7 | 1 |
| `todos.md` row text | 13 | 1 |

**Eleven of fifteen are in shell embedded in a plan document** — roughly eighty lines of `awk`
and `sh` that nobody has run, being reviewed by reading. Pass 4's findings are the kind a
tool answers instantly: `shellcheck` finds the unguarded pipeline (8) and the trap
reassignment (10); running the fixture suite finds the unreachable `case` branch (2), the
inventory that does not match the literals (3), and the parser returning `MULTIEND` on the real
file (1) — which is exactly how Codex found it.

**This is the spec cycle's lesson recurring one level down.** Design §1.6 records it: *a spec
must not ask mechanical questions about artifacts only humans read.* The plan's inverse is
asking a **reader** to decide questions a **machine** settles — and the review is doing that
job badly and expensively, four passes running.

## The simplification that removes the subject matter

The whole region-bounding apparatus — fence nesting, template anchoring, `ends` counting,
`NOSTART`/`MULTISTART`/`NOEND`/`MULTIEND` — exists to stop an occurrence in surrounding command
prose from satisfying the check. **Requiring the canonical line to appear exactly once in each
whole file achieves the same thing with `grep -c`**: an occurrence in the wrong place makes the
count 2 and fails, and there is no parser to get wrong. Six lines instead of thirty, and
findings 1, 2, 3, 5 and 15 stop existing rather than being fixed.

The cost is a real contract change, so it is Daniel's call, not mine: spec §5.2 currently says
*"occurrences outside the region are ignored"*, and whole-file counting makes them fatal. That
is **stricter**, not weaker — but it is different, and it needs a one-line spec amendment
rather than a quiet reinterpretation.

## Status

Stopped and surfaced. Nothing applied from pass 4. The plan is uncommitted in the working
tree at its post-pass-3 state.
