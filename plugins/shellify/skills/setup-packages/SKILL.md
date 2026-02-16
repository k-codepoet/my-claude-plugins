---
description: Cross-platform essential development packages installation. "install packages", "기본 패키지", "development tools", "개발 도구 설치", "essential packages".
allowed-tools: Bash, Read
---

# Setup Packages

기본 개발 패키지를 설치합니다.

## Supported Platforms

- **Linux (apt)**: curl, wget, git, git-lfs, net-tools, procps, openssl, ca-certificates, fontconfig, unzip, screen, zsh
- **macOS (brew)**: curl, wget, git, git-lfs, coreutils, fontconfig, unzip, screen, zsh

## Workflow

### 1. 상태 확인

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/detect-platform.sh"
```

### 2. 설치 실행

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/install-packages.sh"
```

## Notes

- Linux: `sudo` 권한 필요
- macOS: Homebrew 필요 (없으면 https://brew.sh 에서 설치)
