# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code Plugin Marketplace** (`k-codepoet/my-claude-plugins`) containing automation plugins. Active plugins:
- **Knowledge plugins**: Skills-only plugins providing contextual guidance (forgeify, gemify, namify)
- **Product plugins**: Development environment and deployment automation (craftify)
- **Infrastructure plugins**: Linux/server automation with Bash scripts (terrafy)

Archived plugins (in `_archived/`): homeserver-gitops, ubuntu-dev-setup

## Architecture

```
.claude-plugin/marketplace.json  # Marketplace registry (name, owner, plugins[])
└── plugins/
    └── {directory-name}/
        ├── .claude-plugin/plugin.json  # Plugin manifest (name can differ from directory)
        ├── agents/                      # Natural language trigger definitions (.md)
        ├── commands/                    # Legacy slash commands (.md) - help/howto only
        ├── skills/                      # Contextual knowledge (*/SKILL.md)
        ├── scripts/                     # Bash implementation scripts (.sh)
        ├── hooks/hooks.json             # Event-driven hooks
        ├── principles/                  # Plugin design principles (.md)
        ├── assets/                      # Templates and examples
        └── templates/                   # Boilerplate templates
```

**Flow**: User triggers skill/command → Skill provides instructions + allowed-tools → Script executes with `${CLAUDE_PLUGIN_ROOT}` variable

## Development Commands

```bash
# Add marketplace from GitHub (users)
/plugin marketplace add k-codepoet/my-claude-plugins

# Add marketplace locally (development)
/plugin marketplace add ./

# Install a specific plugin
/plugin install forgeify@k-codepoet-plugins
/plugin install gemify@k-codepoet-plugins

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

Required: `name`
Recommended: `version`, `description`, `author.name`
Optional: `keywords`, `commands`, `agents`, `skills` (paths or array of paths)

```json
{
  "name": "forgeify",
  "version": "1.0.0",
  "description": "Plugin description",
  "author": { "name": "author-name" },
  "keywords": ["tag1", "tag2"],
  "commands": ["./commands/"],
  "agents": ["./agents/my-agent.md"],
  "skills": ["./skills/"]
}
```
Note: `name` determines command prefix (e.g., `forgeify` → `/forgeify:help`), while directory name is just for organization.

### Commands (`commands/*.md`)

Note: Commands are legacy. Skills (`skills/{name}/SKILL.md`) are preferred and support all the same frontmatter fields plus additional features. Commands are kept only for help/howto type content.

```yaml
---
description: What the command does      # Recommended
allowed-tools: Read, Bash, Write        # Optional (defaults vary)
argument-hint: [-d directory]           # Optional
name: custom-name                       # Optional (override filename)
hooks:                                  # Optional (PreToolUse, PostToolUse, Stop)
---
Command body with instructions...
```
Note: Command name defaults to filename. Use `name` field only to override.

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
allowed-tools: Read, Write, Bash        # Optional
argument-hint: "<name> [options]"        # Optional
disable-model-invocation: true           # Optional (manual-only)
---
Skill content...
```
Note: File must be named `SKILL.md` (uppercase) inside a directory matching the skill name. Skills auto-activate based on description context. Skills replace commands for all action functionality; commands are kept only for static help/tutorial content.

### Hooks (`hooks/hooks.json`)

Uses nested object structure with event types as keys:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/pre-bash.sh"
          }
        ]
      }
    ]
  }
}
```

Event types: `PreToolUse`, `PostToolUse`, `Stop`, `SessionStart`, `UserPromptSubmit`

Note: Only `type: "command"` is supported in plugin hooks. `type: "prompt"` is silently ignored.

## Script Conventions

- All scripts are **idempotent** (skip already-installed components)
- Scripts perform **platform verification** at start (Linux Ubuntu/Debian only)
- Scripts use `set -e` for fail-fast behavior
- Output uses color-coded messages: green (success), yellow (warning), red (error)
- `${CLAUDE_PLUGIN_ROOT}` environment variable points to plugin root directory

## Plugin Discovery

Commands are prefixed with plugin name (e.g., `/forgeify:help`, `/gemify:inbox`).

```bash
# List all installed plugins
/plugin list

# Check plugin version
cat plugins/<name>/.claude-plugin/plugin.json | jq -r '.name, .version'
```

To find available commands/skills for a plugin, check:
- `plugins/<name>/skills/*/SKILL.md` for slash commands and auto-activating skills
- `plugins/<name>/commands/*.md` for help/tutorial commands (legacy)
- `plugins/<name>/agents/*.md` for natural language triggers

## Version Bumping

When updating a plugin, bump the version in `.claude-plugin/plugin.json`:
```bash
# Check current version
cat plugins/<name>/.claude-plugin/plugin.json | jq -r '.version'

# Update version (semantic versioning: major.minor.patch)
# - patch: bug fixes
# - minor: new features, backward compatible
# - major: breaking changes
```

## Validation

Use the validation script for comprehensive checks:
```bash
# Validate a specific plugin (recommended)
./plugins/forgeify/scripts/validate-plugin.sh plugins/<name>

# Quick manual checks
cat plugins/<name>/.claude-plugin/plugin.json | jq .
cat .claude-plugin/marketplace.json | jq .
bash -n plugins/<name>/scripts/*.sh  # if scripts exist
```

The validation script checks:
- plugin.json schema and required fields
- SKILL.md naming (uppercase, in `skills/{skill-name}/SKILL.md`)
- Path references in plugin.json
- Command frontmatter presence

## Adding New Plugins

1. Create `plugins/{directory-name}/.claude-plugin/plugin.json`
2. Register in `.claude-plugin/marketplace.json` (source path uses directory name)
3. Add skills in `skills/{skill-name}/SKILL.md` with YAML frontmatter
4. For infrastructure plugins: add implementation scripts in `scripts/`
5. Optionally add agents in `agents/` for natural language triggers

## Plugin Naming

- **Directory name**: Used for filesystem organization and `source` path in marketplace.json
- **Plugin name** (in plugin.json): Determines command prefix and install identifier
- Example: Directory `forgeify` has plugin name `forgeify`, so commands are `/forgeify:*` and install is `forgeify@k-codepoet-plugins`
