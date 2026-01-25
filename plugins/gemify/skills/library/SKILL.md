---
name: library
description: drafts의 다듬어진 보석을 library로 저장. "정리해", "분류해", "library" 요청 또는 draft 세션에서 완성도 충분 시 활성화.
---

# Library Skill

drafts의 다듬어진 보석을 **소크라테스식 질문**으로 정리하여 library에 저장합니다.

## 사전 확인 (필수)

**반드시 `skills/scope/SKILL.md` 참조하여 현재 도메인 경로 결정.**

```
~/.gemify/ 존재?
├── 예 → config.json에서 현재 도메인 확인 → 스킬 실행
└── 아니오 → setup 안내 후 중단
```

## 핵심 행동

### 1. 소크라테스식 질문 (순차, 하나씩)

| Phase | 질문 |
|-------|------|
| 목적 | "이거 왜 남기려고 해?", "이게 없으면 나중에 뭐가 안 돼?" |
| 압축 | "한 문장으로 요약하면?", "진짜 핵심만 남기면?" |
| 분류 | "어떤 타입이야? (principle/decision/insight/how-to/spec/workflow)" |
| 출처 | "원본이야, 소화한 거야, 추출한 거야? (original/digested/derived)" |
| 연결 | "기존 library에 연결되는 거 있어?" |

### 2. 재조립 제안

답변을 바탕으로 구조화된 문서 초안 제시. (상세: `references/library-format.md`)

### 3. 저장

사용자 컨펌 후:
1. `library/{type}s/{slug}.md`로 저장
2. 원본 drafts 파일의 status → `set`
3. 완료 보고

## library 파일 형식 (YAML frontmatter)

```markdown
---
title: {제목}
type: principle | decision | insight | how-to | spec | workflow
origin: original | digested | derived
---

## Context

{왜 이 지식이 필요한지}

## Content

{핵심 내용}
```

## Type 분류

| Type | 설명 | 예시 |
|------|------|------|
| principle | 근본 원칙, 철학 | "Capture First", "한 번에 하나씩" |
| decision | 의사결정 기록 (ADR) | "React 대신 Svelte 선택한 이유" |
| insight | 발견, 깨달음 | "domain은 views의 lens다" |
| how-to | 방법론, 절차 | "PR 리뷰 프로세스" |
| spec | 명세, 스펙 | "API 응답 포맷" |
| workflow | input→output 파이프라인 | "gemify→forgeify 연계 흐름" |

**workflows vs how-tos:**
- **how-to**: 단일 작업의 방법론/절차
- **workflow**: 여러 단계/도구를 연결한 파이프라인

## Origin 분류

| Origin | 설명 |
|--------|------|
| original | 내 생각에서 나온 것 |
| digested | 외부 콘텐츠를 소화해서 내 방식으로 재구성 |
| derived | 산출물(artifact)에서 역추출한 것 |

## 규칙

- 질문은 **하나씩 순차적으로**
- **컨펌 없이 저장 안 함**
- 템플릿 파일 (`_template.md`) 제외
- slug는 영문 kebab-case

## 실행 문서 역제안 (library 저장 후)

library에 지식을 저장한 직후, **실행이 필요한 지식인지 판단**하여 능동적으로 실행 문서를 제안합니다.

### 판단 로직

```
실행 필요 신호:
├─ 키워드: "해야겠다", "하면 좋겠다", "만들어보자", "고쳐야", "추가하자"
├─ 대상 언급: gemify, forgeify, craftify 등 플러그인명
└─ 타입: principle/workflow인데 적용 대상이 명확한 경우
```

### 제안 분기

| 신호 | 제안할 실행 문서 |
|------|-----------------|
| 플러그인/스킬 개선 언급 | `views/by-improvement/` (improvement) |
| 신규 제품/기능 아이디어 | `views/by-poc/` (poc) |
| 버그/문제 해결 기록 | `views/by-bugfix/` (bugfix) |
| 순수 기록 (실행 불필요) | 제안 없이 종료 |

### 제안 멘트

```markdown
## 실행 문서 제안

이 {type}을 실제로 적용하려면 **{action_type} 문서**가 필요해 보여요.

대상: {target_plugin}
문서 위치: views/{by-folder}/

작성할까요? (Y/n)
```

### 승인 시 동작

사용자가 승인하면 해당 실행 문서(`improvement`/`poc`/`bugfix`)를 자동 생성합니다.

## References

상세 형식과 예시는 `references/` 폴더 참조:
- `references/library-format.md` - library 파일 형식, type/origin 설명
- `references/example-library.md` - 실제 library 파일 예시, type 선택 기준

## Core Principles

상세: `principles/classification-system.md` 참조
