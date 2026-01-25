---
description: 비전 생성/조회
allowed-tools: Read, Write, Edit, Glob
argument-hint: "[vision-name | new <name>]"
---

# /gemify:vision - 비전 관리

**반드시 `skills/vision/SKILL.md`를 먼저 읽고 그 지침대로 동작하세요.**

## 사용법

```
/gemify:vision                 # 모든 vision 목록
/gemify:vision ai-company      # 특정 vision 조회
/gemify:vision new my-vision   # 새 vision 생성
```

## 동작

**반드시 `skills/scope/SKILL.md` 참조하여 현재 도메인 경로 결정.**

1. $ARGUMENTS가 없으면 → `{domain_path}/visions/` 목록 표시
2. $ARGUMENTS가 `new <name>`이면 → 새 vision 생성 워크플로우
3. 그 외 → 해당 vision 조회

ARGUMENTS: $ARGUMENTS
