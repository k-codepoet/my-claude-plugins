---
description: 비전 대비 현재 상태 평가 + 리뷰 기록
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
argument-hint: "<vision-name>"
---

# /gemify:vision-review - 비전 리뷰

**반드시 `skills/vision-review/SKILL.md`를 먼저 읽고 그 지침대로 동작하세요.**

## 사용법

```
/gemify:vision-review ai-company   # ai-company 비전 리뷰
```

## 동작

1. $ARGUMENTS로 지정된 vision의 definition.md, current.md 읽기
2. 실제 상태 점검 (플러그인 버전, library 밀도, 최근 활동)
3. 평가 수행 (진척도, 밀도, 실현율, 자동화율, 방향성)
4. `reviews/YYYY-MM-DD.md`에 리뷰 기록
5. current.md 갱신

ARGUMENTS: $ARGUMENTS
