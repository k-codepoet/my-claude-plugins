---
name: setup-common
description: Install essential Ubuntu packages for development
allowed-tools: Read, Bash
---

Install essential development packages on Ubuntu Linux.

## Prerequisites Check

1. Verify platform is Linux Ubuntu/Debian:
   - Check `uname -s` returns "Linux"
   - Check `/etc/os-release` contains Ubuntu or Debian

2. If not Linux Ubuntu/Debian, inform the user and stop.

## Workflow

### Step 1: Execute Installation

Run the common packages installation script:
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-common.sh"
```

### Step 2: Verify Installation

Check that key packages are installed:
```bash
which curl wget git zsh
```

## Installed Packages

| Package | Purpose |
|---------|---------|
| curl | HTTP client for downloading |
| wget | HTTP client alternative |
| git | Version control |
| git-lfs | Git Large File Storage |
| net-tools | Network utilities (ifconfig, etc.) |
| procps | Process utilities (ps, top, etc.) |
| openssl | SSL/TLS toolkit |
| ca-certificates | Certificate authorities |
| fontconfig | Font configuration |
| unzip | Archive extraction |
| screen | Terminal multiplexer |
| zsh | Z Shell |

## Completion

Report to user:
- List of installed packages
- Any errors encountered
- Suggest running `setup-zsh` next for shell configuration
