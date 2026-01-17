---
description: 대화형으로 홈서버 인프라를 구성합니다
allowed-tools: ["Bash", "Read", "Write"]
---

# /terrafy:setup

대화형으로 홈서버 인프라를 구성합니다.

## 실행 전 필수

**반드시 스킬을 먼저 읽으세요:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/setup/SKILL.md
```

스킬의 6 Phase 워크플로우를 따라 진행하세요.

## 사용법

```
/terrafy:setup              # 처음부터 시작
/terrafy:setup              # 중단된 Phase부터 재개
```

## 개요

```
Phase 1: 탐색 → Phase 2: 연결 → Phase 3: 배정
    ↓
Phase 4: Portainer → Phase 5: Gateway → Phase 6: 검증
```

## 다음 단계

- `/terrafy:status` - 현재 상태 확인
- `/craftify:deploy` - Phase 6 완료 후 앱 배포
