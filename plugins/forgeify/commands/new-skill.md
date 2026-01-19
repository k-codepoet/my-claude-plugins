---
description: 새 스킬 생성
allowed-tools: Read, Write, Bash, Glob, Grep
argument-hint: <name> [plugin-path]
---

# /forgeify:new-skill

## 실행 전 필수

**반드시 스킬을 먼저 읽으세요:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/new-skill/SKILL.md
```

스킬의 워크플로우를 따라 진행하세요.

## 사용법

```
/forgeify:new-skill <name> [plugin-path]

- name: 스킬 이름 (소문자+하이픈)
- plugin-path: 플러그인 경로 (기본: 현재 디렉토리)
```

## 예시

```
/forgeify:new-skill pdf-processor ./plugins/my-plugin
/forgeify:new-skill data-validator ./
```

ARGUMENTS: $ARGUMENTS
