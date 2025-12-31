---
name: setup-nvm
description: Install NVM (Node Version Manager) for Node.js management
allowed-tools: Read, Bash
---

Install NVM to manage multiple Node.js versions easily.

## Prerequisites Check

1. Verify platform is Linux Ubuntu/Debian:
   - Check `uname -s` returns "Linux"
   - Check `/etc/os-release` contains Ubuntu or Debian

2. If not Linux Ubuntu/Debian, inform the user and stop.

## Workflow

### Step 1: Execute Installation

Run the NVM installation script:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-nvm.sh"
```

### Step 2: Verify Installation

After installation, verify NVM:
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm --version
```

## What Gets Installed

| Component | Description |
|-----------|-------------|
| NVM | Node Version Manager |
| Shell config | .bashrc and .zshrc updated |

## Completion

Report to user:
- NVM installation status
- NVM version
- Usage instructions:
  - `nvm install node` - Install latest Node.js
  - `nvm install --lts` - Install LTS version
  - `nvm install 20` - Install specific version
  - `nvm use <version>` - Switch version
  - `nvm ls` - List installed versions
  - `nvm ls-remote` - List available versions

## Post-Installation

Remind user to:
1. Restart terminal or `source ~/.zshrc` / `source ~/.bashrc`
2. Install Node.js with `nvm install --lts`
