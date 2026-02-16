---
description: Cross-platform shell environment setup (Zsh + Oh My Zsh + Powerlevel10k + fonts + plugins). "zsh setup", "shell setup", "oh-my-zsh", "powerlevel10k", "terminal customization", "터미널 꾸미기", "zsh 설치", "셸 설정".
allowed-tools: Bash, Read
---

# Setup Shell

Zsh + Oh My Zsh + Powerlevel10k + 플러그인 + 폰트를 설치합니다.

## Supported Platforms

- **Linux**: Ubuntu/Debian (apt)
- **macOS**: Homebrew

## Workflow

### 1. 상태 확인

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/detect-platform.sh"
```

결과를 확인하여 이미 설치된 항목을 파악합니다.

### 2. 설치 실행

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/install-shell.sh"
```

설치 항목:
| Component | Purpose |
|-----------|---------|
| Zsh | Modern shell |
| Oh My Zsh | Zsh configuration framework |
| Powerlevel10k | Fast, customizable theme |
| zsh-autosuggestions | Fish-like autosuggestions |
| zsh-syntax-highlighting | Real-time syntax highlighting |
| MesloLGS NF | Nerd Font for Powerlevel10k icons |

### 3. Post-Install Guidance

설치 완료 후 플랫폼별 안내:

**WSL Ubuntu:**
- 터미널 재시작 또는 `exec zsh`
- Windows Terminal 폰트 설정: `MesloLGS NF`
- `p10k configure`로 테마 설정

**macOS:**
- 터미널 재시작 또는 `exec zsh`
- iTerm2/Terminal.app 폰트 설정: `MesloLGS NF`
- `p10k configure`로 테마 설정

## Troubleshooting

- **Icons not showing**: Set terminal font to "MesloLGS NF"
- **Permission denied**: Ensure sudo access (Linux) or Homebrew installed (macOS)
- **chsh requires password**: Run `chsh -s $(which zsh)` manually
