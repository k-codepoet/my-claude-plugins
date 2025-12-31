---
name: digest
description: growing 파일을 소화시켜 corpus로 분류/저장
allowed-tools: Read, Write, Edit
argument-hint: [growing 파일]
---

# /distill:digest - 지식 소화 커맨드

digest 스킬을 사용하여 growing 파일을 corpus로 처리한다.

## 사용법

```
/distill:digest                      # growing 목록 보여주고 선택
/distill:digest growing/파일명.md    # 특정 파일 처리
```

## 파이프라인 위치

```
seed/ + materials/ → growing/ → [/distill:digest] → corpus/
```

## 동작

1. $ARGUMENTS가 있으면 해당 파일 처리
2. 없으면 growing 폴더의 파일 목록 표시 후 선택 요청
3. digest 스킬의 워크플로우 실행
4. 완료 후 growing 파일 status를 `digested`로 변경
