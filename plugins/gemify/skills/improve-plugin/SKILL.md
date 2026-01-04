---
name: improve-plugin
description: 플러그인 개선 문서 생성. "플러그인 개선 아이디어", "plugin 개선안", "개선 문서 작성" 등 요청 시 활성화. 코드 수정은 forgeify로 위임.
---

# Improve Plugin Skill

플러그인 개선 **문서를 생성**합니다. 실제 코드 수정은 forgeify가 담당합니다.

## 단방향 흐름 원칙

```
gemify (지식 생산)        forgeify (실행)
    │                         │
    └── 개선 문서 생성 ──────▶ 개선 문서 실행
        (library/...)         (/forgeify:improve-plugin)
```

- **gemify**: 대화를 통해 개선 아이디어를 정제하고 문서로 저장
- **forgeify**: 저장된 개선 문서를 읽고 플러그인에 적용
- 역방향 없음: gemify는 코드를 직접 수정하지 않음

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

1. (깊어질 것 같으면) Go/No-Go 체크 실행
2. 대화를 통해 개선 아이디어 파악
3. 관련 inbox/materials 탐색 (기존 아이디어 참조)
4. 개선 문서 작성 (frontmatter + body 스키마)
5. `library/engineering/plugin-improvements/`에 저장
6. forgeify로 실행 안내

## 개선 문서 스키마

```yaml
---
target_plugin: plugin-name          # 대상 플러그인 이름
improvement_type: feature|bugfix|refactor
priority: high|medium|low
problem: "해결할 문제 설명"
solution: "해결 방법 요약"
requirements:                        # 구체적 요구사항 목록
  - 요구사항 1
  - 요구사항 2
references: []                       # 추가 참조 문서
domain: engineering
views: []
---

## Why
개선 이유와 맥락

## What
구현할 내용 상세

## Scope
포함:
- 포함 항목

제외:
- 제외 항목
```

## 저장 위치

개선 문서는 ground-truth의 library에 저장합니다:

```
{ground-truth-path}/
└── library/
    └── engineering/
        └── plugin-improvements/
            └── {plugin-name}-{feature-slug}.md
```

## 파일명 규칙

```
{target_plugin}-{feature-slug}.md
```

예시:
- `forgeify-add-validation.md`
- `gemify-improve-plugin-refactor.md`

## 실행 연계

문서 생성 완료 후 안내:

```
개선 문서가 생성되었습니다:
{생성된 파일 경로}

플러그인에 적용하려면:
/forgeify:improve-plugin {생성된 파일 경로}
```

## 규칙

- **코드 수정 금지**: gemify는 문서 생성만 담당
- ground-truth 경로 필요 시 사용자에게 요청
- 기존 개선 문서가 있으면 업데이트 또는 새로 생성 선택 제안
