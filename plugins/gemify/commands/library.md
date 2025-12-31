---
description: drafts 파일을 정리하여 library로 분류/저장
allowed-tools: Read, Write, Edit
argument-hint: [drafts 파일]
---

# /gemify:library - 보석 정리 커맨드

library 스킬을 사용하여 drafts 파일을 library로 처리한다.

## 사용법

```
/gemify:library                      # drafts 목록 보여주고 선택
/gemify:library drafts/파일명.md     # 특정 파일 처리
```

## 파이프라인 위치

```
inbox/ → drafts/ → [/gemify:library] → library/
```

## 동작

1. $ARGUMENTS가 있으면 해당 파일 처리
2. 없으면 drafts 폴더의 파일 목록 표시 후 선택 요청
3. library 스킬의 워크플로우 실행
4. 완료 후 drafts 파일 status를 `set`로 변경
