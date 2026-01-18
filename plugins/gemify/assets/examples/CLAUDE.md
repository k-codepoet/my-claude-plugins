# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

이 저장소는 Gemify 지식 파이프라인을 사용합니다.

```
inbox → draft → library → view
  │       │        │        │
  │       │        │        └─→ vision (방향, 모든 것이 향하는 곳)
  │       │        │
정제되지  다듬기   밀도 있는   흩어진 지식에
않은 생각        지식/재료   의미 부여
```

**핵심**: 원석을 다듬어 보석으로. 생각을 포착하고, 다듬고, 정리합니다.

## Commands

| 명령어 | 설명 | 저장 위치 |
|--------|------|----------|
| `/gemify:inbox [내용]` | 내 생각 포착 | inbox/thoughts/ |
| `/gemify:import [내용]` | 외부 재료 가져오기 | inbox/materials/ |
| `/gemify:draft [파일/아이디어]` | 원석 다듬기 (대화로 확장) | drafts/ |
| `/gemify:library [파일]` | 보석 정리 (library로) | library/ |
| `/gemify:view [type]` | library를 목적별로 조합 | views/ |

## /gemify:draft 대화 모드

```
/gemify:draft
├── facet  - 여러 면 탐색, 넓게 (기본)
└── polish - 깊이 연마 → library 준비
```

- **facet**: 넓게 탐색 ("다른 면에서 보면?", "연결되는 건?")
- **polish**: 깊이 연마 ("왜 중요해?", "핵심만 남기면?")

**polish 트리거**: "연마해봐", "좀 더 다듬자", "핵심이 뭐야"

## Library Type 분류

| Type | 핵심 질문 |
|------|----------|
| principle | 왜 이렇게 해야 하는가? |
| decision | 무엇을 선택했고 왜? |
| insight | 무엇을 알게 됐는가? |
| how-to | 어떻게 하는가? |
| spec | 정확히 무엇인가? |
| workflow | 어떤 순서로 진행하는가? |

## 데이터 디렉토리

- `visions/` - 비전 (지향점, 평가 기준)
- `inbox/thoughts/` - 내 생각 (원석)
- `inbox/materials/` - 외부 재료 (기사, 문서, 대화 등)
- `drafts/` - 다듬는 중인 아이디어
- `library/` - 완성된 지식 (type별 분류)
  - `principles/`, `decisions/`, `insights/`, `how-tos/`, `specs/`, `workflows/`
- `views/` - 서사가 있는 렌더링
  - `by-plugin/` - 플러그인별 종합 문서
  - `by-product/` - 제품별 종합 문서
  - `by-talk/` - 발표/강연
  - `by-curriculum/` - 교육/커리큘럼
  - `by-portfolio/` - 포트폴리오/셀프 브랜딩
  - `by-essay/` - 에세이/수필
  - `by-poc/` - PoC 프로젝트
  - `by-improvement/` - 플러그인 개선
  - `by-bugfix/` - 버그 수정 기록
- `sessions/` - 세션 리포트
- `meta/cluster/` - 지식 클러스터 맵

## Status 상태 흐름

| 폴더 | 상태값 |
|------|--------|
| inbox/ | `raw` → `used` |
| drafts/ | `cutting` → `set` |

## 핵심 규칙

- 질문은 **하나씩 순차적으로**
- 사용자 **컨펌 없이 library에 저장하지 않음**
- 템플릿 파일 (`_template.md`) 처리 대상 제외
- slug는 영문 kebab-case
