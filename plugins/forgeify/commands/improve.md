---
description: 메타도구 개선 라우터
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
argument-hint: <type> (plugin|skill|command|agent|hook)
---

# /forgeify:improve - 메타도구 개선 라우터

## 사용법

```
/forgeify:improve <type> [args...]

type:
  plugin   - 플러그인 전체 개선
  skill    - 스킬 개선
  command  - 커맨드 개선
  agent    - 에이전트 개선
  hook     - 훅 개선
```

## 라우팅

ARGUMENTS: $ARGUMENTS

인자를 파싱하여 적절한 커맨드로 라우팅:

| 입력 | 호출 |
|------|------|
| `/forgeify:improve plugin my-plugin ./doc.md` | Skill 도구로 `forgeify:improve-plugin` 호출 |
| `/forgeify:improve skill my-skill ./doc.md` | Skill 도구로 `forgeify:improve-skill` 호출 |
| `/forgeify:improve command my-cmd ./doc.md` | Skill 도구로 `forgeify:improve-command` 호출 |
| `/forgeify:improve agent my-agent ./doc.md` | Skill 도구로 `forgeify:improve-agent` 호출 |
| `/forgeify:improve hook PreToolUse ./doc.md` | Skill 도구로 `forgeify:improve-hook` 호출 |

## 타입 미지정 시

```
어떤 메타도구를 개선할까요?

1. plugin  - 플러그인 전체
2. skill   - 스킬
3. command - 커맨드
4. agent   - 에이전트
5. hook    - 훅

선택:
```

선택 후 해당 스킬 호출.

## 개선 문서

gemify에서 생성된 개선 문서가 필요합니다:
- 위치: `~/.gemify/views/by-improvement/{plugin}-{slug}.md`
- 생성: `/gemify:improve-plugin` 사용
