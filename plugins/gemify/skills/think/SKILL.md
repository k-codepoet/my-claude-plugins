---
description: 도메인 간 교차 사고 시뮬레이션. "생각 좀 해보자", "think", "이건 양쪽 다 관련", "뇌 시뮬레이션", "교차", "cross" 등 요청 시 활성화. 모든 도메인을 횡단하며 연결점을 발견.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, Task
argument-hint: "[상황/질문]"
---

# Think Skill (교차 사고 시뮬레이션)

**여러 도메인의 지식을 동시에 끌어와서 교차점에서 새로운 통찰을 발견합니다.**

이 스킬은 scope의 단일 도메인 제약을 **의도적으로 벗어남**. 모든 도메인을 동시에 읽되, 쓰기는 my-brain 또는 사용자가 지정한 도메인에만 수행.

## 사전 확인

```
~/.gemify/config.json 읽기
→ domains 목록 확인 (my-brain 제외한 실제 도메인들)
→ 각 도메인 경로 확인
→ my-brain 도메인 존재 확인 → 없으면 안내 후 중단
```

## 동작

### Phase 1: 상황 파악

사용자가 상황/질문을 던지면:

1. **상황 정의**: 무엇을 고민하고 있는가? (한 문장으로 정리)
2. **관련 도메인 식별**: 이 고민이 어떤 도메인들에 걸쳐 있는가?

### Phase 2: 교차 탐색

**각 도메인을 병렬로 탐색** (Task agent 활용 권장):

```
도메인별 탐색 범위:
├── builder: library/, views/, visions/, drafts/ (status: cutting)
├── leader: library/, actions/, views/, visions/
└── (기타 도메인): 해당 도메인의 주요 지식 저장소
```

탐색 방법:
1. 상황의 키워드로 각 도메인 library/ 내 Grep 검색
2. 관련 파일의 frontmatter + 핵심 내용 확인
3. 각 도메인에서 끌어온 지식 요약

### Phase 3: 교차 질문

**핵심 — 여기서 시뮬레이션이 일어남**

각 도메인의 관점으로 질문을 던짐:

```markdown
## 교차 질문

### [Builder 관점]
- 이 상황에 적용할 수 있는 기술적 원칙이 있는가?
- 관련 PoC/제품 경험에서 배운 것은?
- {찾은 principle/insight} → 이 맥락에서 어떻게 적용?

### [Leader 관점]
- 이 상황에서의 얼라인 전략은?
- 관련 의사결정 패턴이 있는가?
- {찾은 principle/action} → 이 맥락에서 어떻게 적용?

### [교차점]
- 도메인 A의 {X}가 도메인 B의 {Y}와 어떻게 연결되는가?
- 이 연결에서 새롭게 보이는 것은?
```

**질문은 하나씩 순차적으로** — 사용자와 대화하며 생각을 발전시킴.

### Phase 4: 합성

대화를 통해 도출된 것들을 정리:

```markdown
## 합성 결과

### 발견된 연결
- {domain_a}/{file} ↔ {domain_b}/{file}: {어떤 연결}

### 새로운 통찰
- {insight 내용}

### 다음 액션
- {구체적 행동}
```

### Phase 5: 라우팅

결과물을 어디에 저장할지 제안:

```
라우팅 판단 기준:
├── 특정 도메인에 속하는 insight → 해당 도메인 library/
├── 특정 도메인의 action item → 해당 도메인 actions/ 또는 views/
├── 어느 쪽에도 속하지 않는 교차 통찰 → my-brain/library/
└── 도메인 간 연결 기록 → my-brain/connections/
```

**반드시 사용자 컨펌 후 저장.**

## 세션 기록

**모든 think 세션은 반드시 기록** → `~/.gemify/my-brain/sessions/`

```markdown
---
title: "{주제}"
date: YYYY-MM-DD
domains_touched: [builder, leader]
trigger: "{어떤 상황/질문으로 시작됐는가}"
---

## Context

{상황 설명}

## Cross-Domain Exploration

### From Builder
- {파일 경로}: {끌어온 내용 요약}

### From Leader
- {파일 경로}: {끌어온 내용 요약}

## Synthesis

{교차에서 발견된 것}

## Routing

| 결과물 | 저장 위치 | 상태 |
|--------|----------|------|
| {insight} | {domain}/{path} | saved/proposed |

## Connections Created

- {slug}.md: {from} ↔ {to}
```

## Connection 파일 형식

`~/.gemify/my-brain/connections/{slug}.md`:

```markdown
---
title: "{연결 제목}"
created: YYYY-MM-DD
from: "{domain}/{path}"
to: "{domain}/{path}"
type: reinforces|extends|tensions|complements
---

## 연결

{from}의 {핵심 개념}이 {to}의 {핵심 개념}과 {type} 관계.

## 맥락

{어떤 think 세션에서 발견됐는가}

## 활용

{이 연결을 어떻게 활용할 수 있는가}
```

### Connection Type

| Type | 의미 | 예시 |
|------|------|------|
| **reinforces** | A가 B를 강화 | builder의 execution-first → leader의 decide-first |
| **extends** | A가 B를 확장 | builder의 PoC workflow → leader의 demo preparation |
| **tensions** | A와 B가 긴장 | builder의 deep-mode → leader의 즉시-배치 |
| **complements** | A와 B가 보완 | builder의 기술 밀도 → leader의 설득 전략 |

## 규칙

- **다른 도메인 파일을 직접 수정하지 않음** — 라우팅 제안만
- 질문은 **하나씩 순차적으로**
- **컨펌 없이 저장 안 함**
- 세션 기록은 **항상** 남김
- slug는 영문 kebab-case
- 도메인 탐색 시 `_template.md` 파일 제외

## 예시 시나리오

```
사용자: "새 인프라 도구 도입하려는데, 팀원들 설득이 안 돼"

[Phase 1] 상황: 기술 도입 + 팀 얼라인 → builder + leader 교차

[Phase 2] 탐색:
  Builder → library/principles/execution-first-principle.md
         → library/workflows/poc-with-scenario.md
  Leader → library/principles/align-principle.md
         → library/how-tos/demo-preparation-guide.md
         → actions/context/team.md

[Phase 3] 교차 질문:
  "Builder의 PoC 시나리오 접근법을 팀 설득에 적용하면?"
  "Leader의 얼라인 패턴 중 '보여주는 align'이 여기서 먹힐까?"
  → 대화로 발전

[Phase 4] 합성:
  발견: "PoC를 먼저 만들어 보여주고, 결과로 얼라인하는 전략"
  새 insight: poc-driven-alignment

[Phase 5] 라우팅:
  → leader/library/insights/poc-driven-alignment.md (사용자 컨펌 후)
  → my-brain/connections/execution-first-meets-align.md
```
