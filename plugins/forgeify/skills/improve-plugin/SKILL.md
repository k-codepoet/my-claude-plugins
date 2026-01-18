---
name: improve-plugin
description: gemify 개선 문서 기반 플러그인 수정 가이드. "플러그인 개선", "plugin 수정", "improve", "개선 문서 실행" 등 요청 시 활성화됩니다.
---

# Improve Plugin 가이드

gemify에서 생성된 개선 문서를 읽고, 해당 내용에 따라 플러그인을 수정합니다.

> **Note**: `~/.gemify/`는 사용자의 지식 저장소(Single Source of Truth)입니다. 모든 개선 문서는 이곳에서 관리됩니다.

## 단방향 흐름 원칙

```
gemify (지식 생산)        forgeify (실행)
    │                         │
    └── 개선 문서 생성 ──────▶ 개선 문서 실행
        (views/by-improvement/) (/forgeify:improve-plugin)
```

- **gemify**: 대화를 통해 개선 아이디어를 정제하고 views/by-improvement/에 저장
- **forgeify**: views의 개선 문서를 읽고 플러그인에 적용
- 역방향 없음: forgeify는 개선 문서를 생성하지 않음

## 개선 문서 스키마

```yaml
---
title: "{Plugin Name} Improvement"
plugin: {plugin-name}
improvement_type: feature|bugfix|refactor
priority: high|medium|low
problem: "{해결할 문제}"
solution: "{해결 방법}"
artifact: {플러그인 경로 | null}
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
revision: 1
sources: []
history:
  - rev: 1
    date: YYYY-MM-DD
    summary: "초기 생성"
---

## Why - 왜 개선하는가

[배경, 해결할 문제]

## What - 무엇을 바꾸는가

[변경할 내용 상세]

## Scope - 범위

포함/제외 범위 명시

## Acceptance Criteria - 완료 기준

[검증 완료 조건]
```

## 개선 문서 위치

gemify:improve-plugin이 생성하는 개선 문서의 위치:

```
~/.gemify/views/by-improvement/{plugin}-{slug}.md
```

## 워크플로우

### 1단계: 개선 문서 파싱

개선 문서를 읽고 다음 정보를 추출합니다:
- **frontmatter**: plugin, problem, solution, artifact
- **body**: Why (맥락), What (구현 상세), Scope (범위), AC (완료 기준)

### 2단계: 대상 플러그인 확인

`plugin` 필드를 기준으로 플러그인 위치를 찾습니다:
1. `artifact` 필드가 있으면: 해당 경로 사용
2. 현재 디렉토리가 마켓플레이스인 경우: `plugins/{plugin}/` 탐색
3. 현재 디렉토리가 플러그인인 경우: 해당 플러그인이 대상인지 확인
4. 찾지 못한 경우: 사용자에게 플러그인 경로 요청

### 3단계: 참조 문서 로드 (Progressive Disclosure)

`sources` 배열이 있으면 추가 상세 정보를 로드합니다:
- 상대 경로: 개선 문서 기준 상대 경로로 해석
- 절대 경로: 직접 참조

개선 문서와 동일 디렉토리에 `references/` 폴더가 있으면 해당 내용도 참조합니다.

### 4단계: 개선 계획 수립

What 섹션과 AC를 기반으로 구체적인 변경 계획을 수립합니다:
- 생성할 파일 목록
- 수정할 파일 목록
- 각 변경의 상세 내용

### 5단계: 사용자 확인

변경 계획을 사용자에게 제시하고 승인을 받습니다:

```
## 개선 계획: {plugin}

### 문제
{problem}

### 해결책
{solution}

### 변경 사항
1. [CREATE] commands/new-command.md - 새 명령어 추가
2. [MODIFY] plugin.json - 버전 업데이트
...

진행하시겠습니까? [Y/N]
```

### 6단계: 변경 적용

승인 후 변경사항을 적용합니다:
- 파일 생성/수정
- plugin.json 버전 업데이트 (patch 버전 증가)

### 7단계: 검증

변경 완료 후 `/forgeify:validate`를 자동 호출하여 검증합니다.

### 8단계: CHANGELOG.md 업데이트

검증 통과 후 플러그인의 CHANGELOG.md를 업데이트합니다:

```markdown
## [{new-version}] - {YYYY-MM-DD}

### {Added|Changed|Fixed}
- **{변경 제목}** - {간략 설명}
  - {상세 내용}
```

- `improvement_type`에 따라 섹션 결정:
  - `feature` → `### Added`
  - `bugfix` → `### Fixed`
  - `refactor` → `### Changed`
- Keep a Changelog 형식 준수
- 버전은 6단계에서 업데이트한 plugin.json 버전과 일치

## 관련 가이드라인

플러그인 수정 시 다음 스킬의 가이드라인을 따릅니다:
- **plugin-guide**: plugin.json 구조
- **command-guide**: 커맨드 frontmatter
- **skill-guide**: 스킬 구조 (Progressive Disclosure)
- **agent-guide**: 에이전트 작성법

## 주의사항

- 개선 문서가 없거나 형식이 잘못된 경우 에러 메시지 표시
- plugin이 현재 환경에 없으면 사용자에게 경로 확인
- 대규모 변경 시 git status 확인 권장
- 자동 실행 없음: 모든 변경은 사용자 확인 후 진행
