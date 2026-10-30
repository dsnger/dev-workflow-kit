1 | fixed | T2: suite entry exports HOME=$work/home for every launch (go, direct and background launches incl. case 15) after unsetting the three lock variables
2 | fixed | every full battery run goes through local-ci.sh on a pushed head, so it holds the real heavy lock (intro, Long runs table)
3 | fixed | Long runs "Limits and cleanup": lock wait bounded apart (HEAVY_LOCK_WAIT_SECS=3600), 60-min battery limit from the holder note, INT to the holder (stops and reaps the group before release), never KILL first, failed removal runs the printed command, leftover check by group
4 | fixed | "Failures in one run": the all-failures claim removed; on a red, each remaining stage runs once separately with results recorded before the next full run
5 | fixed | "Budget": 2 planned, allowance 3 (105 min); a fourth moves the boundary to the close of the running Gate B cycle
6 | fixed | Actions outside the repository: the shared lock path and the gh status posts listed with their authority (the brief)
7 | fixed | new "Before the PR": fetch, rebase onto origin/main, reconcile, 0.52.0 only if 0.51 merged else ask the orchestrator, final run on the rebased head
8 | fixed | T1 names the four conditional steps and the unconditional ones
9 | fixed | Sources and impact boundary lists the changed suites and check-invariants.sh; untouched claim narrowed
