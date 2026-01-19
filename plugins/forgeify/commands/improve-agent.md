---
description: 에이전트 개선
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: <name> [improvement-doc]
---

# /forgeify:improve-agent

## 실행 전 필수

**반드시 스킬을 먼저 읽으세요:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/improve-agent/SKILL.md
```

스킬의 워크플로우를 따라 진행하세요.

## 사용법

```
/forgeify:improve-agent <name> [improvement-doc]

- name: 에이전트 이름
- improvement-doc: 개선 문서 경로 (선택)
```

## 예시

```
/forgeify:improve-agent code-reviewer ~/.gemify/views/by-improvement/my-plugin-reviewer.md
/forgeify:improve-agent test-runner
```

ARGUMENTS: $ARGUMENTS
