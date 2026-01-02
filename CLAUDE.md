# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code Plugin Marketplace** (`k-codepoet/my-claude-plugins`) containing automation plugins. Plugin types include:
- **Infrastructure plugins**: Linux automation with Bash scripts (homeserver-gitops, ubuntu-dev-setup)
- **Knowledge plugins**: Skills-only plugins providing contextual guidance (ced, gemify)

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
# Add marketplace from GitHub (users)
/plugin marketplace add k-codepoet/my-claude-plugins

# Add marketplace locally (development)
/plugin marketplace add ./

# Install a specific plugin
/plugin install homeserver-gitops@k-codepoet-plugins
/plugin install ced@k-codepoet-plugins

# Validate script syntax (from plugin directory)
bash -n scripts/*.sh

# Validate plugin JSON schemas
cat plugins/*/.claude-plugin/plugin.json | jq .
cat .claude-plugin/marketplace.json | jq .
```

## Component Schemas

### marketplace.json

Required fields: `name`, `owner.name`, `plugins[].name`, `plugins[].source`, `plugins[].description`

```json
{
  "name": "k-codepoet-plugins",
  "owner": { "name": "choigawoon" },
  "plugins": [{
    "name": "plugin-name",
    "source": "./plugins/plugin-dir",
    "description": "Plugin description"
  }]
}
```
Note: `name` field becomes the install suffix (e.g., `plugin@k-codepoet-plugins`).

### plugin.json

Required: `name`, `version`, `description`, `author.name`
Optional: `keywords`, `commands`, `agents`, `skills` (paths or array of paths)

```json
{
  "name": "ced",
  "version": "1.0.0",
  "description": "Plugin description",
  "author": { "name": "author-name" },
  "keywords": ["tag1", "tag2"],
  "commands": ["./commands/"],
  "agents": ["./agents/"],
  "skills": ["./skills/"]
}
```
Note: `name` determines command prefix (e.g., `ced` → `/ced:help`), while directory name is just for organization.

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

### Skills (`skills/{skill-name}/SKILL.md`)
```yaml
---
name: skill-name                        # Required
description: What + when to use         # Required
---
Skill content...
```
Note: File must be named `SKILL.md` (uppercase) inside a directory matching the skill name.
Skills auto-activate based on context. Same content can exist as both command (explicit `/ced:skill-guide`) and skill (auto-triggered).

### Hooks (`hooks/hooks.json`)

Fields: `event` (PreToolUse | PostToolUse), `matcher` (tool name), `command` (shell command)

```json
{
  "hooks": [{
    "event": "PreToolUse",
    "matcher": "Bash",
    "command": "bash script.sh"
  }]
}
```

## Script Conventions

- All scripts are **idempotent** (skip already-installed components)
- Scripts perform **platform verification** at start (Linux Ubuntu/Debian only)
- Scripts use `set -e` for fail-fast behavior
- Output uses color-coded messages: green (success), yellow (warning), red (error)
- `${CLAUDE_PLUGIN_ROOT}` environment variable points to plugin root directory

## Available Commands & Skills Quick Reference

| Plugin | Commands | Skills (auto-activate) |
|--------|----------|------------------------|
| homeserver-gitops | `:init`, `:init-iac`, `:join-node`, `:snapshot`, `:restore`, `:help` | k3s-homeserver |
| ubuntu-dev-setup | `:setup-all`, `:setup-common`, `:setup-zsh`, `:setup-nvm`, `:help` | ubuntu-dev-environment |
| ced | `:create`, `:compose`, `:update`, `:validate`, `:howto`, `:help` | plugin-guide, command-guide, skill-guide, agent-guide, hook-guide, marketplace-guide, workflow-guide |
| gemify | `:inbox`, `:import`, `:draft`, `:library`, `:view`, `:capture-pair`, `:retro`, `:improve-plugin`, `:setup`, `:howto`, `:help` | inbox, import, draft, library, view, capture-pair, retro, improve-plugin |

Note: Commands are prefixed with plugin name (e.g., `/ced:help`, `/gemify:inbox`).

## Adding New Plugins

1. Create `plugins/{directory-name}/.claude-plugin/plugin.json`
2. Register in `.claude-plugin/marketplace.json` (source path uses directory name)
3. Add commands in `commands/` with YAML frontmatter
4. For infrastructure plugins: add implementation scripts in `scripts/`
5. For knowledge plugins: add skills in `skills/{skill-name}/SKILL.md`
6. Optionally add agents in `agents/` for natural language triggers

## Plugin Naming

- **Directory name**: Used for filesystem organization and `source` path in marketplace.json
- **Plugin name** (in plugin.json): Determines command prefix and install identifier
- Example: Directory `claude-extension-dev` has plugin name `ced`, so commands are `/ced:*` and install is `ced@k-codepoet-plugins`
