---
name: tidy
description: ground-truth 문서 정리 - views ↔ artifact 일치 검사, 역방향 검증. "정리", "tidy", "검증", "outdated", "깨진 링크" 등 요청 시 활성화.
---

# Tidy Skill

ground-truth 문서를 **역방향으로 검증**하고 점진적으로 정리합니다.

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

## 핵심 개념

tidy는 **역방향 검증** 도구:
- views ↔ artifact 일치 검사
- library 현황 보고 (사용 중/대기 중)
- 점진적 실행 (한 번에 하나씩)

## 검증 순서 (역순)

```
artifact (실제 결과물)
   ↑ 대조
views
   ↑ 추적
library
   ↑ 추적
drafts
   ↑ 추적
inbox
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
