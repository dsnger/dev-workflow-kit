1 | fixed | baseRefName checked against ^[A-Za-z0-9._/-]+$ and SHAs against ^[0-9a-f]{40}$ before the command; failure runs nothing and counts as changed
2 | fixed | --stable replaced by --verbatim (scratch test: indentation-only change gives a new id); spec, story (dated narrowing), reference, CHANGELOG updated
3 | fixed | same as spec slot 1: pr-review-bots.md lines scoped
4 | fixed | label lookup is gh pr view <n> --json labels for the PR this run processes
5 | fixed | Step 4 says the base update itself needs no Gate B; a fix a later claim needs still follows Step 3 item 3
