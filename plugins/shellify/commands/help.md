---
description: shellify 플러그인 도움말
---

# Shellify - Shape your shell

Cross-platform shell environment setup for macOS and Ubuntu/WSL.

## Available Skills

| Skill | Description |
|-------|-------------|
| `/shellify:setup-shell` | Zsh + Oh My Zsh + Powerlevel10k + fonts + plugins |
| `/shellify:setup-nvm` | NVM (Node Version Manager) |
| `/shellify:setup-packages` | Essential development packages |
| `/shellify:setup-devtools` | DevOps CLI tools (kubectl, k9s, helm, argocd, gh, glab) |
| `/shellify:setup-all` | Complete setup (packages + shell + NVM + DevOps tools) |
| `/shellify:status` | Check current installation status |

## Supported Platforms

- **Linux**: Ubuntu/Debian (apt)
- **macOS**: Homebrew

## Quick Start

1. `/shellify:status` - 현재 상태 확인
2. `/shellify:setup-all` - 전체 셋업
3. Set terminal font to "MesloLGS NF"
4. `p10k configure` - 테마 설정
