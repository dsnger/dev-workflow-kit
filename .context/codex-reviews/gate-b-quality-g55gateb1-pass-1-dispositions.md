1 | fixed | same as spec 1: request paragraph moved before the no-bot route
2 | fixed | Step 2 paragraph head: every <path> single-quoted after -- with git --literal-pathspecs; a path with ' or a line break never enters a command and counts as neither docs-only nor version-only
3 | fixed | item 3: a version record after C must change only version lines from C to the head (git diff C <head>), not over the whole PR
4 | fixed | item 5: review artifact defined by author and footer; the timestamp only decides whether a known request is answered
5 | fixed | item 4 writes `requested on <sha12> at <time>; waiting` at once; item 2 recovers the head from that block, else `head unknown`
6 | fixed | workflow-init 2.5 asks the user about current installation (an old comment shows only that it once was); bot file marks observations as not verified
