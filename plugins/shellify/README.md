# shellify

> Shape your shell - Cross-platform shell environment setup

macOS와 Ubuntu/WSL에서 Zsh 기반 개발 환경을 자동으로 구성합니다.

## Features

- **Zsh + Oh My Zsh + Powerlevel10k** - Modern shell with beautiful theme
- **zsh-autosuggestions** - Fish-like command autosuggestions
- **zsh-syntax-highlighting** - Real-time syntax highlighting
- **MesloLGS NF** - Nerd Font for Powerlevel10k icons
- **NVM** - Node Version Manager
- **Essential packages** - curl, wget, git, git-lfs, etc.
- **DevOps CLI tools** - kubectl, k9s, helm, argocd, gh, glab

## Supported Platforms

| Platform | Package Manager |
|----------|----------------|
| Ubuntu/Debian (WSL) | apt |
| macOS | Homebrew |

## Skills

| Skill | Description |
|-------|-------------|
| `setup-shell` | Zsh + Oh My Zsh + Powerlevel10k + fonts + plugins |
| `setup-nvm` | NVM (Node Version Manager) |
| `setup-packages` | Essential development packages |
| `setup-devtools` | DevOps CLI tools (kubectl, k9s, helm, argocd, gh, glab) |
| `setup-all` | Complete setup (packages + shell + NVM + DevOps tools) |
| `status` | Check current installation status |

## Quick Start

```
/shellify:status       # Check what's installed
/shellify:setup-all    # Install everything
```
