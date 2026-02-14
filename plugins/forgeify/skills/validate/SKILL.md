---
name: validate
description: 플러그인이 가이드라인을 준수하는지 검증. "플러그인 검증", "validate", "규격 확인", "리팩토링" 등 요청 시 활성화.
argument-hint: "[plugin-path]"
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

### 1단계: 기본 검증 스크립트 실행

먼저 `scripts/validate-plugin.sh`를 실행하여 기본 검증을 수행합니다:

```bash
bash {forgeify-plugin-path}/scripts/validate-plugin.sh {target-plugin-path}
```

스크립트가 검증하는 항목:
- plugin.json 필수 필드 (name, version, description, author.name)
- commands/*.md의 description frontmatter
- skills/*/SKILL.md의 name(디렉토리명 일치), description
- agents/*.md의 name, description, `<example>` 블록
- hooks/hooks.json 구조

**Exit codes:**
- `0`: 검증 통과 (errors=0)
- `1`: 검증 실패 (errors>0) → 리팩토링 필요
- `2`: 플러그인 경로 오류

### 2단계: 상세 검증 (필요시)

스크립트로 해결되지 않는 문제나 가이드라인 준수 여부를 확인할 때:
1. **가이드 스킬 읽기**: 해당 구성요소의 가이드 스킬을 **Read 도구로 로드**
2. **검증**: 가이드 스킬의 기준으로 검증
3. **리포트**: 추가 문제점 목록화

### 3단계: 리팩토링

검증 실패 시:
1. **리팩토링 제안**: 수정 필요 항목 제시
2. **사용자 확인 후 수정**

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

## Changelog 검증 (4단계)

스크립트가 자동으로 CHANGELOG.md 일치 여부를 검증합니다:

### 검증 항목

1. **버전 일치**: `plugin.json` 버전과 `CHANGELOG.md` 최신 버전 비교
2. **변경 파일 추적**: CHANGELOG 날짜 이후 git commit에서 변경된 파일 조회

### 필터링 규칙

**제외 파일:**
- `CHANGELOG.md` (자기 자신)
- `.gitignore`, `.gitkeep`
- `*.bak`, `*.tmp`

**의미 있는 변경:**
- `commands/*.md`
- `skills/*/SKILL.md`
- `agents/*.md`
- `hooks/hooks.json`
- `scripts/*.sh`
- `.claude-plugin/plugin.json`

### 출력 예시

```
## changelog/
✅ Version match: plugin.json (1.16.0) = CHANGELOG.md (1.16.0)
⚠️  [WARN] Found 3 file(s) changed after 2026-01-18 not in CHANGELOG:
    - skills/wrapup/SKILL.md
    - scripts/migrate-sessions.sh
    - assets/examples/sessions/20260103-wrapup.md

  Recommendation:
    1. Review if these changes warrant a version bump
    2. Update CHANGELOG.md with changes
    3. Bump version in plugin.json
```

## 규칙

- 사용자 확인 없이 자동 수정하지 않음
- Errors는 반드시 수정 필요, Warnings는 권장
- 검증 결과를 명확하게 분류하여 출력
