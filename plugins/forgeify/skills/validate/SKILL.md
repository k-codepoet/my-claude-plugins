---
name: validate
description: 플러그인이 가이드라인을 준수하는지 검증. "플러그인 검증", "validate", "규격 확인", "리팩토링" 등 요청 시 활성화.
---

# Validate Skill

플러그인이 Claude Code 플러그인 가이드라인을 준수하는지 검증하고, 필요시 리팩토링합니다.

## 참조 스킬 (Progressive Disclosure)

각 구성요소의 상세 검증 기준은 해당 스킬을 참조합니다:

| 구성요소 | 참조 스킬 | 핵심 필수 항목 |
|----------|-----------|----------------|
| plugin.json | **plugin-guide** | `name` (kebab-case), version, description, author |
| commands/*.md | **command-guide** | `description` 필수 |
| agents/*.md | **agent-guide** | `name`, `description`, `<example>` 블록 |
| skills/*/SKILL.md | **skill-guide** | `name` (디렉토리명 일치), `description` |
| hooks/hooks.json | **hook-guide** | 중첩 객체 구조, hooks 배열, type/command 필드 |

## 검증 프로세스

1. **탐색**: 플러그인 루트에서 구성요소 탐색
2. **스킬 참조**: 각 구성요소별 가이드 스킬 로드하여 검증
3. **리포트**: 문제점 목록화 (Errors/Warnings)
4. **리팩토링 제안**: 수정 필요 항목 제시
5. **사용자 확인 후 수정**

## 검증 항목 상세

### plugin.json 검증
- `name`: 필수, kebab-case 형식
- `version`: 필수, semver 형식
- `description`: 필수, 플러그인 설명
- `author.name`: 필수
- `agents`: 개별 .md 파일 경로여야 함 (디렉토리 불가)

### commands/*.md 검증
- frontmatter `description`: 필수
- `allowed-tools`: 권장
- `argument-hint`: 권장

### agents/*.md 검증
- frontmatter `name`: 필수
- frontmatter `description`: 필수, 상세한 트리거 조건 포함
- 본문에 `<example>` 블록: 필수

### skills/*/SKILL.md 검증
- 디렉토리명 = 스킬명 일치
- frontmatter `name`: 필수
- frontmatter `description`: 필수, "무엇 + 언제" 포함
- **Progressive Disclosure 준수**:
  - SKILL.md 본문 <5000 토큰 (권장)
  - 상세 내용은 `references/` 폴더로 분리
  - 핵심 정보 먼저, 상세/예외 사항은 뒤로

### hooks/hooks.json 검증
- 파일 존재 여부 확인 (선택적 - 없어도 에러 아님)
- JSON 파싱 가능 여부
- `hooks` 필드가 **객체** 형태인지 (배열 아님)
- 각 이벤트 키가 유효한 이벤트명인지
- 각 이벤트 배열 내 객체에 `hooks` 배열이 있는지
- 각 훅 항목에 필수 필드 존재:
  - `type`: `"command"` 또는 `"prompt"`
  - `command`: 문자열 형태
- `matcher` 사용 시 Tool 이름 대소문자 정확히
- command 스크립트 파일 존재 및 실행 권한 확인

**유효한 이벤트 키:**
- `PreToolUse`, `PostToolUse`, `PostToolUseFailure`
- `PermissionRequest`, `UserPromptSubmit`, `Notification`
- `SessionStart`, `SessionEnd`, `Stop`
- `SubagentStart`, `SubagentStop`, `PreCompact`

**유효한 matcher 값 (대소문자 정확히):**
- `Bash`, `Read`, `Write`, `Edit`, `MultiEdit`, `Glob`, `Grep`, `Task`
- 정규식 패턴 허용 (예: `Write|Edit|MultiEdit`)

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
