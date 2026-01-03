---
description: 의사결정 기록 생성 - library 지식을 docs/humans/decisions/로 발전
allowed-tools: Read, Write, Edit, Glob
argument-hint: [library 파일 또는 주제]
---

# /gemify:human-decision - 의사결정 기록 생성

human-decision 스킬을 사용하여 의사결정 기록(ADR 스타일)을 생성한다.

## 사용법

```
/gemify:human-decision                      # 대화 맥락에서 의사결정 추출
/gemify:human-decision library/파일명.md    # 특정 library 파일 기반
```

## 파이프라인 위치

```
library/ → [/gemify:human-decision] → docs/humans/decisions/
```

## 동작

1. $ARGUMENTS가 있으면 해당 library 파일 기반 처리
2. 없으면 대화 맥락에서 의사결정 추출
3. library 안착 여부 확인 (미안착 시 /gemify:library 먼저 유도)
4. human-decision 스킬의 소크라테스식 질문 워크플로우 실행
5. `docs/humans/decisions/` 디렉토리에 저장
