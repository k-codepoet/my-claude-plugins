---
description: shellify 사용 가이드
argument-hint: "[topic: shell|nvm|packages|devtools|fonts]"
---

# Shellify How-To Guide

## shell - Zsh Environment Setup

Zsh + Oh My Zsh + Powerlevel10k + 플러그인 설치:

```
/shellify:setup-shell
```

설치 후:
1. `exec zsh` 또는 터미널 재시작
2. 폰트를 "MesloLGS NF"로 설정
3. `p10k configure`로 테마 커스터마이징

## nvm - Node Version Manager

NVM 설치 및 Node.js 버전 관리:

```
/shellify:setup-nvm
```

설치 후:
```bash
nvm install --lts     # LTS 버전 설치
nvm install 20        # 특정 버전 설치
nvm use <version>     # 버전 전환
nvm alias default 20  # 기본 버전 설정
```

## packages - Essential Packages

기본 개발 패키지 설치:

```
/shellify:setup-packages
```

Linux: curl, wget, git, git-lfs, net-tools, procps, openssl, ca-certificates, fontconfig, unzip, screen, zsh
macOS: curl, wget, git, git-lfs, coreutils, fontconfig, unzip, screen, zsh

## devtools - DevOps CLI Tools

Kubernetes, GitOps, Git 관련 CLI 도구 설치:

```
/shellify:setup-devtools
```

설치되는 도구:
| Tool | Purpose |
|------|---------|
| kubectl | Kubernetes CLI |
| k9s | Kubernetes TUI dashboard |
| helm | Kubernetes package manager |
| argocd | ArgoCD CLI for GitOps |
| gh | GitHub CLI |
| glab | GitLab CLI |
| git + git-lfs | Version control |

## fonts - Font Setup

MesloLGS NF 폰트는 `/shellify:setup-shell`에 포함되어 있습니다.

설치 후 터미널 앱에서 수동으로 폰트를 설정해야 합니다:

- **Windows Terminal (WSL)**: Settings > Profile > Appearance > Font face > "MesloLGS NF"
- **iTerm2 (macOS)**: Preferences > Profiles > Text > Font > "MesloLGS NF"
- **Terminal.app (macOS)**: Preferences > Profiles > Font > Change > "MesloLGS NF"
