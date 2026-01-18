---
name: ubuntu-dev-environment
description: Ubuntu Linux 개발환경 설정 스킬. Zsh, Oh My Zsh, Powerlevel10k, NVM 설치 및 기본 개발 패키지 구성 방법을 제공합니다. "개발환경 셋업", "zsh 설치", "nvm 설정", "powerlevel10k" 등의 질문에 사용합니다.
---

# Ubuntu Development Environment Setup

This skill provides knowledge about setting up a complete Ubuntu Linux development environment with modern tools.

## When to Use This Skill

Use this skill when:
- Setting up a new Ubuntu development machine
- Installing Zsh, Oh My Zsh, or Powerlevel10k
- Configuring NVM for Node.js version management
- Installing essential development packages on Ubuntu/Debian

## Components Overview

### 1. Essential Packages

Basic development tools installed via apt:
- **curl, wget**: HTTP clients for downloading
- **git, git-lfs**: Version control
- **net-tools, procps**: System utilities
- **openssl, ca-certificates**: Security tools
- **fontconfig**: Font management
- **unzip**: Archive extraction
- **screen**: Terminal multiplexer
- **zsh**: Z Shell

### 2. Zsh Environment

Complete Zsh configuration:

| Component | Purpose |
|-----------|---------|
| Zsh | Modern shell replacement for bash |
| Oh My Zsh | Zsh configuration framework |
| Powerlevel10k | Fast, highly customizable theme |
| zsh-autosuggestions | Fish-like command autosuggestions |
| zsh-syntax-highlighting | Real-time syntax highlighting |
| MesloLGS NF | Nerd Font with icons for P10k |

### 3. NVM (Node Version Manager)

Node.js version management:
- Install multiple Node.js versions
- Switch between versions easily
- Per-project version configuration via `.nvmrc`

## Platform Requirements

- **OS**: Linux Ubuntu/Debian (apt-based)
- **Privileges**: sudo access required
- **Shell**: bash or zsh

## Installation Order

For complete setup:
1. Common packages (provides zsh)
2. Zsh environment (requires zsh)
3. NVM (configures all shells)

## Post-Installation

After installation:
1. Restart terminal or `exec zsh`
2. Set terminal font to "MesloLGS NF"
3. Run `p10k configure` for theme setup
4. Install Node.js: `nvm install --lts`

## Common Commands

```bash
# Zsh
exec zsh                    # Start new Zsh session
p10k configure              # Reconfigure Powerlevel10k

# NVM
nvm install --lts           # Install LTS Node.js
nvm install 20              # Install specific version
nvm use 20                  # Switch to version
nvm ls                      # List installed versions
nvm ls-remote               # List available versions
nvm alias default 20        # Set default version
```

## Troubleshooting

### Powerlevel10k Icons Not Showing
- Set terminal font to "MesloLGS NF"
- Restart terminal completely

### NVM Not Found After Installation
- Run `source ~/.zshrc` or `source ~/.bashrc`
- Or restart terminal

### Permission Denied Errors
- Ensure you have sudo privileges
- Run with `sudo` for apt commands
