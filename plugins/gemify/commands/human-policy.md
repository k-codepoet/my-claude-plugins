---
description: 정책 문서 생성 - library 지식을 docs/humans/policies/로 발전
allowed-tools: Read, Write, Edit, Glob
argument-hint: [library 파일 또는 주제]
---

# /gemify:human-policy - 정책 문서 생성

human-policy 스킬을 사용하여 정책 문서를 생성한다.

## 사용법

```
/gemify:human-policy                      # 대화 맥락에서 정책 추출
/gemify:human-policy library/파일명.md    # 특정 library 파일 기반
```

## 파이프라인 위치

```
library/ → [/gemify:human-policy] → docs/humans/policies/
```

## 동작

1. $ARGUMENTS가 있으면 해당 library 파일 기반 처리
2. 없으면 대화 맥락에서 정책 추출
3. library 안착 여부 확인 (미안착 시 /gemify:library 먼저 유도)
4. human-policy 스킬의 소크라테스식 질문 워크플로우 실행
5. `docs/humans/policies/` 디렉토리에 저장
