---
description: inbox 클러스터링 + 우선순위 판단 + 다음 액션 제안. "triage", "정리", "inbox", "다음 뭐 해", "클러스터" 등 요청 시 활성화.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Triage Skill

inbox의 raw 파일을 **순방향으로 정리**하고 다음 할 일을 찾습니다.

## 사전 확인 (필수)

**반드시 `skills/scope/SKILL.md` 참조하여 현재 도메인 경로 결정.**

```
~/.gemify/ 존재?
├── 예 → config.json에서 현재 도메인 확인 → 스킬 실행
└── 아니오 → setup 안내 후 중단
```

## 핵심 개념

triage는 **순방향 정리** 도구:
- inbox → library/views 연결점 제안
- 클러스터링 + 우선순위 판단
- **밀도 평가** 기반 승격 제안
- 전체 리포트 후 선택

## tidy vs triage

| | triage | tidy |
|---|---|---|
| **방향** | 순방향 (생산) | 탑다운 (체계 → 검증) |
| **대상** | inbox (raw) | 지식 체계 전체 |
| **목적** | 다음 할 일 찾기 | 끊어진 연결 복구 |
| **출력** | 전체 리포트 → 선택 | 하나씩 집중 |

**실행 순서**: tidy → triage (깨진 유리창 먼저 수리)

## 동작 흐름

```
/gemify:triage 요청
    ↓
meta/cluster/current.md 있나?
    ├─ 있음 → triage 본체 실행
    └─ 없음 → "클러스터 맵이 없습니다. 먼저 생성할까요? [Y/n]"
                ├─ Y → map 스킬 호출 → 저장 → triage 이어가기
                └─ n → 종료
```

## 선행 스킬: map

클러스터 맵이 없으면 **map 스킬을 참조**하여 생성:
- map 스킬이 `library/views` 분석
- 클러스터 목록 제안 및 HITL 확인
- `meta/cluster/current.md` 저장
- 상세 내용은 `skills/map/SKILL.md` 참조

## 전체 리포트 포맷

```
## Inbox 현황
- raw thoughts: N개
- raw materials: M개

## 클러스터 (K개)
1. gemify 개선 (3개) - 추천
2. 플러그인 개선 (5개)
3. 인프라 (2개)
4. 미분류 (25개)

어느 클러스터부터? [1-K]
```

## 밀도 평가 기반 승격

각 inbox 항목의 밀도를 평가하여 다음 단계 제안:

| 밀도 수준 | 특징 | 제안 |
|----------|------|------|
| inbox 수준 | 생각/재료 상태, 구조화 필요 | 클러스터링, 보류 |
| draft 수준 | 아이디어 있지만 정제 필요 | draft 승격 제안 |
| library 수준 | 핵심 지식 정제됨, 단일 주제 | library 승격 제안 |

**밀도 높은 항목**: draft/library로 승격 제안
**밀도 낮은 항목**: 클러스터링 또는 보류

## 미분류 항목 처리

Claude가 **양쪽 제안**:
- 기존 편입 가능 → `[편입] [새 클러스터] [스킵]`
- 얼토당토 안 맞음 → 새 클러스터 제안만
- 완전 단독 + 밀도 높음 → draft 시작 제안

## 규칙

- **전체 리포트 후 선택**: 클러스터 목록 보여주고 사용자가 선택
- **HITL 필수**: 자동 클러스터링 없음, 항상 사용자 확인
- **밀도 평가 필수**: 승격 제안 시 밀도 근거 제시
- **Progressive Disclosure**: 클러스터 맵 없으면 map 스킬 참조
- **진입점 하나**: triage만으로 모든 순방향 정리 가능

## Core Principles

상세: `principles/pipeline-density.md` 참조
