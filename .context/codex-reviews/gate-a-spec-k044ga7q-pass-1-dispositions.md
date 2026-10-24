1 | fixed | §2 "--remove" step 1 rechecks branch, tip, dirty, ignored and a fresh lsof right before acting; step 4 uses atomic `git update-ref -d <ref> <oldtip>` after a checkout check; a mkdir lock serialises cleanup runs; the residual one-call race is stated; tests for session-appears and branch-moved added.
2 | fixed | §2 session: lsof missing, non-zero exit, or no n/ line → unknown; visibility scope (processes lsof can see) stated; fixtures for exit 1 and empty output added.
3 | fixed | New `ignored` field (git status --ignored=matching, outside .context/); removable requires 0 unless --discard-ignored; decision 1d; tests added.
4 | fixed | Archive dir reserved with mkdir (atomic, does not follow an existing symlink), numeric suffix on EEXIST, mkdir/cp failure keeps the worktree; the run lock covers concurrent runs; suffix test added.
5 | fixed | gh gets -R <owner>/<repo> parsed from origin and --base <default branch>; GH_REPO test added; non-origin / non-github remotes read unknown.
6 | declined | gh, lsof, mkdir, cp are system tools addressed by name like git, dash and python3 (AGENTS.md § Commands prerequisites); invariant 5's stated scope is CI actions, npm packages, Docker images and MCP servers; both optional tools are stubbed in the suite. §2 "Executed tools" records this and the prerequisites paragraph will name them.
7 | fixed | Main worktree = first porcelain entry; bare → exit 2 before anything else; test added. (separate-git-dir: the first entry is still the main worktree.)
8 | fixed | One-direction safety claim removed; the report states ancestor means contained in the local default ref, stale in either direction.
9 | fixed | Root is strictly a descendant; test uses the parent as --root and asserts the path itself as --root is kept.
10 | fixed | `.gitmodules` in the worktree → keep; test added.
11 | fixed | Sources note names lsof 4.91 man page, git help pages and Codex CLI (Context7 /openai/codex/rust-v0.155.1 plus local --help fallback for 0.162.1).
12 | fixed | Preflight: success = reply holding OK; every other outcome listed as missing access with quote and home; empty CODEX_HOME means ~/.codex; two-minute bound via the Bash timeout.
13 | fixed | --limit 100; exactly 100 results → unknown; test added.
14 | fixed | Plan step 3/4: 12-item prompt-standards read recorded in the PR body, scenario walk for preflight replies and long-run cases; eval scope stated.
