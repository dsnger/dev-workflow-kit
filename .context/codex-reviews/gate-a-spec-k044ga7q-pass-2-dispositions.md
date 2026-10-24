1 | fixed | Mechanism shrunk: archive copy moved before the recheck (step 1), recheck then remove are adjacent; quiescence contract stated (caller closes sessions, nothing else checks out or moves branches); the two remaining windows named exactly, each between two adjacent git calls, with what each loses; no further machinery.
2 | fixed | -R github.com/<owner>/<repo>; GH_HOST named with GH_REPO; Sources note corrected (gh's override takes the default host otherwise).
3 | declined | Re-dispositioned at pass 3: P6 names /workflow-init Step 1's Codex-preflight health commands (claude mcp list / claude mcp get codex); the codex exec probe starts Codex from the user's own config as every gate call does. The exception added in pass 2 was deleted.
4 | fixed | Success = exit 0 plus OK; usage-limit / auth = missing access stop; other outcomes undetermined, settled by the first gate call; scenario walk extended.
5 | fixed | mkdir -p <main>/.context before reserving the leaf; test added.
6 | fixed | Added cp-failure case (worktree and branch stay, next row still removed, exit 1); other injected git failures are not added: git refuses on its own and the per-row stop is the same code path.
7 | fixed | Lock message names both causes and the manual recovery; never taken over silently; test asserts the message.
