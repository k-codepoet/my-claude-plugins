---
name: human-policy
description: 정책 문서 생성. "정책으로 만들어", "policy", "규칙 정리해", "반복 규칙" 등 정책 문서화 요청 시 활성화.
---

# Human Policy Skill

library의 지식을 **정책 문서**로 발전시킵니다.

## 핵심 행동

### 1. Library 안착 확인

먼저 관련 지식이 library에 안착되어 있는지 확인:
- 안착됨 → 정책 추출 진행
- 미안착 → "/gemify:library 먼저 실행하시겠어요?" 제안

### 2. 소크라테스식 질문 (순차, 하나씩)

| Phase | 질문 |
|-------|------|
| 범위 | "이 정책이 적용되는 범위는?" |
| 규칙 | "구체적인 규칙들은?" |
| 예외 | "예외 사항이 있어?" |

### 3. 재조립 제안

답변을 바탕으로 정책 문서 초안 제시:

```markdown
---
id: policy-{seq}-{slug}
created: {ISO8601}
updated: {ISO8601}
status: {active|deprecated}
---

## Policy
{정책 이름}

## Scope
{적용 범위}

## Rules
1. {규칙 1}
2. {규칙 2}

## Exceptions
{예외 사항}

## Review Date
{검토 예정일}
```

### 4. seq 자동 부여

기존 `docs/humans/policies/` 파일에서 가장 높은 seq 찾아 +1:
- 파일명 패턴: `policy-{seq}-{slug}.md`
- 예: policy-001, policy-002 → 다음은 policy-003

### 5. 저장

사용자 컨펌 후:
1. `docs/humans/policies/` 디렉토리 확인 (없으면 생성)
2. `docs/humans/policies/policy-{seq}-{slug}.md`로 저장
3. 완료 보고

## 규칙

- 질문은 **하나씩 순차적으로**
- **컨펌 없이 저장 안 함**
- 템플릿 파일 (`_template.md`) 제외
- slug는 영문 kebab-case
- library 안착 여부 먼저 확인
- Review Date는 생성일 기준 3개월 후 기본값

## Policy Status

| Status | 설명 |
|--------|------|
| active | 현재 적용 중인 정책 |
| deprecated | 더 이상 유효하지 않은 정책 |

## Policy vs Library 차이

| 구분 | Library | Policy |
|------|---------|--------|
| 성격 | 도메인별 지식 (what I know) | 반복 규칙 (what I must do) |
| 위치 | `library/{domain}/` | `docs/humans/policies/` |
| 용도 | 참조용 지식 | 반복적으로 적용할 규칙 |
| 검토 | 필요 시 | 정기 검토 (Review Date) |
