---
name: help
description: Show ubuntu-dev-setup plugin usage and available commands
allowed-tools: []
---

# Ubuntu Dev Setup - Help

Display all available commands and usage instructions.

## Available Commands

| Command | Description |
|---------|-------------|
| `/ubuntu-dev-setup:help` | 이 도움말 표시 |
| `/ubuntu-dev-setup:setup-all` | 전체 설치 (common + zsh + nvm) |
| `/ubuntu-dev-setup:setup-common` | 기본 패키지만 설치 |
| `/ubuntu-dev-setup:setup-zsh` | Zsh + Oh My Zsh + Powerlevel10k 설치 |
| `/ubuntu-dev-setup:setup-nvm` | NVM + Node.js 환경 설치 |

## What Gets Installed

### Common Packages (`setup-common`)
- `curl`, `wget`: HTTP 클라이언트
- `git`, `git-lfs`: 버전 관리
- `net-tools`, `procps`: 시스템 도구
- `openssl`, `ca-certificates`: 보안
- `fontconfig`: 폰트 관리
- `unzip`: 압축 해제
- `screen`: 터미널 멀티플렉서
- `zsh`: Z Shell

### Zsh Environment (`setup-zsh`)
- **Zsh**: Z Shell
- **Oh My Zsh**: Zsh 프레임워크
- **Powerlevel10k**: 강력한 테마
- **zsh-autosuggestions**: 자동 완성 플러그인
- **zsh-syntax-highlighting**: 문법 강조 플러그인
- **MesloLGS NF**: Powerlevel10k 폰트

### NVM (`setup-nvm`)
- **NVM**: Node Version Manager
- Node.js 버전 관리

## Requirements

- **Platform**: Linux Ubuntu/Debian
- **Privileges**: sudo 권한 필요

## Recommended Order

1. `setup-common` - 기본 패키지 설치
2. `setup-zsh` - Zsh 환경 구성
3. `setup-nvm` - Node.js 환경 구성

또는 `setup-all`로 한 번에 설치
