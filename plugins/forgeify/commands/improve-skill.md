---
description: 스킬 개선
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: <name> [improvement-doc]
---

# /forgeify:improve-skill

## 실행 전 필수

**반드시 스킬을 먼저 읽으세요:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/improve-skill/SKILL.md
```

스킬의 워크플로우를 따라 진행하세요.

## 사용법

```
/forgeify:improve-skill <name> [improvement-doc]

- name: 스킬 이름
- improvement-doc: 개선 문서 경로 (선택)
```

## 예시

```
/forgeify:improve-skill pdf-processor ~/.gemify/views/by-improvement/my-plugin-pdf.md
/forgeify:improve-skill data-validator
```

ARGUMENTS: $ARGUMENTS
