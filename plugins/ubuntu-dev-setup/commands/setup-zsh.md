---
name: setup-zsh
description: Setup Zsh with Oh My Zsh, Powerlevel10k theme, and useful plugins
allowed-tools: Read, Bash
---

Configure Zsh shell with Oh My Zsh framework, Powerlevel10k theme, and productivity plugins.

## Prerequisites Check

1. Verify platform is Linux Ubuntu/Debian:
   - Check `uname -s` returns "Linux"
   - Check `/etc/os-release` contains Ubuntu or Debian

2. If not Linux Ubuntu/Debian, inform the user and stop.

## Workflow

### Step 1: Execute Installation

Run the Zsh setup script:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-zsh.sh"
```

### Step 2: Verify Installation

Check installations:
```bash
# Check Oh My Zsh
ls -la ~/.oh-my-zsh

# Check Powerlevel10k
ls -la ~/.oh-my-zsh/custom/themes/powerlevel10k

# Check plugins
ls -la ~/.oh-my-zsh/custom/plugins/
```

## Installed Components

| Component | Description |
|-----------|-------------|
| Zsh | Z Shell - powerful shell replacement |
| Oh My Zsh | Zsh configuration framework |
| Powerlevel10k | Fast, customizable Zsh theme |
| zsh-autosuggestions | Fish-like autosuggestions |
| zsh-syntax-highlighting | Syntax highlighting while typing |
| MesloLGS NF | Nerd Font for Powerlevel10k icons |

## Configuration Applied

- Default shell changed to Zsh
- Theme set to Powerlevel10k
- Plugins enabled: git, zsh-autosuggestions, zsh-syntax-highlighting

## Completion

Report to user:
- Installation status
- Post-installation steps:
  1. Restart terminal or run `exec zsh`
  2. Set terminal font to "MesloLGS NF"
  3. Run `p10k configure` for theme customization
