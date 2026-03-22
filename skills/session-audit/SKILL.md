---
name: session-audit
description: Analyze Claude Code session logs — file writes, settings changes, tool usage, skill invocations, token usage, or text search. Use when asked what changes were made, what tools were used, how tokens were spent, or to audit Claude's activity across sessions.
argument-hint: [MODE] [PATTERN] [--project PROJECT] [--since DATE] [--all]
user-invocable: true
---

Use the Agent tool to run this task in a subagent. The subagent should:

## 1. Determine the mode

Parse `$ARGUMENTS` to determine which cc-search mode to use. The first positional word (if it matches a mode name) selects the mode; otherwise default to `settings`.

| Mode | cc-search command | When to use |
|------|------------------|-------------|
| `settings` | `cc-search settings --group --context` | Default. Config/memory/settings file changes |
| `writes` | `cc-search writes --group --context` | All file writes (code, docs, configs) |
| `tools` | `cc-search tools` | Tool call frequency and patterns |
| `text` | `cc-search text PATTERN` | Search user/assistant messages for a keyword |
| `skills` | `cc-search skills` | Skill invocations with user prompts |
| `usage` | `cc-search usage` | Token usage per session |

Pass any remaining flags from `$ARGUMENTS` through (e.g. `--project`, `--since`, `--all`).

## 2. Run the command

```
python3 ~/.claude/cc-search <mode> [PATTERN] [flags] $ARGUMENTS
```

## 3. Summarize the results

Format depends on the mode:

### settings / writes (file-oriented)
- One section per file, headed with the file path, total modification count, and session slugs/IDs involved
- Under each section, a markdown table with columns: **#** | **Timestamp** | **What changed**
- The "What changed" column should be a concise description of the change, not raw content — use the `ctx:` field and the old/new values to infer *why* it was changed
- After the table, one sentence explaining the overall purpose of changes to that file
- Sort sections by modification count descending
- Omit files that are plans, drafts, or one-off notes (e.g. `claude-notes/`, `.bak` files, `plans/`) unless `$ARGUMENTS` includes `--all`

### tools
- Table with columns: **Tool** | **Call count** | **Sessions** | **Common patterns**
- Sort by call count descending
- Note any unusual tool usage patterns (e.g. high Bash usage, repeated failed calls)

### text
- Group matches by session
- For each session: slug/ID, then a bulleted list of matching excerpts (truncated to ~100 chars) with timestamps
- End with a one-sentence summary of the theme across matches

### skills
- Table with columns: **Skill** | **Invocation count** | **Sessions** | **Typical trigger**
- For each skill, list the user prompts that triggered it (truncated)

### usage
- Table with columns: **Session** | **Date** | **Total tokens** | **Tool calls** | **Duration**
- Sort by date descending
- End with aggregate totals

## 4. Return the full formatted summary as the agent's response.

This keeps the raw cc-search output (which can be 30KB+) out of the main conversation context.
