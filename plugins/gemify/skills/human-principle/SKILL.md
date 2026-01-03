---
name: human-principle
description: 작업 원칙 문서 생성. "원칙으로 정리해", "principle", "왜 이렇게 해야 해?" 등 근본 원칙 정립 요청 시 활성화.
---

# Human Principle Skill

library의 지식을 **작업 원칙 문서**로 발전시킵니다.

## 핵심 행동

### 1. Library 안착 확인

먼저 관련 지식이 library에 안착되어 있는지 확인:
- 안착됨 → 원칙 추출 진행
- 미안착 → "/gemify:library 먼저 실행하시겠어요?" 제안

### 2. 소크라테스식 질문 (순차, 하나씩)

| Phase | 질문 |
|-------|------|
| 핵심 | "이 원칙의 핵심이 뭐야?" |
| 이유 | "왜 이게 원칙이어야 해?" |
| 적용 | "어떻게 적용해?" |
| 사례 | "구체적인 사례가 있어?" |

### 3. 재조립 제안

답변을 바탕으로 원칙 문서 초안 제시:

```markdown
---
id: principle-{seq}-{slug}
created: {ISO8601}
status: active
---

## Principle
{원칙 이름}

## Why
{이 원칙이 중요한 이유}

## How
{이 원칙을 적용하는 방법}

## Examples
{구체적 적용 사례}
```

### 4. seq 자동 부여

기존 `docs/humans/principles/` 파일에서 가장 높은 seq 찾아 +1:
- 파일명 패턴: `principle-{seq}-{slug}.md`
- 예: principle-001, principle-002 → 다음은 principle-003

### 5. 저장

사용자 컨펌 후:
1. `docs/humans/principles/` 디렉토리 확인 (없으면 생성)
2. `docs/humans/principles/principle-{seq}-{slug}.md`로 저장
3. 완료 보고

## 규칙

- 질문은 **하나씩 순차적으로**
- **컨펌 없이 저장 안 함**
- 템플릿 파일 (`_template.md`) 제외
- slug는 영문 kebab-case
- library 안착 여부 먼저 확인

## Principle vs Library 차이

| 구분 | Library | Principle |
|------|---------|-----------|
| 성격 | 도메인별 지식 (what I know) | 행동 지침 (how I should act) |
| 위치 | `library/{domain}/` | `docs/humans/principles/` |
| 용도 | 참조용 지식 | 의사결정 기준 |
