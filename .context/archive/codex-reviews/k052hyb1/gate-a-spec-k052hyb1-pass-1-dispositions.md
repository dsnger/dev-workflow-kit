1 | fixed | AC-3 and §2.3 add the third hit line (new head after the switch, existing check run must pass, source restriction is the human's); §5 keeps the old local-path conditions
2 | fixed | §4 "Stop before release": holder runs the battery in its own process group, TERMs/KILLs and reaps it before exiting on a signal and at the normal end; SIGKILL of the holder stated as the limit; test added
3 | fixed | §4: SFX_HEAVY_HELD bypass only when non-empty; the holder sets SFX_HEAVY_HELD=<pid> for the child only; tests for non-empty, empty and the child's view
4 | fixed | §6: the suite unsets SFX_HEAVY_LOCK, SFX_HEAVY_HELD, HEAVY_LOCK_WAIT_SECS and sets HOME at its start; per-case values; a hostile-inheritance case
5 | fixed | §4 trust boundary: directory must exist, not a symlink, this user's, no group/other write; file regular, this user's, no group/other write; never created or repaired; tests
6 | fixed | AC-4 reworded (switch command: API also local; local-ci.sh: recorded state from the log); §2.2 says --lane never prints and names the stale-log case
7 | fixed | §2.1 re-read after the yes, changed state: not switched; no mutex, recorded under Decisions with the reason; remaining races stated in the docs
8 | fixed | §2.1 a failed PUT is followed by one read; target reached: logged with "reply failed, state read back"; else 75; test
9 | fixed | AC-1 and §2.2: writability checked before the question (64); a post-flip append failure is reported, flip stands, exit 0; tests
10 | fixed | §2.1 only active, disabled_manually, disabled_inactivity are states; anything else, empty or a failed read: 64; tests
11 | fixed | §1 "Library APIs" names the Context7 lookups (jobs, annotations, get/enable/disable); §2.3 takes the check run id from check_run_url
12 | fixed | §3 adds ci-switch.sh and its suite to the ci.yml lint and suites steps; §6 tests they appear
13 | fixed | §4 HEAVY_LOCK_WAIT_SECS must be a positive digit-only integer, default 7200, else 64 before waiting; tests for empty, abc, 0, inf
