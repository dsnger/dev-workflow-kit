---
type: tool_used
tool: Bash
input_match: '"command"\s*:\s*"git commit(?: (?:-a|--all|-q|--quiet|--no-verify|-n|--amend|--allow-empty))* -m ''WIP: [^''\x5c;&|<>$`()"]+''(?: (?:-a|--all|-q|--quiet|--no-verify|-n|--amend|--allow-empty))*"'
---

The hook counts a WIP commit only when the whole Bash command is the commit (is_wip_message_cmd in
plugins/dev-workflow/hooks/codex-gate.sh): no chained `git add &&`, no second `-m`, no line break.
