---
description: Complete Ubuntu development environment setup (common + zsh + nvm)
allowed-tools: Read, Bash, Write
---

Set up a complete Ubuntu development environment with all components.

## Prerequisites Check

1. Verify platform is Linux Ubuntu/Debian:
   - Check `uname -s` returns "Linux"
   - Check `/etc/os-release` contains Ubuntu or Debian

2. If not Linux Ubuntu/Debian, inform the user and stop.

## Workflow

### Step 1: Install Common Packages

Execute the common packages installation:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-common.sh"
```

This installs essential development packages:
- curl, wget, git, git-lfs
- net-tools, procps, openssl
- fontconfig, unzip, screen, zsh

### Step 2: Setup Zsh Environment

Execute the Zsh setup:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-zsh.sh"
```

This configures:
- Oh My Zsh framework
- Powerlevel10k theme
- zsh-autosuggestions plugin
- zsh-syntax-highlighting plugin
- MesloLGS NF fonts

### Step 3: Install NVM

Execute the NVM installation:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-nvm.sh"
```

This sets up:
- NVM (Node Version Manager)
- Shell configuration for bash and zsh

## Completion

Report to user:
- Installation status for each component
- Any warnings or errors encountered
- Next steps:
  - Restart terminal or run `exec zsh`
  - Configure Powerlevel10k with `p10k configure`
  - Set terminal font to "MesloLGS NF"
  - Install Node.js with `nvm install --lts`
