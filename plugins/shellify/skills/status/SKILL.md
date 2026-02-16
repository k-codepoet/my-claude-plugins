---
description: Check current shell environment installation status. "shellify status", "what's installed", "check setup", "설치 상태 확인", "환경 확인".
allowed-tools: Bash, Read
---

# Status

현재 셸 환경의 설치 상태를 확인합니다.

## Workflow

```bash
bash "$CLAUDE_PLUGIN_ROOT/scripts/detect-platform.sh"
```

결과를 사용자에게 요약하여 보여줍니다:
- 플랫폼 정보 (OS, WSL 여부)
- 셸 환경 (Zsh, Oh My Zsh, Powerlevel10k, 플러그인)
- 폰트 설치 여부
- NVM/Node.js 상태
- 패키지 매니저 상태

미설치 항목이 있으면 관련 스킬을 안내합니다:
- 셸 미설치 → `/shellify:setup-shell`
- NVM 미설치 → `/shellify:setup-nvm`
- 패키지 미설치 → `/shellify:setup-packages`
- 전체 → `/shellify:setup-all`
