# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Claude Code Plugin Marketplace** containing Linux automation plugins. Plugins automate infrastructure and development environment setup through slash commands and natural language agents.

## Architecture

```
.claude-plugin/marketplace.json  # Marketplace registry (name, owner, plugins[])
└── plugins/
    └── {plugin-name}/
        ├── .claude-plugin/plugin.json  # Plugin manifest
        ├── agents/                      # Natural language trigger definitions
        ├── commands/                    # Slash command definitions
        ├── scripts/                     # Bash implementation scripts
        └── skills/                      # Contextual knowledge for AI
```

**Flow**: User triggers command/agent -> Command definition references script -> Script executes with `${CLAUDE_PLUGIN_ROOT}` variable

## Component Frontmatter Reference

### marketplace.json (필수 필드만)
```json
{
  "name": "marketplace-name",
  "owner": { "name": "author-name" },
  "plugins": [
    { "name": "plugin-name", "source": "./plugins/plugin-name", "description": "..." }
  ]
}
```

### plugin.json
```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Plugin description",
  "author": { "name": "author-name" },
  "keywords": ["tag1", "tag2"],
  "commands": ["./commands/"],
  "agents": ["./agents/"],
  "skills": ["./skills/"]
}
```

### Commands (`commands/*.md`)
```yaml
---
name: command-name
description: Short description of what the command does
allowed-tools: Read, Bash, Write, Glob, Grep
argument-hint: [-d directory]  # Optional
---
```

### Agents (`agents/*.md`)
```yaml
---
name: agent-name
description: When to trigger this agent
model: inherit  # or: sonnet, opus, haiku
color: green
tools: ["Read", "Write", "Bash", "Glob", "Grep"]
---

Agent instructions here...

## Trigger Examples

<example>
Context: ...
user: "..."
assistant: "..."
<commentary>...</commentary>
</example>
```
Note: `<example>` blocks should be in the body, not frontmatter.

### Skills (`skills/*/SKILL.md`)
```yaml
---
name: skill-name
description: When Claude should use this skill (무엇을 하는지 + 언제 사용하는지)
---
```
Skills provide contextual knowledge that Claude auto-activates based on user queries.

## Plugins

### homeserver-gitops
K3s Kubernetes cluster + IaC repository setup for Ubuntu homeservers.

**Commands**:
- `/homeserver-gitops:init` - Full K3s + IaC setup
- `/homeserver-gitops:init-iac` - IaC directory only (no K3s)
- `/homeserver-gitops:snapshot` - Export cluster state to manifests
- `/homeserver-gitops:restore` - Restore from saved manifests
- `/homeserver-gitops:join-node` - Add worker nodes
- `/homeserver-gitops:help` - Show help

**Agent**: `homeserver-setup` - Triggered by "홈서버 구축", "K3s 설치", "IaC 초기화" etc.

**Skill**: `k3s-homeserver` - K3s 설치 및 IaC 관리 지식 제공

### ubuntu-dev-setup
Ubuntu/Debian development environment automation.

**Commands**:
- `/ubuntu-dev-setup:setup-all` - Complete setup (common + zsh + nvm)
- `/ubuntu-dev-setup:setup-common` - Essential packages only
- `/ubuntu-dev-setup:setup-zsh` - Zsh + Oh My Zsh + Powerlevel10k
- `/ubuntu-dev-setup:setup-nvm` - NVM installation
- `/ubuntu-dev-setup:help` - Show help

**Agent**: `ubuntu-dev-setup` - Triggered by "개발환경 설정", "zsh 설치", "nvm 설정" etc.

**Skill**: `ubuntu-dev-environment` - 개발환경 설정 지식 제공

### claude-extension-dev
Claude Code 확장 개발 한국어 가이드. Skills로 제공되어 Claude가 자동 활성화.

**Skills** (자동 활성화):
- `plugin-guide` - 플러그인 구조, plugin.json 작성법
- `command-guide` - 슬래시 커맨드 작성법
- `agent-guide` - 서브에이전트 정의 및 활용
- `skill-guide` - SKILL.md 작성법, Agent Skills 표준
- `hook-guide` - 이벤트 기반 훅 작성법
- `marketplace-guide` - 마켓플레이스 구축
- `workflow-guide` - 실전 개발 워크플로우

**Commands**:
- `/claude-extension-dev:help` - 도움말

## Plugin Installation (for testing)

```bash
# Add marketplace
/plugin marketplace add ./

# Install specific plugin
/plugin install homeserver-gitops@k-codepoet-plugins
/plugin install ubuntu-dev-setup@k-codepoet-plugins
/plugin install claude-extension-dev@k-codepoet-plugins
```

## Script Conventions

- All scripts are **idempotent** (skip already-installed components)
- Scripts perform **platform verification** at start (Linux Ubuntu/Debian only)
- Scripts use `set -e` for fail-fast behavior
- Output uses color-coded messages: green (success), yellow (warning), red (error)
- `${CLAUDE_PLUGIN_ROOT}` environment variable points to plugin root directory

## Adding New Plugins

1. Create `plugins/{plugin-name}/.claude-plugin/plugin.json` with manifest
2. Register in `.claude-plugin/marketplace.json` (name, source, description만 필수)
3. Add commands in `commands/` with YAML frontmatter (name, description 필수)
4. Add implementation scripts in `scripts/`
5. Optionally add agents for natural language triggers (examples는 본문에)
6. Optionally add skills for contextual knowledge (name, description 필수)
