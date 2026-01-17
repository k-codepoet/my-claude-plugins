---
description: 비전 생성/조회
allowed-tools: Read, Write, Edit, Glob
argument-hint: "[vision-name | new <name>]"
---

# /gemify:vision - 비전 관리

vision 스킬을 사용하여 비전(지향점)을 생성하거나 조회합니다.

## 사용법

```
/gemify:vision                 # 모든 vision 목록
/gemify:vision ai-company      # 특정 vision 조회
/gemify:vision new my-vision   # 새 vision 생성
```

## 동작

1. $ARGUMENTS가 없으면 → `~/.gemify/visions/` 목록 표시
2. $ARGUMENTS가 `new <name>`이면 → 새 vision 생성 워크플로우
3. 그 외 → 해당 vision 조회

상세 동작은 `skills/vision/SKILL.md` 참조.

ARGUMENTS: $ARGUMENTS
