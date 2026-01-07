---
description: POC.md 기반 Claude Code 플러그인 구현 - gemify:poc이 생성한 문서를 읽고 플러그인 생성
allowed-tools: Read, Write, Glob, Grep, Bash
argument-hint: [marketplace-path]
---

# /forgeify:poc

poc 스킬을 사용하여 POC.md 기반으로 플러그인을 구현합니다.

## 사용법

```
/forgeify:poc                    # 현재 디렉토리에서 POC.md 읽기
/forgeify:poc ~/my-marketplace   # 마켓플레이스 경로 지정
```

## 전제 조건

- 현재 디렉토리에 `POC.md` 존재 (gemify:poc이 생성)

ARGUMENTS: $ARGUMENTS
