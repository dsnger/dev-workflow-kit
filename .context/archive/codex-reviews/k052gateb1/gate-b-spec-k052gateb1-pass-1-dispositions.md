1 | fixed | ci-switch.sh skips only the empty no-job line; a selected job with a null or empty check_run_url refuses 64 (tests for both); header says so
2 | fixed | local-ci.test.sh case 53b: an override through a symlinked grandparent waits on the real file's holder, then runs green
