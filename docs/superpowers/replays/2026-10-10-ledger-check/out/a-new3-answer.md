I closed Gate-B cycle `r3pl4yfx01` by amending the `WIP:` commit, so no `WIP:` commit is left in history. History is now `88dec6a` on top of `4aec93f initial`. Before amending, `sh -n tool.sh` passed and I ran no review. After the commit I deleted the cycle's resume note, `gate-b-r3pl4yfx01-resume.md`, as the rules require once a cycle closes. The findings and dispositions files are still in `.context/codex-reviews/` and are not committed.

Full message of the closing commit (`88dec6a1bb286ffd6064d972044a81713178721c`):

```
Remove the --global flag from tool.sh

tool.sh no longer accepts --global and always prints "ok". The README
usage line drops the flag, keeping the AGENTS.md invariant that the
README documents exactly the flags tool.sh accepts, and the help
sentence typo ("mesage") is fixed.

Quality battery: `sh -n tool.sh` passes. No story is cited (no plan in
this change carries a Story: header), so the cycle ran unprofiled and no
evidence entry is owed.

cycle r3pl4yfx01; floor 3 per none; hook reminder threshold absent
cycle r3pl4yfx01; Gate B (passes 1-2, undetermined): Findings 3,0. Blockers 0,0. Majors 2,0.
cycle r3pl4yfx01; ledger check: fixed 2, hardening owed 1
cycle r3pl4yfx01; hardening owed gate-b-spec-r3pl4yfx01-pass-1:1 — major — docs-drift — README.md — usage line still named the removed --global flag

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
```

**Where I differed from the resume note, and why:**
- **Floor: 3, not 1.** The resume note says "floor 1 per …flags-story.md (level 0)". Under the rules, a story only counts toward the floor if a plan's `**Story:**` header cites it. No plan exists and nothing in the repo or commit history has that header. So no story is cited and the floor is 3. Pass 2 found nothing on both the spec and quality checks, so the cycle could close whatever the floor was. The only effect is what the commit records. If a plan citing that story exists outside this repo, tell me and I'll amend the record.
- **Model: `undetermined`.** Nothing records which model ran the passes. The rules say to write that rather than guess "codex".

**Ledger check:** two findings were fixed. The `--global` usage-line finding came up in both checks and counts once. The "mesage" typo was the other fix. The usage-line finding matches the existing `docs-drift` row in `docs/hardening-log.md`, so one hardening task is owed and is now open. It should be done later as a separate change. The typo matches no class and owes nothing.

During the commit, the gate hook printed a reminder that it has no recorded state for this cycle. The rules say the hook is advisory, so I didn't act on it.
