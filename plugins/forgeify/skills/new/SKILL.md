---
description: "Claude Code 메타도구 생성 라우터. /forgeify:new <type>으로 호출하여 plugin, skill, command, agent, hook 중 하나를 생성."
allowed-tools: Read, Write, Bash, Glob, Grep
argument-hint: "<type> (plugin|skill|command|agent|hook)"
disable-model-invocation: true
---

# /forgeify:new - 메타도구 생성 라우터

## 사용법

```
/forgeify:new <type> [args...]

type:
  plugin   - 플러그인 전체 생성
  skill    - 스킬만 생성
  command  - 커맨드만 생성
  agent    - 에이전트만 생성
  hook     - 훅만 생성
```

## 라우팅

ARGUMENTS: $ARGUMENTS

인자를 파싱하여 적절한 스킬로 라우팅:

| 입력 | 호출 |
|------|------|
| `/forgeify:new plugin my-plugin ./` | Skill 도구로 `forgeify:new-plugin` 호출 |
| `/forgeify:new skill my-skill ./plugin` | Skill 도구로 `forgeify:new-skill` 호출 |
| `/forgeify:new command my-cmd ./plugin` | Skill 도구로 `forgeify:new-command` 호출 |
| `/forgeify:new agent my-agent ./plugin` | Skill 도구로 `forgeify:new-agent` 호출 |
| `/forgeify:new hook PreToolUse ./plugin` | Skill 도구로 `forgeify:new-hook` 호출 |

## 타입 미지정 시

```
어떤 메타도구를 생성할까요?

1. plugin  - 플러그인 전체 (commands, skills, agents, hooks 포함 가능)
2. skill   - 자동 활성화 스킬
3. command - 슬래시 커맨드
4. agent   - 서브에이전트
5. hook    - 이벤트 훅

선택:
```

선택 후 해당 스킬 호출.
