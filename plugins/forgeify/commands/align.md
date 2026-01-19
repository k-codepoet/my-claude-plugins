---
description: 공식문서/외부 레퍼런스 기반 가이드 및 플러그인 정렬
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, WebFetch
argument-hint: [target] [--source <url>]
---

# /forgeify:align

## 실행 전 필수

**반드시 스킬을 먼저 읽으세요:**

```
Read: $CLAUDE_PLUGIN_ROOT/skills/align/SKILL.md
```

스킬의 워크플로우를 따라 진행하세요.

## 사용법

```
/forgeify:align [target] [--source <url>]

target:
  - 가이드 이름: plugin-guide, skill-guide, command-guide, agent-guide, hook-guide
  - 플러그인 경로: ./plugins/my-plugin

--source:
  - 공식문서 URL
  - GitHub 레퍼런스 URL
  - 로컬 파일 경로
```

## 예시

```
# 공식문서 기준으로 plugin-guide 갱신
/forgeify:align plugin-guide

# 외부 URL 기준으로 가이드 갱신
/forgeify:align skill-guide --source https://github.com/example/plugin-spec

# 플러그인을 최신 가이드에 맞게 정렬
/forgeify:align ./plugins/my-plugin

# 대화형 모드 (인자 없이)
/forgeify:align
```

ARGUMENTS: $ARGUMENTS
