---
description: 훅 개선
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: <event-type> [improvement-doc]
---

# /forgeify:improve-hook

## 실행 전 필수

**반드시 스킬을 먼저 읽으세요:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/improve-hook/SKILL.md
```

스킬의 워크플로우를 따라 진행하세요.

## 사용법

```
/forgeify:improve-hook <event-type> [improvement-doc]

- event-type: PreToolUse, PostToolUse, Stop, SessionStart, UserPromptSubmit
- improvement-doc: 개선 문서 경로 (선택)
```

## 예시

```
/forgeify:improve-hook PreToolUse ~/.gemify/views/by-improvement/my-plugin-hook.md
/forgeify:improve-hook Stop
```

ARGUMENTS: $ARGUMENTS
