# Library 예시

## 예시: 완성된 library 파일

**파일명**: `library/insights/domain-is-views-lens.md`

```markdown
---
title: "Domain은 Views의 Lens다"
type: insight
origin: original
---

## Context

library 분류 시 6대 domain을 사용했으나 경계가 모호하고 복수 domain 해당 시 하나만 선택해야 하는 문제가 있었음.

## Content

### 핵심 인사이트

- library는 "재료" → 재료를 domain으로 분류하는 건 맞지 않음
- domain은 "이 재료를 어떤 관점에서 보느냐"의 문제
- **domain은 views의 관점(lens)이지, library의 분류 기준이 아니다**

### 결론

- library: Type 기반 분류 (principle, decision, insight, how-to, spec, workflow)
- views: Domain을 lens로 활용하여 재료 조합

## Connections

- `library/decisions/library-type-classification.md` - 이 인사이트 기반 결정
```

## Type 선택 기준

| Type | 핵심 질문 | 예시 |
|------|----------|------|
| principle | 왜 이렇게 해야 하는가? (근본) | "Capture First", "한 번에 하나씩" |
| decision | 무엇을 선택했고 왜? (ADR) | "React 대신 Svelte 선택한 이유" |
| insight | 무엇을 발견했는가? | "domain은 views의 lens다" |
| how-to | 어떻게 하는가? (단일 절차) | "PR 리뷰 프로세스" |
| spec | 무엇이 규격인가? | "API 응답 포맷" |
| workflow | 전체 흐름은? (파이프라인) | "gemify→forgeify 연계" |

## Origin 선택 기준

| Origin | 핵심 질문 |
|--------|----------|
| original | 내 머리에서 나온 거야? |
| digested | 외부 콘텐츠를 내 방식으로 재해석? |
| derived | 이미 만든 결과물에서 역추출? |

## 디렉토리 구조

```
library/
├── principles/
│   └── capture-first.md
├── decisions/
│   └── library-type-classification.md
├── insights/
│   └── domain-is-views-lens.md
├── how-tos/
│   └── pr-review-process.md
├── specs/
│   └── api-response-format.md
├── workflows/
│   └── gemify-forgeify-pipeline.md
└── _template.md
```
