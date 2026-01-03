---
description: 플러그인이 가이드라인을 준수하는지 검증하고 규격에 맞게 리팩토링합니다. 플러그인 검증, 규격 확인, 리팩토링이 필요할 때 사용합니다.
allowed-tools: Read, Glob, Grep, Write, Edit, Bash
argument-hint: [plugin-path]
---

# Plugin Validation & Refactoring

지정된 플러그인(또는 현재 디렉토리)이 Claude Code 플러그인 가이드라인을 준수하는지 검증하고, 필요시 리팩토링합니다.

## 사용법

```
/ced:validate                     # 현재 디렉토리의 플러그인 검증
/ced:validate ./plugins/my-plugin # 특정 플러그인 검증
```

## 검증 체크리스트

### 1. 플러그인 구조 (plugin-guide)

- [ ] `.claude-plugin/plugin.json` 존재 여부
- [ ] `name` 필드: kebab-case, 고유 식별자
- [ ] `version` 필드: semver 형식 (예: 1.0.0)
- [ ] `description` 필드: 간결한 설명
- [ ] 경로 참조가 올바른지 (commands, agents, skills)
- [ ] **agents 필드 형식**: 반드시 `.md` 파일 경로로 끝나야 함 (디렉토리 형식 불가)
  - ❌ 잘못됨: `"agents": ["./agents/"]`
  - ✅ 올바름: `"agents": ["./agents/infra-setup.md"]`
  - 주의: commands, skills는 디렉토리 지정 가능하지만, agents는 개별 파일만 허용

### 2. 커맨드 검증 (command-guide)

`commands/*.md` 파일 각각에 대해:
- [ ] YAML frontmatter 존재
- [ ] `name` 필드: 필수
- [ ] `description` 필드: 필수, 무엇을 하는지 명확히
- [ ] `allowed-tools` 필드: 필요한 도구만 명시 (선택)

### 3. 에이전트 검증 (agent-guide)

`agents/*.md` 파일 각각에 대해:
- [ ] YAML frontmatter 존재
- [ ] `name` 필드: 소문자+하이픈
- [ ] `description` 필드: 언제 사용할지 자연언어로 설명
- [ ] `tools` 필드: 필요한 도구 목록 (선택)
- [ ] `model` 필드: sonnet, opus, haiku, inherit 중 하나 (선택)
- [ ] 본문에 `<example>` 블록 포함 (권장)

### 4. 스킬 검증 (skill-guide)

`skills/*/SKILL.md` 파일 각각에 대해:
- [ ] 디렉토리명과 `name` 필드 일치
- [ ] `name` 필드: 1-64자, 소문자+숫자+하이픈
- [ ] `description` 필드: 무엇을 하는지 + 언제 사용하는지 포함
- [ ] 본문 5000 토큰 이하 권장 (Progressive Disclosure)

### 5. 스크립트 검증

`scripts/*.sh` 파일 각각에 대해:
- [ ] `set -e` 사용 (fail-fast)
- [ ] `${CLAUDE_PLUGIN_ROOT}` 사용 시 올바른 참조
- [ ] 플랫폼 검증 로직 포함 (필요시)
- [ ] 멱등성 보장 (이미 설치된 경우 스킵)

## 검증 프로세스

1. **탐색**: 플러그인 루트에서 모든 구성요소 탐색
2. **검증**: 각 파일을 읽고 체크리스트 대조
3. **리포트**: 발견된 문제점 목록화
4. **리팩토링 제안**: 수정이 필요한 항목 제시
5. **사용자 확인**: 리팩토링 진행 여부 확인
6. **수정 적용**: 승인된 항목 수정

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
3. [plugin.json] agents field uses directory format - must be individual .md files

### Warnings
1. [skills/my-skill/SKILL.md] Description doesn't explain when to use
2. [agents/helper.md] No example blocks found

### Refactoring Actions
1. Add `name` field to plugin.json
2. Add YAML frontmatter to commands/deploy.md
...

Proceed with refactoring? (y/n)
```
