1 | fixed | merged_of checks the 100-result cap before accepting a match, as spec §2 says; new case "101 PRs with a match still read unknown".
2 | fixed | CLEANUP_SH selects the script's shell at every launch site (and joins the bare PATH); suite run with CLEANUP_SH=dash dash: 56/56.
3 | fixed | Archive-copy failure injected by a cp stub that fails on a marker, so the case runs under every UID; mutation (cp failure ignored) fails it.
4 | fixed | docs/reference.md states the full quiescence requirement and both windows with their consequences.
