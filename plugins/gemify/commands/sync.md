---
description: ~/.gemify/ 저장소를 remote와 동기화합니다. 인자 없이 실행 시 전체 상태 진단 + SSOT 일치 점검을 수행합니다.
argument-hint: "[pull|push|status]"
allowed-tools: Read, Bash, Write, Glob, Grep
---

# /gemify:sync

**반드시 `skills/sync/SKILL.md`를 먼저 읽고 그 지침대로 동작하세요.**

## 간략 안내

| 커맨드 | 설명 |
|--------|------|
| `/gemify:sync` | 전체 진단 (remote + SSOT 점검 + 심기 제안) |
| `/gemify:sync pull` | remote → ~/.gemify/ |
| `/gemify:sync push` | ~/.gemify/ → remote |
| `/gemify:sync status` | 동기화 상태 확인 |

## 안전 장치

- **절대 ~/.gemify/ 폴더를 삭제하지 않음**
- push 전 항상 현재 상태 확인
- conflict 발생 시 자동 해결하지 않고 사용자에게 알림
- force push 사용하지 않음
