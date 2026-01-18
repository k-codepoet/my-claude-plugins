---
title: 분류 체계 (Library Type)
type: principle
origin: original
views: [gemify]
---

# 분류 체계 (Classification System)

## Library Type 분류

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

## Views 타입

**핵심 개념**: library = 모델(재사용 가능한 원자 단위), views = 렌더링(서사가 있는 스토리텔링)

| View 타입 | 서사의 핵심 질문 |
|-----------|-----------------|
| by-plugin | 이 플러그인은 무엇이고 어떻게 동작하는가? |
| by-product | 이 제품은 무엇이고 어떻게 만들어졌는가? |
| by-talk | 청중이 무엇을 깨닫고 가는가? |
| by-curriculum | 학습자가 무엇을 할 수 있게 되는가? |
| by-portfolio | 나는 어떤 사람인가? |
| by-essay | 나는 무엇을 믿고/느끼는가? |
| by-poc | 어떤 가설을 어떻게 검증하려 하는가? |
| by-improvement | 어떤 문제를 어떻게 개선하는가? |
| by-bugfix | 어떤 버그를 어떻게 수정했는가? |

## 마이그레이션 히스토리

- **2026-01-04**: library의 domain 기반 분류(`library/{domain}/`)를 type 기반(`library/{type}s/`)으로 마이그레이션
- **이유**: domain은 "영역"이고 type은 "형태". library는 지식의 형태로 분류하는 것이 더 적합
- **2026-01-18**: by-subject 및 6대 domain 제거. views는 목적별 타입으로만 분류
