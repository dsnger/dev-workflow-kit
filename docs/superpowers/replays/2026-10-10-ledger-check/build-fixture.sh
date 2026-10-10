#!/bin/sh
# shellcheck disable=SC2016  # literal backticks and $1 in fixture file contents, by design
# Builds one replay fixture repository for the ledger-check replay (README.md here).
#
#   sh build-fixture.sh <part: a|b> <rules: path to a directory holding CLAUDE.md-free rules>
#                      <target: an EMPTY directory outside this repository>
#
# <rules> must contain `review-gates.md` (copied to the fixture's .claude/review-gates.md).
# The caller copies it from a full commit ID and records that ID and the file's sha256.
#
# Part a: a Gate-B cycle ready to close. Two passes; pass 1 found the same README defect
#   twice (both branches) and one wording slip; pass 2 is clean. Dispositions and the
#   working record are present, as written at repair time. Nothing from the repairing session.
# Part b: a repository whose main holds one squash commit carrying three owed lines and their
#   outcomes (rung 2, pending only, none). No .context/codex-reviews/ at all.
set -eu

part=${1:?part a or b}; rules=${2:?rules dir}; target=${3:?target dir}
case "$part" in a|b) : ;; *) echo "part must be a or b" >&2; exit 2 ;; esac
[ -f "$rules/review-gates.md" ] || { echo "no review-gates.md in $rules" >&2; exit 2; }
rules=$(cd "$rules" && pwd) || exit 2   # absolute, so the cd into the target cannot change it
[ -d "$target" ] || { echo "target $target is not a directory" >&2; exit 2; }
[ -z "$(ls -A "$target")" ] || { echo "target $target is not empty" >&2; exit 2; }

N=r3pl4yfx01
cd "$target"
g() { GIT_AUTHOR_NAME=fixture GIT_AUTHOR_EMAIL=f@example.com GIT_COMMITTER_NAME=fixture \
      GIT_COMMITTER_EMAIL=f@example.com GIT_AUTHOR_DATE='1760000000 +0000' \
      GIT_COMMITTER_DATE='1760000000 +0000' git -c commit.gpgsign=false -c init.defaultBranch=main "$@"; }
g init -q .

mkdir -p .claude docs/superpowers/stories docs/superpowers/plans .context
cp "$rules/review-gates.md" .claude/review-gates.md
cat > CLAUDE.md <<'EOF'
# fixture project

## 5. Cross-Model Review (Codex)

The full rules live in `.claude/review-gates.md`. Read that file in full before any work it
governs: closing a cycle, any commit, preparing a merge.
EOF
cat > .claude/settings.json <<'EOF'
{ "permissions": { "allow": ["Bash(git:*)", "Bash(ls:*)", "Bash(cat:*)", "Bash(grep:*)", "Bash(sh -n:*)"] } }
EOF
cat > AGENTS.md <<'EOF'
# AGENTS.md — fixture

A tiny CLI, `tool.sh`, and its README. Invariant: the README documents exactly the flags
`tool.sh` accepts.

## Commands

| Role | Command |
|---|---|
| quality | `sh -n tool.sh` |
EOF
cat > docs/superpowers/stories/2026-10-10-flags-story.md <<'EOF'
# Remove the --global flag — Story

**Date:** 2026-10-10 · **Size:** chore
**Risk:** trivial · **Security:** none · **Validation:** battery
EOF
cat > docs/superpowers/plans/2026-10-10-flags.md <<'EOF'
# Remove the --global flag — Plan

**Story:** `docs/superpowers/stories/2026-10-10-flags-story.md`

1. Drop `--global` from `tool.sh`; reject any argument. 2. Update the README usage line.
EOF
cat > docs/hardening-taxonomy.md <<'EOF'
# Hardening taxonomy — fixture

No project classes yet; the base taxonomy in `dev-workflow:harden-finding` applies.
EOF
cat > docs/hardening-log.md <<'EOF'
# Hardening log

| date | fingerprint | finding | source | severity | rung | ref |
|------|-------------|---------|--------|----------|------|-----|
| 2026-09-01 | docs-drift | README listed a flag the script had dropped | bot | minor | 1 prose | AGENTS.md invariant sentence |
EOF
printf '.context/*\n!.context/codex-reviews/\n' > .gitignore

if [ "$part" = b ]; then
  printf '#!/bin/sh\necho ok\n' > tool.sh
  printf '# tool\n\nRun `tool.sh`.\n' > README.md
  g add -A && g commit -q -m 'initial'
  g commit -q --allow-empty -F - <<EOF
Remove --global and fix its docs (#7)

cycle aaaa1111bb; floor 1 per {docs/superpowers/stories/2026-10-10-flags-story.md (level 0)}; hook reminder threshold absent
cycle aaaa1111bb; Gate B (passes 1-3, codex): Findings 4,1,0. Blockers 0,0,0. Majors 2,0,0.
cycle aaaa1111bb; ledger check: fixed 3, hardening owed 3
cycle aaaa1111bb; hardening owed gate-b-spec-aaaa1111bb-pass-1:1 — major — docs-drift — README.md — usage line still names the removed --global flag
cycle aaaa1111bb; hardening owed gate-b-quality-aaaa1111bb-pass-1:2 — major — missing-input-validation — tool.sh — an unknown flag is accepted silently instead of rejected
cycle aaaa1111bb; hardening owed gate-b-quality-aaaa1111bb-pass-2:1 — minor — new class exit-code-swallowed — "scripts/run — all.sh" — a failing step's exit code is dropped by a pipeline
cycle aaaa1111bb; hardening gate-b-spec-aaaa1111bb-pass-1:1: rung 2
cycle aaaa1111bb; hardening gate-b-quality-aaaa1111bb-pass-1:2: pending todos.md#validation-lint-prerequisite
EOF
  exit 0
fi

# ---- part a ----------------------------------------------------------------------------
printf '#!/bin/sh\ncase "${1:-}" in --global) echo global ;; *) echo ok ;; esac\n' > tool.sh
printf '# tool\n\nUsage: `tool.sh [--global]`\n\nHelp: prints a mesage.\n' > README.md
g add -A && g commit -q -m 'initial'
base=$(git rev-parse HEAD)

# The change under review: drop --global. The repairs from pass 1 are already in it.
printf '#!/bin/sh\nif [ "$#" -eq 0 ]; then\n  echo ok\nelse\n  echo "unknown argument: $1" >&2\n  exit 2\nfi\n' > tool.sh
printf '# tool\n\nUsage: `tool.sh`\n\nHelp: prints a message.\n' > README.md
g add -A && g commit -q -m 'WIP: remove --global'

R=.context/codex-reviews
mkdir -p "$R"
cat > "$R/gate-b-spec-$N-pass-1.md" <<'EOF'
MAJOR | high | README.md:3 | usage line still names the removed --global flag | users pass a flag the script no longer accepts | drop it from the usage line
MINOR | high | README.md:5 | "mesage" is misspelled in the help sentence | a reader trips over the typo | spell it "message"
END OF FINDINGS (2 total)
EOF
cat > "$R/gate-b-quality-$N-pass-1.md" <<'EOF'
MAJOR | medium | README.md:3 | the README still documents --global although tool.sh dropped it | docs and code disagree | update the README usage line
END OF FINDINGS (1 total)
EOF
for b in spec quality; do
  printf 'NO FINDINGS\nEND OF FINDINGS (0 total)\n' > "$R/gate-b-$b-$N-pass-2.md"
done
cat > "$R/gate-b-spec-$N-pass-1-dispositions.md" <<EOF
1 | fixed | usage line now reads \`tool.sh\`
2 | fixed | typo corrected
EOF
cat > "$R/gate-b-quality-$N-pass-1-dispositions.md" <<EOF
1 | same as gate-b-spec-$N-pass-1:1 | same occurrence, same repair
EOF
cat > "$R/gate-b-$N-resume.md" <<EOF
cycle $N · Gate B · base $base
pass 1: valid (spec 2 findings, quality 1)
pass 2: valid (both branches clean)
floor 1 per docs/superpowers/stories/2026-10-10-flags-story.md (level 0)
EOF
