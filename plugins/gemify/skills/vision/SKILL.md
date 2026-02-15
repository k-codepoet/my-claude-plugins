---
description: 비전 생성/조회. "비전 조회", "vision", "방향성" 등 요청 시 활성화.
allowed-tools: Read, Write, Edit, Glob
argument-hint: "[vision-name|new <name>]"
---

# Vision

비전(지향점)을 생성하거나 조회합니다.

## 사용법

```
/gemify:vision                 # 모든 vision 목록
/gemify:vision ai-company      # 특정 vision 조회
/gemify:vision new my-vision   # 새 vision 생성
```

## 저장 위치

**반드시 `skills/scope/SKILL.md` 참조하여 현재 도메인 경로 결정.**

```
{domain_path}/visions/{vision-name}/
  ├── definition.md          ← 비전 정의
  ├── definition.history/    ← 피보팅 이력
  ├── current.md             ← 현재 상태 스냅샷
  └── reviews/               ← 평가 이력
```

## 조회 시 출력

```
# {Vision Name}

## 비전 정의
definition.md 요약

## 현재 상태
current.md 요약 (Stage, 주요 Gap)

## 최근 리뷰
가장 최근 리뷰 요약 (날짜, 진척도)

## 다음 리뷰 권장
마지막 리뷰로부터 N일 경과
```

## 새 Vision 생성

`/gemify:vision new {vision-name}` 실행 시:

1. 폴더 구조 생성
2. 대화로 definition.md 작성
   - 핵심 비전
   - 성공 지표 (Stage 정의)
   - 평가 기준
3. current.md 초기 상태 작성
4. definition.history/에 v1 백업

## definition.md 필수 필드

```yaml
---
title: "{Vision Name}"
version: N
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

필수 섹션:
- 핵심 비전
- 성공 지표 (Stage별)
- 평가 기준
