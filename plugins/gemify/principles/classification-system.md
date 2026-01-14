---
title: 분류 체계 (Type vs Domain)
type: principle
origin: original
views: [gemify]
---

# 분류 체계 (Classification System)

## 두 가지 분류 체계

Gemify는 **Type**과 **Domain** 두 가지 분류 체계를 사용합니다.

### Type (library 분류)

지식의 **형태**에 따른 분류. `library/{type}s/`에 저장.

| Type | 핵심 질문 | 예시 |
|------|----------|------|
| principle | 왜 이렇게 해야 하는가? | "Capture First", "밀도 기반 파이프라인" |
| decision | 무엇을 선택했고 왜? | "React 대신 Svelte 선택 이유" |
| insight | 무엇을 알게 됐는가? | "domain은 views의 lens다" |
| how-to | 어떻게 하는가? | "PR 리뷰 프로세스" |
| spec | 정확히 무엇인가? | "API 응답 포맷" |
| workflow | 어떤 순서로 진행하는가? | "gemify→forgeify 연계 흐름" |

**디렉토리 구조**: `library/principles/`, `library/decisions/`, `library/insights/`, `library/how-tos/`, `library/specs/`, `library/workflows/`

### Domain (views 분류)

지식의 **영역**에 따른 분류. `views/by-subject/`에서 렌즈로 사용.

| Domain | 핵심 질문 |
|--------|----------|
| product | 무엇을 만들 것인가? |
| engineering | 어떻게 만들 것인가? |
| operations | 어떻게 돌릴 것인가? |
| growth | 어떻게 알릴 것인가? |
| business | 어떻게 유지할 것인가? |
| ai-automation | 어떻게 위임할 것인가? |

**사용처**: views의 subject 주제, 클러스터링 시 상위 카테고리

## Type vs Domain

| | Type | Domain |
|---|---|---|
| 분류 기준 | 지식의 형태 | 지식의 영역 |
| 사용처 | library 저장 | views 렌더링 |
| 경로 | `library/{type}s/` | `views/by-subject/` |
| 예시 | principle, decision | product, engineering |

## 마이그레이션 히스토리

- **2026-01-04**: library의 domain 기반 분류(`library/{domain}/`)를 type 기반(`library/{type}s/`)으로 마이그레이션
- **이유**: domain은 "영역"이고 type은 "형태". library는 지식의 형태로 분류하는 것이 더 적합
- **domain 활용**: views에서 subject별 조합 시 렌즈로 사용
