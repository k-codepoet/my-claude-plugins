---
description: 비전 대비 현재 상태 평가 + 리뷰 기록. "비전 리뷰", "vision review", "진척도 평가", "방향 점검" 등 요청 시 활성화.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
argument-hint: "<vision-name>"
---

# Vision Review

비전(definition) 대비 현재 상태를 평가하고 리뷰를 기록합니다.

## 사용법

```
/gemify:vision-review ai-company
```

## 절차

### 1. 문서 읽기

**반드시 `skills/scope/SKILL.md` 참조하여 현재 도메인 경로 결정.**

```
{domain_path}/visions/{vision-name}/
  ├── definition.md    ← 비전 정의
  ├── current.md       ← 현재 상태
  └── reviews/         ← 이전 리뷰들
```

### 2. 실제 상태 점검

- 플러그인 버전 및 기능 확인
- library/ 문서 밀도 확인
- 최근 활동 (sessions/, commits) 확인

### 3. 평가 수행

| 항목 | 평가 내용 |
|------|----------|
| 진척도 | 이전 리뷰 대비 Stage 진전 |
| 밀도 | 지식체계의 밀도/깊이 |
| 실현율 | 지식 → 구현체 변환 비율 |
| 자동화율 | 사람 개입 없이 처리되는 비율 |
| 방향성 | 비전을 향해 가고 있는가? |

### 4. 리뷰 기록

`reviews/YYYY-MM-DD.md` 에 저장:

```yaml
---
date: YYYY-MM-DD
previous_review: YYYY-MM-DD (또는 null)
stage_before: N
stage_after: N
---
```

## 리뷰 문서 구조

```markdown
# Vision Review: {vision-name}

## 요약
한두 문장으로 현재 상태 요약

## Stage 진행
- 이전: Stage X (YY%)
- 현재: Stage X (YY%)
- 변화: +N% 또는 정체

## 항목별 평가

### 진척도
...

### 밀도
...

### 실현율
...

### 자동화율
...

### 방향성
올바른 방향인가? 피보팅 필요한가?

## Gap 분석
비전과 현재의 주요 차이점

## 권장 다음 단계
우선순위별 액션 아이템

## 피보팅 필요 여부
[ ] 현재 방향 유지
[ ] 미세 조정 필요
[ ] 피보팅 검토 필요
```

### 5. current.md 갱신

평가 결과를 반영하여 current.md 업데이트

## 피보팅 시

방향 전환이 필요하면:

1. 사용자 확인 후 definition.md 수정
2. 이전 버전을 `definition.history/vN-YYYY-MM-DD.md`에 백업
3. 백업 파일에 `pivot_reason` 기록
