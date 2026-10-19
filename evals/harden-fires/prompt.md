---
max_turns: 4
allowed_tools: [Read, Glob, Grep, Skill]
---

Codex Gate B just flagged the same finding again that we fixed two weeks ago: a shell script splices an unquoted path into a command. It keeps coming back. Make sure it never silently returns.
