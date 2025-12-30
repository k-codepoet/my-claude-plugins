# ubuntu-dev-setup

Ubuntu Linux 개발 환경을 자동으로 설정하는 Claude Code 플러그인입니다.

## Features

- **Essential Packages**: curl, wget, git, net-tools 등 기본 개발 도구
- **Zsh Environment**: Oh My Zsh + Powerlevel10k + 생산성 플러그인
- **NVM**: Node Version Manager로 Node.js 버전 관리
- **Idempotent**: 이미 설치된 항목은 건너뜀
- **Platform Check**: Ubuntu/Debian 플랫폼 자동 확인

## Commands

| Command | Description |
|---------|-------------|
| `/ubuntu-dev-setup:help` | 도움말 및 사용법 표시 |
| `/ubuntu-dev-setup:setup-all` | 전체 설치 (common + zsh + nvm) |
| `/ubuntu-dev-setup:setup-common` | 기본 패키지만 설치 |
| `/ubuntu-dev-setup:setup-zsh` | Zsh + Oh My Zsh + Powerlevel10k 설치 |
| `/ubuntu-dev-setup:setup-nvm` | NVM 설치 |

## Installed Components

### Common Packages
```
curl, wget, git, git-lfs, net-tools, procps,
openssl, ca-certificates, fontconfig, unzip, screen, zsh
```

### Zsh Environment
- **Zsh**: Z Shell
- **Oh My Zsh**: Zsh 프레임워크
- **Powerlevel10k**: 고속 커스터마이즈 테마
- **zsh-autosuggestions**: 자동 완성 플러그인
- **zsh-syntax-highlighting**: 문법 강조 플러그인
- **MesloLGS NF**: Powerlevel10k 아이콘 폰트

### NVM
- **NVM v0.40.1**: Node Version Manager
- bash 및 zsh 설정 자동 구성

## Usage

### Natural Language (Agent)
```
"우분투 개발환경 셋업해줘"
"zsh 설치해줘"
"nvm 설치해줘"
"터미널 꾸며줘"
```

### Slash Commands
```
/ubuntu-dev-setup:setup-all
/ubuntu-dev-setup:setup-zsh
/ubuntu-dev-setup:setup-nvm
```

## Post-Installation

설치 완료 후:
1. 터미널 재시작 또는 `exec zsh` 실행
2. 터미널 폰트를 "MesloLGS NF"로 설정
3. `p10k configure`로 Powerlevel10k 테마 커스터마이즈
4. `nvm install --lts`로 Node.js LTS 버전 설치

## Platform

- **Supported**: Linux Ubuntu, Debian (apt-based)
- **Not Supported**: macOS, Windows, non-apt Linux distros

## Directory Structure

```
ubuntu-dev-setup/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   └── ubuntu-dev-setup.md
├── commands/
│   ├── help.md
│   ├── setup-all.md
│   ├── setup-common.md
│   ├── setup-nvm.md
│   └── setup-zsh.md
├── scripts/
│   ├── install-common.sh
│   ├── install-nvm.sh
│   └── install-zsh.sh
├── skills/
│   └── ubuntu-dev-environment/
│       └── SKILL.md
└── README.md
```

## Author

choigawoon
