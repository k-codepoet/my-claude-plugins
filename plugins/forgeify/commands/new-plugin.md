---
description: 새 플러그인 생성
allowed-tools: Read, Write, Bash, Glob, Grep
argument-hint: <name> [marketplace-path]
---

# /forgeify:new-plugin

## 실행 전 필수

**반드시 스킬을 먼저 읽으세요:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/new-plugin/SKILL.md
```

스킬의 워크플로우를 따라 진행하세요.

## 사용법

```
/forgeify:new-plugin <name> [marketplace-path]

- name: 플러그인 이름
- marketplace-path: 마켓플레이스 경로 (기본: 현재 디렉토리)
```

## 예시

```
/forgeify:new-plugin pdf-processor ./
/forgeify:new-plugin my-automation ~/my-marketplace
```

ARGUMENTS: $ARGUMENTS
