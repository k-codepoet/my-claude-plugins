---
name: human-decision
description: 의사결정 기록 생성. "결정 기록해", "decision", "왜 이걸 선택했어?", "ADR" 등 의사결정 문서화 요청 시 활성화.
---

# Human Decision Skill

library의 지식을 **의사결정 기록(ADR 스타일)**으로 발전시킵니다.

## 핵심 행동

### 1. Library 안착 확인

먼저 관련 지식이 library에 안착되어 있는지 확인:
- 안착됨 → 의사결정 추출 진행
- 미안착 → "/gemify:library 먼저 실행하시겠어요?" 제안

### 2. 소크라테스식 질문 (순차, 하나씩)

| Phase | 질문 |
|-------|------|
| 결정 | "무슨 결정을 해야 해?" |
| 옵션 | "어떤 옵션들이 있어?" |
| 선택 | "왜 이걸 선택했어?" |
| 결과 | "결과가 어떻게 될 것 같아?" |

### 3. 재조립 제안

답변을 바탕으로 의사결정 문서 초안 제시:

```markdown
---
id: decision-{seq}-{slug}
created: {ISO8601}
status: {proposed|accepted|deprecated|superseded}
superseded_by: null
---

## Title
{결정 제목}

## Context
{결정이 필요한 상황, 배경}

## Options Considered
1. **Option A**: {설명}
   - Pros:
   - Cons:
2. **Option B**: {설명}
   - Pros:
   - Cons:

## Decision
{선택한 옵션과 이유}

## Consequences
{예상되는 결과, 영향}
```

### 4. seq 자동 부여

기존 `docs/humans/decisions/` 파일에서 가장 높은 seq 찾아 +1:
- 파일명 패턴: `decision-{seq}-{slug}.md`
- 예: decision-001, decision-002 → 다음은 decision-003

### 5. 저장

사용자 컨펌 후:
1. `docs/humans/decisions/` 디렉토리 확인 (없으면 생성)
2. `docs/humans/decisions/decision-{seq}-{slug}.md`로 저장
3. 완료 보고

## 규칙

- 질문은 **하나씩 순차적으로**
- **컨펌 없이 저장 안 함**
- 템플릿 파일 (`_template.md`) 제외
- slug는 영문 kebab-case
- library 안착 여부 먼저 확인
- status 기본값은 `accepted` (이미 결정된 경우)

## Decision Status

| Status | 설명 |
|--------|------|
| proposed | 제안됨, 아직 결정 안 됨 |
| accepted | 결정됨, 현재 적용 중 |
| deprecated | 더 이상 유효하지 않음 |
| superseded | 다른 결정으로 대체됨 (superseded_by 필드 참조) |

## Decision vs Library 차이

| 구분 | Library | Decision |
|------|---------|----------|
| 성격 | 도메인별 지식 (what I know) | 선택 기록 (what I chose) |
| 위치 | `library/{domain}/` | `docs/humans/decisions/` |
| 용도 | 참조용 지식 | 의사결정 추적 및 회고 |
