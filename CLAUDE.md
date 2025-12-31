# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code Plugin Marketplace** containing automation plugins. Plugin types include:
- **Infrastructure plugins**: Linux automation with Bash scripts (homeserver-gitops, ubuntu-dev-setup)
- **Knowledge plugins**: Skills-only plugins providing contextual guidance (ced)

## Architecture

```
.claude-plugin/marketplace.json  # Marketplace registry (name, owner, plugins[])
└── plugins/
    └── {directory-name}/
        ├── .claude-plugin/plugin.json  # Plugin manifest (name can differ from directory)
        ├── agents/                      # Natural language trigger definitions (.md)
        ├── commands/                    # Slash command definitions (.md)
        ├── skills/                      # Contextual knowledge (*/SKILL.md)
        ├── scripts/                     # Bash implementation scripts (.sh)
        ├── hooks/hooks.json             # Event-driven hooks
        ├── .mcp.json                    # MCP server configuration
        └── .lsp.json                    # LSP server configuration
```

**Flow**: User triggers command/agent → Command definition references script → Script executes with `${CLAUDE_PLUGIN_ROOT}` variable

## Development Commands

```bash
# Test locally - add this marketplace to Claude Code
/plugin marketplace add ./

# Install a specific plugin for testing
/plugin install homeserver-gitops@k-codepoet-plugins
/plugin install ubuntu-dev-setup@k-codepoet-plugins
/plugin install ced@k-codepoet-plugins

# Validate script syntax (from plugin directory)
bash -n scripts/*.sh
```

## Component Schemas

### marketplace.json
```json
{
  "name": "marketplace-name",           // Required
  "owner": { "name": "author-name" },   // Required
  "plugins": [{
    "name": "plugin-name",              // Required
    "source": "./plugins/plugin-name",  // Required
    "description": "..."                // Required
  }]
}
```

### plugin.json
```json
{
  "name": "plugin-name",                // Required (can differ from directory name)
  "version": "1.0.0",                   // Required
  "description": "Plugin description",  // Required
  "author": { "name": "author-name" },  // Required
  "keywords": ["tag1", "tag2"],         // Optional
  "commands": ["./commands/"],          // Optional - path or array of paths
  "agents": ["./agents/"],              // Optional - path or array of paths
  "skills": ["./skills/"]               // Optional - path or array of paths
}
```
Note: `name` in plugin.json determines the command prefix (e.g., `ced` → `/ced:help`), while directory name is just for organization.

### Commands (`commands/*.md`)
```yaml
---
name: command-name                      # Required
description: What the command does      # Required
allowed-tools: Read, Bash, Write        # Optional (defaults vary)
argument-hint: [-d directory]           # Optional
---
Command body with instructions...
```

### Agents (`agents/*.md`)
```yaml
---
name: agent-name                        # Required
description: When to trigger            # Required (detailed trigger conditions)
model: inherit                          # Optional: inherit|sonnet|opus|haiku
color: green                            # Optional
tools: ["Read", "Write", "Bash"]        # Optional
---
Agent instructions...

<example>
Context: ...
user: "..."
assistant: "..."
<commentary>Why this triggers the agent</commentary>
</example>
```
Note: `<example>` blocks belong in body, not frontmatter.

### Skills (`skills/*/SKILL.md`)
```yaml
---
name: skill-name                        # Required
description: What + when to use         # Required
---
Skill content...
```
Skills auto-activate based on context. Same content can exist as both command (explicit `/ced:skill-guide`) and skill (auto-triggered).

## Script Conventions

- All scripts are **idempotent** (skip already-installed components)
- Scripts perform **platform verification** at start (Linux Ubuntu/Debian only)
- Scripts use `set -e` for fail-fast behavior
- Output uses color-coded messages: green (success), yellow (warning), red (error)
- `${CLAUDE_PLUGIN_ROOT}` environment variable points to plugin root directory

## Adding New Plugins

1. Create `plugins/{plugin-name}/.claude-plugin/plugin.json`
2. Register in `.claude-plugin/marketplace.json`
3. Add commands in `commands/` with YAML frontmatter
4. Add implementation scripts in `scripts/`
5. Optionally add agents for natural language triggers
6. Optionally add skills for contextual knowledge
