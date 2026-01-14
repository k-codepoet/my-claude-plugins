---
name: validate
description: 플러그인이 가이드라인을 준수하는지 검증. "플러그인 검증", "validate", "규격 확인", "리팩토링" 등 요청 시 활성화.
---

# Validate Skill

플러그인이 Claude Code 플러그인 가이드라인을 준수하는지 검증하고, 필요시 리팩토링합니다.

## 참조 스킬 (Progressive Disclosure)

**중요: 각 구성요소 검증 전 반드시 해당 가이드 스킬을 먼저 읽어서 최신 기준을 확인하세요.**

| 구성요소 | 참조 스킬 (반드시 읽기) |
|----------|------------------------|
| plugin.json | `skills/plugin-guide/SKILL.md` |
| commands/*.md | `skills/command-guide/SKILL.md` |
| agents/*.md | `skills/agent-guide/SKILL.md` |
| skills/*/SKILL.md | `skills/skill-guide/SKILL.md` |
| hooks/hooks.json | `skills/hook-guide/SKILL.md` |
| marketplace.json | `skills/marketplace-guide/SKILL.md` |

## 검증 프로세스

1. **탐색**: 플러그인 루트에서 구성요소 탐색
2. **가이드 스킬 읽기**: 각 구성요소별 가이드 스킬을 **Read 도구로 먼저 로드**
3. **검증**: 가이드 스킬의 기준으로 검증 (이 스킬의 요약이 아닌 가이드 스킬 원본 기준)
4. **리포트**: 문제점 목록화 (Errors/Warnings)
5. **리팩토링 제안**: 수정 필요 항목 제시
6. **사용자 확인 후 수정**

## 검증 항목 요약

> **주의**: 아래는 빠른 참조용 요약입니다.
> **실제 검증 시에는 반드시 해당 가이드 스킬을 Read로 먼저 읽고 그 기준을 따르세요.**

| 구성요소 | 핵심 필수 항목 | 상세 기준 |
|----------|----------------|-----------|
| plugin.json | name, version, description, author.name | → plugin-guide |
| commands/*.md | frontmatter `description` | → command-guide |
| agents/*.md | name, description, `<example>` 블록 | → agent-guide |
| skills/*/SKILL.md | name (디렉토리명 일치), description | → skill-guide |
| hooks/hooks.json | hooks 객체, type, command | → hook-guide |

## 출력 형식

```
## Validation Report: {plugin-name}

### Summary
- Total issues: N
- Errors: N (must fix)
- Warnings: N (recommended)

### Errors
1. [plugin.json] Missing required field: name

### Warnings
1. [skills/my-skill/SKILL.md] Description doesn't explain when to use

### Refactoring Actions
1. Add `name` field to plugin.json

Proceed with refactoring? (y/n)
```

## 규칙

- 사용자 확인 없이 자동 수정하지 않음
- Errors는 반드시 수정 필요, Warnings는 권장
- 검증 결과를 명확하게 분류하여 출력
