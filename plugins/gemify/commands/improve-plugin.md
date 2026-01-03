---
description: 플러그인 개선 문서 생성 - 대화를 통해 개선 아이디어를 정제하고 문서로 저장. 코드 수정은 forgeify로 위임.
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion
argument-hint: [대상 플러그인명]
---

# /gemify:improve-plugin - 플러그인 개선 문서 생성

플러그인 개선 **문서를 생성**합니다. 실제 코드 수정은 `/forgeify:improve`가 담당합니다.

## 단방향 흐름

```
gemify (지식 생산)        forgeify (실행)
    │                         │
    └── 개선 문서 생성 ──────▶ 개선 문서 실행
        (library/...)         (/forgeify:improve)
```

## 사용법

```
/gemify:improve-plugin forgeify     # forgeify 플러그인 개선 문서 작성
/gemify:improve-plugin              # 대상 플러그인 입력 요청
```

## 동작

### 1. 대상 플러그인 확인

```
$ARGUMENTS 있음? → 해당 플러그인명 사용
$ARGUMENTS 없음? → AskUserQuestion으로 플러그인명 요청
                   "어떤 플러그인을 개선할까요?"
```

### 2. 개선 아이디어 파악

대화를 통해 다음을 파악:
- **problem**: 해결할 문제
- **solution**: 해결 방법 요약
- **requirements**: 구체적 요구사항
- **improvement_type**: feature|bugfix|refactor
- **priority**: high|medium|low

### 3. ground-truth 경로 확인

```
$ARGUMENTS에 ground-truth 경로가 있음? → 해당 경로 사용
없음? → AskUserQuestion으로 요청
        "개선 문서를 저장할 ground-truth 경로를 입력해주세요"
        예: ~/k-codepoet/ground-truth
```

### 4. 개선 문서 생성

`{ground-truth}/library/engineering/plugin-improvements/`에 저장:

```yaml
---
target_plugin: {플러그인명}
improvement_type: {타입}
priority: {우선순위}
problem: "{문제 설명}"
solution: "{해결 방법}"
requirements:
  - 요구사항 1
  - 요구사항 2
references: []
domain: engineering
views: []
---

## Why
{개선 이유와 맥락}

## What
{구현할 내용 상세}

## Scope
포함:
- {포함 항목}

제외:
- {제외 항목}
```

### 5. 실행 안내

```
개선 문서가 생성되었습니다:
{생성된 파일 경로}

플러그인에 적용하려면:
/forgeify:improve {생성된 파일 경로}
```

## 파일명 규칙

```
{target_plugin}-{feature-slug}.md
```

예시:
- `forgeify-add-validation.md`
- `gemify-improve-plugin-refactor.md`

## 규칙

- **코드 수정 금지**: gemify는 문서 생성만 담당
- 기존 개선 문서가 있으면 업데이트 또는 새로 생성 선택 제안
- ground-truth 경로가 없으면 반드시 사용자에게 요청
