---
name: retro
description: 이미 완료된 작업을 역방향으로 기록. "사후 기록", "역방향", "retro", "이미 만들었는데" 등 요청 시 활성화. 밀도 평가 후 적절한 단계(inbox/draft/library) 제안.
---

# Retro Skill (사후처리)

**이미 완료된 작업**의 의사결정 과정을 역방향으로 library에 기록합니다.

## 사전 확인 (필수)

**스킬 실행 전 반드시 확인:**

```
~/.gemify/ 존재?
├── 예 → 스킬 실행 계속
└── 아니오 → setup 안내 후 중단
```

Setup 안내:
```
~/.gemify/가 설정되지 않았습니다.

설정하기:
  /gemify:setup              # 새로 시작
  /gemify:setup --clone URL  # 기존 repo 가져오기
```

## 언제 사용하나

- 아이디어 논의 → 바로 구현해버린 경우
- inbox → drafts → library 흐름을 건너뛰고 작업한 경우
- 사후에 의사결정/지식을 기록하고 싶을 때

## 일반 흐름 vs Retro 흐름

```
[일반 흐름]
inbox → drafts → library → 구현

[Retro 흐름]
아이디어 → 구현(완료) → /gemify:retro → [밀도 평가] → 적절한 단계
                                            │
                        ┌───────────────────┼───────────────────┐
                        ▼                   ▼                   ▼
                  inbox 수준           draft 수준          library 수준
                  (정리 필요)          (다듬기 필요)       (바로 저장 가능)
```

## 동작

1. 대화 맥락에서 **완료된 작업** 파악
2. **밀도 평가**: 대화 내용이 어느 수준인지 판단
3. 수준에 맞는 소크라테스식 질문 (순차, 하나씩):
   - inbox 수준 → "먼저 생각을 정리해볼까? inbox에 저장하고 나중에 다듬자"
   - draft 수준 → "핵심이 뭐야? 좀 더 다듬어볼까?"
   - library 수준 → "어떤 type이야? (principle/decision/insight/how-to/spec/workflow)"
4. **역방향 추적**: 빠진 단계가 있다면 채우기 제안
5. 사용자 컨펌 후 해당 단계에 저장 (`library/{type}s/{slug}.md`)

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
