---
description: 현재 환경을 스캔하고 인프라 상태를 보여줍니다
allowed-tools: ["Bash", "Read"]
---

# /terrafy:status

현재 환경을 파악하고 인프라 상태를 보여줍니다.

## 실행 전 필수

**반드시 스킬을 먼저 읽으세요:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/status/SKILL.md
```

스킬의 상황별 출력 형식을 따라 결과를 보여주세요.

## 사용법

```
/terrafy:status    # 현재 인프라 상태 확인
```

## 상태 표시

| 표시 | 의미 |
|------|------|
| `[x]` | 완전 구성, 정상 |
| `[~]` | 준비됨 |
| `[ ]` | 미구성 |
| `[?]` | 확인 필요 |
| `[!]` | 문제 있음 |

## 다음 단계

- `/terrafy:setup` - 인프라 구성 시작/재개
