# claude-session-tools

Search, reconstruct, and audit your Claude Code session history.

Claude Code stores full conversation history — including thinking blocks, tool calls, and pre-compaction transcripts — as JSONL files in `~/.claude/projects/`. These tools make that history queryable.

## Tools

### `cc-search` — search session history

```bash
# Find all writes to settings/config/memory files, grouped by file
cc-search settings --group

# Find writes to files matching a path pattern
cc-search writes CLAUDE.md
cc-search writes memory/

# Find tool calls by name
cc-search tools Bash --project xorq
cc-search tools Write --since 2026-02-01

# Full-text search across all messages (including thinking blocks)
cc-search text "pre-commit" --project xorq

# Filters available on all modes
--project NAME    # partial project name match
--since DATE      # e.g. 2026-03-01
--group           # group writes results by file path
--context         # show preceding user message for each result
--content         # show full content, not abbreviated
--output FILE     # write to file
```

### `transcript` — reconstruct full sessions

```bash
# List all sessions
transcript --list
transcript --list --project xorq

# Render a session (prefix match on session ID)
transcript abc123
transcript abc123 --thinking       # include thinking blocks
transcript abc123 --no-tools       # hide tool calls
transcript abc123 --output out.md  # save to file
```

### `/session-audit` skill

Once the plugin is installed, ask Claude to audit its own changes:

```
/session-audit
/session-audit --project xorq
/session-audit --since 2026-03-01
```

Claude will run `cc-search settings --group --context` and summarize the results as a per-file breakdown with when/what/why tables.

## Install

**Prerequisites:** Python 3.8+, no other dependencies.

```bash
git clone https://github.com/dlovell/claude-session-tools
cd claude-session-tools
make install          # copies bin/* to ~/.local/bin/
claude install .      # installs the session-audit skill
```

This installs to `~/.claude/` by default, which requires no PATH changes. To install elsewhere: `make install INSTALL_DIR=/usr/local/bin`.

## How it works

Claude Code appends every conversation turn to a JSONL file at:

```
~/.claude/projects/<project-name>/<session-id>.jsonl
```

Each line is a JSON record with `type` (`user`, `assistant`, `system`, `progress`). Assistant records contain `content` blocks of type `thinking`, `text`, or `tool_use`. Compaction events are marked with `subtype: compact_boundary` — but all pre-compaction messages remain in the file since it's append-only.

`cc-search` and `transcript` parse these files directly. No Claude API calls, no network access.

## Related projects

- [simonw/claude-code-transcripts](https://github.com/simonw/claude-code-transcripts) — HTML export
- [raine/claude-history](https://github.com/raine/claude-history) — fuzzy-search TUI (Rust)
- [daaain/claude-code-log](https://github.com/daaain/claude-code-log) — HTML index generator
