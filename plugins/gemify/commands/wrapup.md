---
description: 세션 마무리 - HITL 체크 후 세션 리포트 생성
allowed-tools: Read, Write, Edit, Glob
---

# /gemify:wrapup - 세션 마무리

**반드시 `skills/wrapup/SKILL.md`를 먼저 읽고 그 지침대로 동작하세요.**

## 사용법

```
/gemify:wrapup                  # 현재 세션 마무리
```

## 동작

### 1. HITL 체크 (놓친 것 확인)

1. 이번 세션에서 다룬 내용 요약
2. 빠뜨린 것/추가 작업 확인
3. 마무리 승인 받기

### 2. 리포트 생성

승인 후 `sessions/YYYY-MM-DD-{slug}.md` 저장:

- **Summary**: 이번 세션에서 한 일
- **Outputs**: 생성/수정된 파일
- **Stashed for Next**: inbox에 챙겨둔 것
- **Next Actions**: 파생 TODO

## 세션 범위

- 기본값: 대화 전체
- 필요시 구간 지정 가능

## 핵심

- HITL 체크 없이 리포트 생성 안 함
- inbox 항목 = "미완료"가 아니라 "의도적으로 챙겨둔 것"
