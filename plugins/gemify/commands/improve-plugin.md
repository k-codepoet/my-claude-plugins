---
description: 플러그인 개선 문서 생성 - 대화를 통해 개선 아이디어를 정제하고 문서로 저장. 코드 수정은 forgeify로 위임.
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion
argument-hint: [대상 플러그인명]
---

# /gemify:improve-plugin - 플러그인 개선 문서 생성

플러그인 개선 **문서를 생성**합니다. 실제 코드 수정은 `/forgeify:improve-plugin`이 담당합니다.

## 단방향 흐름

```
gemify (지식 생산)        forgeify (실행)
    │                         │
    └── 개선 문서 생성 ──────▶ 개선 문서 실행
        (views/by-improvement/) (/forgeify:improve-plugin)
```

## 사용법

```
/gemify:improve-plugin forgeify     # forgeify 플러그인 개선 문서 작성
/gemify:improve-plugin              # 대상 플러그인 입력 요청
```

## 워크플로우 (6단계)

| 단계 | 설명 |
|------|------|
| 1. triage | 관련 inbox 자료 수집 (클러스터 기반) |
| 2. draft | facet 모드로 Why/What/Scope/AC 구체화 |
| 3. plugin | 대상 플러그인 확인 |
| 4. view | views/by-improvement/{plugin}-{slug}.md 저장 + 스냅샷 |
| 5. artifact | 플러그인 경로 확인, artifact 필드 업데이트 |
| 6. handoff | forgeify로 실행 안내 |

## 동작

### 1. 입력 분석 (triage 연동)

```
$ARGUMENTS 있음? → 해당 플러그인명 사용, triage로 관련 자료 검색
$ARGUMENTS 없음? → AskUserQuestion으로 플러그인명 요청
                   "어떤 플러그인을 개선할까요?"
```

### 2. 요구사항 구체화 (draft facet 모드)

대화를 통해 다음을 파악:
- **Why**: 해결할 문제, 개선 이유
- **What**: 변경할 내용 상세
- **Scope**: 포함/제외 범위
- **Acceptance Criteria**: 완료 기준
- **improvement_type**: feature|bugfix|refactor
- **priority**: high|medium|low

### 3. ground-truth 경로 확인

```
$ARGUMENTS에 ground-truth 경로가 있음? → 해당 경로 사용
없음? → AskUserQuestion으로 요청
        "개선 문서를 저장할 ground-truth 경로를 입력해주세요"
        예: ~/k-codepoet/ground-truth
```

### 4. view 생성

`{ground-truth}/views/by-improvement/`에 저장:

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

{배경, 해결할 문제}

## What - 무엇을 바꾸는가

{변경할 내용 상세}

## Scope - 범위

**포함:**
- {포함 항목}

**제외:**
- {제외 항목}

## Acceptance Criteria - 완료 기준

- [ ] {완료 기준}

## Context - 참조

{관련 자료 링크}
```

### 5. 스냅샷 생성

`.history/improvement/{plugin}-{slug}/01-YYYY-MM-DD.md` 생성

### 6. forgeify 핸드오프

문서 생성 완료 후 자동 적용 제안:

```
개선 문서가 생성되었습니다:
{views/by-improvement/...}

바로 적용할까요? (y/n)
```

**y 입력 시:**
- forgeify:improve-plugin 자동 호출
- 현재 맥락(생성된 파일 경로)을 전달

**n 입력 시:**
- 기존처럼 명령어 안내만 표시:
  ```
  플러그인에 적용하려면:
  /forgeify:improve-plugin {생성된 파일 경로}
  ```

## 파일명 규칙

```
{plugin}-{feature-slug}.md
```

예시:
- `forgeify-add-validation.md`
- `gemify-improve-plugin-views-pattern.md`

## 규칙

- **코드 수정 금지**: gemify는 문서 생성만 담당
- **views/by-improvement/에 원본 저장**
- **업데이트 시 .history/ 스냅샷 생성**
- 기존 개선 문서가 있으면 업데이트 또는 새로 생성 선택 제안
- ground-truth 경로가 없으면 반드시 사용자에게 요청
