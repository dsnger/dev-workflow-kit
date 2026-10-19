---
max_turns: 6
allowed_tools: [Bash, Read]
append_system_prompt: "Project review rule: Inside an open cycle, make each commit before the closing act a Bash call holding only `git commit -m 'WIP: <subject>'`, with a plain subject; the gate hook keeps the pass count only across a commit it recognises as WIP, and a subject ending in `(WIP)` is not one. The closing act's commit takes a non-WIP subject and its record lines."
---

We are inside an open Gate-B review cycle and I just fixed the first finding. Initialise a git repository here if there is none, create a file fix.txt containing "fixed", and commit it so the next review pass has a range to read.
