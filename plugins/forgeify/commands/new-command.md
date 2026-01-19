---
description: 새 커맨드 생성
allowed-tools: Read, Write, Bash, Glob, Grep
argument-hint: <name> [plugin-path]
---

# /forgeify:new-command

## 실행 전 필수

**반드시 스킬을 먼저 읽으세요:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/new-command/SKILL.md
```

스킬의 워크플로우를 따라 진행하세요.

## 사용법

```
/forgeify:new-command <name> [plugin-path]

- name: 커맨드 이름
- plugin-path: 플러그인 경로 (기본: 현재 디렉토리)
```

## 예시

```
/forgeify:new-command deploy ./plugins/my-plugin
/forgeify:new-command setup ./
```

ARGUMENTS: $ARGUMENTS
