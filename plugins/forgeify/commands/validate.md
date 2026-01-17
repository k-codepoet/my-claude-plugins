---
description: 플러그인이 가이드라인을 준수하는지 검증하고 규격에 맞게 리팩토링합니다.
argument-hint: [plugin-path]
---

# /forgeify:validate

플러그인이 Claude Code 가이드라인을 준수하는지 검증합니다.

## 사용법

```
/forgeify:validate                     # 현재 디렉토리의 플러그인 검증
/forgeify:validate ./plugins/my-plugin # 특정 플러그인 검증
```

## 검증 항목

| 구성요소 | 필수 항목 |
|----------|-----------|
| plugin.json | `name` (kebab-case), `version`, `description`, `author.name` |
| commands/*.md | frontmatter `description` 필수 |
| agents/*.md | `name`, `description`, `<example>` 블록 |
| skills/*/SKILL.md | `name` (디렉토리명 일치), `description` |
| hooks/hooks.json | hooks 객체 구조, `type`/`command` 필드 |

## 검증 프로세스

### 1단계: 기본 검증 스크립트 실행

```bash
bash {forgeify-plugin-path}/scripts/validate-plugin.sh {target-plugin-path}
```

스크립트가 자동 검증하는 항목:
- plugin.json 필수 필드
- commands/*.md의 description frontmatter
- skills/*/SKILL.md의 name, description
- agents/*.md의 name, description, `<example>` 블록
- hooks/hooks.json 구조

### 2단계: 상세 검증 (필요시)

스크립트로 해결 안 되는 문제는 수동으로 상세 검증:
- 가이드 스킬 기준 준수 여부
- 의미적 품질 (description이 when to use를 설명하는지 등)

### 3단계: 리팩토링 제안

- Errors/Warnings 목록화
- 수정 필요 항목 제시
- 사용자 확인 후 수정

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

- Errors는 반드시 수정 필요
- Warnings는 권장 사항
- 사용자 확인 없이 자동 수정하지 않음

상세 검증 기준은 `skills/validate/SKILL.md` 참조.
