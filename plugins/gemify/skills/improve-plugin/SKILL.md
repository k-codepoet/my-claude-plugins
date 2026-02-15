---
description: 플러그인 개선 문서 생성. "플러그인 개선 아이디어", "plugin 개선안", "개선 문서 작성" 등 요청 시 활성화. 코드 수정은 forgeify로 위임.
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion
argument-hint: "[대상 플러그인명]"
---

# Improve Plugin Skill

플러그인 개선 **문서를 생성**합니다. 실제 코드 수정은 forgeify가 담당합니다.

## 사전 확인 (필수)

**반드시 `skills/scope/SKILL.md` 참조하여 현재 도메인 경로 결정.**

```
~/.gemify/ 존재?
├── 예 → config.json에서 현재 도메인 확인 → 스킬 실행
└── 아니오 → setup 안내 후 중단
```

## 단방향 흐름 원칙

```
gemify (지식 생산)        forgeify (실행)
    │                         │
    └── 개선 문서 생성 ──────▶ 개선 문서 실행
        (views/by-improvement/) (/forgeify:improve-plugin)
```

- **gemify**: 대화를 통해 개선 아이디어를 정제하고 문서로 저장
- **forgeify**: 저장된 개선 문서를 읽고 플러그인에 적용
- 역방향 없음: gemify는 코드를 직접 수정하지 않음

## 워크플로우 (6단계)

| 단계 | 설명 |
|------|------|
| 1. triage | 관련 inbox 자료 수집 (클러스터 기반) |
| 2. draft | facet 모드로 Why/What/Scope/AC 구체화 |
| 3. plugin | 대상 플러그인 확인 |
| 4. view | views/by-improvement/{plugin}-{slug}.md 저장 + 스냅샷 |
| 5. artifact | 플러그인 경로 확인, artifact 필드 업데이트 |
| 6. handoff | forgeify로 실행 안내 |

## Go/No-Go 체크 (깊어질 것 같은 작업)

작업이 5분 이상 걸릴 것 같으면 먼저 체크:

```
□ 실제 문제가 발생했는가? (미래 걱정 아닌지)
□ 현재 사용자가 나만인가?
□ 문제가 발생하면 그때 해도 늦지 않은가?
```

**판정**:
- 3개 모두 "아니오" → **Go** (진행)
- 하나라도 "예" → **No-Go** (즉시 중단, 우선순위 재점검)

핵심 원칙: **기록은 자유롭게, 실행은 신중하게**

## 동작

### 1. 입력 분석 (triage 연동)

- 플러그인명 + 문제 설명 → 해당 플러그인 기반으로 triage 검색
- inbox 파일 경로 → 해당 파일 기반으로 triage 확장
- 없음 → "어떤 플러그인을 개선할까요?" 후 triage 모드

### 2. 요구사항 구체화 (draft facet 모드)

대화를 통해 파악:
- **Why**: 배경, 해결할 문제
- **What**: 변경할 내용 상세
- **Scope**: 포함/제외 범위
- **Acceptance Criteria**: 완료 기준

### 3. 플러그인 확인

대상 플러그인 존재 여부 확인 → artifact 경로 설정

### 4. view 생성

- views/by-improvement/{plugin}-{slug}.md 파일 생성
- .history/improvement/{plugin}-{slug}/01-YYYY-MM-DD.md 스냅샷
- 템플릿: `references/view-template.md` 참조

### 5. artifact 설정

플러그인 경로가 확인되면 `artifact` 필드 업데이트

### 6. forgeify 핸드오프

문서 생성 완료 후 자동 적용 제안:

```
개선 문서가 생성되었습니다:
{views/by-improvement/...}

바로 적용할까요? (y/n)
```

**y 입력 시 (중요!):**

> ⚠️ **gemify가 직접 코드를 수정하면 안 됨!**
> 반드시 Skill 도구로 `forgeify:improve-plugin` 스킬을 호출해야 함.

```
Skill 도구 사용:
  skill: "forgeify:improve-plugin"
  args: "{생성된 파일 경로}"
```

- Skill 도구로 forgeify:improve-plugin 호출
- 생성된 파일 경로를 args로 전달
- forgeify가 문서를 읽고 코드 수정 실행

**n 입력 시:**
- 명령어 안내만 표시:
  ```
  플러그인에 적용하려면:
  /forgeify:improve-plugin {생성된 파일 경로}
  ```

### 단방향 원칙과 위임

- **gemify는 절대 직접 코드를 수정하지 않음**
- forgeify에게 **Skill 도구로 위임**하는 것이므로 원칙 위반 아님
- 사용자 확인(y) 후 Skill 도구로 forgeify 실행

## 저장 위치

개선 문서는 현재 도메인의 `views`에 저장합니다.

> **Note**: `~/.gemify/{domain}/`은 해당 도메인의 지식 저장소(Single Source of Truth)입니다.

```
{domain_path}/
└── views/
    ├── by-improvement/
    │   └── {plugin}-{slug}.md
    └── .history/
        └── improvement/
            └── {plugin}-{slug}/
                └── 01-YYYY-MM-DD.md
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
- `~/.gemify/` 경로가 없으면 `/gemify:setup` 안내
- 도메인 경로는 scope 스킬 규칙에 따라 결정됨
- 기존 개선 문서가 있으면 업데이트 또는 새로 생성 선택 제안
