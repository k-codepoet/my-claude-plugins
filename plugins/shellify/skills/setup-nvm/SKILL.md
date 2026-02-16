---
description: Cross-platform NVM (Node Version Manager) installation. "nvm install", "node setup", "node version manager", "nvm 설치", "노드 설치".
allowed-tools: Bash, Read
---

# Setup NVM

NVM (Node Version Manager)을 설치하고 셸에 설정합니다.

## Supported Platforms

- **Linux**: Ubuntu/Debian
- **macOS**: Homebrew-based systems

## Workflow

### 1. 상태 확인

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/detect-platform.sh"
```

### 2. 설치 실행

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/install-nvm.sh"
```

### 3. Node.js 설치 (선택)

설치 후 사용자에게 Node.js 버전 설치를 제안:

```bash
nvm install --lts      # LTS 버전
nvm install 20         # 특정 버전
```

## Post-Install

- `source ~/.zshrc` 또는 터미널 재시작
- `nvm ls`로 설치된 버전 확인
