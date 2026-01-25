---
name: tidy
description: 지식 체계 탑다운 재정리 - vision에서 출발하여 끊어진 연결고리, 미스링크 전부 복구. "정리", "tidy", "검증", "outdated", "깨진 링크", "미스링크" 등 요청 시 활성화.
---

# Tidy Skill

지식 체계를 **탑다운으로 재정리**합니다. vision에서 출발하여 끊어진 연결고리, 미스링크를 전부 복구합니다.

## 사전 확인 (필수)

**반드시 `skills/scope/SKILL.md` 참조하여 현재 도메인 경로 결정.**

```
~/.gemify/ 존재?
├── 예 → config.json에서 현재 도메인 확인 → 스킬 실행
└── 아니오 → setup 안내 후 중단
```

## 핵심 개념

tidy는 **탑다운 재정리** 도구:
- vision에서 출발하여 전체 연결 상태 점검
- 끊어진 연결고리, 미스링크 복구
- 고아 문서, 방치된 문서 식별
- 점진적 실행 (한 번에 하나씩)

## retro vs tidy

| | retro | tidy |
|---|---|---|
| **방향** | 바텀업 (작업 → 체계) | 탑다운 (체계 → 검증) |
| **트리거** | 작업 완료 후 | 주기적 / 필요시 |
| **목적** | 놓친 지식 수확 | 끊어진 연결 복구 |

## 검증 순서 (탑다운)

```
vision
   │ 이 vision에 연결된 views 있나?
   ↓
views
   │ 각 view의 sources(library) 연결 살아있나?
   │ artifact 경로 유효한가?
   ↓
library
   │ 어디서도 참조 안 되는 고아 문서?
   │ 깨진 내부 링크?
   ↓
drafts
   │ 오래 방치된 drafts?
   │ status: cutting인데 진행 안 된 것?
   ↓
inbox
   │ 너무 오래된 raw 상태?
   ↓
artifact (실제 결과물)
   │ views와 일치?
```

## 동작 방식

```
리포트 → 컨펌 → 수정
```

1. **탐색**: views의 artifact 필드와 실제 파일 비교
2. **리포트**: 불일치 **하나만** 보여줌 (하나씩 집중)
3. **HITL 판단 요청**
4. **수정**: 사용자 컨펌 후 실행
5. **종료**: 다음 tidy 호출 대기

## 탐색 우선순위

1. artifact 필드 누락 (views에 없음)
2. 깨진 링크 (존재하지 않는 파일 참조)
3. used 마킹 누락 (inbox status가 raw인데 실제 사용됨)
4. outdated 감지 (오래된 updated, 이름 변경된 참조)
5. 중복 view

## HITL 선택지

```
[A] artifact 기준으로 view 업데이트
[B] view 기준으로 artifact 수정 (별도 작업)
[C] 둘 다 반영할 부분 있음 (수동)
[D] 나중에 볼게
```

## 출력 포맷

```
/gemify:tidy

views/by-subject/forgeify.md ↔ plugins/forgeify/ 불일치 발견

artifact가 더 최신입니다 (1시간 전 수정)
view는 2일 전 업데이트

[A] artifact 기준으로 view 업데이트
[B] view 기준으로 artifact 수정 (별도 작업)
[C] 둘 다 반영할 부분 있음 (수동)
[D] 나중에 볼게
```

## source-of-truth 판단

```
의도적 변경: views가 먼저 (설계 → 구현)
급한 수정: artifact가 먼저 (hotfix → 나중에 문서화)

→ 수정 시점으로 추측 + HITL로 최종 판단
```

## triage와의 관계

| | triage | tidy |
|---|---|---|
| 대상 | inbox (raw) | library/views/drafts |
| 목적 | 다음 할 일 찾기 | 기존 것 검증/수정 |
| 방향 | 순방향 (생산) | 역방향 (유지보수) |

**실행 순서**:
1. `/gemify:tidy` (깨진 유리창 수리)
2. `/gemify:triage` (새 inbox 연결)

## 규칙

- **하나씩 집중**: 한 번에 하나의 불일치만 보고
- **HITL 필수**: 자동 수정 없음, 항상 사용자 확인
- **점진적 실행**: 완료 후 다음 호출 대기
