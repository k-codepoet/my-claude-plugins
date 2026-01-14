---
description: ~/.gemify/ 저장소를 remote와 동기화합니다. 인자 없이 실행 시 전체 상태 진단 + SSOT 일치 점검을 수행합니다.
argument-hint: "[pull|push|status]"
allowed-tools: Read, Bash, Write, Glob, Grep
---

# /gemify:sync - Git 동기화 & SSOT 점검

`~/.gemify/` 저장소를 remote와 동기화하고, 플러그인 구현과의 일치 여부를 점검합니다.

상세 동작은 **sync** 스킬을 참조합니다.

## 사용법

```bash
/gemify:sync          # 전체 상태 진단 (remote + SSOT 점검)
/gemify:sync pull     # remote에서 가져오기
/gemify:sync push     # remote로 올리기
/gemify:sync status   # 동기화 상태 확인
```

## 서브커맨드

| 커맨드 | 설명 |
|--------|------|
| (없음) | **전체 진단**: remote 동기화 + SSOT 일치 점검 + 심기 제안 |
| `pull` | remote → ~/.gemify/ (git pull --rebase) |
| `push` | ~/.gemify/ → remote (add + commit + push) |
| `status` | 현재 동기화 상태 확인 |

## 0단계: ~/.gemify/ 확인

```
~/.gemify/ 존재?
├── 아니오 → "/gemify:setup으로 먼저 설정하세요" + 종료
└── 예 → 계속
```

## 안전 장치

- **절대 ~/.gemify/ 폴더를 삭제하지 않음**
- push 전 항상 현재 상태 확인
- conflict 발생 시 자동 해결하지 않고 사용자에게 알림
- force push 사용하지 않음
