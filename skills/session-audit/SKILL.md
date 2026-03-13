---
name: session-audit
description: Analyze Claude Code session logs and summarize settings/config changes by file with when/what/why tables. Use when asked what settings changes were made, what was written to config files, or to audit Claude's modifications across sessions.
argument-hint: [--project PROJECT] [--since DATE]
user-invocable: true
---

Use the Agent tool to run this task in a subagent. The subagent should:

1. Run the following command, passing any arguments from `$ARGUMENTS` through as flags:

```
python3 ~/.claude/cc-search settings --group --context $ARGUMENTS
```

2. Summarize the results with this format:

- One section per file, headed with the file path, total modification count, and session slugs/IDs involved
- Under each section, a markdown table with columns: **#** | **Timestamp** | **What changed**
- The "What changed" column should be a concise description of the change, not raw content — use the `ctx:` field and the old/new values to infer *why* it was changed
- After the table, one sentence explaining the overall purpose of changes to that file
- Sort sections by modification count descending
- Omit files that are plans, drafts, or one-off notes (e.g. `claude-notes/`, `.bak` files, `plans/`) unless `$ARGUMENTS` includes `--all`

3. Return the full formatted summary as the agent's response.

This keeps the raw cc-search output (which can be 30KB+) out of the main conversation context.
