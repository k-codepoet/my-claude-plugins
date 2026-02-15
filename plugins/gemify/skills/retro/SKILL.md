---
description: 이미 완료된 작업을 사후 처리. "사후 기록", "역방향", "retro", "이미 만들었는데" 등 요청 시 활성화. gemify의 모든 관점을 병렬로 적용하여 가장 적합한 경로로 라우팅.
allowed-tools: Read, Write, Edit
---

# Retro Skill (사후처리)

**이미 완료된 작업**에서 놓쳤던 지식 조각들을 수확합니다. gemify의 모든 관점을 병렬로 적용하여 가장 적합한 경로로 라우팅합니다.

## 사전 확인 (필수)

**반드시 `skills/scope/SKILL.md` 참조하여 현재 도메인 경로 결정.**

```
~/.gemify/ 존재?
├── 예 → config.json에서 현재 도메인 확인 → 스킬 실행
└── 아니오 → setup 안내 후 중단
```

## 언제 사용하나

- 아이디어 논의 → 바로 구현해버린 경우
- inbox → drafts → library 흐름을 건너뛰고 작업한 경우
- 사후에 의사결정/지식을 기록하고 싶을 때

## 일반 흐름 vs Retro 흐름

```
[일반 흐름]
inbox → drafts → library → view → vision

[Retro 흐름]
아이디어 → 구현(완료) → /gemify:retro → [모든 관점 병렬 적용] → 가장 적합한 경로
```

## 라우팅 대상

retro는 gemify의 모든 관점을 병렬로 적용하여 가장 적합한 경로로 라우팅:

```
retro
  ├→ inbox (정제 안 된 조각)
  ├→ draft (다듬을 것)
  ├→ library (밀도 있는 지식) ← 대부분 여기로
  ├→ view (의미 부여된 것)
  ├→ poc (PoC 문서화)
  ├→ improve-plugin (플러그인 개선)
  └→ bugfix (버그 수정 기록)
```

**고밀도 작업일수록 library 재료가 많이 추출됨**

## 동작

1. 대화 맥락에서 **완료된 작업** 파악
2. **모든 관점 병렬 적용**: 어떤 유형의 지식이 담겨있는지 분석
   - principle? decision? insight? how-to? spec? workflow?
   - PoC 개발? 플러그인 개선? 버그 수정?
3. 추출 가능한 지식 조각들 나열
4. 각 조각의 밀도 평가 + 적합한 경로 제안
5. 사용자 컨펌 후 해당 경로로 저장

## 밀도 평가 기준

| 수준 | 특징 | 제안 |
|------|------|------|
| **inbox 수준** | 생각/재료 상태, 구조화 필요 | inbox → draft → library |
| **draft 수준** | 아이디어 있지만 정제 필요 | draft 먼저 → library |
| **library 수준** | 핵심 지식 정제됨, 단일 주제 | library로 |
| **view 수준** | 서사 완성, 연결 명확, 재사용 가능 | view 또는 library로 |

## library 파일 형식

```markdown
---
title: {제목}
type: principle | decision | insight | how-to | spec | workflow
origin: original | digested | derived
created_via: retro
---

## Context

{왜 이 작업을 했는지, 배경}

## Content

{핵심 내용}

## Lessons

{나중에 참고할 교훈 - 선택적}
```

## Library Type

| Type | 핵심 질문 |
|------|----------|
| principle | 왜 이렇게 해야 하는가? |
| decision | 무엇을 선택했고 왜? |
| insight | 무엇을 알게 됐는가? |
| how-to | 어떻게 하는가? |
| spec | 정확히 무엇인가? |
| workflow | 어떤 순서로 진행하는가? |

## 규칙

- 질문은 **하나씩 순차적으로**
- **컨펌 없이 저장 안 함**
- `created_via: retro`로 사후 기록임을 표시
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

## 예시 시나리오

```
사용자: 방금 improve-plugin 스킬을 만들었는데, 기록해줘
→ /gemify:retro 활성화
→ 밀도 평가: library 수준 (핵심 결정 명확)
→ type 질문 → workflow 선택
→ library/workflows/improve-plugin-workflow.md 저장
```

## Core Principles

상세: `principles/pipeline-density.md`, `principles/classification-system.md` 참조
