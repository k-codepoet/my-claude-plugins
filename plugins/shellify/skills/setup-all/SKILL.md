---
description: Complete cross-platform development environment setup (packages + shell + NVM + DevOps tools). "dev setup", "개발환경 셋업", "full setup", "set up everything", "전체 설치".
allowed-tools: Bash, Read
---

# Setup All

개발 환경을 한번에 셋업합니다: 기본 패키지 + 셸 환경 + NVM + DevOps CLI 도구.

## Supported Platforms

- **Linux**: Ubuntu/Debian (apt)
- **macOS**: Homebrew

## Workflow

순서대로 실행합니다:

### 1. 플랫폼 확인

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/detect-platform.sh"
```

### 2. 기본 패키지 설치

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/install-packages.sh"
```

### 3. 셸 환경 설치

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/install-shell.sh"
```

### 4. NVM 설치

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/install-nvm.sh"
```

### 5. DevOps CLI 도구 설치

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/install-devtools.sh"
```

### 6. 최종 상태 확인

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/detect-platform.sh"
```

## Post-Install

1. 터미널 재시작 또는 `exec zsh`
2. 터미널 폰트를 `MesloLGS NF`로 설정
3. `p10k configure`로 테마 설정
4. `nvm install --lts`로 Node.js 설치
