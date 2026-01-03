---
description: 플러그인이 가이드라인을 준수하는지 검증하고 규격에 맞게 리팩토링합니다. 플러그인 검증, 규격 확인, 리팩토링이 필요할 때 사용합니다.
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
argument-hint: [plugin-path]
---

# Plugin Validation & Refactoring

지정된 플러그인(또는 현재 디렉토리)이 Claude Code 플러그인 가이드라인을 준수하는지 검증하고, 필요시 리팩토링합니다.

## 사용법

```
/forgeify:validate                     # 현재 디렉토리의 플러그인 검증
/forgeify:validate ./plugins/my-plugin # 특정 플러그인 검증
```

## 검증 기준

각 구성요소의 상세 검증 기준은 해당 스킬을 참조합니다:

| 구성요소 | 참조 스킬 | 핵심 필수 항목 |
|----------|-----------|----------------|
| plugin.json | plugin-guide | `name` (kebab-case) |
| commands/*.md | command-guide | `description` |
| agents/*.md | agent-guide | `name`, `description` |
| skills/*/SKILL.md | skill-guide | `name` (디렉토리명 일치), `description` |

## 검증 프로세스

1. **탐색**: 플러그인 루트에서 구성요소 탐색
2. **스킬 참조**: 각 구성요소별 가이드 스킬 로드하여 검증
3. **리포트**: 문제점 목록화
4. **리팩토링 제안**: 수정 필요 항목 제시
5. **사용자 확인 후 수정**

## 출력 형식

```
## Validation Report: {plugin-name}

### Summary
- Total issues: N
- Errors: N (must fix)
- Warnings: N (recommended)

### Errors
1. [plugin.json] Missing required field: name
2. [commands/deploy.md] Missing frontmatter

### Warnings
1. [skills/my-skill/SKILL.md] Description doesn't explain when to use

### Refactoring Actions
1. Add `name` field to plugin.json
...

Proceed with refactoring? (y/n)
```
