---
description: 새 훅 생성
allowed-tools: Read, Write, Bash, Glob, Grep
argument-hint: <event-type> [plugin-path]
---

# /forgeify:new-hook

## 실행 전 필수

**반드시 스킬을 먼저 읽으세요:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/new-hook/SKILL.md
```

스킬의 워크플로우를 따라 진행하세요.

## 사용법

```
/forgeify:new-hook <event-type> [plugin-path]

- event-type: PreToolUse, PostToolUse, Stop, SessionStart, UserPromptSubmit
- plugin-path: 플러그인 경로 (기본: 현재 디렉토리)
```

## 예시

```
/forgeify:new-hook PreToolUse ./plugins/my-plugin
/forgeify:new-hook Stop ./
```

ARGUMENTS: $ARGUMENTS
