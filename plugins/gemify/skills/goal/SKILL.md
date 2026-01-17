---
name: goal
description: 북극성 생성/조회
invocation: user
triggers:
  - "/gemify:goal"
  - "목표 조회"
  - "북극성"
  - "goal"
args: "[goal-name]"
---

# Goal

북극성(목표)을 생성하거나 조회합니다.

## 사용법

```
/gemify:goal                 # 모든 goal 목록
/gemify:goal ai-company      # 특정 goal 조회
/gemify:goal new my-goal     # 새 goal 생성
```

## 저장 위치

```
~/.gemify/goals/{goal-name}/
  ├── north-star.md          ← 북극성 (목표)
  ├── north-star.history/    ← 피보팅 이력
  ├── current.md             ← 현재 상태 스냅샷
  └── reviews/               ← 평가 이력
```

## 조회 시 출력

```
# {Goal Name}

## 북극성
north-star.md 요약

## 현재 상태
current.md 요약 (Stage, 주요 Gap)

## 최근 리뷰
가장 최근 리뷰 요약 (날짜, 진척도)

## 다음 리뷰 권장
마지막 리뷰로부터 N일 경과
```

## 새 Goal 생성

`/gemify:goal new {goal-name}` 실행 시:

1. 폴더 구조 생성
2. 대화로 north-star.md 작성
   - 핵심 비전
   - 성공 지표 (Stage 정의)
   - 평가 기준
3. current.md 초기 상태 작성
4. north-star.history/에 v1 백업

## north-star.md 필수 필드

```yaml
---
title: "{Goal Name} 북극성"
version: N
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

필수 섹션:
- 핵심 비전
- 성공 지표 (Stage별)
- 평가 기준
